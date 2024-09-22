from flask import Flask, request, jsonify, render_template
from gevent.pywsgi import WSGIServer
import math
from scipy.stats import norm

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

# Black-Scholes formula for calculating options prices
def black_scholes(S, K, T, r, sigma):
    '''
    Calculate Black-Scholes options prices.
    
    Parameters:
    S: Current stock price
    K: Strike price
    T: Time to maturity (in years)
    r: Risk-free interest rate
    sigma: Volatility (standard deviation of the stock's return)

    Output:
        call = Black-Scholes Call Option Price
        put = Black-Scholes Put Option Price
    '''
    
    if T == 0:
        call = max( S - K , 0 )
        put = max( K - S , 0 )
    else:
       # Black-Scholes formulas require calculating d1 and d2
        d1 = (math.log(S / K) + (r + 0.5 * sigma ** 2) * T) / (sigma * math.sqrt(T))
        d2 = d1 - sigma * math.sqrt(T)
        
        # Call option price
        call = S * norm.cdf(d1) - K * math.exp(-r * T) * norm.cdf(d2)
        # Put option price
        put = K * math.exp(-r * T) * norm.cdf(-d2) - S * norm.cdf(-d1)
    
    return call, put

# Define a route to calculate options prices
@app.route('/black-scholes', methods=['POST'])
def calculate_option_price():
    # Get data from the request body (in JSON format)
    data = request.get_json()
    
    # Extract input parameters
    S = float(data['S'])        # Stock price
    K = float(data['K'])        # Strike price
    T = float(data['T'])        # Time to maturity
    r = float(data['r'])        # Risk-free interest rate
    sigma = float(data['sigma'])# Volatility
    
    # Compute the Black-Scholes prices
    try:
        call_price, put_price = black_scholes(S, K, T, r, sigma)
        return jsonify({'call_price': call_price, 'put_price': put_price}), 200
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    # Debug/Development
    # app.run(debug=True, host="0.0.0.0", port="5000")
    # Production
    http_server = WSGIServer(('', 5000), app)
    http_server.serve_forever()
