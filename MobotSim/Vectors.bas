Attribute VB_Name = "Vectors"
'Vectors.bas by G.Birbilis (birbilis@kagi.com)
'Version: 20060113

Option Explicit
Option Base 0


Type Vector
 x As Single
 y As Single
End Type

Function CreateVector(ByVal vx As Single, ByVal vy As Single) As Vector
 With CreateVector
  .x=vx
  .y=vy
 End With
End Function

Function CreateVectorRnd As Vector
 CreateVectorRnd=CreateVector(Rnd,Rnd)
End Function

Function VectorToString(ByRef vec As Vector) As String
 VectorToString=CStr(vec.x)+", "+CStr(vec.y)
End Function

Function VectorFromString(ByVal s As String) As Vector
 'TO DO
End Function

Function VectorSum(ByRef a As Vector, ByRef b As Vector) As Vector
 VectorSum=CreateVector(a.x+b.x, a.y+b.y)
End Function

'TO DO: Function VectorDot
'TO DO: Function VectorMul

Sub VectorAdd(ByRef a As Vector, ByRef b As Vector)
 a=VectorSum(a,b)
End Sub

Function VectorDiff(ByRef a As Vector, ByRef b As Vector) As Vector
 VectorDiff=CreateVector(a.x-b.x, a.y-b.y)
End Function

Function VectorScaled(ByRef vec As Vector, ByVal scale As Single) As Vector
 With vec
  VectorScaled=CreateVector(.x*scale, .y*scale)
 End With
End Function

Sub VectorScale(ByRef vec As Vector, ByVal scale As Single)
 vec=VectorScaled(vec,scale)
End Sub

Function VectorStretched(ByRef a As Vector, ByRef stretch As Vector) As Vector
 With a
  VectorStretched=CreateVector(.x*stretch.x, .y*stretch.y)
 End With
End Function

Sub VectorStretch(ByRef vec As Vector, ByRef stretch As Vector)
 vec=VectorStretched(vec,stretch)
End Sub

Function VectorLength(ByRef vec As Vector) As Single
 With vec
  'VectorLength=Sqrt(Sqr(.x)+Sqr(.y)) 'wrong: ...
  VectorLength=Sqr(.x*.x+.y*.y) '...in SAX Basic it is SQR=SQRT
 End With
End Function

Function VectorAbs(ByRef vec As Vector) As Vector
 With vec
  VectorAbs=CreateVector(Abs(.x), Abs(.y))
 End With
End Function

Function VectorSgn(ByRef vec As Vector) As Vector
 With vec
  VectorSgn=CreateVector(Sgn(.x), Sgn(.y))
 End With
End Function

Function VectorMax(ByRef vec As Vector) As Single
 With vec
  If .y>.x Then
   VectorMax=.y
  Else
   VectorMax=.x
  End If
 End With
End Function

Function VectorMin(ByRef vec As Vector) As Single
 With vec
  If .y<.x Then
   VectorMin=.y
  Else
   VectorMin=.x
  End If
 End With
End Function
