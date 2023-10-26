def Black_Scholes_Call_Put_Option_Price(S,K,r,T,sigma):
    """Computes Black-Scholes Call & Put Option Prices

    Input:
          S (float matrix) = Stock Price
          K (float matrix) = Strike
          r (float) = Interest Rate
          T (float) = Time to Maturity
          sigma (float) = Volatility

    Output:
          Call = Black-Scholes Call Option Price
          Put = Black-Scholes Put Option Price
    """

    from scipy.stats import norm
    from numpy import log, sqrt, exp, multiply

    if T==0:
        Call = max( S - K , 0 )
        Put = max( K - S , 0 )
    else:
        d1 = (log(S/K) + (r+sigma**2 / 2)*T)/(sigma*sqrt(T))
        d2 = (log(S/K) + (r-sigma**2 / 2)*T)/(sigma*sqrt(T))
        Call = multiply(S,norm.cdf(d1)) - exp(-r*T)*multiply(K,norm.cdf(d2))
        Put = exp(-r*T)*multiply(K,norm.cdf(-d2)) - multiply(S,norm.cdf(-d1))

    return Call, Put