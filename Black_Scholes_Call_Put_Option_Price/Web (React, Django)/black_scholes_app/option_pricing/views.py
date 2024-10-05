from rest_framework.decorators import api_view
from rest_framework.response import Response
from scipy.stats import norm
import math

@api_view(['POST'])
def black_scholes(request):
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
    data = request.data
    underlying_price = float(data.get('underlying_price'))
    strike_price = float(data.get('strike_price'))
    time_to_expiry = float(data.get('time_to_expiry'))
    volatility = float(data.get('volatility'))
    risk_free_rate = float(data.get('risk_free_rate'))

    if time_to_expiry == 0:
        call_option_price = max( underlying_price - strike_price , 0 )
        put_option_price = max( strike_price - underlying_price , 0 )
    else:
        # Black-Scholes formulas require calculating d1 and d2
        d1 = (math.log(underlying_price / strike_price) + (risk_free_rate + 0.5 * volatility ** 2) * time_to_expiry) / (volatility * math.sqrt(time_to_expiry))
        d2 = d1 - volatility * math.sqrt(time_to_expiry)
        
        # Call option price
        call_option_price = underlying_price * norm.cdf(d1) - strike_price * math.exp(-risk_free_rate * time_to_expiry) * norm.cdf(d2)
        # Put option price
        put_option_price = strike_price * math.exp(-risk_free_rate * time_to_expiry) * norm.cdf(-d2) - underlying_price * norm.cdf(-d1)

    return Response({
        'call_option_price': call_option_price,
        'put_option_price': put_option_price
    })
