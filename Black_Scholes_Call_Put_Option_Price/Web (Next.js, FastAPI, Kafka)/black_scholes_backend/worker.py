from confluent_kafka import Consumer, Producer
from numpy import log, sqrt, exp, multiply
from scipy.stats import norm
import json
import asyncio

print("🔧 Worker started...")

# Kafka configuration
KAFKA_BOOTSTRAP = 'kafka:9092'  # Address of Kafka broker

# Create Kafka consumer to listen for option pricing requests
consumer = Consumer({
    'bootstrap.servers': KAFKA_BOOTSTRAP,
    'group.id': 'blackscholes_worker_group',
    'auto.offset.reset': 'earliest'
})
consumer.subscribe(['blackscholes_requests'])

# Create Kafka producer to send option pricing results
producer = Producer({'bootstrap.servers': KAFKA_BOOTSTRAP})

def Black_Scholes_Call_Put_Option_Price(data):
    """
    Calculates European Call and Put option prices using the Black-Scholes formula.

    Parameters:
        data (dict): A dictionary containing:
            - S: Current stock price
            - K: Strike price
            - r: Risk-free interest rate
            - T: Time to maturity (in years)
            - sigma: Volatility of the underlying asset

    Returns:
        dict: A dictionary with keys 'call' and 'put' representing the option prices.
    """
    S, K, r, T, sigma = data['S'], data['K'], data['r'], data['T'], data['sigma']
    if T == 0:
        # Handle immediate expiration (intrinsic value)
        Call = max(S - K, 0)
        Put = max(K - S, 0)
    else:
        # Black-Scholes formula
        d1 = (log(S/K) + (r + sigma**2 / 2)*T) / (sigma * sqrt(T))
        d2 = d1 - sigma * sqrt(T)
        Call = multiply(S, norm.cdf(d1)) - exp(-r*T) * multiply(K, norm.cdf(d2))
        Put = exp(-r*T) * multiply(K, norm.cdf(-d2)) - multiply(S, norm.cdf(-d1))
    return {"call": float(Call), "put": float(Put)}

def delivery_report(err, msg):
    """
    Kafka delivery callback to report success or failure of message publishing.

    Parameters:
        err (KafkaError or None): Error if message failed to deliver.
        msg (KafkaMessage): The Kafka message object.
    """
    if err is not None:
        print(f"❌ Delivery failed: {err}")
    else:
        print(f"✅ Message delivered to {msg.topic()} [{msg.partition()}]")

def publish_result(result):
    """
    Publishes the calculated Black-Scholes result to the Kafka response topic.

    Parameters:
        result (dict): Dictionary containing the pricing result and client_id.
    """
    producer.produce(
        "blackscholes_responses", 
        json.dumps(result).encode("utf-8"),
        callback=delivery_report
    )
    # Flush to ensure message is delivered (blocking)
    producer.flush()

async def consume():
    """
    Main async loop that consumes option pricing requests from Kafka,
    processes them using the Black-Scholes model, and publishes the result.
    """
    print("📥 Worker Kafka loop running...")
    while True:
        # Run blocking Kafka poll in a background thread
        msg = await asyncio.to_thread(consumer.poll, 1.0)
    
        if msg is None:
            continue
        if msg.error():
            print(f"Consumer error: {msg.error()}")
            continue

        try:
            # Parse the incoming message
            data = json.loads(msg.value().decode("utf-8"))
            print(f"✅ Processing request: {data}")

            # Compute option prices
            result = Black_Scholes_Call_Put_Option_Price(data)
            result["client_id"] = data["client_id"]  # Attach client ID for response routing
            
            # Send the result to Kafka
            publish_result(result)
            print(f"📤 Published result: {result}")
        except Exception as e:
            print(f"❌ Worker exception: {e}")

# Start the async event loop
if __name__ == '__main__':
    asyncio.run(consume())
