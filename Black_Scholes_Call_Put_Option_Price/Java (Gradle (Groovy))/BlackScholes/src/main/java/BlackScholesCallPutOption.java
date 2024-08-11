import java.util.Scanner;
import org.apache.commons.math3.distribution.NormalDistribution;

public class BlackScholesCallPutOption {

    /**
     * This method computes Black-Scholes Call and Put Option Prices.
     *
     * @param S      Stock Price
     * @param K      Strike
     * @param r      Interest Rate
     * @param T      Time to Maturity
     * @param sigma  Volatility
     * @return an array containing Call and Put option prices
     */
    static double[] blackScholesCallPutOptionPrice(double S, double K, double r, double T, double sigma) {
        double[] result = new double[2]; // result[0] = Call, result[1] = Put

        if (T == 0) {
            result[0] = Math.max(S - K, 0.0);
            result[1] = Math.max(K - S, 0.0);
        } else {
            double d1 = (Math.log(S / K) + (r + Math.pow(sigma, 2) / 2) * T) / (sigma * Math.sqrt(T));
            double d2 = (Math.log(S / K) + (r - Math.pow(sigma, 2) / 2) * T) / (sigma * Math.sqrt(T));

            NormalDistribution normalDistribution = new NormalDistribution();

            result[0] = S * normalDistribution.cumulativeProbability(d1) - Math.exp(-r * T) * K * normalDistribution.cumulativeProbability(d2);
            result[1] = Math.exp(-r * T) * K * normalDistribution.cumulativeProbability(-d2) - S * normalDistribution.cumulativeProbability(-d1);
        }
        return result;
    }


    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        double S, K, r, T, sigma;

        System.out.println("Stock Price:");
        S = Double.parseDouble(scanner.nextLine());
        System.out.println("Strike:");
        K = Double.parseDouble(scanner.nextLine());
        System.out.println("Interest Rate:");
        r = Double.parseDouble(scanner.nextLine());
        System.out.println("Time to Maturity:");
        T = Double.parseDouble(scanner.nextLine());
        System.out.println("Volatility:");
        sigma = Double.parseDouble(scanner.nextLine());

        double[] result = blackScholesCallPutOptionPrice(S, K, r, T, sigma);
        double Call = result[0];
        double Put = result[1];

        System.out.println("Call = " + Call);
        System.out.println("Put = " + Put);
    }

}
