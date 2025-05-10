<#
    .SYNOPSIS
        Computes the European call and put option prices using the Black-Scholes model.

    .DESCRIPTION
        This function calculates the call and put option prices based on the Black-Scholes formula.
        The calculation uses a fast tanh-based approximation for the standard normal cumulative distribution function (CDF).
        
    .PARAMETER S
        The current price of the underlying asset (spot price).
        
    .PARAMETER K
        The strike price of the option.
        
    .PARAMETER T
        The time to expiration in years.
        
    .PARAMETER r
        The annualized risk-free interest rate (as a decimal).
        
    .PARAMETER sigma
        The annualized volatility of the underlying asset (as a decimal).
        
    .RETURNVALUE
        An object with two properties:
            - `call`: The price of the call option.
            - `put`: The price of the put option.

    .EXAMPLE
        $prices = Get-BlackScholesCallPut -S 100 -K 100 -T 1 -r 0.02 -sigma 0.2
        Write-Host "Call Price: $($prices.call)"
        Write-Host "Put Price: $($prices.put)"
        # This will output the prices of the call and put options for the given parameters.

    .NOTES
        Author: geekarim
        Last Updated: 2025-05-09
#>

function Get-BlackScholesCallPut {
    param (
        [double]$S,      # Current price of the underlying asset (spot price)
        [double]$K,      # Strike price of the option
        [double]$T,      # Time to expiration in years
        [double]$r,      # Annualized risk-free interest rate (as a decimal)
        [double]$sigma   # Annualized volatility of the underlying asset (as a decimal)
    )

    if ($T -eq 0) {
        # If time to expiration is zero, compute prices directly
        $callPrice = [Math]::Max($S - $K, 0)
        $putPrice = [Math]::Max($K - $S, 0)
    } else {
        # Compute d1 and d2
        $d1 = ([Math]::Log($S / $K) + (($r + 0.5 * $sigma * $sigma) * $T)) / ($sigma * [Math]::Sqrt($T))
        $d2 = $d1 - $sigma * [Math]::Sqrt($T)
        
        # Call and put prices using the Black-Scholes formula
        $callPrice = $S * (normalCDF $d1) - $K * [Math]::Exp(-$r * $T) * (normalCDF $d2)
        $putPrice = $K * [Math]::Exp(-$r * $T) * (normalCDF -$d2) - $S * (normalCDF -$d1)
    }
    return @{call = $callPrice; put = $putPrice}
}

# Function to approximate the standard normal cumulative distribution function (CDF)
function normalCDF {
    param ([double]$x)

    # TanH approximation for the CDF
    return 0.5 * (1 + [Math]::Tanh([Math]::Sqrt(2 / [Math]::PI) * ($x + 0.044715 * [Math]::Pow($x, 3))))
}

# Example usage
$S = 100      # Stock price
$K = 100      # Strike price
$T = 1        # Time to expiration in years
$r = 0.02     # Risk-free interest rate
$sigma = 0.2  # Volatility

$prices = Get-BlackScholesCallPut -S $S -K $K -T $T -r $r -sigma $sigma
Write-Host "Call Price: $($prices.call)"
Write-Host "Put Price: $($prices.put)"