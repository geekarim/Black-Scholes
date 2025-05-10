      *> ---------------------------------------------------------------
      *> Program: BLACK-SCHOLES
      *> Purpose: Computes European call and put option prices using the 
      *>          Black-Scholes model.
      *> 
      *> Description:
      *>   - Accepts input parameters:
      *>       S      = Current stock price
      *>       K      = Strike price
      *>       T      = Time to maturity (in years)
      *>       R      = Risk-free interest rate
      *>       SIGMA  = Volatility of the underlying asset
      *>
      *>   - If T = 0, returns intrinsic value (max(S-K, 0) or 
      *>     max(K-S, 0))
      *>   - Otherwise:
      *>       1. Calculates d1 and d2
      *>       2. Approximates normal CDF of d1 and d2 using 
      *>          tanh-inspired formula (a smooth, fast approximation)
      *>       3. Computes Black-Scholes call and put prices
      *>
      *>   - Displays both call and put prices
      *> 
      *> Dependencies:
      *>   - No external libraries required
      *>   - Uses COBOL math functions (LOG, EXP, SQRT, MAX)
      *> 
      *> Note:
      *>   The normal CDF approximation uses a hyperbolic tangent-style
      *>   approximation
      *> ---------------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BLACK-SCHOLES.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      * Input parameters
       01 S            PIC 9(5)V9(5) VALUE 100.00000.
       01 K            PIC 9(5)V9(5) VALUE 100.00000.
       01 T            PIC 9(1)V9(5) VALUE 1.00000.
       01 R            PIC 9(1)V9(5) VALUE 0.02000.
       01 SIGMA        PIC 9(1)V9(5) VALUE 0.20000.

      * Computation variables
       01 D1           PIC S9(4)V9(6).
       01 D2           PIC S9(4)V9(6).
       01 CDF-D1       PIC 9(4)V9(6).
       01 CDF-D2       PIC 9(4)V9(6).
       01 CALLPRICE    PIC 9(6)V9(6).
       01 PUTPRICE     PIC 9(6)V9(6).

      * Variables for normal CDF approximation
       01 X-IN         PIC S9(4)V9(6).
       01 CDF-OUT      PIC 9(4)V9(6).

       PROCEDURE DIVISION.
       MAIN.
           IF T = 0 THEN
               PERFORM CALCULATE-INSTANT-VALUE
           ELSE
               PERFORM CALCULATE-BLACK-SCHOLES
           END-IF

           PERFORM DISPLAY-RESULTS
           STOP RUN.

       CALCULATE-INSTANT-VALUE.
           COMPUTE CALLPRICE = FUNCTION MAX(S - K, 0)
           COMPUTE PUTPRICE  = FUNCTION MAX(K - S, 0).

       CALCULATE-BLACK-SCHOLES.
           COMPUTE D1 = (FUNCTION LOG(S / K) + (R + 0.5 * SIGMA ** 2) * 
           T) / (SIGMA * FUNCTION SQRT(T))
           COMPUTE D2 = D1 - SIGMA * FUNCTION SQRT(T)

           MOVE D1 TO X-IN
           PERFORM NORMAL-CDF
           MOVE CDF-OUT TO CDF-D1

           MOVE D2 TO X-IN
           PERFORM NORMAL-CDF
           MOVE CDF-OUT TO CDF-D2

           COMPUTE CALLPRICE = S * CDF-D1 - K * FUNCTION EXP(-R * T) * 
           CDF-D2

           COMPUTE D1 = -1 * D1
           MOVE D1 TO X-IN
           PERFORM NORMAL-CDF
           MOVE CDF-OUT TO CDF-D1

           COMPUTE D2 = -1 * D2
           MOVE D2 TO X-IN
           PERFORM NORMAL-CDF
           MOVE CDF-OUT TO CDF-D2

           COMPUTE PUTPRICE  = K * FUNCTION EXP(-R * T) * CDF-D2 - S * 
           CDF-D1.

       DISPLAY-RESULTS.
           DISPLAY "Call Price: " CALLPRICE
           DISPLAY "Put Price:  " PUTPRICE.

       NORMAL-CDF.
           COMPUTE CDF-OUT = 0.5 * (1 + (FUNCTION EXP(FUNCTION SQRT(2 / 
           3.141593) * (X-IN + 0.044715 * X-IN ** 3)) - FUNCTION EXP(- 
           FUNCTION SQRT(2 / 3.141593) * (X-IN + 0.044715 * X-IN ** 3)))
           /(FUNCTION EXP(FUNCTION SQRT(2 / 3.141593) * (X-IN + 0.044715
           * X-IN ** 3)) + FUNCTION EXP(- FUNCTION SQRT(2 / 3.141593) * 
           (X-IN + 0.044715 * X-IN ** 3)))).
