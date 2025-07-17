from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from confluent_kafka import Producer, Consumer
from confluent_kafka.admin import AdminClient, NewTopic
import json
import asyncio
from contextlib import asynccontextmanager

# Global dictionary to store connected clients
clients = {}

# Kafka bootstrap server address
KAFKA_BOOTSTRAP = 'kafka:9092'

# Kafka producer instance
producer = Producer({'bootstrap.servers': KAFKA_BOOTSTRAP})

# Kafka consumer instance
consumer = Consumer({
    'bootstrap.servers': KAFKA_BOOTSTRAP,
    'group.id': 'fastapi_response_group',
    'auto.offset.reset': 'earliest',
})
consumer.subscribe(['blackscholes_responses'])

def create_kafka_topics():
    """
    Creates Kafka topics for communication between the FastAPI app and clients.
    """
    admin_client = AdminClient({'bootstrap.servers': KAFKA_BOOTSTRAP})
    topic_names = ["blackscholes_requests", "blackscholes_responses"]
    new_topics = [NewTopic(topic, num_partitions=3, replication_factor=1) for topic in topic_names]

    futures = admin_client.create_topics(new_topics)

    for topic, future in futures.items():
        try:
            future.result()
            print(f"✅ Topic '{topic}' created")
        except Exception as e:
            if "TopicAlreadyExists" in str(e):
                print(f"ℹ️ Topic '{topic}' already exists")
            else:
                print(f"❌ Error creating topic '{topic}': {e}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Async context manager for handling FastAPI application lifespan events.
    Creates Kafka topics on app startup and cleans up on shutdown.
    """
    # Create Kafka topics on startup
    await asyncio.to_thread(create_kafka_topics)

    task = asyncio.create_task(kafka_consumer_loop())
    yield
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        pass

# Create FastAPI app instance with lifespan handler
app = FastAPI(lifespan=lifespan)

# CORS settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class OptionInput(BaseModel):
    """
    Pydantic BaseModel for incoming POST request data to /blackscholes endpoint.
    Represents input parameters for Black-Scholes options pricing model.
    """
    S: float  # Underlying asset price
    K: float  # Strike price
    r: float  # Risk-free interest rate
    T: float  # Time to maturity (in years)
    sigma: float  # Volatility of the underlying asset
    client_id: str  # Unique identifier for the client

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    """
    WebSocket endpoint to establish a connection with clients.
    """
    await websocket.accept()
    clients[client_id] = websocket
    try:
        while True:
            await websocket.send_text("ping")
            await asyncio.sleep(10)  # Send 'ping' every 10 seconds
    except WebSocketDisconnect:
        print(f"Client {client_id} disconnected")
    finally:
        clients.pop(client_id, None)

@app.post("/blackscholes")
async def send_to_kafka(data: OptionInput):
    """
    POST endpoint to send option input data to Kafka for processing.
    """
    msg = data.model_dump()  # Convert Pydantic BaseModel to dictionary
    producer.produce("blackscholes_requests", json.dumps(msg).encode("utf-8"))
    return {"status": "queued", "client_id": data.client_id}

async def kafka_consumer_loop():
    """
    Asynchronous loop to consume messages from Kafka and forward them to connected clients.
    """
    while True:
        msg = await asyncio.to_thread(consumer.poll, 1.0)
        if msg is None or msg.error():
            continue

        try:
            data = json.loads(msg.value().decode("utf-8"))
            client_id = data.get("client_id")

            if client_id in clients:
                await clients[client_id].send_json(data)
                print(f"✅ Sent result to client {client_id}")
            else:
                print(f"❌ Client {client_id} not connected")
                
        except Exception as e:
            print(f"Error processing Kafka message: {e}")
