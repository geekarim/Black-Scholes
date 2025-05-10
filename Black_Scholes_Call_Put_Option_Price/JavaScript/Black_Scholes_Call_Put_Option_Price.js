/**
 * Computes European call and put option prices using the Black-Scholes model.
 * Uses a fast tanh-based approximation for the standard normal cumulative distribution function (CDF).
 *
 * @function blackScholesCallPut
 * @param {number} S     Current price of the underlying asset (spot price).
 * @param {number} K     Strike price of the option.
 * @param {number} T     Time to expiration in years.
 * @param {number} r     Annualized risk-free interest rate (as a decimal).
 * @param {number} sigma Annualized volatility of the underlying asset (as a decimal).
 * @returns {Object}     An object with `call` and `put` properties containing the option prices.
 *
 * @example
 * const prices = blackScholesCallPut(100, 100, 1, 0.02, 0.2);
 * console.log(prices.call); // → Call price
 * console.log(prices.put);  // → Put price
 */
function blackScholesCallPut(S, K, T, r, sigma) {
    if (T===0) {
        const callPrice = Math.max( S - K, 0);
        const putPrice = Math.max( K - S, 0);
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
 * @function normalCDF
 * @param {number} x Input value.
 * @returns {number} Approximate CDF value between 0 and 1.
 */
function normalCDF(x) {
    return 0.5 * (1 + Math.tanh(Math.sqrt(2 / Math.PI) * (x + 0.044715 * Math.pow(x, 3))));
}

// Example usage:
const S = 100;      // Stock price
const K = 100;      // Strike price
const T = 1;        // Time to expiration in years
const r = 0.02;     // Risk-free interest rate
const sigma = 0.2;  // Volatility

const prices = blackScholesCallPut(S, K, T, r, sigma);
console.log("Call Price:", prices.call);
console.log("Put Price:", prices.put);