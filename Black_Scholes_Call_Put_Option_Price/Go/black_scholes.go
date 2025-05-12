package main

import (
	"fmt"
	"math"
)

// normalCDF computes the cumulative distribution function (CDF)
// of the standard normal distribution using the built-in error function.
//
// It implements the formula:
//
//	Φ(x) = 0.5 * (1 + erf(x / √2))
//
// This is used in the Black-Scholes model to compute probabilities.
func normalCDF(x float64) float64 {
	return 0.5 * (1 + math.Erf(x/math.Sqrt2))
}

// blackScholesCallPut calculates the prices of European call and put options
// using the Black-Scholes model.
//
// Parameters:
//   - S:     Current price of the underlying asset (spot price)
//   - K:     Strike price of the option
//   - T:     Time to expiration in years
//   - r:     Annualized risk-free interest rate (as a decimal)
//   - sigma: Annualized volatility of the underlying asset (as a decimal)
//
// Returns:
//   - call: Price of the European call option
//   - put:  Price of the European put option
//
// If T == 0, the function returns the intrinsic values of the options.
func blackScholesCallPut(S, K, T, r, sigma float64) (call, put float64) {
	if T == 0 {
		call = math.Max(S-K, 0)
		put = math.Max(K-S, 0)
		return
	}

	d1 := (math.Log(S/K) + (r+0.5*sigma*sigma)*T) / (sigma * math.Sqrt(T))
	d2 := d1 - sigma*math.Sqrt(T)

	call = S*normalCDF(d1) - K*math.Exp(-r*T)*normalCDF(d2)
	put = K*math.Exp(-r*T)*normalCDF(-d2) - S*normalCDF(-d1)

	return
}

// main demonstrates usage of the blackScholesCallPut function
// with sample input values and prints the resulting option prices.
func main() {
	S := 100.0   // Current stock price
	K := 100.0   // Strike price
	T := 1.0     // Time to expiration (in years)
	r := 0.02    // Risk-free interest rate
	sigma := 0.2 // Volatility

	call, put := blackScholesCallPut(S, K, T, r, sigma)

	fmt.Printf("Call Price: %v\n", call)
	fmt.Printf("Put Price:  %v\n", put)
}
