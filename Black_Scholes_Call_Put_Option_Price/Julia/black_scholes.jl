using Distributions

"""
    black_scholes_call_put(S::Float64, K::Float64, T::Float64, r::Float64, sigma::Float64) -> Dict{String, Float64}

Computes the prices of European call and put options using the Black-Scholes formula.

# Arguments
- `S`: Current price of the underlying asset (spot price).
- `K`: Strike price of the option.
- `T`: Time to expiration in years.
- `r`: Annual risk-free interest rate (as a decimal, e.g., 0.02 for 2%).
- `sigma`: Annual volatility of the underlying asset (as a decimal, e.g., 0.2 for 20%).

# Returns
A `Dict` with two keys:
- `"call"`: The price of the European call option.
- `"put"`: The price of the European put option.

# Notes
- If `T == 0`, the function returns the intrinsic values of the options.
- Uses the standard normal cumulative distribution function (`cdf`) from the `Distributions` package.

# Example
```julia
prices = black_scholes_call_put(100.0, 100.0, 1.0, 0.02, 0.2)
println("Call Price: ", prices["call"])
println("Put Price: ", prices["put"])
```
"""
function black_scholes_call_put(S::Float64, K::Float64, T::Float64, r::Float64, sigma::Float64)
    if T == 0
        call_price = max(S - K, 0)
        put_price = max(K - S, 0)
    else
        d1 = (log(S / K) + (r + 0.5 * sigma^2) * T) / (sigma * sqrt(T))
        d2 = d1 - sigma * sqrt(T)
        N = Normal(0, 1)
        call_price = S * cdf(N, d1) - K * exp(-r * T) * cdf(N, d2)
        put_price = K * exp(-r * T) * cdf(N, -d2) - S * cdf(N, -d1)
    end
    return Dict("call" => call_price, "put" => put_price)
end

# Example usage
S = 100.0
K = 100.0
T = 1.0
r = 0.02
sigma = 0.2

prices = black_scholes_call_put(S, K, T, r, sigma)
println("Call Price: ", prices["call"])
println("Put Price: ", prices["put"])