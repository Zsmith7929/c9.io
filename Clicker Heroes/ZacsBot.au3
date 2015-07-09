#include <ImageSearch.au3>
#include <ScreenCapture.au3>
#include <Date.au3>

HotKeySet("{F8}", "toggleScript")
HotKeySet("{F9}", "terminate")
HotKeySet("{F10}", "ascend")

AutoItSetOption("SendCapslockMode",0) ; Prevent controlSend from activating the caps lock key

; Game location properties
Global $left=0
Global $top=0
Global $right=0
Global $bottom=0

$handle = WinGetHandle("Clicker Heroes")
$levelTick = 0
$bossFail = 0
$pause = True
$stuck = False
$monitorOneWidth = 1920
$x1=0
$y1=0
$x2=0
$y2=0

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

Func _RunAU3($sFilePath, $sWorkingDir = "", $iShowFlag = @SW_SHOW, $iOptFlag = 0)
	Return Run('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $sFilePath & '"', $sWorkingDir, $iShowFlag, $iOptFlag)
EndFunc   ;==>_RunAU3

Func getScreenshot()

	_ScreenCapture_Capture("screen.jpg", 2219, 62, 2503, 104, False)
	;ShellExecute("screen.jpg") ;Debug feature to pop up the picture captured
EndFunc

Func findScreenshot($filename)

	$result = _ImageSearchArea($filename, 1, $left, $top, $right, $bottom, $x1, $y1, 100)
	$x1 = $x1 - $monitorOneWidth
	If $result = 1 Then
		ControlClick($handle,"", "", "Left",2, $x1, $y1)
		Sleep(300)
	EndIf
EndFunc

Func farmModeOff()
	checkScreen()
	Sleep(300)
	$result = _ImageSearchArea("images/farm.png", 1, $left, $top, $right, $bottom, $x1, $y1, 100)
	If $result = 1 Then
		Sleep(300)
		ControlClick($handle,"", "", "Left",1, 1519, 335)
		Sleep(300)
		$bossFail = $bossFail + 1
	Else
	EndIf
EndFunc

Func findFish()
   $result = _ImageSearchArea("images/fish2.png", 1, $left, $top, $right, $bottom, $x1, $y1, 125)
   $x1 = $x1 - $monitorOneWidth
	  If $result = 1 Then
		 ;MsgBox(0,"Fish Result","find the feesh at x:" & $x1 & " y:" & $y1 & " ", 5)
		 ControlClick($handle,"", "", "Left",5,$x1,$y1)
		 Sleep(300)
		 ControlClick($handle,"", "", "Left",5,$x1,$y1)
	  EndIf
EndFunc

Func toggleScript()
	If $pause = True Then
		$pause = False
	Else
		$pause = True
	EndIf
EndFunc

Func upgrade($image, $mass=True, $checkRed=True, $click=True)

	checkScreen()
	ControlSend($handle,"", "", "{CTRLDOWN}")
	Sleep(500)
	$fail = 0
	ControlClick($handle, "", "", "left", 1, 1173, 511) ; Move cursor
	Sleep(500)
	ControlClick($handle, "", "", "left", 2, 781, 290) ; SCROLL UP
	Sleep(500)
	While $fail < 40
		If $mass == True Then
			$level = _ImageSearchArea("images/x100.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
		Else
			$level = _ImageSearchArea($image, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
		EndIf

		If $level == 1 And ($bottom - $top) > 175 Then
			;MsgBox(0,"a","found one-- top: " & $top & " bottom: " & $bottom)

			If $checkRed == True Then

				Local $red = PixelSearch($x1-100, $y1, $x1+100, $y1+100, 0xFE8743, 10, 1, $handle)

				If @error == 0 Then
					;MsgBox(0,"a","found red. current top: " & $top & "new top: " & $red[1])
					$top = $red[1]
					$fail = $fail + 1
				Else
					$x1 = $x1 - $monitorOneWidth
					;MsgBox(0,"a","trying to click x:" & $x1 & " y:" & $y1)
					ControlClick($handle,"", "", "Left",1,$x1,$y1)
					Sleep(300)
					ControlClick($handle, "", "", "left", 1, 1173, 511)
					Sleep(300)

				EndIf

			Else
				If $click == True Then
					$x1 = $x1 - $monitorOneWidth
					;MsgBox(0,"a","trying to click x:" & $x1 & " y:" & $y1)
					ControlClick($handle,"", "", "Left",1,$x1,$y1-20)
					Sleep(300)
					Return 1

				Else
					Local $z[2]
					$x1 = $x1 - $monitorOneWidth
					$z[0] = $x1
					$z[1] = $y1
					ControlSend($handle,"", "", "{CTRLUP}")
					Sleep(300)
					Return $z
				EndIf
			EndIf

		Else
			$fail = $fail + 1
			ControlClick($handle, "", "", "left", 1, 1173, 511) ; Move cursor
			Sleep(500)
			checkScreen()
			$down = _ImageSearchArea("images/scroll.png", 1, $left, $top, $right, $bottom, $x1, $y1, 80)
			$x1 = $x1 - $monitorOneWidth
			If $down == 1 Then
				;MsgBox(0,"a","trying to scroll at x:" & $x1 & " y:" & $y1+60)
				ControlClick($handle,"", "", "Left",1,$x1,$y1+37)
				Sleep(1000)
			Else
				;MsgBox(0,"a","couldn't find the scroll bar")
			EndIf

		EndIf
	WEnd
	ControlSend($handle,"", "", "{CTRLUP}")

	Sleep(300)
	ControlClick($handle, "", "", "left", 2, 781, 450) ; SCROLL UP
	Sleep(500)
	ControlClick($handle, "", "", "left", 2, 780, 790) ; SCROLL DOWN
	Sleep(500)

	; "Buy Available Upgrades"
	checkScreen()
	findScreenshot("images/upgrade.png")

	Sleep(300)

	checkScreen()
	Local $z[2]
	$z[0] = 0
	$z[1] = 0
	Return $z

EndFunc

Func gildedUpgrade($filename)
	$samurai = upgrade($filename, False, False, False)
	ControlSend($handle,"", "", "{CTRLDOWN}")
	If $samurai[0] > 0 Then
		For $i = 0 To 5 Step 1
			ControlClick($handle, "", "", "left", 1, $samurai[0]-350, $samurai[1]+40)
			Sleep(300)
		Next
	EndIf
	ControlSend($handle,"", "", "{CTRLUP}")
	ControlClick($handle, "", "", "left", 2, 781, 450) ; SCROLL UP
	Sleep(500)

EndFunc

Func ascend()
	;salvage before ascending
	checkScreen()
	;MsgBox(0,"ascend","starting ascension ")
	$relic = _ImageSearchArea("images/relic.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
	If $relic == 1 Then
		Local $newX1 = $x1-$monitorOneWidth
		;MsgBox(0,"ascend","relic at x: " & $newX1 & " y: " & $y1)
		_ScreenCapture_Capture("relic.png",$x1-10, $y1-10, $x1+10, $y1+10)
		Sleep(300)
		ControlClick($handle,"", "", "Left",5,$newX1,$y1-25)
		Sleep(500)
		;hit the salvage button
		$salvage = _ImageSearchArea("images/salvage.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
		If $salvage == 1 Then
			;MsgBox(0,"ascend","salvage")
			Sleep(300)
			ControlClick($handle,"", "", "Left",1,$x1-$monitorOneWidth,$y1-20)
			Sleep(500)
			;confirm salvage
			$yes = _ImageSearchArea("images/yes.png", 1, $left, $top, $right, $bottom, $x1, $y1, 100)
			If $yes == 1 Then
				;MsgBox(0,"ascend","yes ")
				ControlClick($handle,"", "", "Left",1,$x1-$monitorOneWidth,$y1-20)
				Sleep(300)
				ControlClick($handle,"", "", "Left",1,$x1-$monitorOneWidth,$y1-20)
				Sleep(500)

			Else
				Return
			EndIf

		EndIf

	Else
		Return
	EndIf

	;back to the main page
	$main = _ImageSearchArea("images/main.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
	If $main == 1 Then
		Sleep(300)
		ControlClick($handle,"", "", "Left",1,$x1-$monitorOneWidth,$y1-20)
		Sleep(500)
		ControlClick($handle,"", "", "Left",1,$x1-$monitorOneWidth,$y1-20)
		Sleep(500)
		;search for amenhotep to ascend
		$ascend = upgrade("images/ascend.png", False, False, True)
		If $ascend > 0 Then
			Sleep(1000)
			$yes = _ImageSearchArea("images/yesascend.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
			If $yes == 1 Then
				;MsgBox(0,"ascend","yes ")
				Sleep(300)
				ControlClick($handle,"", "", "Left",1,$x1-$monitorOneWidth,$y1-20)
				Sleep(500)
				farmModeOff()
				Sleep(300)
				$levelTick = 0
				$bossFail = 0
				FileWriteLine("ascendlog.txt", "Ascended at: " & _DateTimeFormat(_NowCalc(), 1) & " " & _NowTime())

			Else
				Return
			EndIf

		Else
			Return
		EndIf


	Else
		Return
	EndIf

EndFunc


Run("juggernaut.exe") ; KEEP JUGGERNAUT ALIVE SCRIPT, runs separately
;_RunAU3("juggernaut.exe")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

While 1

	If $pause = False Then

		$result = _ImageSearchArea("images/x4.png", 1, 3033, 120, 3324, 254, $x1, $y1, 100)
		If $result == 1 Then
			ControlClick($handle,"", "", "Left",5,$x1,$y1)
			Sleep(300)
		EndIf

		$result = _ImageSearchArea("images/x.png", 1, 3033, 120, 3324, 254, $x1, $y1, 100)
		If $result == 1 Then
			ControlClick($handle,"", "", "Left",5,$x1,$y1)
			Sleep(300)
		EndIf

		$result = _ImageSearchArea("images/x2.png", 1, 3033, 120, 3324, 254, $x1, $y1, 100)
		If $result == 1 Then
			ControlClick($handle,"", "", "Left",5,$x1,$y1)
			Sleep(300)
		EndIf

		$result = _ImageSearchArea("images/x3.png", 1, 3033, 120, 3324, 254, $x1, $y1, 100)
		If $result == 1 Then
			ControlClick($handle,"", "", "Left",5,$x1,$y1)
			Sleep(300)
		EndIf


		If $bossFail < 24 Then
			checkScreen()
			findFish()
			Sleep(300)
		EndIf


		Sleep(300)
		farmModeOff()
		Sleep(300)
		ControlSend($handle,"", "", "6")
		Sleep(300)
		ControlSend($handle,"", "", "9")

		; Try to upgrade errthang

		Sleep(300)

		gildedUpgrade("images/atlas.png")

		ControlClick($handle, "", "", "left", 2, 781, 450) ; SCROLL UP
		Sleep(300)

		If Mod($levelTick, 10) == 0 Then
			Sleep(500)
			If $bossFail > 25 Then
				ascend()
			Else
				upgrade(0)
			EndIf
		EndIf


		;Check for presents!
		$present = _ImageSearchArea("images/present.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
		Sleep(300)

		If $present == 1 Then
				$x1 = $x1 - $monitorOneWidth
			ControlClick($handle,"", "", "Left",5,$x1,$y1)
			Sleep(1000)
			ControlClick($handle,"", "", "Left",5,807, 472)
			Sleep(1000)
			ControlClick($handle,"", "", "Left",5,1267, 168)
			Sleep(300)
			checkScreen()
			$result = _ImageSearchArea("images/X.png", 1, 3033, 120, 3324, 254, $x1, $y1, 100)
			$x1 = $x1 - $monitorOneWidth
			If $result == 1 Then
				ControlClick($handle,"", "", "Left",5,$x1,$y1)
			EndIf


			EndIf


		For $x = 0 To 2 Step 1 ;40


			; Check for fish

			If $bossFail < 24 Then
				checkScreen()
				findFish()
				Sleep(300)
			EndIf

			If $pause = False Then

				; Use activatables
				checkScreen()
				$golden = _ImageSearchArea("images/Golden.png", 1, $left, $top, $right, $bottom, $x1, $y1, 100)
				If $golden == 1 Then
					ControlSend($handle,"", "", "1")
					Sleep(100)
					ControlSend($handle,"", "", "4")
					Sleep(100)
					ControlSend($handle,"", "", "8")
					Sleep(100)
					ControlSend($handle,"", "", "5")
					Sleep(100)

				EndIf


				$boss = _ImageSearchArea("images/Boss.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
				If $boss == 1 Then
					ControlSend($handle,"", "", "7")
					Sleep(100)
					ControlSend($handle,"", "", "3")
					Sleep(100)
					ControlSend($handle,"", "", "2")
					Sleep(100)
					ControlSend($handle,"", "", "1")
					Sleep(100)
				EndIf


				; Click loop
				For $i = 0 To 1000 Step 1
					If $pause = False Then
						ControlClick($handle, "", "", "left", 1, 1173, 511)
						Sleep(1)
					EndIf

				Next
			EndIf
		Next

		$levelTick = $levelTick + 1

	Else
		Sleep(1000)
	EndIf

WEnd
