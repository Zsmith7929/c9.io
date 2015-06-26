#include <ImageSearch.au3>
#include <ScreenCapture.au3>

HotKeySet("{F8}", "toggleScript")
HotKeySet("{F9}", "terminate")

; Game location properties
Global $left=0
Global $top=0
Global $right=0
Global $bottom=0

$pause = True
$stuck = False
$monitorOneWidth = 1920
$x1=0
$y1=0

Func terminate()
	; kills both scripts

	While ProcessExists("AutoIt3.exe")
		ProcessClose("juggernaut.exe")
		ProcessClose("AutoIt3.exe")
	WEnd

EndFunc

Func checkScreen()
	; Sets the boundary of the window
   Local $aPos = WinGetPos("Clicker Heroes")

   $left = $aPos[0]
   $top = $aPos[1]
   $right = $left + $aPos[2]
   $bottom = $top + $aPos[3]
EndFunc

Func getScreenshot()

	_ScreenCapture_Capture("screen.jpg", 2219, 62, 2503, 104, False)
	;ShellExecute("screen.jpg") ;Debug feature to pop up the picture captured
EndFunc

Func findScreenshot($filename)

	$result = _ImageSearchArea($filename, 1, $left, $top, $right, $bottom, $x1, $y1, 100)
	$x1 = $x1 - $monitorOneWidth
	If $result = 1 Then
		ControlClick("Clicker Heroes","", "", "Left",2, $x1, $y1)
		Sleep(300)
	EndIf
EndFunc

Func farmModeOff()
	checkScreen()
	Sleep(300)
	$result = _ImageSearchArea("images/farm.png", 1, $left, $top, $right, $bottom, $x1, $y1, 100)
	If $result = 1 Then
		Sleep(300)
		ControlClick("Clicker Heroes","", "", "Left",1, 1519, 335)
		Sleep(300)
	Else
	EndIf
EndFunc

Func findFish()
   $result = _ImageSearchArea("images/fish2.png", 1, $left, $top, $right, $bottom, $x1, $y1, 125)
   $x1 = $x1 - $monitorOneWidth
	  If $result = 1 Then
		 ;MsgBox(0,"Fish Result","find the feesh at x:" & $x1 & " y:" & $y1 & " ", 5)
		 ControlClick("Clicker Heroes","", "", "Left",5,$x1,$y1)
		 Sleep(300)
		 ControlClick("Clicker Heroes","", "", "Left",5,$x1,$y1)
	  EndIf
EndFunc

Func toggleScript()
	If $pause = True Then
		$pause = False
	Else
		$pause = True
	EndIf
EndFunc


Run("juggernaut.exe") ; KEEP JUGGERNAUT ALIVE SCRIPT, runs separately

While 1

	If $pause = False Then


		Sleep(300)
		farmModeOff()
		Sleep(300)
		ControlSend("Clicker Heroes","", "", "6")

		; Try to upgrade errthang

		Sleep(300)
		ControlClick("Clicker Heroes", "", "", "left", 2, 781, 342) ; SCROLL UP
		Sleep(500)
		ControlClick("Clicker Heroes", "", "", "left", 2, 780, 790) ; SCROLL DOWN
		Sleep(500)


		; "Buy Available Upgrades"
		checkScreen()
		findScreenshot("images/upgrade.png")

		Sleep(300)

		ControlClick("Clicker Heroes", "", "", "left", 10, 185, 646) ; LEVEL
		Sleep(300)
		ControlClick("Clicker Heroes", "", "", "left", 10, 183, 504) ; LEVEL
		Sleep(300)
		ControlClick("Clicker Heroes", "", "", "left", 10, 180, 368) ; LEVEL
		Sleep(500)

		ControlClick("Clicker Heroes", "", "", "left", 2, 781, 342) ; SCROLL UP
		Sleep(300)


		;Check for presents!
		$present = _ImageSearchArea("images/present.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
		Sleep(300)

		If $present == 1 Then
				$x1 = $x1 - $monitorOneWidth
			ControlClick("Clicker Heroes","", "", "Left",5,$x1,$y1)
			Sleep(1000)
			ControlClick("Clicker Heroes","", "", "Left",5,807, 472)
			Sleep(1000)
			ControlClick("Clicker Heroes","", "", "Left",5,1267, 168)
			Sleep(300)
			checkScreen()
			$result = _ImageSearchArea("images/X.png", 1, 3033, 120, 3324, 254, $x1, $y1, 100)
			$x1 = $x1 - $monitorOneWidth
			If $result == 1 Then
				ControlClick("Clicker Heroes","", "", "Left",5,$x1,$y1)
			EndIf


			EndIf


		For $x = 0 To 2 Step 1 ;40


			; Check for fish
			checkScreen()
			findFish()
			Sleep(300)
			If $pause = False Then

				; Use activatables
				checkScreen()
				$golden = _ImageSearchArea("images/Golden.png", 1, $left, $top, $right, $bottom, $x1, $y1, 100)
				If $golden == 1 Then
					ControlSend("Clicker Heroes","", "", "1")
					Sleep(100)
					ControlSend("Clicker Heroes","", "", "4")
					Sleep(100)
					ControlSend("Clicker Heroes","", "", "8")
					Sleep(100)
					ControlSend("Clicker Heroes","", "", "5")
					Sleep(100)

				EndIf


				$boss = _ImageSearchArea("images/Boss.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
				If $boss == 1 Then
					ControlSend("Clicker Heroes","", "", "7")
					Sleep(100)
					ControlSend("Clicker Heroes","", "", "3")
					Sleep(100)
					ControlSend("Clicker Heroes","", "", "2")
					Sleep(100)
					ControlSend("Clicker Heroes","", "", "1")
					Sleep(100)
				EndIf


				; Click loop
				For $i = 0 To 1000 Step 1
					If $pause = False Then
						ControlClick("Clicker Heroes", "", "", "left", 1, 1173, 511)
						Sleep(1)
					EndIf

				Next
			EndIf
		Next
	Else
		Sleep(1000)
	EndIf
WEnd
