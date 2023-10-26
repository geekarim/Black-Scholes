function [Call, Put] = Black_Scholes_Call_Put_Option_Price(S,K,r,T,sigma)
% Computes Black-Scholes Call & Put Option Prices
% Same as built-in blsprice(Price,Strike,Rate,Time,Volatility)
%
% Input:
%   S     = Stock Price
%   K     = Strike
%   r     = Interest Rate
%   T     = Time to Maturity
%   sigma = Volatility
%
% Output:
%   Call  = Black-Scholes Call Option Price
%   Put   = Black-Scholes Put Option Price

if T==0
    Call = max( S - K , 0 );
    Put = max( K - S , 0 );
else
    d1 = (log(S./K) + (r+sigma^2 / 2)*T)/(sigma*sqrt(T));
    d2 = (log(S./K) + (r-sigma^2 / 2)*T)/(sigma*sqrt(T));
    Call = S.*normcdf(d1) - exp(-r*T)*K.*normcdf(d2);
    Put = exp(-r*T)*K.*normcdf(-d2) - S.*normcdf(-d1);
end
end