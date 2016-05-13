Attribute VB_Name = "Collision"
'Collision.bas by George Birbilis (birbilis@kagi.com)
'Version: 20060113

'#Uses "Math.bas"
'#Uses "Vectors.bas"
'#Uses "Debuging.bas"

Option Explicit
Option Base 0


Function CollidePoint(ByRef point As Vector) As Boolean
 With point
  'DebugTrace "Checking point (", VectorToString(point), ")"
  If (SpaceTest(.x,.y)=1) Then
   CollidePoint=True
   DebugTrace "Collision at point (", VectorToString(point), ")"
  Else
   CollidePoint=False
  End If
 End With
End Function

Function CollideSegment(ByRef point1 As Vector, ByRef point2 As Vector) As Boolean
 Dim collisionPoint As Vector
 CollideSegment=CollideSegmentGetPoint(point1,point2,collisionPoint)
End Function

Private Sub TraceSegmentCollision(ByRef point1 As Vector, ByRef point2 As Vector)
 DebugTrace "Segment (", VectorToString(point1), ")-(", VectorToString(point2), ") has collision"
End Sub

Function CollideSegmentGetPoint(ByRef point1 As Vector, ByRef point2 As Vector, ByRef collisionPoint As Vector) As Boolean 'any collision point returned is the closest to "point1"
 Dim d As Vector, p As Vector
 Dim m As Integer, i As Integer

 Const FACTOR As Integer=1 'how detailed check will be done

 'DebugTrace "Checking segment (", VectorToString(point1), ")-(", VectorToString(point2), ")"

 d=VectorDiff(point2,point1)
 m=Max(6,Int(VectorMax(VectorAbs(d))/FACTOR)) 'check at least 6 points (4 points inside the segment and the two segment end points

 If m=0 Then
  If CollidePoint(point1) Then
   CollideSegmentGetPoint=True
   collisionPoint=point1
   TraceSegmentCollision point1,point2
  Else
   CollideSegmentGetPoint=False
  End If
  Exit Function
 End If

 d=VectorScaled(d,1!/m)

 For i=1 To m
  p=VectorSum(point1, CreateVector(i*d.x, i*d.y))
  If CollidePoint(p) Then
   CollideSegmentGetPoint=True
   collisionPoint=p
   TraceSegmentCollision point1,point2
   Exit Function
  End If
 Next i

 CollideSegmentGetPoint=False
End Function
