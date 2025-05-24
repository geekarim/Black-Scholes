package com.blackscholes

import org.apache.commons.math3.distribution.NormalDistribution
import kotlin.math.*

/**
 * A utility object that provides a method to calculate the Black-Scholes option pricing model
 * for European call and put options.
 */
object BlackScholesCalculator {

    /**
     * Calculates the prices of European call and put options using the Black-Scholes formula.
     *
     * @param S Current stock price (spot price)
     * @param K Strike price of the option
     * @param r Risk-free interest rate (as a decimal, e.g., 0.05 for 5%)
     * @param T Time to maturity in years (e.g., 0.5 for 6 months)
     * @param sigma Volatility of the underlying stock (as a decimal, e.g., 0.2 for 20%)
     * @return A [Pair] where `first` is the call option price and `second` is the put option price
     */
    fun blackScholesCallPutOptionPrice(
        S: Double, K: Double, r: Double, T: Double, sigma: Double
    ): Pair<Double, Double> {
        val normalDistribution = NormalDistribution()

        // Handle case when time to maturity is 0 (option expires immediately)
        if (T == 0.0) {
            val call = max(S - K, 0.0)
            val put = max(K - S, 0.0)
            return Pair(call, put)
        }

        // Calculate d1 and d2 parameters used in the Black-Scholes formula
        val d1 = (ln(S / K) + (r + sigma * sigma / 2.0) * T) / (sigma * sqrt(T))
        val d2 = d1 - sigma * sqrt(T)

        // Calculate the call option price using the cumulative distribution function (CDF)
        val call = S * normalDistribution.cumulativeProbability(d1) -
                K * exp(-r * T) * normalDistribution.cumulativeProbability(d2)

        // Calculate the put option price using the CDF
        val put = K * exp(-r * T) * normalDistribution.cumulativeProbability(-d2) -
                S * normalDistribution.cumulativeProbability(-d1)

        return Pair(call, put)
    }
}
