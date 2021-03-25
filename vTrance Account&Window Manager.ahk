#NoEnv
#SingleInstance force
SetBatchLines, -1
Process, Priority,, High
SendMode Input
SetWorkingDir %A_ScriptDir%
SetKeyDelay 0
SetMouseDelay 0
SetTitleMatchMode 1
CoordMode, Mouse, Window
CoordMode, Pixel, Window

#Include %A_ScriptDir%\Includes\oINI.ahk

Global oINI := oINI_Load(A_ScriptDir "\Config.ini"), DofusPath := oINI["Config", "Path"], DofusTotal := oINI["Config", "AccountTotal"], DofusData := {}, Selected := oINI["Config", "LastActive"]


;For section, sections in oINI
    ;For key, value in sections
        ;msgbox in For-loop: [%section%] %key% `, %value% 

/* For Key, value in oINI.DofusAccount1
 * 	MsgBox % Key "|" Value
 */
; Write: oINI.SectionD.key_a := "value 8"
; Read: MsgBox % oINI.DofusAccount1.AccountName


Gui, +LastFound
Menu, LVContextMenu, Add, Add Account, AddAccount
Menu, LVContextMenu, Add, Edit Account, EditAccount
Menu, LVContextMenu, Add, Remove Account, RemoveAccount
Menu, LVContextMenu, Add, Move Up, MovUp
Menu, LVContextMenu, Add, Move Down, MovDown
Gui, Add, ListView, x2 y29 w480 h180 NoSortHdr -LV0x10 -LV0x20 vmylistview, Account|Password|X|Y|W|H|Character
	LV_Modifycol(1, 120)
	LV_Modifycol(2, 60)
	LV_Modifycol(3, 40)
	LV_Modifycol(4, 40)
	LV_Modifycol(5, 40)
	LV_Modifycol(6, 40)
	LV_Modifycol(7, 120)
For Section, Sections in oINI
	If (Section != "Config")
		LV_Add("", oINI[Section, "AccountName"], "******", oINI[Section, "WindowX"], oINI[Section, "WindowY"], oINI[Section, "WindowW"], oINI[Section, "WindowH"], oINI[Section, "CharacterSelected"])
Gui, Add, Button, x2 y-1 w100 h30 gLaunch, Launch Selected
Gui, Add, Button, x112 y-1 w100 h30 gSave, Save Positions
Gui, Add, Button, x224 y-1 w75 h25 gRefresh, Refresh Table
Gui, Character:Add, GroupBox, x-8 y-1 w200 h200 , Character
Gui, Character:Add, Text, x12 y49 w70 h20 , Account:
Gui, Character:Add, Text, x12 y69 w70 h20 , Password:
Gui, Character:Add, Text, x12 y89 w70 h20 , Character:
Gui, Character:Add, Text, x12 y109 w70 h20 , Position X
Gui, Character:Add, Text, x12 y129 w70 h20 , Position Y
Gui, Character:Add, Text, x12 y149 w70 h20 , Position W:
Gui, Character:Add, Text, x12 y169 w70 h20 , Position H:
Gui, Character:Add, Edit, x82 y49 w100 h20 vAccountLogin, 
Gui, Character:Add, Edit, x82 y69 w100 h20 vAccountPassword, Edit3
Gui, Character:Add, Edit, x82 y109 w100 h20 vPositonX, Edit4
Gui, Character:Add, Edit, x82 y129 w100 h20 vPositonY, Edit5
Gui, Character:Add, Edit, x82 y149 w100 h20 vPositonW, Edit6
Gui, Character:Add, Edit, x82 y169 w100 h20 vPositonH, Edit7
Gui, Character:Add, Button, w100 h20 gAddCharacter, Add Character
Gui, Character:Add, Button, w100 h20 gCharacterGUISave, Save n Close
Gui, Character:Add, DropDownList, x82 y89 w100 h20 R5 vCharacters
Gui, Add, Button, x2 y212 w100 h25 gAstrub, Return To Astrub
Gui, Add, Button, x104 y212 w100 h25 gPoints, View Points
Gui, Add, Button, x206 y212 w100 h25 gClose, Close All
Gui, Show, Center AutoSize, vTrance Account Manager - v2.0.0
Return

Close:
WinGet, id, list, ahk_exe dofus.dll
Loop, %id%
{
    this_id := id%A_Index%
    WinGetTitle, this_title, ahk_id %this_id%
	winclose, %this_title%
}
Return

Return:
Return

GuiContextMenu:
ConTextMenuControl := A_GuiControl
if (A_GuiControl = "mylistview")
{
   Menu, LVContextMenu, Show, %A_GuiX%, %A_GuiY%
   Return
}
Return

^Escape::
GuiClose:
ExitApp

CharacterGUISave:
Gui, Character:Submit
oINI["DofusAccount" SelectedAccount, "AccountName"] := AccountLogin
oINI["DofusAccount" SelectedAccount, "Password"] := AccountPassword
RegExMatch(Characters, ".*\/", Name)
oINI["DofusAccount" SelectedAccount, "CharacterSelected"] := RegExReplace(Name, "\/")
oINI["DofusAccount" SelectedAccount, "WindowX"] := PositionX
oINI["DofusAccount" SelectedAccount, "WindowY"] := PositionY
oINI["DofusAccount" SelectedAccount, "WindowW"] := PositionW
oINI["DofusAccount" SelectedAccount, "WindowH"] := PositionH
oINI.SetPath(A_ScriptDir "\Config.ini")
oINI.Save()
RefreshList()
Return

Refresh:
RefreshList()
Return

Launch:
DofusData := {}
RowNumber = 0  ; This causes the first loop iteration to start the search at the top of the list.
Selected := ""
Loop {
    RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
    if not RowNumber  ; The above returned zero, so there are no more selected rows.
        break
	Selected := Selected "," RowNumber
	Run, %DofusPath%, , , NewPID
	Sleep, 550
	MouseClick, Left, 690, 210
	WinGet, aHandle, ID, ahk_exe dofus.dll
	oINI["DofusAccount" RowNumber, "Handle"] := aHandle
	DofusData.Insert(RowNumber, {Name: oINI["DofusAccount" RowNumber, "CharacterSelected"], Handle: aHandle, Launched: "No"})
	WinSetTitle, ahk_id %aHandle%, , % "Dofus-" DofusData[RowNumber].Name	
}
oINI["Config", "LastActive"] := Selected
TotalComplete := 0
CheckAcc := 1
While (TotalComplete != LV_GetCount("Selected"))
{
	Loop, Parse, Selected, , `,
	{
		WinActivate, % "ahk_id " DofusData[A_LoopField].Handle
		Sleep, 300
		If (DofusData[A_LoopField].Launched = "No")
		{
			If (fImage(130, 345, 190, 390, A_ScriptDir "\Images\Play.png") = 0)
			{
				MouseClick, Left, 255, 240
				Sleep, 300
				Send, ^a
				Sleep, 300
				Send, {Backspace}
				Name := oINI["DofusAccount" A_LoopField, "AccountName"]
				Send, %Name%
				Sleep, 500
				MouseClick, Left, 255, 305
				Sleep, 300
				Send, ^a
				Sleep, 300
				Send, {Backspace}
				Pass := oINI["DofusAccount" A_LoopField, "Password"]
				Send, %Pass%
				Sleep, 500
				MouseClick, Left, 160, 365
			}
			If (fImage(55, 240, 180, 450, A_ScriptDir "\Images\Server.png") = 0)
			{
				MouseClick, Left, 125, 350, 2
				Sleep, 1500
			}
			If (fImage(320, 470, 420, 500, A_ScriptDir "\Images\Character.png") = 0)
			{
				RegExMatch(oINI["DofusAccount" A_LoopField, "CharacterTotal"], oINI["DofusAccount" A_LoopField, "CharacterSelected"] ".*\|\|", Answer)
				RegExMatch(Answer, "\/.*", Answer)
				RegExReplace(RegExReplace(Answer, "\|\|"), "\/")
				Sleep, 500
				If (RegExReplace(RegExReplace(Answer, "\|\|"), "\/") = 1)
					MouseClick, Left, 115, 350, 2 ; Slot 1
				If (RegExReplace(RegExReplace(Answer, "\|\|"), "\/") = 2)
					MouseClick, Left, 245, 350, 2 ; Slot 2
				If (RegExReplace(RegExReplace(Answer, "\|\|"), "\/") = 3)
					MouseClick, Left, 375, 350, 2 ; Slot 3
				If (RegExReplace(RegExReplace(Answer, "\|\|"), "\/") = 4)
					MouseClick, Left, 510, 350, 2 ; Slot 4
				If (RegExReplace(RegExReplace(Answer, "\|\|"), "\/") = 5)
					MouseClick, Left, 645, 350, 2 ; Slot 5
				Sleep, 500
				DofusData[A_LoopField].Launched := "Yes"
				WinMove, % "ahk_id " DofusData[A_LoopField].Handle, , % oINI["DofusAccount" A_LoopField, "WindowX"], % oINI["DofusAccount" A_LoopField, "WindowY"], % oINI["DofusAccount" A_LoopField, "WindowW"], % oINI["DofusAccount" A_LoopField, "WindowH"]
				TotalComplete++
				Sleep, 1500
			}
		}
	}
}
oINI.SetPath(A_ScriptDir "\Config.ini")
oINI.Save()
RefreshList()
Return

Save:
	Loop, Parse, Selected, , `,
	{
		This_ID := DofusData[A_LoopField].Handle
		WinGetPos, PositionX, PositionY, PositionW, PositionH, ahk_id %This_ID%
		oINI["DofusAccount" A_LoopField, "WindowX"] := PositionX
		oINI["DofusAccount" A_LoopField, "WindowY"] := PositionY
		oINI["DofusAccount" A_LoopField, "WindowW"] := PositionW
		oINI["DofusAccount" A_LoopField, "WindowH"] := PositionH
	}
	oINI.SetPath(A_ScriptDir "\Config.ini")
	oINI.Save()
	RefreshList()
Return

AddAccount:
TotalAccounts := 0
For Section, Sections in oINI
	If (Section != "Config")
		TotalAccounts++
SelectedAccount := TotalAccounts + 1
oINI.Insert("DofusAccount" SelectedAccount, Object())
GuiControl, Character:, AccountLogin
GuiControl, Character:, AccountPassword
GuiControl, Character:, Characters, |
GuiControl, Character:, PositonX
GuiControl, Character:, PositonY
GuiControl, Character:, PositonW
GuiControl, Character:, PositonH
Gui, Character:Show, Center AutoSize, % " Add Character"
Return

EditAccount:
SelectedAccount := LV_GetNext("Selected")
GuiControl, Character:, AccountLogin, % oINI["DofusAccount" SelectedAccount, "AccountName"]
GuiControl, Character:, AccountPassword, % oINI["DofusAccount" SelectedAccount, "Password"]
GuiControl, Character:, Characters, % "|"oINI["DofusAccount" SelectedAccount, "CharacterTotal"]
GuiControl, Character:, PositonX, % oINI["DofusAccount" SelectedAccount, "WindowX"]
GuiControl, Character:, PositonY, % oINI["DofusAccount" SelectedAccount, "WindowY"]
GuiControl, Character:, PositonW, % oINI["DofusAccount" SelectedAccount, "WindowW"]
GuiControl, Character:, PositonH, % oINI["DofusAccount" SelectedAccount, "WindowH"]
Gui, Character:Show, Center AutoSize, % "Character - " oINI["DofusAccount" SelectedAccount, "AccountName"]
Return

RemoveAccount:
Return

AddCharacter:
InputBox, CharacterName, Adding Character, Please enter your Characters Name. This will be used for Window Title and Character Identity.
If CharacterName
{
	InputBox, CharacterSlot, Adding Character, Please enter the Character Slot #.
	If CharacterSlot
	{
		If (oINI["DofusAccount" SelectedAccount, "CharacterTotal"] = "")
		{
			oINI["DofusAccount" SelectedAccount, "CharacterTotal"] := CharacterName "/" CharacterSlot "||"
		}
		else
		{
			oINI["DofusAccount" SelectedAccount, "CharacterTotal"] := RegExReplace(oINI["DofusAccount" SelectedAccount, "CharacterTotal"], "\|\|", "|") CharacterName "/" CharacterSlot "||"
		}
		GuiControl, Character:, Characters, % "|" oINI["DofusAccount" SelectedAccount, "CharacterTotal"]
	}
}
Return

RemoveCharacter:

Return

MovUp:
	LV_MoveRow()
Return

MovDown:
	LV_MoveRow(false)
Return


^LButton::
XButton1:: ; Mouse Button #3 Click Master's Mouse X/Y on Slaves
IfWinActive, Dofus
{
	WinGet, ActiveID, ID, A
	MouseGetPos, PosX, PosY
	MouseClick, L, %PosX%, %PosY%
	Selected := oINI["Config", "LastActive"]
	Loop, Parse, Selected, , `,
	{
		This_ID := oINI["DofusAccount" A_LoopField, "Handle"]
		If (This_ID != ActiveID)
		{
			WinActivate, % "ahk_id " This_ID
			MouseClick, L, %PosX%, %PosY%
			Sleep, 50
		}
	}
	WinActivate, ahk_id %ActiveID%
	MouseMove, %PosX%, %PosY%
}
else
	MouseClick, X1
Return

^1::
IfWinActive, Dofus
{
	Astrub:
	WinGet, ActiveID, ID, A
	Send, {Enter}
	Send, {!}shop{Enter}
	Selected := oINI["Config", "LastActive"]
	Loop, Parse, Selected, , `,
	{
		This_ID := oINI["DofusAccount" A_LoopField, "Handle"]
		If (This_ID != ActiveID)
		{
			WinActivate, % "ahk_id " This_ID
			Send, {Enter}
			Send, {!}shop{Enter}
			Sleep, 50
		}
	}
	WinActivate, ahk_id %ActiveID%
	return
}
return

^2::
IfWinActive, Dofus
{
	Points:
	WinGet, ActiveID, ID, A
	Send, {Enter}
	Send, {!}points{Enter}
	Selected := oINI["Config", "LastActive"]
	Loop, Parse, Selected, , `,
	{
		This_ID := oINI["DofusAccount" A_LoopField, "Handle"]
		If (This_ID != ActiveID)
		{
			WinActivate, % "ahk_id " This_ID
			Send, {Enter}
			Send, {!}points{Enter}
			Sleep, 50
		}
	}
	WinActivate, ahk_id %ActiveID%
	return
}
return

!LButton::
XButton2::
	Loop % oINI["Config", "Clicks"]
	{
		MouseClick, Left, , , 2
		Sleep, 100
	}
Return


RefreshList() {
	Selected := ""
	Loop {
		RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
		if not RowNumber  ; The above returned zero, so there are no more selected rows.
			break
		Selected := Selected "," RowNumber
	}
	oINI := oINI_Load(A_ScriptDir "\Config.ini")
	LV_Delete()
	For Section, Sections in oINI
		If (Section != "Config")
			LV_Add("", oINI[Section, "AccountName"], "******", oINI[Section, "WindowX"], oINI[Section, "WindowY"], oINI[Section, "WindowW"], oINI[Section, "WindowH"], oINI[Section, "CharacterSelected"])
	
	oINI["Config", "LastActive"] := Selected
}

LV_MoveRow(moveup = true) {
	If moveup not in 1,0
		Return
	while x := LV_GetNext(x)
		i := A_Index, i%i% := x
	If (!i) || ((i1 < 2) && moveup) || ((i%i% = LV_GetCount()) && !moveup)
		Return
	cc := LV_GetCount("Col"), fr := LV_GetNext(0, "Focused"), d := moveup ? -1 : 1
	Loop, %i% {
		r := moveup ? A_Index : i - A_Index + 1, ro := i%r%, rn := ro + d
		Loop, %cc% {
			LV_GetText(to, ro, A_Index), LV_GetText(tn, rn, A_Index)
			LV_Modify(rn, "Col" A_Index, to), LV_Modify(ro, "Col" A_Index, tn)
		}
		LV_Modify(ro, "-select -focus"), LV_Modify(rn, "select vis")
		If (ro = fr)
			LV_Modify(rn, "Focus")
	}
}

fImage(X1:=0, X2:=0, X3:=0, X4:=0, Path="") {
	ImageSearch, PosX, PosY, %X1%, %X2%, %X3%, %X4%, %Path%
	If (ErrorLevel = 0) && (PosX != 0)
		Return ErrorLevel
	else
		Return 1
}

