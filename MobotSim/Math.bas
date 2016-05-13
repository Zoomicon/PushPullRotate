Attribute VB_Name = "Math"
'Math.bas by G.Birbilis (birbilis@kagi.com)
'Version: 20051213

Option Explicit
Option Base 0


Function min(a,b As Variant) As Variant
 If a<b Then min=a Else min=b
End Function


Function max(a,b As Variant) As Variant
 If a>b Then max=a Else max=b
End Function

'Function Sqrt(ByVal x As Single) As Single
' Sqrt=Exp(1/2*Log(x))
' Sqrt=x^(1/2)
'End Function

Function RoundN(ByVal x As Single, ByVal n As Integer) As Single
 Dim m As Single
 m=10^n
 RoundN=Round(x*m)/m
End Function

Function TruncN(ByVal x As Single, ByVal n As Integer) As Single
 Dim m As Single
 m=10^n
 TruncN=Int(x*m)/m
End Function
