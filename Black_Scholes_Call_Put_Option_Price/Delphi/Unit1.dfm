object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Black-Scholes Call & Put Option Price'
  ClientHeight = 407
  ClientWidth = 612
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label1: TLabel
    Left = 60
    Top = 32
    Width = 58
    Height = 15
    Caption = 'Stock price'
  end
  object Label2: TLabel
    Left = 60
    Top = 72
    Width = 29
    Height = 15
    Caption = 'Strike'
  end
  object Label3: TLabel
    Left = 60
    Top = 112
    Width = 62
    Height = 15
    Caption = 'Interest rate'
  end
  object Label4: TLabel
    Left = 60
    Top = 152
    Width = 26
    Height = 15
    Caption = 'Time'
  end
  object Label5: TLabel
    Left = 60
    Top = 192
    Width = 45
    Height = 15
    Caption = 'Volatility'
  end
  object Label6: TLabel
    Left = 60
    Top = 300
    Width = 49
    Height = 15
    Caption = 'Call price'
  end
  object Label7: TLabel
    Left = 62
    Top = 340
    Width = 47
    Height = 15
    Caption = 'Put price'
  end
  object Edit1: TEdit
    Left = 200
    Top = 29
    Width = 121
    Height = 23
    TabOrder = 0
    Text = '100'
  end
  object Edit2: TEdit
    Left = 200
    Top = 69
    Width = 121
    Height = 23
    TabOrder = 1
    Text = '100'
  end
  object Edit3: TEdit
    Left = 200
    Top = 109
    Width = 121
    Height = 23
    TabOrder = 2
    Text = '0.02'
  end
  object Edit4: TEdit
    Left = 200
    Top = 149
    Width = 121
    Height = 23
    TabOrder = 3
    Text = '1'
  end
  object Edit5: TEdit
    Left = 200
    Top = 189
    Width = 121
    Height = 23
    TabOrder = 4
    Text = '0.2'
  end
  object Button1: TButton
    Left = 224
    Top = 232
    Width = 75
    Height = 25
    Caption = 'Compute'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Edit6: TEdit
    Left = 200
    Top = 297
    Width = 121
    Height = 23
    TabOrder = 6
  end
  object Edit7: TEdit
    Left = 200
    Top = 337
    Width = 121
    Height = 23
    TabOrder = 7
  end
end
