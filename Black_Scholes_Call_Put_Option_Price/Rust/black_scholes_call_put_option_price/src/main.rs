use std::f64::consts::E;
use statrs::distribution::{Normal, ContinuousCDF};

/// Computes Black-Scholes Call & Put Option Prices
///
/// # Arguments
/// * `s(f64)` - Stock Price
/// * `k(f64)` - Strike
/// * `r(f64)` - Interest Rate
/// * `t(f64)` - Time to Maturity
/// * `sigma(f64)` - Volatility
///
/// # Returns
/// * `call(f64)` - Black-Scholes Call Option Price
/// * `put(f64)` - Black-Scholes Put Option Price
fn black_scholes_call_put_option_price(
    s: f64,     // Stock Price
    k: f64,     // Strike
    r: f64,     // Interest Rate
    t: f64,     // Time to Maturity
    sigma: f64  // Volatility
) -> (f64, f64) {

    if t == 0.0 {
        let call = f64::max(s - k,0.0);
        let put = f64::max(k - s,0.0);
        // Return
        (call, put)
    } else {
        // Calculate d1 and d2
        let d1 = (f64::ln(s / k) + (r + 0.5 * sigma * sigma) * t) / (sigma * f64::sqrt(t));
        let d2 = d1 - sigma * f64::sqrt(t);

        // Create a standard normal distribution
        let normal = Normal::new(0.0, 1.0).unwrap();

        // Calculate the call & put option prices
        let call = s * normal.cdf(d1) - k * E.powf(-r * t) * normal.cdf(d2);
        let put = k * E.powf(-r * t) * normal.cdf(-d2) - s * normal.cdf(-d1);
        // Return
        (call, put)
    }
}

fn main() {
    let s = 100.0;      // Stock Price
    let k = 100.0;      // Strike
    let r = 0.02;       // Interest Rate
    let t = 3.0;        // Time to maturity
    let sigma = 0.2;    // Volatility

    let (call_price, put_price) = black_scholes_call_put_option_price(s, k, r, t, sigma);
    print!("{}, {}", call_price, put_price);
}