Attribute VB_Name = "Module1"
'WallFollower.bas by George Birbilis (birbilis@kagi.com) [originated from WallFollower demo of MobotSim]
'Version: 20060113

'#Uses "debuging.bas"

Option Explicit
Option Base 0


Sub WallFollowerInit(ByVal timestepSec As Single)
 SetTimeStep timestepSec
End Sub

Sub WallFollowerStep(ByVal mobot As Integer, ByVal rightSensor As Integer, ByVal leftSensor As Integer,ByVal speed As Single)
 Dim sR As Single, sL As Single, wR As Single, wL As Single

 'Read sensors

 Const UPDATE_MAP As Integer = 0
 sR = MeasureRange(mobot,rightSensor,UPDATE_MAP) 'Read right sensor
 sL = MeasureRange(mobot,leftSensor,UPDATE_MAP)  'Read left sensor
 DebugTrace "sensors: right=",sR,", left=",sL

 'calculate wheels speed adjustment based on sensor

 Const MIN_DISTANCE As Single = 0.7
 Const MAX_DISTANCE As Single = 0.9

 'subsumption layers (lower ones replace higher ones)

 wR=speed : wL=speed  'move arround

 If sR > MAX_DISTANCE Then 'too far from the right
  wR=0
  wL=speed
 End If

 If sL > MAX_DISTANCE And (sR=-1 Or sL>sR) Then 'too far from the left (and more far than to the right [-1 means no objects detected within range])
  wR=speed
  wL=0
 End If

 If sR < MIN_DISTANCE And (sR<>-1) Then 'too close to the right
  wR=speed
  wL=0
 End If

 If sL < MIN_DISTANCE And (sL<>-1) And (sR=-1 Or sL<sR) Then 'too close to the left (and more close than to the right [-1 means no objects detected within range])
  wR=0
  wL=speed
 End If

 SetWheelSpeed(mobot,wL,wR)

 StepForward   ' Dynamics simulation progresses one time step

End Sub
