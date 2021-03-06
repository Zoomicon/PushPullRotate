;;-- could implement this as tie-mode="minmax" for link breeds and add "min-length" and "max-length" to them (similarly can add "min-angle"/"max-angle")

;-- PushPullRotate (http://github.com/Zoomicon/PushPullRotate/NetLogo)
;-- Version: 20160719
;-- (from desktop version: 20160719)

;-- lines commented with ";;" are not supported by NetLogoWeb

;;extensions [profiler]

breed [connectors connector]
undirected-link-breed [rods rod]

connectors-own [anchored? c-hops]
rods-own [min-length max-length master r-hops vetoed?] ;-- assuming min-length<=max-length

globals [dragging? selected]

;---------------------------------------------------------------

to-report move [newpos]
  make-hierarchy
  ;anchor true
  setpos newpos
  let max-iterations 250
  let iterations 1
  while [ any? rods with [rod-broken?] ] [
    ifelse rods-fix [
      out-show "No vetoes occured"
    ][
      out-show "Vetoes occured"
      ask rods with [rod-broken? and vetoed?] [
        ask [other-end] of master [
          make-hierarchy ;-- back-propagation
          out-show word "Veto loop: " not rods-fix
        ]
      ]
    ]
    set iterations iterations + 1
    if iterations > max-iterations [
      ;anchor false
      report false
    ]
  ]
  ;anchor false
  report true
end

;------------------------------------------------------------

to make-hierarchy
  ask rods [ init-rod ]
  set c-hops 1
  let work [make-hierarchy-connector] of self
  while [any? work][
    set work connector-set ([make-hierarchy-connector] of work) ;-- connector-set can also process (nested) lists of agentsets
  ]
end

to-report make-hierarchy-connector
  let freerods my-rods with [master = nobody]
  ask freerods [
    set master myself
    set r-hops [c-hops + 1] of master
  ]
  report connector-set ([other-end] of freerods)
end

;------------------------------------------------------------

to-report rod-max-stretch?
  report (abs (rod-length - max-length)) < 0.5
end

to-report rod-max-shrink?
  report (abs (rod-length - min-length)) < 0.5
end

;------------------------------------------------------------

to-report rod-broken?
  report rod-excess-stretch? or rod-excess-shrink?
end

to-report rod-excess-stretch?
  report (rod-length > max-length + 0.5) ;-- added error margin
end

to-report rod-excess-shrink?
  report (rod-length < min-length - 0.5) ;-- added error margin
end

to minmax-lengths-fix
  if (min-length > max-length) [ ;-- swap min and max length constraints if min-length > max-length
    let temp max-length
    set max-length min-length
    set min-length temp
  ]
end

to-report rods-fix
  ask rods [ minmax-lengths-fix ] ;-- need to call this when using buttons that set all rods' min-length or max-length in one step

  let result true
  foreach (sort-by [ [?1 ?2] -> [r-hops] of ?1 < [r-hops] of ?2 ] (rods with [rod-broken?]) ) [ ;-- treat rods with less r-hops first (could also try inverse ordering, but would make it harder to implement with only local interactions)
    ?1 -> ask ?1 [ set result (rod-fix and result) ]
  ]
  report result
end

to-report rod-fix
  if rod-excess-stretch? [ report [[rod-pull] of myself] of master ] ;-- on excess stretch, PULL
  if rod-excess-shrink? [ report [[rod-push] of myself] of master ] ;-- on excess shrink, PUSH
  report true ;-- no excess stretch or shrink, STAY
end

to-report rod-pull
  report rod-adapt (rod-length - max-length) "Pulled by "
end

to-report rod-push
  report rod-adapt (rod-length - min-length) "Pushed by " ;-- negative distance to go backwards
end

to-report rod-adapt [the-distance the-action]
  let result false
  ask other-end [
    ifelse anchored? [
      ask myself [ set vetoed? true ]
      out-show word "Vetoed to " ([master] of myself)
      ;-- let result false
    ][
      face [master] of myself
      forward the-distance
      out-show word the-action ([master] of myself)
      set result true
    ]
  ]
  update-rod-color
  report result
end

;---------------------------------------------------------------

to init-connector
  set size 8

  set label-color black
  set label who

  anchor false
  set c-hops -1
end

to init-rod
  set master nobody
  set r-hops -1
  set vetoed? false
end

;---------------------------------------------------------------
; INITIALIZATION
;---------------------------------------------------------------

to startup
  set-default-shape connectors "circle"
  reset
end

;---------------------------------------------------------------
; START BUTTON
;---------------------------------------------------------------

to start
  ;;output-show runresult mode ;-- this isn't supported in NetLogo Web

  ifelse (mode = "go") [
    go
  ][
    ifelse (mode = "edit-make-connectors") [
      if (edit-make-connectors) [ stop ]
    ][
      ifelse (mode = "edit-make-rods") [
        if edit-make-rods [ stop ]
      ][
        ifelse (mode = "edit-move-connectors") [
          if edit-move-connectors [ stop]
        ][
          if (mode = "edit-anchor-connectors") [
            if edit-anchor-connectors [ stop ]
          ]
        ]
      ]
    ]
  ]
end

;---------------------------------------------------------------
; RESET BUTTON
;---------------------------------------------------------------

to reset
  ;-- clear-all should be at beginning of setup/reset procedure and reset-ticks at end (__clear-all-and-reset-ticks is deprecated)
  clear-all
  set dragging? false
  set selected nobody
  ask patches [ set pcolor white ]   ;-- white background
  display
  reset-ticks
end

;---------------------------------------------------------------
; START BUTTON ACTIONS
;---------------------------------------------------------------

to go
  if not mouse-down? [
    set dragging? false
    stop
  ]

  if not dragging? [
    set selected connector-at-mouse
    set dragging? true
    if not continuous_solving? [ wait-mouse-up ]
  ]

  if selected = nobody [ stop ]

  profiler-begin

  ask selected [
    ifelse move mouse-pos [
      out-show "Moved"
    ][
      out-error "Can't adapt system"
    ]
  ]

  ask rods [ update-rod-color ]
  display
  profiler-end
end

;---------------------------------------------------------------

to-report edit-make-connectors
  if not mouse-down? [ report false ]

  set selected connector-at-mouse

  ifelse selected = nobody [
    create-connectors 1 [ init-connector (setpos mouse-pos) ]
  ][
    ask selected [ die ]
  ]
  display

  wait-mouse-up

  report true
end

;---------------------------------------------------------------

to-report edit-make-rods
  if not mouse-down? [ report false ]

  set selected connector-at-mouse
  if (selected = nobody) [ report false ]

  wait-mouse-up

  let selected2 connector-at-mouse
  if (selected2 = nobody) [ report false ]

  if (selected = selected2) [
    user-message "Drag connector to other one to (un)link them using a rod"
    report false
  ]

  ask selected [
    ifelse rod-neighbor? selected2 [
      ask rod-with selected2 [ die ]
    ][
      create-rod-with selected2 [ init-rod update-rod-minmaxlen ]
    ]
  ]

  display

  report true
end

;---------------------------------------------------------------

to-report edit-move-connectors
  if not mouse-down? [ report false ]

  set selected connector-at-mouse
  if (selected = nobody) [ report false ]

  while [mouse-down?] [
    ask selected [
      setpos mouse-pos ;-- drag until mouse button released
      ;ask my-rods [ update-rod-minmaxlen ]
    ]
    display
  ]

  report true
end

;---------------------------------------------------------------

to-report edit-anchor-connectors
  if not mouse-down? [ report false ]

  set selected connector-at-mouse
  if (selected = nobody) [ report false ]

  if selected != nobody [
    ask selected [ anchor (not anchored?) ] ;-- toggle anchor
    display
  ]

  wait-mouse-up

  report true
end

;---------------------------------------------------------------
; HELPERS
;---------------------------------------------------------------

to-report connector-set [value] ;-- fix for missing <breed>-set at NetLogo 4.1.1
  report turtle-set value
end

;to-report rod-set [value] ;-- fix for missing <breed>-set at NetLogo 4.1.1
;  report link-set value
;end

to-report rod-length ;-- fix for missing <breed>-length at NetLogo 4.1.1
  report link-length
end

;-----------------------------------------------------------

to-report connector-at-pos [the-pos]
  report one-of connectors with [distancepos the-pos < size]
end

to-report connector-at-mouse
  report connector-at-pos mouse-pos
end

;-----------------------------------------------------------

to update-rod-minmaxlen
  set min-length rod-length
  set max-length rod-length
  update-rod-color
end

to set-rod-min-length
  set min-length rod-length
  update-rod-color
end

to set-rod-max-length
  set max-length rod-length
  update-rod-color
end

;-----------------------------------------------------------

to anchor [flag]
  set anchored? flag
  ifelse flag
    [ set color red ]
    [ set color sky ]
end

to update-rod-color
  ifelse rod-max-shrink?
    [ set color red ]
    [ ifelse rod-max-stretch?
        [ set color green ]
        [ set color black ] ]
end

;-----------------------------------------------------------
; OUTPUT
;---------------------------------------------------------------

to out-show [value]
  if output? [ output-show value ]
end

to out-error [value]
  ;;beep
  out-show value
end

to out-print [value]
  if output? [ output-print value ]
end

;-----------------------------------------------------------
; PROFILING (NOT SUPPORTED IN NETLOGO WEB)
;---------------------------------------------------------------

to profiler-begin
  if profiling? [
;;    profiler:reset
;;    profiler:start
  ]
end

to profiler-end
  if profiling? [
;;    profiler:stop
;;    out-print profiler:report
  ]
end

;---------------------------------------------------------------

to wait-mouse-up
;;  while [mouse-down?] [ ;-- this loop (with or without an out-print in it) seems to freeze NetLogo Web, but works fine in classic NetLogo
;;    ;out-print "waiting for mouse up"
;;  ]
  set dragging? false
end

;-----------------------------------------------------------
; ABSTRACTING 2D/3D POSITIONING
;-----------------------------------------------------------

to-report pos
  ;report (list xcor ycor 0) ;-- NetLogo 4.1.1 has no mouse-zcor (for 3D mice)
  report (list xcor ycor)
end

to setpos [newpos]
  ;setxyz (item 0 newpos) (item 1 newpos) (item 2 newpos)
  setxy (item 0 newpos) (item 1 newpos)
end

to-report distancepos [the-pos]
  ;report distancexyz (item 0 the-pos) (item 1 the-pos) (item 2 the-pos)
  report distancexy (item 0 the-pos) (item 1 the-pos)
end

to-report mouse-pos
  ;report (list mouse-xcor mouse-ycor 0) ;-- NetLogo 4.1.1 has no mouse-zcor (for 3D mice)
  report (list mouse-xcor mouse-ycor)
end


; Copyright 2010-2015 George Birbilis. All rights reserved.
; UI is based on NetLogo's "Planarity" (game) model
; The full copyright notice is in the Information tab.
@#$#@#$#@
GRAPHICS-WINDOW
5
10
415
421
-1
-1
2.0
1
12
1
1
1
0
0
0
1
-100
100
-100
100
1
1
1
time
30.0

BUTTON
430
10
545
55
NIL
start
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
555
10
732
55
mode
mode
"go" "edit-make-connectors" "edit-make-rods" "edit-move-connectors" "edit-anchor-connectors"
0

BUTTON
430
60
545
93
reset
if (user-yes-or-no? \"Reset?\") [ reset ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
430
100
970
405
12

SWITCH
430
410
532
443
profiling?
profiling?
1
1
-1000

BUTTON
875
410
972
443
clear output
;if (user-yes-or-no? \"Clear output?\") [  \n  clear-output\n;]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
855
10
970
43
set rods min-length
ask rods [ set-rod-min-length ]\ndisplay
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
855
50
970
83
set rods max-length
ask rods [ set-rod-max-length ]\ndisplay
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
760
410
863
443
output?
output?
0
1
-1000

SWITCH
570
60
732
93
continuous_solving?
continuous_solving?
0
1
-1000

@#$#@#$#@
## TO DO

- add the rotate to avoid obstacle logic (from previous paper [see mobotsim code too])

- if a master node gets too close to another node, have that one behave as slave and get repelled (thus affecting all its links). Maybe add similar behaviour for obstacles. Can call this an "Implicit Master-Slave" behaviour (in contrast to an "Explicit Master-Slave" one)

- if node gets close to link, have it rotate to get repelled, as if that node was an obstacle

## WHAT IS IT?

PUSH-PULL-ROTATE SIMULATOR

## HOW IT WORKS

.... The details are in the Procedures tab.

## HOW TO USE IT

...

## THINGS TO NOTICE

...

## THINGS TO TRY

...

## EXTENDING THE MODEL

...

## RELATED MODELS

Intersecting Links Example -- has sample code for finding the point where two links intersect

## CREDITS AND REFERENCES

...

## HOW TO CITE

If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the NetLogo software:
- Birbilis, G. (2010).  .. model.
  http://ccl.northwestern.edu/netlogo/models/Planarity
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

In other publications, please use:
- Copyright 2010 George Birbilis. All rights reserved. See http://.../netlogo/models/...ity for terms of use.

## COPYRIGHT NOTICE

Copyright 2010 George Birbilis. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:
a) this copyright notice is included.
b) this model will not be redistributed for profit without permission from George Birbilis. Contact George Birbilis for appropriate licenses for redistribution for profit.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0-RC2
@#$#@#$#@
set starting-level 8
setup
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
