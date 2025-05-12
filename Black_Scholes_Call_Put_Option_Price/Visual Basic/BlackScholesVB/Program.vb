Imports System

Module Program
    ''' <summary>
    ''' Main entry point of the program that calculates the European Call and Put options 
    ''' prices using the Black-Scholes model. The results are displayed to the console.
    ''' </summary>
    Sub Main()
        ' Spot price (Current price of the underlying asset)
        Dim S As Double = 100
        ' Strike price (The price at which the option holder can buy/sell the asset)
        Dim K As Double = 100
        ' Time to expiration (in years)
        Dim T As Double = 1
        ' Risk-free interest rate (annual rate, as a decimal)
        Dim r As Double = 0.02
        ' Volatility (annualized volatility of the underlying asset, as a decimal)
        Dim sigma As Double = 0.2

        ' Calculate the call and put option prices using Black-Scholes model
        Dim prices = BlackScholesCallPut(S, K, T, r, sigma)

        ' Output the calculated call and put prices
        Console.WriteLine("Call Price: " & prices.callPrice)
        Console.WriteLine("Put Price: " & prices.putPrice)
    End Sub

    ''' <summary>
    ''' Calculates the European call and put option prices using the Black-Scholes model.
    ''' The function handles the case where time to expiration (T) is zero (i.e., at expiry),
    ''' and uses a fast approximation for the cumulative distribution function (CDF).
    ''' </summary>
    ''' <param name="S">The current price of the underlying asset (spot price).</param>
    ''' <param name="K">The strike price of the option.</param>
    ''' <param name="T">Time to expiration in years.</param>
    ''' <param name="r">The annualized risk-free interest rate (as a decimal).</param>
    ''' <param name="sigma">The annualized volatility of the underlying asset (as a decimal).</param>
    ''' <returns>A tuple containing the calculated call price and put price.</returns>
    ''' <example>
    ''' Dim prices = BlackScholesCallPut(100, 100, 1, 0.02, 0.2)
    ''' Console.WriteLine(prices.callPrice) ' Call price
    ''' Console.WriteLine(prices.putPrice)  ' Put price
    ''' </example>
    Function BlackScholesCallPut(S As Double, K As Double, T As Double, r As Double, sigma As Double) As (callPrice As Double, putPrice As Double)
        If T = 0 Then
            ' If time to expiration is 0, options are exercised immediately
            Dim callPrice As Double = Math.Max(S - K, 0)
            Dim putPrice As Double = Math.Max(K - S, 0)
            Return (callPrice, putPrice)
        Else
            ' Calculate d1 and d2 for the Black-Scholes model
            Dim d1 As Double = (Math.Log(S / K) + (r + 0.5 * sigma ^ 2) * T) / (sigma * Math.Sqrt(T))
            Dim d2 As Double = d1 - sigma * Math.Sqrt(T)

            ' Calculate call and put option prices using the Black-Scholes formula
            Dim callPrice As Double = S * NormalCDF(d1) - K * Math.Exp(-r * T) * NormalCDF(d2)
            Dim putPrice As Double = K * Math.Exp(-r * T) * NormalCDF(-d2) - S * NormalCDF(-d1)

            Return (callPrice, putPrice)
        End If
    End Function

    ''' <summary>
    ''' Approximates the cumulative distribution function (CDF) of the standard normal distribution 
    ''' using a tanh-based approximation formula.
    ''' </summary>
    ''' <param name="x">The input value to compute the CDF for.</param>
    ''' <returns>The approximated CDF value between 0 and 1.</returns>
    ''' <example>
    ''' Dim cdfValue = NormalCDF(1.0)
    ''' Console.WriteLine(cdfValue) ' Approximate CDF value for 1.0
    ''' </example>
    Function NormalCDF(x As Double) As Double
        ' Fast tanh-based approximation for CDF of the standard normal distribution
        Return 0.5 * (1 + Math.Tanh(Math.Sqrt(2 / Math.PI) * (x + 0.044715 * x ^ 3)))
    End Function
End Module