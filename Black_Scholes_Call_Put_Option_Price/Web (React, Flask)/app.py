from flask import Flask, jsonify, request
from flask_cors import CORS
import math
from scipy.stats import norm

app = Flask(__name__)
CORS(app)  # Enable Cross-Origin Resource Sharing for React

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
    
    return round(call, 2), round(put, 2)

@app.route('/api/calculate', methods=['POST'])
def calculate_option_price():
    data = request.json
    S = float(data['S'])
    K = float(data['K'])
    T = float(data['T'])
    r = float(data['r'])
    sigma = float(data['sigma'])
    
    # Compute option price using Black-Scholes formula
    call_price, put_price = black_scholes(S, K, T, r, sigma)
    
    return jsonify({
        'call_price': call_price,
        'put_price': put_price
    })

if __name__ == '__main__':
    app.run(debug=True)
