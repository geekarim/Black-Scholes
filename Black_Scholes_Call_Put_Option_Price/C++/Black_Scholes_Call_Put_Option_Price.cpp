#include <iostream>
#include <cmath>
#include <tuple>

std::tuple <double, double> Black_Scholes_Call_Put_Option_Price(double S,double K,double r,double T,double sigma)
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

    if (T == 0)
    {
        double Call = std::max( S - K, 0.0 );
        double Put = std::max( K - S, 0.0 );
        return std::make_tuple(Call, Put);
    }
    else
    {
        double d1 = (log(S/K) + (r+pow(sigma,2) / 2)*T)/(sigma*sqrt(T));
        double d2 = (log(S/K) + (r-pow(sigma,2) / 2)*T)/(sigma*sqrt(T));
        double Call = S*((1.0 + erf(d1 / sqrt(2.0))) / 2.0) - exp(-r*T)*K*((1.0 + erf(d2 / sqrt(2.0))) / 2.0);
        double Put = exp(-r*T)*K*((1.0 + erf(-d2 / sqrt(2.0))) / 2.0) - S*((1.0 + erf(-d1 / sqrt(2.0))) / 2.0);
        return std::make_tuple(Call, Put);
    }
}

int main()
{
    double Call, Put;
    double S, K, r, T, sigma;

    std::cout << "Stock Price:"<< std::endl;
    std::cin >> S;
    std::cout << "Strike:"<< std::endl;
    std::cin >> K;
    std::cout << "Interest Rate:"<< std::endl;
    std::cin >> r;
    std::cout << "Time to Maturity:"<< std::endl;
    std::cin >> T;
    std::cout << "Volatility:"<< std::endl;
    std::cin >> sigma;

    std::tie(Call, Put) = Black_Scholes_Call_Put_Option_Price(S,K,r,T,sigma);
    std::cout << "Call==" << Call << std::endl;
    std::cout << "Put==" << Put << std::endl;
}