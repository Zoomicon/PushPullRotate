'BirbRobot.bas by G.Birbilis (birbilis@kagi.com)
'Version: 20060112 (based on BirbRobot.pas script from MachineLab, ver. 20050425)

'#Uses "Math.bas"
'#Uses "Vectors.bas"
'#Uses "Marks.bas"
'#Uses "Collision.bas"
'#Uses "Mobots.bas"
'#Uses "WallFollowerAlgorithm.bas"
'#Uses "Debuging.bas"



'--- ROBOT TOPOLOGY ---

Const N As Integer = 15
Dim pos(N-1) As Vector
Dim lmin(N-1) As Single
Dim lmax(N-1) As Single
Dim fixedPin(N-1) As Boolean


'--- ACTION/REACTION ---

Function IsLocationFree(ByVal pin As Integer, ByRef newLocation As Vector) As Boolean
 'Dim oldLocation As Vector
 'oldLocation=GetMobotLocation(0)
 'setMobotLocation(0,CreateVector(0,0))

 If pin<=2 Then 'temporary patch to avoid the two first marks to complain that they're upon the controller (pin 0) mobot (which is a bit oversized)
  IsLocationFree=True
  Exit Function
 End If

 IsLocationFree=(Not CollidePoint(newLocation))
 'SetMobotLocation(0,oldLocation)
End Function

Function Move(ByVal pin As Integer, newLocation As Vector) As Boolean
 If IsLocationFree(pin,newLocation) Then '!!! must also check if link collides !!!
  pos(pin)=newLocation
  SetMarkLocation(pin,newLocation)
  Move=True 'not colliding with other objects (robots or obstacles), accept the performed movement
 Else
  Move=False '...veto
 End If '!!! should also somehow check to see we won't eventually collide with other mobots (chain head eating tail) !!!
End Function

Function Adapt(ByVal master As Integer, ByVal slave As Integer) As Boolean
 Dim mloc As Vector, sloc As Vector, diff As Vector, location As Vector
 Dim dist As Single
 Dim rod As Integer

 rod=min(master,slave)
 mloc=pos(master)
 sloc=pos(slave)

 Adapt=False

 '-- ROTATE --
 If (master>2) Then 'master>2 is temporary patch to avoid the two first marks to complain that they're upon the controller (pin 0) mobot (which is a bit oversized)
  Do While CollideSegmentGetPoint(mloc,sloc,location)
   'shake the colliding location a bit and use it as the rod's new axis (instead of using the masterNewPos-slaveCurrentPos line)
   'sloc=VectorSum(location,CreateVectorRnd) 'in random direction
   sloc=VectorSum(VectorStretched(VectorSgn(VectorDiff(sloc,location)),CreateVectorRnd),location) 'shake more towards the last (non-colliding) slave position
   DebugTrace master, " rotated ", slave '!!! should print the degrees the rod rotated
  Loop
 End If

 diff=VectorDiff(sloc,mloc)
 dist=VectorLength(diff)

 '-- PULL --
 If(dist>lmax(rod)) Then 'link tries To stretch above its max length
  If fixedPin(slave) Then Exit Function
  location=VectorSum(VectorScaled(diff,lmax(rod)/dist),mloc)
  If Not Move(slave,location) Then Exit Function
  DebugTrace master, " pulled ", slave
 '-- PUSH --
 ElseIf(dist<lmin(rod)) Then 'link tries To shrink below its mix length
  If fixedPin(slave) Then Exit Function
  location=VectorSum(VectorScaled(diff,lmin(rod)/dist),mloc)
  If Not Move(slave,location) Then Exit Function
  DebugTrace master, " pushed ", slave
 '-- RESIZE --
 Else
  'link can resize (lmin(rod)<=dist<=lmax(rod)), so don't move the slave at all
  DebugTrace master, " moved"
 End If

 Adapt=True

End Function

Sub Propagate(ByVal master As Integer, ByVal direction As Integer) 'direction Is either +1 Or -1
 Dim slave As Integer

 slave=master+direction
 If (slave>=0) And (slave<N) Then '<=N-1
  If Not Adapt(master,slave) Then
   direction=-direction 'If slave can adapt To master's motion, propagate back veto action
   DebugTrace slave, " vetoed to", master
  End If
  Call Propagate(slave,direction)
 End If
End Sub


'--- INITIALIZATION ---

Const L_MIN As Single = 0.1
Const L_MAX As Single = 0.2
Const TIMESTEP As Single = 0.1
Const TRAJECTORY As Integer = 1

Sub Init
 Dim i As Integer
 Dim x,y As Single
 Dim location As Vector

 SetMobotTheta(CONTROLLER,0)

 x=10
 y=10
 For i=0 To N-1
  lmin(i)=L_MIN
  lmax(i)=L_MAX
  fixedPin(i)=False

  'location=GetMarkLocation(i)
  location=CreateVector(x,y)
  pos(i)=location
  SetMarkLocation(i,location)
  y=y+(lmin(i)+lmax(i))/2
 Next i
 'fixedPin(N-1)=True
 'fixedPin(0)=True

 SetMisreadings(CONTROLLER,0)
 SetDrawTrajectory(CONTROLLER,TRAJECTORY)
 SetMobotLocation(CONTROLLER,pos(CONTROLLER))

 WallFollowerInit(TIMESTEP)
End Sub


'--- MAIN LOOP ---

Const CONTROLLER As Integer = 0
Const SPEED=30
Const ISTRACING=False

Sub Run
 Dim newLocation As Vector

 WallFollowerStep CONTROLLER,4,7,SPEED

 newLocation=GetMobotLocation(CONTROLLER)

 If Not fixedPin(CONTROLLER) Then
  If Move(CONTROLLER,newLocation) Then
   Propagate CONTROLLER,1 'react To master's previous motion (propagate up the chain)
   Propagate CONTROLLER,-1 '...propagate down the chain
  Else
   SetMobotLocation(CONTROLLER,pos(CONTROLLER))
  End If
 End If
End Sub

Sub Main
 Randomize 'seed the random number generator using the current time
 tracing=ISTRACING
 Init
 While True
  Run
 Wend
End Sub
