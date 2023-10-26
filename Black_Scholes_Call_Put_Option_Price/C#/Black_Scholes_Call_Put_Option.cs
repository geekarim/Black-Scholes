using System;
using MathNet.Numerics;

/// <summary>
/// This class computes Black-Scholes Call and Put Option Prices getting parameters from the user.
/// </summary>
class Black_Scholes_Call_Put_Option
{
    /// <summary>
    /// This method computes Black-Scholes Call and Put Option Prices.
    /// </summary>
    /// <param name="S">Stock Price</param>
    /// <param name="K">Strike</param>
    /// <param name="r">Interest Rate</param>
    /// <param name="T">Time to Maturity</param>
    /// <param name="sigma">Volatility</param>
    /// <returns>
    /// <c><paramref name="Call"/></c> is Black-Scholes Call Option Price.
    /// <c><paramref name="Put"/></c> is Black-Scholes Put Option Price.
    /// </returns>
    static (double Call, double Put) Black_Scholes_Call_Put_Option_Price(double S, double K, double r, double T, double sigma)
    {
        if (T == 0)
        {
            double Call = Math.Max(S - K, 0.0);
            double Put = Math.Max(K - S, 0.0);
            return (Call, Put);
        }
        else
        {
            double d1 = (Math.Log(S / K) + (r + Math.Pow(sigma, 2) / 2) * T) / (sigma * Math.Sqrt(T));
            double d2 = (Math.Log(S / K) + (r - Math.Pow(sigma, 2) / 2) * T) / (sigma * Math.Sqrt(T));
            double Call = S * N(d1) - Math.Exp(-r * T) * K * N(d2);
            double Put = Math.Exp(-r * T) * K * N(-d2) - S * N(-d1);
            return (Call, Put);
        }
    }

    /// <summary>
    /// This method computes Normal (Gaussian) CDF.
    /// </summary>
    static double N (double x) {
        MathNet.Numerics.Distributions.Normal result = new MathNet.Numerics.Distributions.Normal ();
        return result.CumulativeDistribution (x);
    }

    static void Main()
    {
        double Call, Put;
        double S, K, r, T, sigma;

        Console.WriteLine("Stock Price:");
        S = Convert.ToDouble(Console.ReadLine());
        Console.WriteLine("Strike:");
        K = Convert.ToDouble(Console.ReadLine());
        Console.WriteLine("Interest Rate:");
        r = Convert.ToDouble(Console.ReadLine());
        Console.WriteLine("Time to Maturity:");
        T = Convert.ToDouble(Console.ReadLine());
        Console.WriteLine("Volatility:");
        sigma = Convert.ToDouble(Console.ReadLine());

        (Call, Put) = Black_Scholes_Call_Put_Option_Price(S, K, r, T, sigma);
        Console.WriteLine("Call==" + Call);
        Console.WriteLine("Put==" + Put);
    }
}