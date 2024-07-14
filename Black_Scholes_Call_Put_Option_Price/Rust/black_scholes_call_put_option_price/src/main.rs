use std::f64::consts::E;
use statrs::distribution::{Normal, ContinuousCDF};
use std::io::{self, Write};

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

    // Helper function to read a floating point number from the user
    fn read_f64(prompt: &str) -> f64 {
        let mut input = String::new();
        print!("{}", prompt);
        io::stdout().flush().unwrap();
        io::stdin().read_line(&mut input).expect("Failed to read line");
        input.trim().parse().expect("Invalid input")
    }

    let s = read_f64("Enter the stock price: ");
    let k = read_f64("Enter the strike price: ");
    let r = read_f64("Enter the interest rate (e.g., 0.02 for 2%): ");
    let t = read_f64("Enter the time to maturity (in years): ");
    let sigma = read_f64("Enter the volatility (e.g., 0.2 for 20%): ");

    let (call_price, put_price) = black_scholes_call_put_option_price(s, k, r, t, sigma);
    print!("{}, {}", call_price, put_price);
}