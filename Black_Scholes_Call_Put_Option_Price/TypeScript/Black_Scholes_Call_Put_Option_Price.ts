/**
 * Computes European call and put option prices using the Black-Scholes model.
 * Uses a fast tanh-based approximation for the standard normal cumulative distribution function (CDF).
 *
 * @param S Current price of the underlying asset (spot price).
 * @param K Strike price of the option.
 * @param T Time to expiration in years.
 * @param r Annualized risk-free interest rate (as a decimal).
 * @param sigma Annualized volatility of the underlying asset (as a decimal).
 * @returns An object with `call` and `put` properties containing the option prices.
 */
function blackScholesCallPut(S: number, K: number, T: number, r: number, sigma: number): { call: number, put: number } {
    if (T === 0) {
        const callPrice = Math.max(S - K, 0);
        const putPrice = Math.max(K - S, 0);
        return { call: callPrice, put: putPrice };
    } else {
        const d1 = (Math.log(S / K) + (r + 0.5 * sigma ** 2) * T) / (sigma * Math.sqrt(T));
        const d2 = d1 - sigma * Math.sqrt(T);
        const callPrice = S * normalCDF(d1) - K * Math.exp(-r * T) * normalCDF(d2);
        const putPrice = K * Math.exp(-r * T) * normalCDF(-d2) - S * normalCDF(-d1);
        return { call: callPrice, put: putPrice };
    }
}

/**
 * Approximates the standard normal cumulative distribution function (CDF)
 * using a tanh-based formula.
 *
 * @param x Input value.
 * @returns Approximate CDF value between 0 and 1.
 */
function normalCDF(x: number): number {
    return 0.5 * (1 + Math.tanh(Math.sqrt(2 / Math.PI) * (x + 0.044715 * Math.pow(x, 3))));
}

// Example usage:
const S: number = 100;      // Stock price
const K: number = 100;      // Strike price
const T: number = 1;        // Time to expiration in years
const r: number = 0.02;     // Risk-free interest rate
const sigma: number = 0.2;  // Volatility

const prices = blackScholesCallPut(S, K, T, r, sigma);
console.log("Call Price:", prices.call);
console.log("Put Price:", prices.put);