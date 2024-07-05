#include <stdio.h>
#include <math.h>

struct Tuple {
    double first;
    double second;
};

struct Tuple Black_Scholes_Call_Put_Option_Price(double S, double K, double r, double T, double sigma)
{
    /**
     * Computes Black-Scholes Call & Put Option Prices
     *
     * Input:
     * @param[in] S     = Stock Price
     * @param[in] K     = Strike
     * @param[in] r     = Interest Rate
     * @param[in] T     = Time to Maturity
     * @param[in] sigma = Volatility
     *
     * Output:
     * @param[out] Call  = Black-Scholes Call Option Price
     * @param[out] Put   = Black-Scholes Put Option Price
    */

    struct Tuple result;
    double d1, d2;

    if (T == 0)
    {
        result.first = fmax(S - K, 0.0);
        result.second = fmax(K - S, 0.0);
    }
    else
    {
        d1 = (log(S / K) + (r + pow(sigma, 2) / 2) * T) / (sigma * sqrt(T));
        d2 = (log(S / K) + (r - pow(sigma, 2) / 2) * T) / (sigma * sqrt(T));

        result.first = S * ((1.0 + erf(d1 / sqrt(2.0))) / 2.0) - exp(-r * T) * K * ((1.0 + erf(d2 / sqrt(2.0))) / 2.0);
        result.second = exp(-r * T) * K * ((1.0 + erf(-d2 / sqrt(2.0))) / 2.0) - S * ((1.0 + erf(-d1 / sqrt(2.0))) / 2.0);
    }

    return result;
}

int main()
{
    double Call, Put;
    double S, K, r, T, sigma;

    printf("Stock Price:\n");
    scanf("%lf", &S);
    printf("Strike:\n");
    scanf("%lf", &K);
    printf("Interest Rate:\n");
    scanf("%lf", &r);
    printf("Time to Maturity:\n");
    scanf("%lf", &T);
    printf("Volatility:\n");
    scanf("%lf", &sigma);

    struct Tuple result = Black_Scholes_Call_Put_Option_Price(S, K, r, T, sigma);

    printf("Call == %.6f\n", result.first);
    printf("Put == %.6f\n", result.second);

    return 0;
}
