Attribute VB_Name = "Mobots"
'Mobots.bas by George Birbilis <birbilis@kagi.com>
'Version: 20051213

'#Uses "Vectors.bas"

Option Explicit
Option Base 0


Function GetMarkLocation(ByVal mobot As Integer) As Vector
 GetMarkLocation=CreateVector(GetMarkX(mobot),GetMarkY(mobot))
End Function


Function SetMarkLocation(ByVal mobot As Integer, newLocation As Vector) As Boolean
 SetMarkLocation=SetMarkPosition(mobot,newLocation.x,newLocation.y)<>-1 'could calculate angle here from previous location and new location
End Function
