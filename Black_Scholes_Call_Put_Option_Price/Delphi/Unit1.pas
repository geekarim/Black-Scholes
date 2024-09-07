unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Math;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Button1: TButton;
    Label6: TLabel;
    Label7: TLabel;
    Edit6: TEdit;
    Edit7: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{
  CDFNormal:
  This function calculates the cumulative distribution function (CDF)
  of the standard normal distribution using an approximation based on
  the hyperbolic tangent (tanh) function.

  The formula is derived from a fast approximation to the normal CDF
  and is often used in machine learning contexts like GELU (Gaussian
  Error Linear Units).

  Input:
    x: Double - The input value for which the CDF is calculated.

  Output:
    Result: Double - The CDF value for the normal distribution at 'x'.

  Example:
    CDFNormal(0.5) -> 0.691462
}
function CDFNormal(x: Double): Double;
begin
  // Fast approximation to the normal CDF using tanh function
  Result := 0.5 * (1 + tanh(sqrt(2 / pi) * (x + 0.044715 * power(x, 3))));
end;


{
  Button1Click:
  This procedure is executed when the user clicks Button1. It computes the
  Black-Scholes option prices (both Call and Put) based on user input values
  for stock price (S), strike price (K), risk-free interest rate (r), time to
  maturity (T), and volatility (sigma).

  The procedure uses the Black-Scholes formula to calculate the Call and Put
  option prices, which are then displayed in Edit6 (Call) and Edit7 (Put).

  Inputs:
    S: Double - The current stock price.
    K: Double - The option's strike price.
    r: Double - The risk-free interest rate.
    T: Double - The time to maturity (in years).
    sigma: Double - The volatility of the stock (standard deviation of returns).
}
procedure TForm1.Button1Click(Sender: TObject);
var
  S, K, r, T, sigma: Double;
  d1, d2: Double;
  Call, Put: Double;
begin
  // Convert user input from text (Edit components) to floating-point values
  S := StrToFloat(Edit1.Text);   // Stock price
  K := StrToFloat(Edit2.Text);   // Strike price
  r := StrToFloat(Edit3.Text);   // Interest rate
  T := StrToFloat(Edit4.Text);   // Time to maturity
  sigma := StrToFloat(Edit5.Text);  // Volatility

  // If time to maturity is zero, use intrinsic value of the options
  if T = 0 then
  begin
    Call := max(S - K, 0);  // Intrinsic value of a Call option
    Put := max(K - S, 0);   // Intrinsic value of a Put option
  end
  else
  begin
    // Calculate d1 and d2 for Black-Scholes formula
    d1 := (ln(S / K) + (r + 0.5 * sqr(sigma)) * T) / (sigma * sqrt(T));
    d2 := d1 - sigma * sqrt(T);

    // Calculate the Call option price using Black-Scholes formula
    Call := S * CDFNormal(d1) - exp(-r * T) * K * CDFNormal(d2);

    // Calculate the Put option price using Black-Scholes formula
    Put := exp(-r * T) * K * CDFNormal(-d2) - S * CDFNormal(-d1);
  end;

  // Output the Call option price into Edit6
  Edit6.Text := FloatToStr(Call);

  // Output the Put option price into Edit7
  Edit7.Text := FloatToStr(Put);
end;


end.
