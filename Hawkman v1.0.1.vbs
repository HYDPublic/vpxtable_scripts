' Hawkman - Taito 1983
' IPD No. 4512 / 1983 / 4 Players
' VPX - version by JPSalas 2018, version 1.0.1

Option Explicit
Randomize

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs in order to run this table, available in the vp10 package"
On Error Goto 0

LoadVPM "01550000", "Taito.vbs", 3.26

Dim bsTrough, dtbank1, dtbank2, dtbank3, dtbank4, dtbank5, bsRightSaucer, bsTopSaucer, x

Const cGameName = "hawkman"

Const UseSolenoids = 1
Const UseLamps = 0
Const UseGI = 0
Const UseSync = 0 'set it to 1 if the table runs too fast
Const HandleMech = 0

Dim VarHidden
If Table1.ShowDT = true then
    VarHidden = 1
    For each x in aReels
        x.Visible = 1
    Next
else
    VarHidden = 0
    For each x in aReels
        x.Visible = 0
    Next
    lrail.Visible = 0
    rrail.Visible = 0
end if

if B2SOn = true then VarHidden = 1

' Standard Sounds
Const SSolenoidOn = "fx_Solenoid"
Const SSolenoidOff = ""
Const SCoin = "fx_Coin"

'************
' Table init.
'************

Sub table1_Init
    vpmInit me
    With Controller
        .GameName = cGameName
        If Err Then MsgBox "Can't start Game" & cGameName & vbNewLine & Err.Description:Exit Sub
        .SplashInfoLine = "Hawkman - Taito 1983" & vbNewLine & "VPX table by JPSalas v.1.0.1"
        .HandleKeyboard = 0
        .ShowTitle = 0
        .ShowDMDOnly = 1
        .ShowFrame = 0
        .HandleMechanics = 0
        .Hidden = VarHidden
        .Games(cGameName).Settings.Value("rol") = 0 '1= rotated display, 0= normal
        '.SetDisplayPosition 0,0, GetPlayerHWnd 'restore dmd window position
        On Error Resume Next
        Controller.SolMask(0) = 0
        vpmTimer.AddTimer 2000, "Controller.SolMask(0)=&Hffffffff'" 'ignore all solenoids - then add the Timer to renable all the solenoids after 2 seconds
        Controller.Run GetPlayerHWnd
        On Error Goto 0
    End With

    ' Nudging
    vpmNudge.TiltSwitch = 30
    vpmNudge.Sensitivity = 3
    vpmNudge.TiltObj = Array(Bumper1, Bumper2, Bumper3, LeftSlingshot, RightSlingshot)

    ' Trough
    Set bsTrough = New cvpmBallStack
    With bsTrough
        .InitSw 0, 51, 41, 31, 0, 0, 0, 0
        .InitKick BallRelease, 90, 4
        .InitExitSnd SoundFX("fx_ballrel", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)
        .Balls = 3
    End With

    ' Saucers
    Set bsRightSaucer = New cvpmBallStack
    bsRightSaucer.InitSaucer sw3, 3, 2180, 5
    bsRightSaucer.InitExitSnd SoundFX("fx_kicker", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)
    bsRightSaucer.KickForceVar = 3

    Set bsTopSaucer = New cvpmBallStack
    bsTopSaucer.InitSaucer sw1, 1, 270, 5
    bsTopSaucer.InitExitSnd SoundFX("fx_kicker", DOFContactors), SoundFX("fx_Solenoid", DOFContactors)
    bsTopSaucer.KickForceVar = 3

    ' Drop targets
    set dtbank1 = new cvpmdroptarget
    dtbank1.InitDrop Array(sw13, sw23, sw33), Array(13, 23, 33)
    dtbank1.initsnd SoundFX("", DOFDropTargets), SoundFX("fx_resetdrop", DOFContactors)

    set dtbank2 = new cvpmdroptarget
    dtbank2.InitDrop Array(sw43, sw53, sw63), Array(43, 53, 63)
    dtbank2.initsnd SoundFX("", DOFDropTargets), SoundFX("fx_resetdrop", DOFContactors)

    set dtbank3 = new cvpmdroptarget
    dtbank3.InitDrop Array(sw54, sw64, sw74), Array(54, 64, 74)
    dtbank3.initsnd SoundFX("", DOFDropTargets), SoundFX("fx_resetdrop", DOFContactors)

    set dtbank4 = new cvpmdroptarget
    dtbank4.InitDrop Array(sw42, sw52, sw62), Array(42, 52, 62)
    dtbank4.initsnd SoundFX("", DOFDropTargets), SoundFX("fx_resetdrop", DOFContactors)

    set dtbank5 = new cvpmdroptarget
    dtbank5.InitDrop Array(sw2, sw12, sw22), Array(2, 12, 22)
    dtbank5.initsnd SoundFX("", DOFDropTargets), SoundFX("fx_resetdrop", DOFContactors)

    ' Main Timer init
    PinMAMETimer.Interval = PinMAMEInterval
    PinMAMETimer.Enabled = 1

    Controller.Switch(60) = 1
    Controller.Switch(70) = 1

    ' Turn on Gi
    GiOn
End Sub

Sub table1_Paused:Controller.Pause = 1:End Sub
Sub table1_unPaused:Controller.Pause = 0:End Sub
Sub table1_exit:Controller.stop:End Sub

'**********
' Keys
'**********

Sub table1_KeyDown(ByVal Keycode)
    If keycode = LeftTiltKey Then Nudge 90, 5:PlaySound SoundFX("fx_nudge", 0), 0, 1, -0.1, 0.25
    If keycode = RightTiltKey Then Nudge 270, 5:PlaySound SoundFX("fx_nudge", 0), 0, 1, 0.1, 0.25
    If keycode = CenterTiltKey Then Nudge 0, 6:PlaySound SoundFX("fx_nudge", 0), 0, 1, 0, 0.25
    If keycode = PlungerKey Then PlaySound "fx_PlungerPull", 0, 1, 0.1, 0.25:Plunger.Pullback
    if keycode = rightflipperkey then controller.switch(72) = 1
    If vpmKeyDown(keycode)Then Exit Sub
End Sub

Sub table1_KeyUp(ByVal Keycode)
    if keycode = rightflipperkey then controller.switch(72) = 0
    If vpmKeyUp(keycode)Then Exit Sub
    If keycode = PlungerKey Then PlaySound "fx_plunger", 0, 1, 0.1, 0.25:Plunger.Fire
End Sub

'*********
' Switches
'*********

' Slings
Dim LStep, RStep

Sub LeftSlingShot_Slingshot
    PlaySound SoundFX("fx_slingshot", DOFContactors), 0, 1, -0.05, 0.05
	DOF 104, DOFPulse
    LeftSling4.Visible = 1
    Lemk.RotX = 26
    LStep = 0
    vpmTimer.PulseSw 71
    LeftSlingShot.TimerEnabled = 1
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 1:LeftSLing4.Visible = 0:LeftSLing3.Visible = 1:Lemk.RotX = 14
        Case 2:LeftSLing3.Visible = 0:LeftSLing2.Visible = 1:Lemk.RotX = 2
        Case 3:LeftSLing2.Visible = 0:Lemk.RotX = -10:LeftSlingShot.TimerEnabled = 0
    End Select
    LStep = LStep + 1
End Sub

Sub RightSlingShot_Slingshot
    PlaySound SoundFX("fx_slingshot", DOFContactors), 0, 1, 0.05, 0.05
	DOF 105, DOFPulse
    RightSling4.Visible = 1
    Remk.RotX = 26
    RStep = 0
    vpmTimer.PulseSw 71
    RightSlingShot.TimerEnabled = 1
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 1:RightSLing4.Visible = 0:RightSLing3.Visible = 1:Remk.RotX = 14
        Case 2:RightSLing3.Visible = 0:RightSLing2.Visible = 1:Remk.RotX = 2
        Case 3:RightSLing2.Visible = 0:Remk.RotX = -10:RightSlingShot.TimerEnabled = 0
    End Select
    RStep = RStep + 1
End Sub

' Scoring rubbers
' Rubber animations
Dim Rub1, Rub2, Rub3

Sub sw11_Hit:vpmTimer.PulseSw 11:Rub1 = 1:sw11_Timer:End Sub

Sub sw11_Timer
    Select Case Rub1
        Case 1:r3.Visible = 0:r4.Visible = 1:sw11.TimerEnabled = 1
        Case 2:r4.Visible = 0:r5.Visible = 1
        Case 3:r5.Visible = 0:r3.Visible = 1:sw11.TimerEnabled = 0
    End Select
    Rub1 = Rub1 + 1
End Sub

Sub sw11a_Hit:vpmTimer.PulseSw 11:Rub2 = 1:sw11a_Timer:End Sub
Sub sw11a_Timer
    Select Case Rub2
        Case 1:r1.Visible = 0:r9.Visible = 1:sw11a.TimerEnabled = 1
        Case 2:r9.Visible = 0:r10.Visible = 1
        Case 3:r10.Visible = 0:r1.Visible = 1:sw11a.TimerEnabled = 0
    End Select
    Rub2 = Rub2 + 1
End Sub

Sub sw11b_Hit:vpmTimer.PulseSw 12:Rub3 = 1:sw11b_Timer:End Sub
Sub sw11b_Timer
    Select Case Rub3
        Case 1:r8.Visible = 0:r11.Visible = 1:sw11b.TimerEnabled = 1
        Case 2:r11.Visible = 0:r13.Visible = 1
        Case 3:r13.Visible = 0:r8.Visible = 1:sw11b.TimerEnabled = 0
    End Select
    Rub3 = Rub3 + 1
End Sub

' Bumpers
Sub Bumper1_Hit:DOF 101, DOFPulse:vpmTimer.PulseSw 44:PlaySound SoundFX("fx_bumper", DOFContactors), 0, 1, -0.05:LiBumper1a.Duration 1, 200, 0:LiBumper1b.Duration 1, 200, 0:LiBumper1c.Duration 1, 200, 0:End Sub
Sub Bumper2_Hit:DOF 103, DOFPulse:vpmTimer.PulseSw 44:PlaySound SoundFX("fx_bumper", DOFContactors), 0, 1, 0.05:LiBumper2a.Duration 1, 200, 0:LiBumper2b.Duration 1, 200, 0:LiBumper2c.Duration 1, 200, 0:End Sub
Sub Bumper3_Hit:DOF 102, DOFPulse:vpmTimer.PulseSw 44:PlaySound SoundFX("fx_bumper", DOFContactors), 0, 1, 0:LiBumper3a.Duration 1, 200, 0:LiBumper3b.Duration 1, 200, 0:LiBumper3c.Duration 1, 200, 0:End Sub

' Drain & Saucers
Sub Drain_Hit:Playsound "fx_drain":bsTrough.AddBall Me:End Sub
Sub sw3_Hit::PlaySound "fx_kicker_enter", 0, 1, 0.05:bsRightSaucer.AddBall 0:End Sub
Sub sw1_Hit::PlaySound "fx_kicker_enter", 0, 1, 0.05:bsTopSaucer.AddBall 0:End Sub

' Rollovers
Sub sw4_Hit:Controller.Switch(4) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw4_UnHit:Controller.Switch(4) = 0:End Sub

Sub sw75_Hit:Controller.Switch(75) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw75_UnHit:Controller.Switch(75) = 0:End Sub

Sub sw55_Hit:Controller.Switch(55) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw55_UnHit:Controller.Switch(55) = 0:End Sub

Sub sw65_Hit:Controller.Switch(65) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw65_UnHit:Controller.Switch(65) = 0:End Sub

Sub sw21_Hit:Controller.Switch(21) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw21_UnHit:Controller.Switch(21) = 0:End Sub

Sub sw25_Hit:Controller.Switch(25) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw25_UnHit:Controller.Switch(25) = 0:End Sub

Sub sw35_Hit:Controller.Switch(35) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw35_UnHit:Controller.Switch(35) = 0:End Sub

Sub sw45_Hit:Controller.Switch(45) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw45_UnHit:Controller.Switch(45) = 0:End Sub

Sub sw14_Hit:Controller.Switch(14) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw14_UnHit:Controller.Switch(14) = 0:End Sub

Sub sw24_Hit:Controller.Switch(24) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw24_UnHit:Controller.Switch(24) = 0:End Sub

Sub sw34_Hit:Controller.Switch(34) = 1:PlaySound "fx_sensor", 0, 1, pan(ActiveBall):End Sub
Sub sw34_UnHit:Controller.Switch(34) = 0:End Sub

' Droptargets
Sub sw13_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw23_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw33_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw43_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw53_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw63_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw54_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw64_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw74_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw42_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw52_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw62_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw2_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw12_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub
Sub sw22_Hit:PlaySound SoundFX("fx_droptarget", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub

Sub sw13_Dropped:dtbank1.Hit 1:End Sub
Sub sw23_Dropped:dtbank1.Hit 2:End Sub
Sub sw33_Dropped:dtbank1.Hit 3:End Sub
Sub sw43_Dropped:dtbank2.Hit 1:End Sub
Sub sw53_Dropped:dtbank2.Hit 2:End Sub
Sub sw63_Dropped:dtbank2.Hit 3:End Sub
Sub sw54_Dropped:dtbank3.Hit 1:End Sub
Sub sw64_Dropped:dtbank3.Hit 2:End Sub
Sub sw74_Dropped:dtbank3.Hit 3:End Sub
Sub sw42_Dropped:dtbank4.Hit 1:End Sub
Sub sw52_Dropped:dtbank4.Hit 2:End Sub
Sub sw62_Dropped:dtbank4.Hit 3:End Sub
Sub sw2_Dropped:dtbank5.Hit 1:End Sub
Sub sw12_Dropped:dtbank5.Hit 2:End Sub
Sub sw22_Dropped:dtbank5.Hit 3:End Sub

' Spinners
Sub Spinner1_Spin:vpmTimer.PulseSw 32:PlaySound SoundFX("fx_spinner", DOFContactors), 0, 1, 0.05:End Sub

'Targets
Sub sw61_Hit:vpmTimer.PulseSw 61:PlaySound SoundFX("fx_target", DOFDropTargets), 0, 1, pan(ActiveBall):End Sub

'*********
'Solenoids
'*********

SolCallback(1) = "bsTopSaucer.SolOut"
SolCallback(2) = "bsTrough.SolOut"
SolCallback(3) = "bsRightSaucer.SolOut"
SolCallback(5) = "dtbank1.SolDropUp"
SolCallback(6) = "dtbank2.SolDropUp"
SolCallback(7) = "dtbank5.SolDropUp"
SolCallback(8) = "dtbank3.SolDropUp"
SolCallback(9) = "dtbank4.SolDropUp"

SolCallback(17) = "SolGi" '17=relay
SolCallback(18) = "vpmNudge.SolGameOn"

Sub SolGi(enabled)
    If enabled Then
        GiOff
    Else
        GiOn
    End If
End Sub

'**************
' Flipper Subs
'**************

SolCallback(sLRFlipper) = "SolRFlipper"
SolCallback(sLLFlipper) = "SolLFlipper"

Sub SolLFlipper(Enabled)
    If Enabled Then
        PlaySound SoundFX("fx_flipperup", DOFFlippers), 0, 1, -0.1, 0.05
        LeftFlipper.RotateToEnd
    Else
        PlaySound SoundFX("fx_flipperdown", DOFFlippers), 0, 1, -0.1, 0.05
        LeftFlipper.RotateToStart
    End If
End Sub

Sub SolRFlipper(Enabled)
    If Enabled Then
        PlaySound SoundFX("fx_flipperup", DOFFlippers), 0, 1, 0.1, 0.05
        RightFlipper.RotateToEnd
        RightFlipper1.RotateToEnd
    Else
        PlaySound SoundFX("fx_flipperdown", DOFFlippers), 0, 1, 0.1, 0.05
        RightFlipper.RotateToStart
        RightFlipper1.RotateToStart
    End If
End Sub

Sub LeftFlipper_Collide(parm)
    PlaySound "fx_rubber_flipper", 0, parm / 10, -0.1, 0.25
End Sub

Sub RightFlipper_Collide(parm)
    PlaySound "fx_rubber_flipper", 0, parm / 10, 0.1, 0.25
End Sub

'*****************
'   Gi Effects
'*****************

Dim OldGiState
OldGiState = -1 'start witht he Gi off

Sub GiON
    For each x in aGiLights
        x.State = 1
    Next
End Sub

Sub GiOFF
    For each x in aGiLights
        x.State = 0
    Next
End Sub

Sub GiEffect(enabled)
    If enabled Then
        For each x in aGiLights
            x.Duration 2, 1000, 1
        Next
    End If
End Sub

Sub GIUpdate
    Dim tmp, obj
    tmp = Getballs
    If UBound(tmp) <> OldGiState Then
        OldGiState = Ubound(tmp)
        If UBound(tmp) = -1 Then
            GiOff
        Else
            GiOn
        End If
    End If
End Sub

'***************************************************
'       JP's VP10 Fading Lamps & Flashers
'       Based on PD's Fading Light System
' SetLamp 0 is Off
' SetLamp 1 is On
' fading for non opacity objects is 4 steps
'***************************************************

Dim LampState(200), FadingLevel(200)
Dim FlashSpeedUp(200), FlashSpeedDown(200), FlashMin(200), FlashMax(200), FlashLevel(200), FlashRepeat(200)

InitLamps()             ' turn off the lights and flashers and reset them to the default parameters
LampTimer.Interval = 10 ' lamp fading speed
LampTimer.Enabled = 1

' Lamp & Flasher Timers

Sub LampTimer_Timer()
    Dim chgLamp, num, chg, ii
    chgLamp = Controller.ChangedLamps
    If Not IsEmpty(chgLamp)Then
        For ii = 0 To UBound(chgLamp)
            LampState(chgLamp(ii, 0)) = chgLamp(ii, 1)       'keep the real state in an array
            FadingLevel(chgLamp(ii, 0)) = chgLamp(ii, 1) + 4 'actual fading step
        Next
    End If
    If VarHidden Then
        UpdateLeds
    End If
    UpdateLamps
    GIUpdate
    RollingUpdate
	BigGateP.RotX = Biggate.CurrentAngle
End Sub

Sub UpdateLamps()
    NFadeL 0, li0
    NFadeL 1, li1
    NFadeL 10, li10
    NFadeL 100, li100
    NFadeL 101, li101
    NFadeL 102, li102
    NFadeL 103, li103
    NFadeL 109, li109
    NFadeL 11, li11
    NFadeL 110, Li110
    NFadeL 111, Li111
    NFadeL 112, Li112
    NFadeL 113, li113
    NFadeL 119, li119
    NFadeL 12, li12
    NFadeL 120, li120
    NFadeL 121, li121
    NFadeL 122, li122
    NFadeL 123, li123
    NFadeL 129, li129
    NFadeL 130, li130
    NFadeL 131, li131
    NFadeL 132, li132
    NFadeL 133, li133
    NFadeL 143, li143
    NFadeL 153, li153
    NFadeL 2, li2
    NFadeL 20, li20
    NFadeL 21, li21
    NFadeL 22, li22
    NFadeL 30, li30
    NFadeL 31, li31
    NFadeL 32, li32
    NFadeL 40, li40
    NFadeL 41, li41
    NFadeL 42, li42
    NFadeL 50, li50
    NFadeL 51, li51
    NFadeL 52, li52
    NFadeL 60, li60
    NFadeL 61, li61
    NFadeL 70, li70
    NFadeL 71, li71
    NFadeL 72, li72
    NFadeLm 79, li79
    Flash 79, li79a
    NFadeLm 80, li80
    Flash 80, li80a
    NFadeL 81, li81
    NFadeL 82, li82
    NFadeL 83, li83
    NFadeL 89, li89
    NFadeLm 90, li90
    Flash 90, li90a
    NFadeLm 91, li91
    Flash 91, li91a
    NFadeL 92, li92
    NFadeL 93, li93
    NFadeL 99, li99
    'backdrop lights
    If VarHidden Then
        NFadeL 139, li139
        NFadeL 140, li140
        NFadeL 141, li141
        NFadeL 142, li142
        NFadeL 149, li149
        NFadeL 150, li150
        NFadeL 151, li151
        NFadeL 152, li152
    End If
End Sub

' div lamp subs

Sub InitLamps()
    Dim x
    For x = 0 to 200
        LampState(x) = 0        ' current light state, independent of the fading level. 0 is off and 1 is on
        FadingLevel(x) = 4      ' used to track the fading state
        FlashSpeedUp(x) = 0.2   ' faster speed when turning on the flasher
        FlashSpeedDown(x) = 0.1 ' slower speed when turning off the flasher
        FlashMax(x) = 1         ' the maximum value when on, usually 1
        FlashMin(x) = 0         ' the minimum value when off, usually 0
        FlashLevel(x) = 0       ' the intensity of the flashers, usually from 0 to 1
        FlashRepeat(x) = 20     ' how many times the flash repeats
    Next
End Sub

Sub AllLampsOff
    Dim x
    For x = 0 to 200
        SetLamp x, 0
    Next
End Sub

Sub SetLamp(nr, value)
    If value <> LampState(nr)Then
        LampState(nr) = abs(value)
        FadingLevel(nr) = abs(value) + 4
    End If
End Sub

' Lights: used for VP10 standard lights, the fading is handled by VP itself

Sub NFadeL(nr, object)
    Select Case FadingLevel(nr)
        Case 4:object.state = 0:FadingLevel(nr) = 0
        Case 5:object.state = 1:FadingLevel(nr) = 1
    End Select
End Sub

Sub NFadeLm(nr, object) ' used for multiple lights
    Select Case FadingLevel(nr)
        Case 4:object.state = 0
        Case 5:object.state = 1
    End Select
End Sub

'Lights, Ramps & Primitives used as 4 step fading lights
'a,b,c,d are the images used from on to off

Sub FadeObj(nr, object, a, b, c, d)
    Select Case FadingLevel(nr)
        Case 4:object.image = b:FadingLevel(nr) = 6                   'fading to off...
        Case 5:object.image = a:FadingLevel(nr) = 1                   'ON
        Case 6, 7, 8:FadingLevel(nr) = FadingLevel(nr) + 1            'wait
        Case 9:object.image = c:FadingLevel(nr) = FadingLevel(nr) + 1 'fading...
        Case 10, 11, 12:FadingLevel(nr) = FadingLevel(nr) + 1         'wait
        Case 13:object.image = d:FadingLevel(nr) = 0                  'Off
    End Select
End Sub

Sub FadeObjm(nr, object, a, b, c, d)
    Select Case FadingLevel(nr)
        Case 4:object.image = b
        Case 5:object.image = a
        Case 9:object.image = c
        Case 13:object.image = d
    End Select
End Sub

Sub NFadeObj(nr, object, a, b)
    Select Case FadingLevel(nr)
        Case 4:object.image = b:FadingLevel(nr) = 0 'off
        Case 5:object.image = a:FadingLevel(nr) = 1 'on
    End Select
End Sub

Sub NFadeObjm(nr, object, a, b)
    Select Case FadingLevel(nr)
        Case 4:object.image = b
        Case 5:object.image = a
    End Select
End Sub

' Flasher objects

Sub Flash(nr, object)
    Select Case FadingLevel(nr)
        Case 4 'off
            FlashLevel(nr) = FlashLevel(nr)- FlashSpeedDown(nr)
            If FlashLevel(nr) <FlashMin(nr)Then
                FlashLevel(nr) = FlashMin(nr)
                FadingLevel(nr) = 0 'completely off
            End if
            Object.IntensityScale = FlashLevel(nr)
        Case 5 ' on
            FlashLevel(nr) = FlashLevel(nr) + FlashSpeedUp(nr)
            If FlashLevel(nr)> FlashMax(nr)Then
                FlashLevel(nr) = FlashMax(nr)
                FadingLevel(nr) = 1 'completely on
            End if
            Object.IntensityScale = FlashLevel(nr)
    End Select
End Sub

Sub Flashm(nr, object) 'multiple flashers, it doesn't change anything, it just follows the main flasher
    Select Case FadingLevel(nr)
        Case 4, 5
            Object.IntensityScale = FlashLevel(nr)
    End Select
End Sub

Sub FlashBlink(nr, object)
    Select Case FadingLevel(nr)
        Case 4 'off
            FlashLevel(nr) = FlashLevel(nr)- FlashSpeedDown(nr)
            If FlashLevel(nr) <FlashMin(nr)Then
                FlashLevel(nr) = FlashMin(nr)
                FadingLevel(nr) = 0 'completely off
            End if
            Object.IntensityScale = FlashLevel(nr)
            If FadingLevel(nr) = 0 AND FlashRepeat(nr)Then 'repeat the flash
                FlashRepeat(nr) = FlashRepeat(nr)-1
                If FlashRepeat(nr)Then FadingLevel(nr) = 5
            End If
        Case 5 ' on
            FlashLevel(nr) = FlashLevel(nr) + FlashSpeedUp(nr)
            If FlashLevel(nr)> FlashMax(nr)Then
                FlashLevel(nr) = FlashMax(nr)
                FadingLevel(nr) = 1 'completely on
            End if
            Object.IntensityScale = FlashLevel(nr)
            If FadingLevel(nr) = 1 AND FlashRepeat(nr)Then FadingLevel(nr) = 4
    End Select
End Sub

' Desktop Objects: Reels & texts (you may also use lights on the desktop)

' Reels

Sub FadeR(nr, object)
    Select Case FadingLevel(nr)
        Case 4:object.SetValue 1:FadingLevel(nr) = 6                   'fading to off...
        Case 5:object.SetValue 0:FadingLevel(nr) = 1                   'ON
        Case 6, 7, 8:FadingLevel(nr) = FadingLevel(nr) + 1             'wait
        Case 9:object.SetValue 2:FadingLevel(nr) = FadingLevel(nr) + 1 'fading...
        Case 10, 11, 12:FadingLevel(nr) = FadingLevel(nr) + 1          'wait
        Case 13:object.SetValue 3:FadingLevel(nr) = 0                  'Off
    End Select
End Sub

Sub FadeRm(nr, object)
    Select Case FadingLevel(nr)
        Case 4:object.SetValue 1
        Case 5:object.SetValue 0
        Case 9:object.SetValue 2
        Case 3:object.SetValue 3
    End Select
End Sub

'Texts

Sub NFadeT(nr, object, message)
    Select Case FadingLevel(nr)
        Case 4:object.Text = "":FadingLevel(nr) = 0
        Case 5:object.Text = message:FadingLevel(nr) = 1
    End Select
End Sub

Sub NFadeTm(nr, object, message)
    Select Case FadingLevel(nr)
        Case 4:object.Text = ""
        Case 5:object.Text = message
    End Select
End Sub

'************************************
'          LEDs Display
'     Based on Scapino's LEDs
'************************************

Dim Digits(32)
Dim Patterns(11)
Dim Patterns2(11)

Patterns(0) = 0     'empty
Patterns(1) = 63    '0
Patterns(2) = 6     '1
Patterns(3) = 91    '2
Patterns(4) = 79    '3
Patterns(5) = 102   '4
Patterns(6) = 109   '5
Patterns(7) = 125   '6
Patterns(8) = 7     '7
Patterns(9) = 127   '8
Patterns(10) = 111  '9

Patterns2(0) = 128  'empty
Patterns2(1) = 191  '0
Patterns2(2) = 134  '1
Patterns2(3) = 219  '2
Patterns2(4) = 207  '3
Patterns2(5) = 230  '4
Patterns2(6) = 237  '5
Patterns2(7) = 253  '6
Patterns2(8) = 135  '7
Patterns2(9) = 255  '8
Patterns2(10) = 239 '9

'Assign 6-digit output to reels
Set Digits(0) = a0
Set Digits(1) = a1
Set Digits(2) = a2
Set Digits(3) = a3
Set Digits(4) = a4
Set Digits(5) = a5

Set Digits(6) = b0
Set Digits(7) = b1
Set Digits(8) = b2
Set Digits(9) = b3
Set Digits(10) = b4
Set Digits(11) = b5

Set Digits(12) = c0
Set Digits(13) = c1
Set Digits(14) = c2
Set Digits(15) = c3
Set Digits(16) = c4
Set Digits(17) = c5

Set Digits(18) = d0
Set Digits(19) = d1
Set Digits(20) = d2
Set Digits(21) = d3
Set Digits(22) = d4
Set Digits(23) = d5

Set Digits(24) = e0
Set Digits(25) = e1

Sub UpdateLeds
    On Error Resume Next
    Dim ChgLED, ii, jj, chg, stat
    ChgLED = Controller.ChangedLEDs(&HFF, &HFFFF)
    If Not IsEmpty(ChgLED)Then
        For ii = 0 To UBound(ChgLED)
            chg = chgLED(ii, 1):stat = chgLED(ii, 2)
            For jj = 0 to 10
                If stat = Patterns(jj)OR stat = Patterns2(jj)then Digits(chgLED(ii, 0)).SetValue jj
            Next
        Next
    End IF
End Sub

'******************************
' Diverse Collection Hit Sounds
'******************************

Sub aMetals_Hit(idx):PlaySound "fx_MetalHit2", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0:End Sub
Sub aRubber_Bands_Hit(idx):PlaySound "fx_rubber_band", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0:End Sub
Sub aRubber_Posts_Hit(idx):PlaySound "fx_rubber_post", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0:End Sub
Sub aRubber_Pins_Hit(idx):PlaySound "fx_rubber_pin", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0:End Sub
Sub aPlastics_Hit(idx):PlaySound "fx_PlasticHit", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0:End Sub
Sub aGates_Hit(idx):PlaySound "fx_Gate", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0:End Sub
Sub aWoods_Hit(idx):PlaySound "fx_Woodhit", 0, Vol(ActiveBall), pan(ActiveBall), 0, Pitch(ActiveBall), 0, 0:End Sub

' *********************************************************************
'                      Supporting Ball & Sound Functions
' *********************************************************************

Function Vol(ball) ' Calculates the Volume of the sound based on the ball speed
    Vol = Csng(BallVel(ball) ^2 / 2000)
End Function

Function Pan(ball) ' Calculates the pan for a ball based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = ball.x * 2 / table1.width-1
    If tmp> 0 Then
        Pan = Csng(tmp ^10)
    Else
        Pan = Csng(-((- tmp) ^10))
    End If
End Function

Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function

Function BallVel(ball) 'Calculates the ball speed
    BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2)))
End Function

Function AudioFade(ball) 'only on VPX 10.4 and newer
    Dim tmp
    tmp = ball.y * 2 / Table1.height-1
    If tmp> 0 Then
        AudioFade = Csng(tmp ^10)
    Else
        AudioFade = Csng(-((- tmp) ^10))
    End If
End Function

'*****************************************
'      JP's VP10 Rolling Sounds
'*****************************************

Const tnob = 20 ' total number of balls
Const lob = 0   'number of locked balls
ReDim rolling(tnob)
InitRolling

Sub InitRolling
    Dim i
    For i = 0 to tnob
        rolling(i) = False
    Next
End Sub

Sub RollingUpdate()
    Dim BOT, b, ballpitch
    BOT = GetBalls

    ' stop the sound of deleted balls
    For b = UBound(BOT) + 1 to tnob
        rolling(b) = False
        StopSound("fx_ballrolling" & b)
    Next

    ' exit the sub if no balls on the table
    If UBound(BOT) = lob - 1 Then Exit Sub 'there no extra balls on this table

    ' play the rolling sound for each ball
    For b = lob to UBound(BOT)
        If BallVel(BOT(b))> 1 Then
            If BOT(b).z <30 Then
                ballpitch = Pitch(BOT(b))
            Else
                ballpitch = Pitch(BOT(b)) + 15000 'increase the pitch on a ramp or elevated surface
            End If
            rolling(b) = True
            PlaySound("fx_ballrolling" & b), -1, Vol(BOT(b)), Pan(BOT(b)), 0, ballpitch, 1, 0
        Else
            If rolling(b) = True Then
                StopSound("fx_ballrolling" & b)
                rolling(b) = False
            End If
        End If
    Next
End Sub

'**********************
' Ball Collision Sound
'**********************

Sub OnBallBallCollision(ball1, ball2, velocity)
    PlaySound("fx_collide"), 0, Csng(velocity) ^2 / 2000, Pan(ball1), 0, Pitch(ball1), 0, 0
End Sub