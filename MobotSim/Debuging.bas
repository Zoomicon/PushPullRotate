Attribute VB_Name = "Module1"
'Debuging.bas by G.Birbilis (birbilis@kagi.com)
'Version: 20060112

Option Explicit
Option Base 0


Const DEFAULT_TRACING=True

Public tracing As Boolean

Public Sub DebugTrace(ParamArray params())
 Dim i As Integer
 If tracing Then
  For i=LBound(params) To UBound(params)
   Debug.Print params(i); 'doesn't add a new line
   Print #1,params(i);
  Next i
  Debug.Print "" 'new line
  Print #1,"" 'new line
 End If
End Sub

Private Sub Main
 tracing=DEFAULT_TRACING
 Open MacroDir & "\trace.log" For Append Shared As #1
 Print #1,""
 Print #1,"------------"
 Print #1,Now
 Print #1,"------------"
End Sub
