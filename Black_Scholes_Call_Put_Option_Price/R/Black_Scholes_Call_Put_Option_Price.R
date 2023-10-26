Black_Scholes_Call_Put_Option_Price <-
  function(S, K, r, Time, sigma) {
    #' Black_Scholes_Call_Put_Option_Price
    #'
    #' Computes Black-Scholes Call & Put Option Prices
    #'
    #' @param S     = Stock Price
    #' @param K     = Strike
    #' @param r     = Interest Rate
    #' @param Time  = Time to Maturity
    #' @param sigma = Volatility
    #'
    #' @return The returned value is a list with components
    #'
    #'  $Call containing Black-Scholes Call Option Price
    #'
    #'  $Put containing Black-Scholes Put Option Price
    #'
    #' @export
    
    if (Time == 0) {
      Call = max(S - K , 0)
      Put = max(K - S , 0)
    } else {
      d1 = (log(S / K) + (r + sigma ^ 2 / 2) * Time) / (sigma * sqrt(Time))
      
      d2 = (log(S / K) + (r - sigma ^ 2 / 2) * Time) / (sigma * sqrt(Time))
      
      Call = S * pnorm(d1) - exp(-r * Time) * K * pnorm(d2)
      
      Put = exp(-r * Time) * K * pnorm(-d2) - S * pnorm(-d1)
      
    }
    
    return(list(Call = Call, Put = Put))
  }