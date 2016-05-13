Attribute VB_Name = "Mobots"
'Mobots.bas by George Birbilis <birbilis@kagi.com>
'Version: 20060112

'#Uses "Vectors.bas"

Option Explicit
Option Base 0


Function GetMobotLocation(ByVal mobot As Integer) As Vector
 GetMobotLocation=CreateVector(GetMobotX(mobot),GetMobotY(mobot))
End Function

Function SetMobotLocation(ByVal mobot As Integer, newLocation As Vector) As Boolean
 SetMobotLocation=SetMobotPosition(mobot,newLocation.x,newLocation.y,GetMobotTheta(mobot))<>-1 'could calculate angle here from previous location and new location
End Function

Function SetMobotRelLocation(ByVal mobot As Integer, locationDelta As Vector) As Boolean
 SetMobotRelLocation=SetMobotRelPosition(mobot,locationDelta.x,locationDelta.y,0)<>-1 'could calculate angle here from previous location and new location
End Function

Function SetMobotTheta(ByVal mobot As Integer, ByVal theta As Single)
 SetMobotPosition(mobot,GetMobotX(mobot),GetMobotY(mobot),theta)
End Function
