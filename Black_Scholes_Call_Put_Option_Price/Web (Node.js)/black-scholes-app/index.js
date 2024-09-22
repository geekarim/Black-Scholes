const express = require('express');
const bodyParser = require('body-parser');
const { erf } = require('mathjs');  // Import the error function (erf) from mathjs for normal CDF calculation
const app = express();
const port = 3000;

// Use body-parser to parse JSON request bodies
app.use(bodyParser.json());

/**
 * Calculates the Cumulative Distribution Function (CDF) of the standard normal distribution.
 * This function utilizes the error function (erf) to compute the value.
 * 
 * @param {number} x - The input value for which the CDF is calculated.
 * @returns {number} - The cumulative probability for a standard normal distribution up to x.
 */
function normalCDF(x) {
    return (1.0 + erf(x / Math.sqrt(2.0))) / 2.0;
}

/**
 * Black-Scholes formula to calculate European call and put option prices.
 * 
 * @param {number} S - Current stock price.
 * @param {number} K - Option strike price.
 * @param {number} T - Time to option maturity in years.
 * @param {number} r - Risk-free interest rate.
 * @param {number} sigma - Volatility of the stock (standard deviation of returns).
 * 
 * @returns {object} - An object containing both call and put option prices.
 *                     Format: { call: <call_price>, put: <put_price> }
 */
function blackScholes(S, K, T, r, sigma) {
    if (T === 0) {
        // When the option has expired (T = 0), return intrinsic value.
        const call = Math.max(S - K, 0);  // Call option intrinsic value
        const put = Math.max(K - S, 0);   // Put option intrinsic value
        return { call, put };
    } else {
        // Calculate d1 and d2 for the Black-Scholes model
        const d1 = (Math.log(S / K) + (r + 0.5 * sigma ** 2) * T) / (sigma * Math.sqrt(T));
        const d2 = d1 - sigma * Math.sqrt(T);

        // Calculate call and put prices using the Black-Scholes formula
        const call = S * normalCDF(d1) - K * Math.exp(-r * T) * normalCDF(d2);
        const put = K * Math.exp(-r * T) * normalCDF(-d2) - S * normalCDF(-d1);

        return { call, put };  // Return both call and put prices
    }
}

// Serve the frontend HTML file
// This serves the index.html file when a user navigates to the root ('/') URL.
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});

/**
 * API route to calculate Black-Scholes option prices.
 * This endpoint accepts JSON input and returns the computed call and put prices.
 * 
 * Input format (JSON):
 *  {
 *      "S": <Stock Price>,
 *      "K": <Strike Price>,
 *      "T": <Time to Maturity>,
 *      "r": <Risk-free Interest Rate>,
 *      "sigma": <Volatility>
 *  }
 * 
 * Output format (JSON):
 *  {
 *      "call_price": <Calculated Call Option Price>,
 *      "put_price": <Calculated Put Option Price>
 *  }
 */
app.post('/black-scholes', (req, res) => {
    const { S, K, T, r, sigma } = req.body;  // Extract data from the request body

    try {
        // Parse values as floats and pass them to the blackScholes function
        const { call, put } = blackScholes(parseFloat(S), parseFloat(K), parseFloat(T), parseFloat(r), parseFloat(sigma));
        
        // Send the calculated option prices as JSON
        res.json({ call_price: call, put_price: put });
    } catch (error) {
        // Handle potential errors, e.g., invalid input
        res.status(400).json({ error: error.message });
    }
});

// Start the server and listen on the specified port
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
