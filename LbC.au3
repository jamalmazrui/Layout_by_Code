; Layout by Code (AutoIt implementation)
; Version 2.4
; October 20, 2015
; Copyright 2006 - 2015 by Jamal Mazrui
; GNU Lesser General Public License (LGPL)#include-once
#include <GUIConstants.au3>
#include <array.au3>
#include <GUIStatusBar.au3>
If not IsDeclared("SPI_GetWorkArea") Then $SPI_GetWorkArea = 48
If not IsDeclared("sSBClassSeq") Then $sSBClassSeq = "msctls_statusbar321"
If Not IsDeclared("BS_PushBUTTON") Then Global Const $BS_PushButton = 0
If Not IsDeclared("BS_RADIOBUTTON") Then Global Const $BS_RadioButton = 4
If not IsDeclared("GWL_Style") Then Global Const $GWL_Style = -16
If not IsDeclared("lbs_MultipleSel") Then Global Const $LBS_MULTIPLESEL = 8
If not IsDeclared("GWL_ExStyle") Then Global Const $GWL_ExStyle = -20

Global $nLbcCommandEcho = 1
Global Const $nLbcCharWidth = _lbcU2X(4)
Global Const $nLbcCharHeight = _lbcU2Y(8)
Global Const $nLbcHDividerPad = _lbcU2X(7)
Global Const $nLbcVDividerPad = _lbcU2X(7)
Global Const $nLbcHRelatedPad = _lbcU2X(4)
Global Const $nLbcVRelatedPad = _lbcU2X(4)
Global Const $nLbcHLabelPad = _lbcU2X(3)
Global Const $nLbcVLabelPad = _lbcU2Y(3)

Global Const $nLbcMinLabelWidth = 2 * $nLbcCharWidth
Global Const $nLbcMinButtonWidth = 8 * $nLbcCharWidth
Global Const $nLbcMinCheckboxWidth = 8 * $nLbcCharWidth
Global Const $nLbcMinRadioWidth = 8 * $nLbcCharWidth
Global Const $nLbcMinListWidth = 20 * $nLbcCharWidth
Global Const $nLbcMinListHeight = 5 * $nLbcCharHeight
Global Const $nLbcMinInputWidth = 20 * $nLbcCharWidth
Global Const $nLbcMinEditWidth = 20 * $nLbcCharWidth
Global Const $nLbcMinEditHeight = 5 * $nLbcCharHeight

Func _lbcConfirm($sTitle, $sLabel, $vVal = "n")
Local $iFlag = 3
If $vVal = "n" Then $iFlag = $iFlag + 256
$vVal = MsgBox($iFlag, $sTitle, $sLabel)
Switch $vVal
Case 6
If $nLbcCommandEcho Then _lbcSay("Yes")
$vVal = "y"
Case 7
If $nLbcCommandEcho Then _lbcSay("No")
$vVal = "n"
Case Else
If $nLbcCommandEcho Then _lbcSay("Cancel")
$vVal = ""
EndSwitch
Return $vVal
EndFunc

Func _lbcLogAppend($sFile, $sText)
Local $h = FileOpen($sFile, 1)
FileWriteLine($h, $sText)
FileClose($h)
EndFunc

Func _lbcInputBox($sTitle, $sLabel, $sValue, $sChar = "")
Local $sReturn = InputBox($sTitle, $sLabel, $sValue, $sChar)
If $nLbcCommandEcho and StringLen($sReturn) = 0 Then _lbcSay("Cancel")
Return $sReturn
EndFunc

Func _lbcRunFile($sFile)
Local $a = DllCall("shell32.dll", "Long", "ShellExecuteA", "Long", 0, "Str", "open", "Str", $sFile, "Str", "", "Str", "", "Long", @SW_Show)
EndFunc

Func _lbcChoose($sTitle, $sText, $sButtonList, $hOldForm = -1)
Local $nOldEventMode = Opt("GUIOnEventMode")
Opt("GUIOnEventMode", 0)
Local $sButton

If $hOldForm = -1 Then $hOldForm = _lbcWinGetHandle()
Local $hForm = _lbcCreate($sTitle)
If StringLen($sText) >0 Then 
_lbcCtrlCreateLabel($sText)
_lbcStartBand()
EndIf

Local $aButton = StringSplit($sButtonList, "|")
For $n = 1 to $aButton[0]
$sButton = $aButton[$n]
If $n = 1 Then
_lbcCtrlCreateButton($sButton, -1, -1, -1, -1, -1, $BS_DEFPUSHBUTTON)
Else
_lbcStartBand()
_lbcCtrlCreateButton($sButton)
EndIf
Next
Local $vIdList = _lbcClassGetIdList("Button")
Local $iWidth = _lbcCtrlGetWidth($vIdList)
_lbcCtrlSetWidth($vIdList, $iWidth)
If StringLen($sText) > 0 Then _lbcBandHCenter(1)
_lbcShow($hForm)

$sButton = ""
While 1
$msg = GUIGetMsg()
If $msg = 0 Then
ContinueLoop
ElseIf $msg >0 Then
$sButton = GUICtrlRead($msg)
ExitLoop
ElseIf $msg = $GUI_EVENT_CLOSE Then
ExitLoop
EndIf
WEnd
_lbcDelete($hForm)
_lbcSwitch($hOldForm)
Opt("GUIOnEventMode", $nOldEventMode)
If $nLbcCommandEcho Then _lbcSay(_lbcIif(StringLen($sButton) = 0, "Cancel", StringReplace($sButton, "&", "")))
Return $sButton
EndFunc

Func _lbcPick($sTitle, $sCaption, $sList, $hOldForm = -1)
Local $nOldEventMode = Opt("GUIOnEventMode")
Opt("GUIOnEventMode", 0)
Local $iDefault = 0
Local $sItem

Local $sOldDelim = Opt("GUIDataSeparatorChar")
Opt("GUIDataSeparatorChar", "|")
If $hOldForm = -1 Then $hOldForm = _lbcWinGetHandle()
Local $hForm = _lbcCreate($sTitle)
Local $vIdList = _lbcCtrlCreateList($sCaption, $sList)
ControlCommand($hForm, "", $vIdList, "SetCurrentSelection", $iDefault)
_lbcStartBand()
Local $vIdOK = _lbcCtrlCreateButton("OK", -1, -1, -1, -1, -1, $BS_DEFPUSHBUTTON)
Local $vIdCancel = _lbcCtrlCreateButton("Cancel")
_lbcBandHCenter()
_lbcShow($hForm)

While 1
$msg = GUIGetMsg()
Switch $msg
Case 0
ContinueLoop
Case $vIdOK
$sItem = ControlCommand($hForm, "", $vIdList, "GetCurrentSelection")
ExitLoop
Case $vIdCancel
ExitLoop
Case $GUI_EVENT_CLOSE
ExitLoop
EndSwitch
WEnd
_lbcDelete($hForm)
Opt("GUIDataSeparatorChar", @Cr)
_lbcSwitch($hOldForm)
Opt("GUIOnEventMode", $nOldEventMode)
If $nLbcCommandEcho Then _lbcSay(_lbcIif(StringLen($sItem) = 0, "Cancel", StringReplace($sItem, "&", "")))
Return $sItem
EndFunc

Func _lbcOutput($sTitle, $sText, $hOldForm = -1)
Local $nOldEventMode = Opt("GUIOnEventMode")
Opt("GUIOnEventMode", 0)
Local $sButton
Local $EM_SetSel = 177

If $hOldForm = -1 Then $hOldForm = _lbcWinGetHandle()
Local $hForm = _lbcCreate($sTitle)
Local $vIdEdit = _lbcCtrlCreateEdit("", $sText, -1, -1, 400, 400, BitOr($GUI_SS_Default_Edit, $WS_TabStop))
_lbcStartBand()
Local $vIdClipboard = _lbcCtrlCreateButton("&Clipboard", -1, -1, -1, -1, -1, $BS_DEFPUSHBUTTON)
Local $vIdFile = _lbcCtrlCreateButton("&File")
Local $vIdCancel = _lbcCtrlCreateButton("Cancel")
_lbcBandHCenter()
GUISetState($vIdEdit, $GUI_Focus)
GUICtrlSendMsg($vIdEdit, $EM_SetSel, 0, 0)
_lbcShow($hForm)

While 1
$msg = GUIGetMsg()
Switch $msg
Case 0
ContinueLoop
Case $vIdClipboard
If $nLbcCommandEcho Then _lbcSay("Clipboard")
$sText = GUICtrlRead($vIdEdit)
ClipPut($sText)
ExitLoop
Case $vIdFile
If $nLbcCommandEcho Then _lbcSay("File")
$sText = GUICtrlRead($vIdEdit)
Local $sFile = FileSaveDialog("Save to File", @MyDocumentsDir, "Text files (*.txt)", 16, "output.txt")
Local $h = FileOpen($sFile, 2)
FileWrite($h, $sText)
FileClose($h)
_lbcRunFile($sFile)
ExitLoop
Case $vIdCancel
If $nLbcCommandEcho Then _lbcSay("Cancel")
ExitLoop
Case $GUI_EVENT_CLOSE 
If $nLbcCommandEcho Then _lbcSay("Cancel")
ExitLoop
EndSwitch
WEnd
_lbcDelete($hForm)
_lbcSwitch($hOldForm)
Opt("GUIOnEventMode", $nOldEventMode)
EndFunc

Func _lbcHelp($sTitle, $sText, $hOldForm = -1)
Local $nOldEventMode = Opt("GUIOnEventMode")
Opt("GUIOnEventMode", 0)
Local $sButton
Local $EM_SetSel = 177

If $hOldForm = -1 Then $hOldForm = _lbcWinGetHandle()
Local $hForm = _lbcCreate($sTitle)
Local $vIdHelp = _lbcCtrlCreateEdit("", $sText, -1, -1, 400, 400, BitOr($GUI_SS_Default_Edit, $ES_ReadOnly, $WS_TabStop))
_lbcStartBand()
Local $vIdClose = _lbcCtrlCreateButton("Close", -1, -1, -1, -1, -1, $BS_DEFPUSHBUTTON)
_lbcBandHCenter()
GUISetState($vIdHelp, $GUI_Focus)
GUICtrlSendMsg($vIdHelp, $EM_SetSel, 0, 0)
_lbcShow($hForm)

While 1
$msg = GUIGetMsg()
Switch $msg
Case 0
ContinueLoop
Case $vIdClose
If $nLbcCommandEcho Then _lbcSay("Close")
ExitLoop
Case $GUI_EVENT_CLOSE 
If $nLbcCommandEcho Then _lbcSay("Cancel")
ExitLoop
EndSwitch
WEnd
_lbcDelete($hForm)
_lbcSwitch($hOldForm)
Opt("GUIOnEventMode", $nOldEventMode)
EndFunc

Func _lbcEdit($sTitle, $sText, $hOldForm = -1)
Local $nOldEventMode = Opt("GUIOnEventMode")
Opt("GUIOnEventMode", 0)
Local $sButton
Local $EM_SetSel = 177

If $hOldForm = -1 Then $hOldForm = _lbcWinGetHandle()
Local $hForm = _lbcCreate($sTitle)
Local $vIdEdit = _lbcCtrlCreateEdit("", $sText, -1, -1, 400, 400, BitOr($GUI_SS_Default_Edit, $WS_TabStop))
_lbcStartBand()
Local $vIdOK = _lbcCtrlCreateButton("OK", -1, -1, -1, -1, -1, $BS_DEFPUSHBUTTON)
Local $vIdCancel = _lbcCtrlCreateButton("Cancel")
_lbcBandHCenter()
GUISetState($vIdEdit, $GUI_Focus)
GUICtrlSendMsg($vIdEdit, $EM_SetSel, 0, 0)
_lbcShow($hForm)

$sText = ""
While 1
$msg = GUIGetMsg()
Switch $msg
Case 0
ContinueLoop
Case $vIdOK
;If $nLbcCommandEcho Then _lbcSay("OK")
$sText = GUICtrlRead($vIdEdit)
ExitLoop
Case $vIdCancel
If $nLbcCommandEcho Then _lbcSay("Cancel")
ExitLoop
Case $GUI_EVENT_CLOSE 
If $nLbcCommandEcho Then _lbcSay("Cancel")
ExitLoop
EndSwitch
WEnd
_lbcDelete($hForm)
_lbcSwitch($hOldForm)
Opt("GUIOnEventMode", $nOldEventMode)
Return $sText
EndFunc

Func _lbcCtrlSetData($vIdList, $vData, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $n, $vId
Local $aId = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
GUICtrlSetData($vId, $vData)
Next
Return $nCount
EndFunc

Func _lbcWinGetBandList($hForm= -1)
Local $i, $j
Local $vBandList

If $hForm = -1 Then $hForm = _lbcWinGetHandle()
$iCount = UBound($aLbcGroup, 1) -1
$jCount = UBound($aLbcGroup, 2) -1
For $i = 1 to $iCount 
For $j = 1 to $jCount 
$nBand = $aLbcGroup[$i][$j]
If $nBand = 0 Then 
If $j = 1 Then
ExitLoop 2
Else
ExitLoop
EndIf
EndIf
$vBandList = $vBandList & String($nBand) & "|"
Next
Next
If StringRight($vBandList, 1) = "|" Then $vBandList = StringTrimRight($vBandList, 1)
Return $vBandList
EndFunc

Func _lbcSwitch($hForm, $hOldForm = -1)
If $hOldForm = -1 Then $hOldForm = _lbcWinGetHandle()
If IsDeclared("aLbcForm") Then
Local $nCount = UBound($aLbcForm, 1) - 1
For $n = 0 to $nCount
If $aLbcForm[$n][0] = $hForm Then ExitLoop
Next
If $n <= $nCount Then
$hLbcForm = $aLbcForm[$n][0]
$aLbcGroup = $aLbcForm[$n][1]
$aLbcBand = $aLbcForm[$n][2]
EndIf
EndIf

If not IsDeclared("hLbcForm") Then Global $hLbcForm
$hLbcForm = $hForm
GUISwitch($hForm)
Return $hOldForm
EndFunc

Func _lbcWinGenCode($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $sLine, $sVar

Local $aPos = WinGetPos($hForm)
Local $aclient = WinGetClientSize($hForm)
Local $sText = WinGetTitle($hForm)
Local $nStyle = _lbcWinGetStyle($hForm)
Local $nExStyle = _lbcWinGetExStyle($hForm)
$sCode = "#Include <GUIConstants.au3>" & @CrLf
$sCode = $sCode & "#Include <GUIStatusBar.au3>" & @CrLf
;$sCode = $sCode & "$hForm = GUICreate(" & Chr(34) & $sText & Chr(34) & ", " & $aClient[0] & ", " & $aClient[1] & ", " & 
$sCode = $sCode & "$hForm = GUICreate(" & Chr(34) & $sText & Chr(34) & ", " & $aPos[2] & ", " & $aPos[3] & ", " & $aPos[0] & ", " & $aPos[1] & ", " & $nStyle & ", " & $nExStyle & ")" & @CrLf 

Local $vIdList = _lbcWinGetIdList($hForm)
Local $aId = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$sText = ControlGetText($hForm, "", $vId)
$sText = StringReplace($sText, @CrLf, "|")
$aPos = ControlGetPos($hForm, "", $vId)
$h = ControlGetHandle($hForm, "", Int($vId))
$nStyle = _lbcCtrlGetStyle($vId)
$nExStyle = _lbcCtrlGetExStyle($vId)
$vVal = GUICtrlRead($vId)
$sClass = _lbcCtrlGetClass($vId)
Switch $sClass
Case "Static"
$sLine = "GUICtrlCreateLabel(" 
Case "Button"
If BitAnd($nStyle, $BS_CHECKBOX) Then
$sLine = "GUICtrlCreateCheckbox(" 
;ElseIf BitAnd($nStyle, $BS_AutoRadioButton) And not BitAnd($nStyle, $BS_Center) And $SText <> "OK" Then
ElseIf BitAnd($nStyle, $BS_AutoRadioButton) And not BitAnd($nStyle, $BS_PushButton) and IsNumber($vVal) Then
$sLine = "GUICtrlCreateRadio(" 
Else
$sLine = "GUICtrlCreateButton(" 
EndIf
Case "Listbox"
$sLine = "GUICtrlCreateList(" 
Case "Combobox"
$sLine = "GUICtrlCreateCombo(" 
Case "Edit"
If BitAnd($nStyle, $ES_MULTILINE) Then
$sLine = "GUICtrlCreateEdit(" 
Else
$sLine = "GUICtrlCreateInput(" 
EndIf
Case Else
$sLine = "GUICtrlCreate" & $sClass & "("
EndSwitch
$sLine = $sLine & Chr(34) & $sText & Chr(34) & ", " & $aPos[0] & ", " & $aPos[1] & ", " & $aPos[2] & ", " & $aPos[3] & ", " & $nStyle & ", " & $nExStyle & ")"
If StringLen($sVar) = 0 Then
$sVar = $sText
$sVar = StringReplace($sVar, "&", "")
$sVar = StringReplace($sVar, ":", "")
$sVar = StringReplace($sVar, "-", "")
$sVar = StringReplace($sVar, "%", "")
$sVar = StringReplace($sVar, ",", "")
$sVar = StringReplace($sVar, " ", "")
$sVar = StringReplace($sVar, "/", "")
$sVar = StringReplace($sVar, "\", "")
EndIf
If not StringInStr($sText, ":") Then
$sLine = "$vId" & $sVar & " = " & $sLine
$sVar = ""
EndIf
If $sClass <> StringTrimRight($sSBClassSeq, 1) Then $sCode = $sCode & $sLine & @crlf
Next
Local $h = _lbcStatusBarGetHandle($hForm)
If $h Then 
$sCode = $sCode & "Local $aRight[2] = [" & $nLbcHDividerPad & ", -1]" & @Crlf
$sCode = $sCode & "Local $aText[2] = [" & Chr(34) & Chr(34) & ", " & Chr(34) & "Ready" & Chr(34) & "]" & @Crlf
$sCode = $sCode & "_GuiCtrlStatusBar_Create($hForm, $aRight, $aText)" & @Crlf
EndIf
$sCode = $sCode & "GUISetState(@SW_SHOW)" & @CrLf
$sCode = $sCode & "While 1" & @Crlf
$sCode = $sCode & "$MSG = GUIGetMsg()" & @Crlf
$sCode = $sCode & "Switch $MSG" & @Crlf
$sCode = $sCode & "Case 0" & @Crlf
$sCode = $sCode & "ContinueLoop" & @Crlf
If $h Then
$sCode = $sCode & "Case $GUI_EVENT_RESIZED" & @CrLf
$sCode = $sCode & "_GuiCtrlStatusBar_Resize(ControlGetHandle($hForm, " & Chr(34) & "msctls_statusbar321" & Chr(34) & ")" & @CrLf
EndIf
$sCode = $sCode & "Case $GUI_Event_Close" & @Crlf
$sCode = $sCode & "ExitLoop" & @Crlf
$sCode = $sCode & "EndSwitch" & @Crlf
$sCode = $sCode & "WEnd" & @Crlf
$sCode = $sCode & "GUIDelete()" & @Crlf
Return $sCode
EndFunc

Func _lbcGroupGetBandList($nGroup= -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $n
Local $vBandList

$nCount = UBound($aLbcGroup, 2) -1
For $n = 1 to $nCount 
$nBand = $aLbcGroup[$nGroup][$n]
If $nBand = 0 Then ExitLoop
$vBandList = $vBandList & String($nBand) & "|"
Next
If StringRight($vBandList, 1) = "|" Then $vBandList = StringTrimRight($vBandList, 1)
Return $vBandList
EndFunc

Func _lbcDelItem($sList, $sItem, $sDelim = "|")
$sList = StringReplace($sDelim & $sList & $sDelim, $sDelim & $sItem & $sDelim, $sDelim)
Return _lbcStringStrip($sList, $sDelim)
EndFunc

Func _lbcStringStrip($sText, $sDelim)
Return StringReplace(StringStripWS(StringReplace($sText, $sDelim, @lf), 3), @lf, $sDelim)
EndFunc

Func _lbcCtrlGetText($vId, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Return ControlGetText($hForm, "", Int($vId))
EndFunc

Func _lbcCtrlGetClass($vId, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $a = DllCall("user32.dll", "Long", "GetClassNameA", "Hwnd", ControlGetHandle($hForm, "", Int($vId)), "Str", "", "Long", 80)
Return $a[2]
EndFunc

Func _lbcCtrlGetBorders($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aBorder[4]
Local $vId 
Local $n, $nLeft, $nMinLeft = 1000000, $nTop, $nMinTop = 1000000, $nRight, $nMaxRight, $nBottom, $nMaxBottom


Local $aid = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
Local $aPos = ControlGetPos($hForm, "", $vId)
$nLeft = $aPos[0]
$nTop = $aPos[1]
$nRight = $aPos[0] + $aPos[2]
$nBottom = $aPos[1] + $aPos[3]
If $nLeft < $nMinLeft Then $nMinLeft = $nLeft
If $nTop < $nMinTop Then $nMinTop = $nTop
If $nRight > $nMaxRight Then $nMaxRight = $nRight
If $nBottom > $nMaxBottom Then $nMaxBottom = $nBottom
Next
If $nMinLeft = 1000000 Then $nMinLeft = 0
If $nMinTop = 1000000 Then $nMinTop = 0
$aBorder[0] = $nMinLeft
$aBorder[1] = $nMinTop
$aBorder[2] = $nMaxRight
$aBorder[3] = $nMaxBottom
Return $aBorder
EndFunc

Func _lbcCtrlGetMargins($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aMargin[4]
Local $n, $nLeftMargin = 1000000, $nTopMargin = 1000000, $nRightMargin, $nBottomMargin
Local $aBorder = _lbcCtrlGetBorders($vIdList)
Local $nLeft = $aBorder[0]
Local $nTop = $aBorder[1]
Local $nRight = $aBorder[2]
Local $nBottom = $aBorder[3]
Local $vWinIdList = _lbcWinGetIdList()
$vWinIdList = _lbcCtrlDelId($vWinIdList, $vIdList)
Local $aId = StringSplit($vWinIdList, "|")
Local $nCount = UBound($aId) -1
For $n = 1 to $nCount
$vId = Int($aId[$n])
Local $aPos = ControlGetPos($hForm, "", $vId)
If (($nTop >= $aPos[1]) and ($nTop <= $aPos[1] + $aPos[3])) or (($nbottom >= $aPos[1]) and ($nbottom <= $aPos[1] + $aPos[3])) Then
If (($nLeft > $aPos[0] + $aPos[2]) and ($nLeftMargin < $aPos[0] + $aPos[2])) Then $nLeftMargin = $aPos[0] + $aPos[2]
If (($nRight < $aPos[0]) and ($nRightMargin > $aPos[0])) Then $nRightMargin = $aPos[0]
EndIf
If (($nLeft >= $aPos[0]) and ($nLeft <= $aPos[0] + $aPos[2])) or (($nRight >= $aPos[0]) and ($nRight <= $aPos[0] + $aPos[2])) Then
If (($nTop > $aPos[1] + $aPos[3]) and ($nTopMargin < $aPos[1] + $aPos[3])) Then $nTopMargin = $aPos[1] + $aPos[3]
If (($nBottom < $aPos[1]) and ($nBottomMargin > $aPos[1])) Then $nBottomMargin = $aPos[1]
EndIf
Next
If $nLeftMargin = 1000000 Then $nLeftMargin = 0
If $nTopMargin = 1000000 Then $nTopMargin = 0
;If $nRightMargin = 0 Then $nRightMargin = $nRight + $nLbcHDividerPad
;If $nBottomMargin = 0 Then $nBottomMargin = $nBottom + $nLbcVDividerPad
If $nRightMargin = 0 or $nBottomMargin = 0 Then $aBorder = _lbcCtrlGetBorders(_lbcWinGetIdList())
If $nRightMargin = 0 Then $nRightMargin = $aBorder[2] + $nLbcHDividerPad
If $nBottomMargin = 0 Then $nBottomMargin = $aBorder[3] + $nLbcVDividerPad
$aMargin[0] = $nLeftMargin
$aMargin[1] = $nTopMargin
$aMargin[2] = $nRightMargin
$aMargin[3] = $nBottomMargin
Return $aMargin
EndFunc

Func _lbcCtrlAddId($vIdList1, $vIdList2)
Local $n
Local $sId
Local $vIdList
Local $aId = StringSplit($vIdList2, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$sId = String($aId[$n])
If Not StringInStr("|" & $vIdList1 & "|", "|" & $sId & "|") Then
$vIdList = $vIdList & $sId & "|"
EndIf
Next
$vIdList = $vIdList1 & "|" & $vIdList
If StringRight($vIdList, 1) = "|" Then $vIdList = StringTrimRight($vIdList, 1)
If StringLeft($vIdList, 1) = "|" Then $vIdList = StringTrimLeft($vIdList, 1)
Return $vIdList
EndFunc

Func _lbcCtrlDelId($vIdList1, $vIdList2)
Local $n
Local $sId
Local $vIdList
Local $Aid = StringSplit($vIdList1, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$sId = String($aId[$n])
If Not StringInStr("|" & $vIdList2 & "|" & $vIdList & "|", "|" & $sId & "|") Then
$vIdList = $vIdList & $sId & "|"
EndIf
Next
If StringRight($vIdList, 1) = "|" Then $vIdList = StringTrimRight($vIdList, 1)
Return $vIdList
EndFunc

Func _lbcCtrlGetExStyle($vId, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $h = ControlGetHandle($hForm, "", Int($vId))
Local $a = DllCall("user32.dll", "int", "GetWindowLong", "hwnd", $h, "int", $GWL_ExStyle)
Local $nExStyle = $a[0]
Return $nExStyle
EndFunc

Func _lbcCtrlDelExStyle($vIdList, $nExStyle, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $h
Local $n, $nOldExStyle, $nNewExStyle
Local $vId
Local $Aid = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$h = ControlGetHandle($hForm, "", $Vid)
$nOldExStyle = _lbcCtrlGetExStyle($vId)
If 1 Then
$nNewExStyle = BitAnd($nOldExStyle, BitNot($nExStyle))
Else
$nNewExStyle = BitOr($nOldExStyle, $nExStyle)
$nNewExStyle = BitXOr($nNewExStyle, $nExStyle)
EndIf
Local $a = DllCall("user32.dll", "int", "SetWindowLong", "hwnd", $h, "int", $GWL_ExStyle, "Int", $nNewExStyle)
Next
Return $nCount
EndFunc

Func _lbcCtrlAddExStyle($vIdList, $nExStyle, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $h
Local $n, $nOldExStyle, $nNewExStyle
Local $vId
Local $Aid = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$h = ControlGetHandle($hForm, "", $Vid)
$nOldExStyle = _lbcCtrlGetExStyle($vId)
$nNewExStyle = BitOr($nOldExStyle, $nExStyle)
Local $a = DllCall("user32.dll", "int", "SetWindowLong", "hwnd", $h, "int", $GWL_ExStyle, "Int", $nNewExStyle)
Next
Return $nCount
EndFunc

Func _lbcCtrlGetStyle($vId, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $h = ControlGetHandle($hForm, "", Int($vId))
Local $a = DllCall("user32.dll", "int", "GetWindowLong", "hwnd", $h, "int", $GWL_STYLE)
Local $nStyle = $a[0]
Return $nStyle
EndFunc

Func _lbcCtrlDelStyle($vIdList, $nStyle, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $h
Local $n, $nOldStyle, $nNewStyle
Local $vId
Local $Aid = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$h = ControlGetHandle($hForm, "", $Vid)
$nOldStyle = _lbcCtrlGetStyle($vId)
If 1 Then
$nNewStyle = BitAnd($nOldStyle, BitNot($nStyle))
Else
$nNewStyle = BitOr($nOldStyle, $nStyle)
$nNewStyle = BitXOr($nNewStyle, $nStyle)
EndIf
Local $a = DllCall("user32.dll", "int", "SetWindowLong", "hwnd", $h, "int", $GWL_STYLE, "Int", $nNewStyle)
Next
Return $nCount
EndFunc

Func _lbcCtrlAddStyle($vIdList, $nStyle, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $h
Local $n, $nOldStyle, $nNewStyle
Local $vId
Local $Aid = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$h = ControlGetHandle($hForm, "", $Vid)
$nOldStyle = _lbcCtrlGetStyle($vId)
$nNewStyle = BitOr($nOldStyle, $nStyle)
Local $a = DllCall("user32.dll", "int", "SetWindowLong", "hwnd", $h, "int", $GWL_STYLE, "Int", $nNewStyle)
Next
Return $nCount
EndFunc

Func _lbcCtrlSetStyle($vIdList, $nStyle, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $n, $vId
Local $aId = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
GUICtrlSetStyle($vId, $nStyle)
Next
Return $nCount
EndFunc

Func _lbcCtrlSetState($vIdList, $nState, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $n, $vId
Local $aId = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
GUICtrlSetState($vId, $nState)
Next
Return $nCount
EndFunc

Func _lbcClassGetIdList($sClass, $hForm = -1)
Local $n
Local $vIdList
Local $nLen = StringLen($sClass)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $sList = _lbcWinGetClassList($hForm)
Local $a = StringSplit($sList, "|")
Local $nCount = UBound($a) - 1
For $n = 1 to $nCount
If $sClass = StringLeft($a[$n], $nLen) Then 
$vIdList = $vIdList & _lbcCtrlGetIdBySeq($n) & "|"
EndIf
Next

If StringRight($vIdList, 1) = "|" Then $vIdList = StringTrimRight($vIdList, 1)
Return $vIdList
EndFunc

Func _lbcSetCol($vVal)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$nLbcCol = $nLbcCol + Int($vVal)
Else
$nLbcCol = Int($vVal)
EndIf
EndFunc

Func _lbcSetRow($vVal)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$nLbcRow = $nLbcRow + Int($vVal)
Else
$nLbcRow = Int($vVal)
EndIf
EndFunc

Func _lbcCtrlGetIdByText($sText, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $aId = DllCall("user32.dll", "Long", "GetDlgCtrlID", "Hwnd", ControlGetHandle($hForm, "", $sText))
Local $vId = $aId[0]
Return $vId
EndFunc

Func _lbcCtrlGetIdByHandle($h)
Local $aId = DllCall("user32.dll", "Long", "GetDlgCtrlID", "Hwnd", $h)
Local $vId = $aId[0]
Return $vId
EndFunc

Func _lbcCtrlGetIdByClass($sClassSeq, $hForm = -1)
Local $n
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $sList = _lbcWinGetClassList($hForm)
Local $a = StringSplit($sList, "|")
Local $nCount = UBound($a) - 1
For $n = 1 to $nCount
If $sClassSeq = $a[$n] Then Return _lbcCtrlGetIdBySeq($n)
Next
EndFunc

Func _lbcCtrlGetIdBySeq($nSeq, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $sList = _lbcWinGetClassList($hForm)
Local $a = StringSplit($sList, "|")
;_lbctest($nseq)
;_lbctest($slist)
Local $sClassSeq = $a[$nSeq]
Local $aId = DllCall("user32.dll", "Long", "GetDlgCtrlID", "Hwnd", ControlGetHandle($hForm, "", $sClassSeq))
Local $vId = $aId[0]
Return $vId
EndFunc

Func _lbcWinGetClassList($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i, $n, $nCount
Local $sList = @lf

Local $s = WinGetClassList($hForm)
$s = StringStripWS($s, 3)
Local $a = StringSplit($s, @LF)
$nCount = UBound($a) - 1
For $n = 1 to $nCount
$i = 1
While $i < 200
$s = $a[$n] & String($i)
If StringInStr($sList, @lf & $s & @lf) Then
$i = $i + 1
Else
$sList = $sList & $s & @lf
$i = 200
EndIf
WEnd
Next

$sList = StringStripWS($sList, 3)
$sList = StringReplace($sList, @lf, "|")
Return $sList
EndFunc

Func _lbcWinReSpace($hForm = -1)
Local $n

If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $nCount = UBound($aLbcBand, 1) -1
For $n = 1 to $nCount
If StringLen($aLbcBand[$n][1]) = 0 Then ContinueLoop
_lbcBandRespace($n)
Next
Return $nCount
EndFunc

Func _lbcBandReSpace($vBandList = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i, $iCount, $nBand
Local $n, $nLeft, $nTop, $nWidth, $nHeight
Local $sCaption, $sClass
Local $vId

If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
If $nBand = 1 Then
$nCol = $nLbcHDividerPad
$nRow = $nLbcVDividerPad
Else
Local $vRef = $aLbcBand[$nBand][0]
Local $vIdList = _lbcBandGetIdList(Int(StringTrimRight($vRef, 2)))
Local $aBorder = _lbcCtrlGetBorders($vIdList)
Switch StringRight($vRef, 2)
Case "hd"
$nCol = $aBorder[2] + $nLbcHDividerPad
$nRow = $aBorder[1]
Case "vr"
$nCol = $aBorder[0]
$nRow = $aBorder[3] + $nLbcVRelatedPad
;Case "vd"
Case Else
$nCol = $aBorder[0]
$nRow = $aBorder[3] + $nLbcVDividerPad
EndSwitch
EndIf
$vIdList = _lbcBandGetIdList($nBand)
Local $aId = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
Local $aPos = ControlGetPos($hForm, "", $vId)
$nLeft = $nCol
$nTop = $nRow
$nWidth = $aPos[2]
$nHeight = $aPos[3]
_lbcControlMove($hForm, "", Int($vId), $nLeft, $nTop, $nWidth, $nHeight)
If $n = $nCount Then ExitLoop

$sClass = _lbcCtrlGetClass($vId)
$sCaption = _lbcCtrlGetText($vId)
If $sClass = "Static" and StringRight($sCaption, 1) = ":" Then
$nCol = $nCol + $nWidth + $nLbcHLabelPad
Else
$nCol = $nCol + $nWidth + $nLbcHRelatedPad
EndIf
Next
Next
Return $iCount
EndFunc

Func _lbcCtrlGetGroup($vId, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Return _lbcBandGetGroup(_lbcCtrlGetBand($vId, $hForm), $hForm)
EndFunc

Func _lbcBandGetGroup($nBand = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i, $j, $nGroup

If $nBand = -1 Then $nBand = $nLbcBand
For $i = 1 to UBound($aLbcGroup, 1) -1
For $j = 1 to UBound($aLbcGroup, 2) -1
If $aLbcGroup[$i][$j] = $nBand Then 
$nGroup = $i
ExitLoop 2
EndIf
Next
Next
Return $nGroup
EndFunc

Func _lbcCtrlGetBand($vId, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i, $j, $nBand

For $i = 1 to UBound($aLbcBand, 1) -1
For $j = 1 to UBound($aLbcBand, 2) -1
If $aLbcBand[$i][$j] = $vId Then 
$nBand = $i
ExitLoop 2
EndIf
Next
Next
Return $nBand
EndFunc

Func _lbcBandEvenSpace($vBandList = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i, $n, $vId
If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
Local $vIdList = _lbcBandGetIdList($nBand)
Local $aId = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = $aId[$n]
Local $aPos = ControlGetPos($hForm, "", $vId)
$nCtrlWidth = $nCtrlWidth + $aPos[2]
Next

Local $aMargin = _lbcCtrlGetMargins($vIdList)
Local $nLeftMargin = $aMargin[1]
Local $nRightMargin = $aMargin[3]
Local $nSpace = ($nRightMargin - $nCtrlWidth) / ($nCount + 1)
Local $nCol = $nLeftMargin + $nSpace
For $n = 1 to $nCount
$vId = $aId[$n]
Local $aPos = ControlGetPos($hForm, "", $vId)
$nLeft = $nCol
$nTop = $aPos[1]
$nWidth = $aPos[2]
$nHeight = $aPos[3]
_lbcControlMove($hForm, "", Int($vId), $nLeft, $nTop, $nWidth, $nHeight)
$nCol = $nCol + $nWidth + $nSpace
Next
Next
Return $iCount
EndFunc

Func _lbcBandLJustify($vBandList = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i
If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
Local $vIdList = _lbcBandGetIdList($nBand)
Local $aBorder = _lbcCtrlGetBorders($vIdList)
Local $aMargin = _lbcCtrlGetMargins($vIdList)
Local $nLeftMarginSpace = $aBorder[0] - $aMargin[0]
Local $nDelta = $nLbcHDividerPad - $nLeftMarginSpace
Local $sDelta = String($nDelta)
If StringLeft($sDelta, 1) <> "-" Then $sDelta = "+" & $sDelta
_lbcCtrlSetLeft($vIdList, $sDelta)
Next
Return $iCount
EndFunc

Func _lbcBandRJustify($vBandList = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i
If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
Local $vIdList = _lbcBandGetIdList($nBand)
Local $aBorder = _lbcCtrlGetBorders($vIdList)
Local $aMargin = _lbcCtrlGetMargins($vIdList)
Local $nRightMarginSpace = $aMargin[2] - $aBorder[2]
Local $nDelta = $nRightMarginSpace - $nLbcHDividerPad
Local $sDelta = String($nDelta)
If StringLeft($sDelta, 1) <> "-" Then $sDelta = "+" & $sDelta
_lbcCtrlSetLeft($vIdList, $sDelta)
Next
Return $iCount
EndFunc

Func _lbcBandHCenter($vBandList = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i
If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
Local $vIdList = _lbcBandGetIdList($nBand)
Local $aBorder = _lbcCtrlGetBorders($vIdList)
Local $aMargin = _lbcCtrlGetMargins($vIdList)
Local $nLeftMarginSpace = $aBorder[0] - $aMargin[0]
Local $nRightMarginSpace = $aMargin[2] - $aBorder[2]
Local $nDelta = ($nRightMarginSpace - $nLeftMarginSpace) / 2
Local $sDelta = String($nDelta)
If StringLeft($sDelta, 1) <> "-" Then $sDelta = "+" & $sDelta
_lbcCtrlSetLeft($vIdList, $sDelta)
Next
Return $iCount
EndFunc

Func _lbcBandEvenHeight($vBandList = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i
If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
Local $vIdList = _lbcBandGetIdList($nBand)
_lbcCtrlSetHeight($vIdList, _lbcCtrlGetHeight($vIdList))
Next
Return $iCount
EndFunc

Func _lbcBandSetHeight($vBandList , $nValue, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $i
If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
Local $vIdList = _lbcBandGetIdList($nBand)
_lbcCtrlSetHeight($vIdList, $nValue)
Next
Return $iCount
EndFunc

Func _lbcWinGetIdList($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $vId, $vIdList 
Local $i, $n, $nCount
Local $sList = @lf

Local $s = WinGetClassList($hForm)
$s = StringStripWS($s, 3)
Local $a = StringSplit($s, @LF)
$nCount = UBound($a) - 1
For $n = 1 to $nCount
$i = 1
While $i < 200
$s = $a[$n] & String($i)
If StringInStr($sList, @lf & $s & @lf) Then
$i = $i + 1
Else
$sList = $sList & $s & @lf
$i = 200
EndIf
WEnd
Local $aId = DllCall("user32.dll", "Long", "GetDlgCtrlID", "Hwnd", ControlGetHandle($hForm, "", $s))
$vId = $aId[0]
If $vId Then $vIdList = $vIdList & $vId & "|"
Next

If StringRight($vIdList, 1) = "|" Then $vIdList = StringTrimRight($vIdList, 1)
Return $vIdList
EndFunc

Func _lbcGroupGetIdList($nGroup= -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $n
Local $vIdList

If $nGroup = -1 Then $nGroup = $nLbcGroup
$nCount = UBound($aLbcGroup, 2) -1
For $n = 1 to $nCount 
$nBand = $aLbcGroup[$nGroup][$n]
If $nBand = 0 Then ExitLoop
$vIdList = _lbcCtrlAddId($vIdList, _lbcBandGetIdList($nBand))
Next
Return $vIdList
EndFunc

Func _lbcBandGetIdList($vBandList = -1, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $vId, $vIdList 
Local $n, $nCount

Local $i
If $vBandList = -1 Then $vBandList = $nLbcBand
Local $aBand = StringSplit($vBandList, "|")
Local $iCount = UBound($aBand) -1
For $i = 1 to $iCount
$nBand = Int($aBand[$i])
$nCount = UBound($aLbcBand, 2) -1
For $n = 1 to $nCount 
$vId = $aLbcBand[$nBand][$n]
If IsInt($vId) And $vId > 0 Then $vIdList = $vIdList & $vId & "|"
Next
Next
If StringRight($vIdList, 1) = "|" Then $vIdList = StringTrimRight($vIdList, 1)
Return $vIdList
EndFunc

Func _lbcCtrlGetLeft($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nLeft, $nMinLeft = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nLeft = $aPos[0]
If $nLeft < $nMinLeft Then $nMinLeft = $nLeft
Next
If $nMinLeft = 1000000 Then $nMinLeft = 0
Return $nMinLeft
EndFunc

Func _lbcCtrlGetTop($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nTop, $nMinTop = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nTop = $aPos[1]
If $nTop < $nMinTop Then $nMinTop = $nTop
Next
If $nMinTop = 1000000 Then $nMinTop = 0
Return $nMinTop
EndFunc

Func _lbcCtrlGetRight($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nRight, $nMaxRight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nRight = $aPos[0] + $aPos[2]
If $nRight > $nMaxRight Then $nMaxRight = $nRight
Next
Return $nMaxRight
EndFunc

Func _lbcCtrlGetBottom($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nBottom, $nMaxBottom


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nBottom = $aPos[1] + $aPos[3]
If $nBottom > $nMaxBottom Then $nMaxBottom = $nBottom
Next
Return $nMaxBottom
EndFunc

Func _lbcCtrlGetWidth($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nLeft, $nMinLeft = 1000000, $nMaxRight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nLeft = $aPos[0]
If $nLeft < $nMinLeft Then $nMinLeft = $nLeft
$nRight = $aPos[0] + $aPos[2]
If $nRight > $nMaxRight Then $nMaxRight = $nRight
Next
Return $nMaxRight - $nMinLeft
EndFunc

Func _lbcCtrlGetHeight($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nTop, $nMinTop = 1000000, $nMaxBottom


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nTop = $aPos[1]
If $nTop < $nMinTop Then $nMinTop = $nTop
$nBottom = $aPos[1] + $aPos[3]
If $nBottom > $nMaxBottom Then $nMaxBottom = $nBottom
Next
Return $nMaxBottom - $nMinTop
EndFunc

Func _lbcCtrlGetHCenter($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nLeft, $nMinLeft, $nMaxRight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nLeft = $aPos[0]
If $nLeft < $nMinLeft Then $nMinLeft = $nLeft
$nRight = $aPos[0] + $aPos[2]
If $nRight > $nMaxRight Then $nMaxRight = $nRight
Next
Return ($nMinLeft + $nMaxRight) / 2
EndFunc

Func _lbcCtrlGetVCenter($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nTop, $nMinTop, $nMaxBottom


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nTop = $aPos[1]
If $nTop < $nMinTop Then $nMinTop = $nTop
$nBottom = $aPos[1] + $aPos[3]
If $nBottom > $nMaxBottom Then $nMaxBottom = $nBottom
Next
Return ($nMinTop + $nMaxBottom) /2
EndFunc

Func _lbcCtrlGetLeftmost($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId, $vIdLeftmost 
Local $n, $nCount, $nLeft, $nMinLeft = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nLeft = $aPos[0]
If $nLeft < $nMinLeft Then 
$nMinLeft = $nLeft
$vIdLeftmost = $vId
EndIf
Next
If $nMinLeft = 1000000 Then $nMinLeft = 0
Return $vIdLeftmost
EndFunc

Func _lbcCtrlGetTopmost($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId, $vIdTopmost 
Local $n, $nCount, $nTop, $nMinTop = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nTop = $aPos[1]
If $nTop < $nMinTop Then 
$nMinTop = $nTop
$vIdTopmost = $vId
EndIf
Next
If $nMinTop = 1000000 Then $nMinTop = 0
Return $vIdTopmost
EndFunc

Func _lbcCtrlGetRightmost($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nRight, $nMaxRight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nRight = $aPos[0] + $aPos[2]
If $nRight > $nMaxRight Then 
$nMaxRight = $nRight
$vIdRightmost = $vId
EndIf
Next
Return $vIdRightmost
EndFunc

Func _lbcCtrlGetBottommost($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId, $vIdBottommost 
Local $n, $nCount, $nBottom, $nMaxBottom


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nBottom = $aPos[1] + $aPos[3]
If $nBottom > $nMaxBottom Then 
$nMaxBottom = $nBottom
$vIdBottommost = $vId
EndIf
Next
Return $vIdBottommost
EndFunc

Func _lbcCtrlGetWidest($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId, $vIdWidest 
Local $n, $nCount, $nWidth, $nMaxWidth


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nWidth = $aPos[2]
If $nWidth > $nMaxWidth Then 
$nMaxWidth = $nWidth
$vIdWidest = $vId
EndIf
Next
Return $vIdWidest
EndFunc

Func _lbcCtrlGetNarrowest($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId, $vIdNarrowest
Local $n, $nCount, $nWidth, $nMinWidth = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nWidth = $aPos[2]
If $nWidth < $nMinWidth Then 
$nMinWidth = $nWidth
$vIdNarrowest = $vId
EndIf
Next
Return $vIdNarrowest
EndFunc

Func _lbcCtrlGetTallest($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId, $vIdTallest 
Local $n, $nCount, $nHeight, $nMaxHeight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nHeight = $aPos[3]
If $nHeight > $nMaxHeight Then 
$nMaxHeight = $nHeight
$vIdTallest = $vId
EndIf
Next
Return $vIdTallest
EndFunc

Func _lbcCtrlGetShortest($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId, $vIdShortest
Local $n, $nCount, $nHeight, $nMinHeight = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
$nHeight = $aPos[2]
If $nHeight < $nMinHeight Then 
$nMinHeight = $nHeight
$vIdShortest = $vId
EndIf
Next
Return $vIdShortest
EndFunc

Func _lbcCtrlSetLeft($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nLeft, $nMinLeft = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[0] = $aPos[0] + Int($vVal)
Else
$aPos[0] = Int($vVal)
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcCtrlSetTop($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nTop, $nMinTop = 1000000


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[1] = $aPos[1] + Int($vVal)
Else
$aPos[1] = Int($vVal)
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcCtrlSetRight($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nRight, $nMaxRight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[0] = $aPos[0] + Int($vVal)
Else
$aPos[0] = Int($vVal) - $aPos[2]
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcCtrlSetBottom($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nBottom, $nMaxBottom


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[1] = $aPos[1] + Int($vVal)
Else
$aPos[1] = Int($vVal) - $aPos[3]
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcCtrlSetWidth($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nLeft, $nMinLeft, $nMaxRight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[2] = $aPos[2] + Int($vVal)
Else
$aPos[2] = Int($vVal)
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcCtrlSetHeight($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nTop, $nMinTop, $nMaxBottom


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[3] = $aPos[3] + Int($vVal)
Else
$aPos[3] = Int($vVal)
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcCtrlSetHCenter($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nLeft, $nMinLeft, $nMaxRight


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[0] = $aPos[0] + Int($vVal)
Else
$aPos[0] = Int($vVal) - ($aPos[2] / 2)
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcCtrlSetVCenter($vIdList, $vVal, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $aId, $aPos
Local $vId 
Local $n, $nCount, $nTop, $nMinTop, $nMaxBottom


$aid = StringSplit($vIdList, "|")
$nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vId = Int($aId[$n])
$aPos = ControlGetPos($hForm, "", $vId)
If IsString($vVal) And StringInStr("+-", StringLeft($vVal, 1)) Then 
$aPos[1] = $aPos[1] + Int($vVal)
Else
$aPos[1] = Int($vVal) - ($aPos[3] / 2)
EndIf
_lbcControlMove($hForm, "", Int($vId), $aPos[0], $aPos[1], $aPos[2], $aPos[3])
Next
Return $nCount
EndFunc

Func _lbcU2X($nU)
If 1 Then
Local $a = DllCall("user32.dll", "Long", "GetDialogBaseUnits")
Local $nX = $a[0]
Local $s = Hex($nX)
$s = "0000" & StringRight($s, 4)
$nX = (Dec($s) * $nU) / 4
Else
$structRect = DllStructCreate("Int;Int;Int;Int")
DllStructSetData($structRect, 1, $nU)
DllCall("user32.dll", "Long", "MapDialogRect", "Hwnd", $hForm, "Ptr", DllStructGetPtr($structRect))
Local $nX = DllStructGetData($structRect, 1)
$structRect = 0
EndIf
Return $nX
EndFunc

Func _lbcU2Y($nU)
Local $a = DllCall("user32.dll", "Long", "GetDialogBaseUnits")
Local $nY = $a[0]
Local $s = Hex($nY)
$s = "0000" & StringLeft($s, 4)
$nY = (Dec($s) * $nU) / 8
Return $nY
EndFunc

Func _lbcCtrlGetTextWidest($vIdList, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $n, $nWidth, $nMaxWidth
Local $vId, $vMaxId
Local $aId = StringSplit($vIdList, "|")
Local $nCount = UBound($aId) - 1
For $n = 1 to $nCount
$vid = Int($aId[$n])
$sText = ControlGetText($hForm, "", $vId)
$nWidth = _lbcCtrlGetTextWidth($vId, $sText)
If $nMaxWidth < $nWidth Then 
$nMaxWidth = $nWidth
$vMaxId = $vId
EndIf
Next
Return $vMaxId
EndFunc

Func _lbcCtrlGetTextWidth($vId, $sText, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $WM_GetFont = 49
Local $h = ControlGetHandle($hForm, "", Int($vId))
Local $a = DllCall("user32.dll", "Long", "SendMessageA", "Hwnd", $h, "Long", $WM_GetFont, "Long", 0, "Long", 0)
Local $hFont = $a[0]
$a = DllCall("user32.dll", "Long", "GetDC", "Hwnd", $h)
Local $hDC = $a[0]
$a = DllCall("gdi32.dll", "Long", "SelectObject", "Long", $hDC, "Long", $hFont)
$hFont = $a[0]
$a = DllCall("gdi32.dll", "Long", "GetTextFaceA", "Long", $hDC, "Long", 80, "Str", "")
Local $sFont = $a[3]
Local $iLength = StringLen($sText)
$structSize = DllStructCreate("int;int")
$a = DllCall("gdi32.dll", "Long", "GetTextExtentPoint32A", "Long", $hDC, "Str", $sText, "Long", $iLength, "Ptr", DllStructGetPtr($structSize))
Local $iWidth = DllStructGetData($structSize, 1)
$structSize = 0
DllCall("gdi32.dll", "Long", "SelectObject", "Long", $hDC, "Long", $hFont)
DllCall("user32.dll", "Long", "ReleaseDC", "Hwnd", $h, "Long", $hDC)
Return $iWidth
EndFunc

Func _lbcCtrlGetTextHeight($vId, $sText, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $WM_GetFont = 49
Local $h = ControlGetHandle($hForm, "", Int($vId))
Local $a = DllCall("user32.dll", "Long", "SendMessageA", "Hwnd", $h, "Long", $WM_GetFont, "Long", 0, "Long", 0)
Local $hFont = $a[0]
$a = DllCall("user32.dll", "Long", "GetDC", "Hwnd", $h)
Local $hDC = $a[0]
$a = DllCall("gdi32.dll", "Long", "SelectObject", "Long", $hDC, "Long", $hFont)
$hFont = $a[0]
Local $iLength = StringLen($sText)
$structSize = DllStructCreate("int;int")
$a = DllCall("gdi32.dll", "Long", "GetTextExtentPoint32A", "Long", $hDC, "Str", $sText, "Long", $iLength, "Ptr", DllStructGetPtr($structSize))
Local $iHeight = DllStructGetData($structSize, 2)
$structSize = 0
DllCall("gdi32.dll", "Long", "SelectObject", "Long", $hDC, "Long", $hFont)
DllCall("user32.dll", "Long", "ReleaseDC", "Hwnd", $h, "Long", $hDC)
Return $iHeight
EndFunc

Func _lbcCtrlGetFontName($vId, $hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

Local $WM_GetFont = 49
Local $h = ControlGetHandle($hForm, "", Int($vId))
Local $a = DllCall("user32.dll", "Long", "SendMessageA", "Hwnd", $h, "Long", $WM_GetFont, "Long", 0, "Long", 0)
Local $hFont = $a[0]
$a = DllCall("user32.dll", "Long", "GetDC", "Hwnd", $h)
Local $hDC = $a[0]
$a = DllCall("gdi32.dll", "Long", "SelectObject", "Long", $hDC, "Long", $hFont)
$hFont = $a[0]
$a = DllCall("gdi32.dll", "Long", "GetTextFaceA", "Long", $hDC, "Long", 80, "Str", "")
Local $sFont = $a[3]
DllCall("gdi32.dll", "Long", "SelectObject", "Long", $hDC, "Long", $hFont)
DllCall("user32.dll", "Long", "ReleaseDC", "Hwnd", $h, "Long", $hDC)
Return $sFont
EndFunc

Func _lbcSay($sText, $nCheck = 0)
;return if AutoIt program is not the active window
;If $nCheck and WinGetProcess(wingettitle("")) <> WinGetProcess(autoitwingettitle()) Then Return
If $nCheck and WinGetProcess(wingettitle("")) <> @AutoItPID Then Return

Local $iResult = 0
If 1 Then
Local $oJFW = ObjCreate("FreedomSci.JawsApi")
If Not @Error Then $iResult = $oJFW.SayString($sText, 0)
$oJFW = 0
If $iResult Then Return 1
Else
Local $sDLL = RegRead("HKEY_LOCAL_MACHINE64\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\jfw.Exe", "Path")
If FileExists($sDll) Then
$sDLL = $sDLL & "\jfwapi.dll"
Else
$sDll = "jfwapi.dll"
EndIf
If FileExists($sDll) Then
Local $a = DllCall($sDLL, "Long", "JFWSayString", "Str", $sText, "Long", 0) 
If not @Error and $a[0] Then Return 1
EndIf
EndIf

$sDll = "nvdaControllerClient32.dll"
Local $a = DllCall($sDLL, "Long", "nvdaController_speakText", "WStr", $sText) 
If not @Error and $a[0] Then Return 1

Local $o = ObjCreate("GwSpeak.Speak")
If @Error Then Return 0

$o.SpeakString($sText)
$o = 0
Return 2
EndFunc

Func _lbcTestCoord($vId, $hForm = -1)
Local $sText
If $hForm = -1 Then $hForm = _lbcWinGetHandle()

$aPos = ControlGetPos($hForm, "", $vId)
If IsArray($aPos) Then
$sText = "left=" & $aPos[0] & @CRLF
$sText = $sText & "top=" & $aPos[1] & @CRLF
$sText = $sText & "width=" & $aPos[2] & @CRLF
$sText = $sText & "height=" & $aPos[3]
Else
$sText = "Invalid ID!"
EndIf
_lbcTest($sText, "Coordinates")
EndFunc

Func _lbcCreate($sCaption)
;Opt("WinTitleMatchMode",   4) 		;  advanced
Opt("WinWaitDelay"     ,  10)  		;  speeds up WinMove
Opt("GuiResizeMode"    , 802) 	;  controls will never move when window is resized
Opt("GUICoordMode",1)
Opt("GUIDataSeparatorChar", "|")

Global $aLbcForm[10][3]
Global $aLbcGroup[101][101]
Global $nLbcGroup = 1
Global $nLbcBandNum = 1
Global $aLbcBand[101][101]
Global $nLbcBand = 1
$aLbcGroup[$nLbcGroup][$nLbcBandNum] = $nLbcBand
Global $nLbcBandCtrl = 1

Global $nLbcCol = $nLbcHDividerPad
Global $nLbcRow = $nLbcVDividerPad
Global $nLbcBandHeight = $nLbcCharHeight
Global $nLbcMaxRight = $nLbcCol
Global $nLbcMaxBottom = $nLbcRow

Local $hForm = GUICreate($sCaption)
$aLbcBand[0][0] = $hForm
Global $hLbcForm = $hForm
GUIStartGroup()
Return $hForm
EndFunc

Func _lbcShow($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $nCount = UBound($aLbcForm, 1) - 1
For $n = 0 to $nCount
If not IsHwnd($aLbcForm[$n][0]) Then ExitLoop
Next
$aLbcForm[$n][0] = $hForm
$aLbcForm[$n][1] = $aLbcGroup
$aLbcForm[$n][2] = $aLbcBand

Local $vIdList = _lbcWinGetIdList($hForm)
Local $aBorder = _lbcCtrlGetBorders($vIdList)
Local $nWidth = $aBorder[2] + $nLbcHDividerPad
Local $nHeight = $aBorder[3] + $nLbcVDividerPad
Local $h = _lbcStatusBarGetHandle($hForm)
If $h Then $nHeight = $nHeight + _lbcU2Y(7)

Local $a = WinGetClientSize($hForm)
Local $nHDelta = $nWidth - $a[0]
Local $nVDelta = $nHeight - $a[1]
Local $a = WinGetPos($hForm)
$nWidth = $a[2] + $nHDelta
$nHeight = $a[3] + $nVDelta
Local $nLeft = (@DesktopWidth - $nWidth) / 2
Local $nTop = (_lbcDesktopGetClientHeight() - $nHeight) / 2
WinMove($hForm, "", $nLeft, $nTop, $nWidth, $nHeight)
If $h Then _lbcStatusBarResize()
GUISetState(@SW_SHOW, $hForm)
EndFunc

Func _lbcTest($sText, $sTitle = "Test")
If IsArray($sText) Then
_ArrayDisplay($sText, $sTitle)
Else
MsgBox(0, $sTitle, $sText)
EndIf
EndFunc

Func _lbcStartBand($nBand = -1)
If $nBand = -1 Then $nBand = $nLbcBand
Local $vRef = String($nBand) & "vr"

If $nBand = 0 Then
Local $vIdList = _lbcWinGetIdList()
Else
Local $vIdList = _lbcBandGetIdList($nBand)
EndIf
Local $aBorder = _lbcCtrlGetBorders($vIdList)
$nLbcCol = $aBorder[0]
$nLbcRow = $aBorder[3] + $nLbcVRelatedPad

$nLbcBandNum = $nLbcBandNum + 1
$nLbcBand = $nLbcBand + 1
$aLbcGroup[$nLbcGroup][$nLbcBandNum] = $nLbcBand
$aLbcBand[$nLbcBand][0] = $vRef
$nLbcBandCtrl = 1
EndFunc

Func _lbcStartVGroup($nBand = -1)
If $nBand = -1 Then $nBand = $nLbcBand
Local $vRef = String($nBand) & "vd"

If $nBand = 0 Then
Local $vIdList = _lbcWinGetIdList()
Else
Local $vIdList = _lbcBandGetIdList($nBand)
EndIf
Local $aBorder = _lbcCtrlGetBorders($vIdList)
;_lbcTest($aBorder, $nBand)
$nLbcCol = $aBorder[0]
$nLbcRow = $aBorder[3] + $nLbcVDividerPad

$nLbcGroup = $nLbcGroup + 1
$nLbcBandNum = 1

$nLbcBand = $nLbcBand + 1
$aLbcGroup[$nLbcGroup][$nLbcBandNum] = $nLbcBand
$aLbcBand[$nLbcBand][0] = $vRef
$nLbcBandCtrl = 1
GUIStartGroup()
EndFunc

Func _lbcStartHGroup($nBand = -1)
If $nBand = -1 Then $nBand = $nLbcBand
Local $vRef = String($nBand) & "hd"

If $nBand = 0 Then
Local $vIdList = _lbcWinGetIdList()
Else
Local $vIdList = _lbcBandGetIdList($nBand)
EndIf
Local $aBorder = _lbcCtrlGetBorders($vIdList)
$nLbcCol = $aBorder[2] + $nLbcHDividerPad
$nLbcRow = $aBorder[1]

$nLbcGroup = $nLbcGroup + 1
$aLbcGroup[$nLbcGroup][0] = $vRef
$nLbcBandNum = 1

$nLbcBand = $nLbcBand + 1
$aLbcGroup[$nLbcGroup][$nLbcBandNum] = $nLbcBand
$aLbcBand[$nLbcBand][0] = $vRef
$nLbcBandCtrl = 1
GUIStartGroup()
EndFunc

Func _lbcCtrlCreateLabel($sCaption, $nData = 0, _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then 
$nWidth = StringLen($sCaption) * $nLbcCharWidth
If $nWidth < $nLbcMinLabelWidth Then $nWidth = $nLbcMinLabel
EndIf
If $nHeight = -1 Then $nHeight = $nLbcCharHeight
;If $nStyle = -1 Then $nStyle = BitOr($GUI_SS_DEFAULT_Label, $SS_CENTERIMAGE)
If $nStyle = -1 Then $nStyle = $GUI_SS_DEFAULT_Label
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateLabel($sCaption, $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)
$nWidth = _lbcCtrlGetTextWidth($vId, StringReplace($sCaption, "&", ""))
_lbcControlMove($hLbcForm, "", Int($vId), $nLeft, $nTop, $nWidth, $nHeight)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHLabelPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateButton($sCaption, $nData = 0, _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then $nWidth = _lbcU2X(50)
If $nHeight = -1 Then $nHeight = _lbcU2Y(8)
If $nStyle = -1 Then $nStyle = BitOr($GUI_SS_DEFAULT_Button, $BS_Center, $BS_VCENTER)
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateButton($sCaption, $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)
GUICtrlSetState($vId, $nData)
$nOldWidth = $nWidth
$nWidth= _lbcCtrlGetTextWidth($vId, StringReplace($sCaption, "&", ""))
If $nWidth > $nOldWidth Then _lbcControlMove($hLbcForm, "", Int($vId), $nLeft, $nTop, $nWidth, $nHeight)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHRelatedPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateCheckbox($sCaption, $nData = 0, _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then 
$nWidth = StringLen($sCaption) * $nLbcCharWidth + $nLbcCharWidth
EndIf
If $nHeight = -1 Then $nHeight = _lbcU2Y(8)
If $nStyle = -1 Then $nStyle = BitOr($GUI_SS_DEFAULT_Checkbox, $BS_VCENTER)
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateCheckbox($sCaption, $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)
GUICtrlSetState($vId, $nData)
$nWidth = _lbcCtrlGetTextWidth($vId, $sCaption & "WX")
_lbcControlMove($hLbcForm, "", Int($vId), $nLeft, $nTop, $nWidth, $nHeight)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHRelatedPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateRadio($sCaption, $nData = 0, _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then 
$nWidth = StringLen($sCaption) * $nLbcCharWidth + $nLbcCharWidth
EndIf
If $nHeight = -1 Then $nHeight = _lbcU2Y(8)
If $nStyle = -1 Then $nStyle = BitOr($GUI_SS_DEFAULT_Radio, $BS_VCENTER)
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateRadio($sCaption, $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)
GUICtrlSetState($vId, $nData)
$nWidth = _lbcCtrlGetTextWidth($vId, $sCaption & "WX")
_lbcControlMove($hLbcForm, "", Int($vId), $nLeft, $nTop, $nWidth, $nHeight)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHRelatedPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateInput($sCaption, $sData = "", _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)
If StringLen($sCaption) > 0 Then _lbcCtrlCreateLabel($sCaption)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then $nWidth = _lbcU2X(100)
If $nHeight = -1 Then $nHeight = _lbcU2Y(8)
If $nStyle = -1 Then $nStyle = $GUI_SS_DEFAULT_Input
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateInput($sData, $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHRelatedPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateEdit($sCaption, $sData = "", _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)

If StringLen($sCaption) > 0 Then _lbcCtrlCreateLabel($sCaption)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then $nWidth = _lbcU2X(100)
If $nHeight = -1 Then $nHeight = _lbcU2Y(50)
If $nStyle = -1 Then $nStyle = $GUI_SS_DEFAULT_Edit
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateEdit($sData, $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHRelatedPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateList($sCaption, $sData = "", _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)

If StringLen($sCaption) > 0 Then _lbcCtrlCreateLabel($sCaption)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then $nWidth = _lbcU2X(100)
If $nHeight = -1 Then $nHeight = _lbcU2Y(50)
;If $nStyle = -1 Then $nStyle = $GUI_SS_DEFAULT_List
If $nStyle =-1 Then $nStyle = BitOr($WS_Border, $WS_VScroll, $WS_TabStop, $LBS_USETABSTOPS)
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateList("", $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)
GUICtrlSetData($vId, $sData)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHRelatedPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateCombo($sCaption, $sData = "", _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)

If StringLen($sCaption) > 0 Then _lbcCtrlCreateLabel($sCaption)
If $nLeft = -1 Then $nLeft = $nLbcCol
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then $nWidth = _lbcU2X(100)
If $nHeight = -1 Then $nHeight = _lbcU2Y(50)
If $nStyle = -1 Then $nStyle = $GUI_SS_DEFAULT_Combo
If $nExtend = -1 Then $nExtend = 0
Local $vId = GUICtrlCreateCombo("", $nLeft, $nTop, $nWidth, $nHeight, $nStyle, $nExtend)
GUICtrlSetData($vId, $sData)

$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth + $nLbcHRelatedPad
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $vId
EndFunc

Func _lbcCtrlCreateStatusBar($sCaption, $nData = 0, _
$nLeft = -1, $nTop = -1, $nWidth = -1, $nHeight = -1, $nStyle = -1, $nExtend = -1)
Local $hForm = $hLbcForm
If $nLeft = -1 Then $nLeft = 0
If $nTop = -1 Then $nTop = $nLbcRow
If $nWidth = -1 Then $nWidth = _lbcCtrlGetRight(_lbcWinGetIdList()) + $nLbcHDividerPad
If $nHeight = -1 Then $nHeight = $nLbcCharHeight
If $nStyle = -1 Then $nStyle = BitOr($WS_Child, $WS_Visible)
If $nExtend = -1 Then $nExtend = 0
Local $aRight[2]
$aRight[0] = $nLbcHDividerPad
$aRight[1] = -1
Local $aText[2]
$aText[0] = ""
$aText[1] = $sCaption
Local $h = _GuiCtrlStatusBar_Create($hForm, $aRight, $aText)

Local $vId = 0
$aLbcBand[$nLbcBand][$nLbcBandCtrl] = $vId
$nLbcBandCtrl = $nLbcBandCtrl + 1

$nLbcCol = $nLeft + $nWidth
If $nLbcBandHeight < $nHeight Then $nLbcBandHeight = $nHeight
Return $h
EndFunc

Func _lbcStatusBarSetText($sText = "", $hForm = -1)
Local $h = _lbcStatusBarGetHandle($hForm)
_GuiCtrlStatusBar_SetText($h, $sText, 1)
EndFunc

Func _lbcStatusBarGetText($hForm = -1)
Local $h = _lbcStatusBarGetHandle($hForm)
Return _GuiCtrlStatusBar_GetText($h, 1)
EndFunc

Func _lbcStatusBarGetHandle($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Return ControlGetHandle($hForm, "", $sSBClassSeq)
EndFunc

Func _lbcStatusBarResize($hForm = -1)
Local $h = _lbcStatusBarGetHandle($hForm)
If $h Then _GuiCtrlStatusBar_Resize($h)
EndFunc

Func _lbcWinGetHandle()
Local $hForm
If IsDeclared("hLbcForm") Then
$hForm = $hLbcForm
Else
$hForm = GUISwitch(0)
If Int($hForm) = 0 Then
$hForm = WinGetHandle("")
Else
GUISwitch($hForm)
EndIf
Global $nLbcForm = $hForm
EndIf
Return $hForm
EndFunc

Func _lbcDesktopGetClientHeight()
Local $structRect = DllStructCreate("Int;Int;Int;Int")
Local $aRect = DllCall("user32.dll", "Long", "SystemParametersInfoA", "Int", $SPI_GetWorkArea, "Int", 0, "Ptr", DllStructGetPtr($StructRect), "Int", 0)
Local $nBottom = DllStructGetData($StructRect, 4)
Local $nTop = DllStructGetData($StructRect, 2)
Local $nHeight = $nBottom - $nTop
$StructRect = 0
Return $nHeight
EndFunc

Func _lbcDelete($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
If IsDeclared("aLbcForm") Then
Local $nCount = UBound($aLbcForm, 1) - 1
For $n = 0 to $nCount
If $aLbcForm[$n][0] = $hForm Then ExitLoop
Next
If $n <= $nCount Then
$aLbcForm[$n][0] = 0
$aLbcForm[$n][1] = 0
$aLbcForm[$n][2] = 0
EndIf
EndIf
GUIDelete($hForm)
EndFunc
Func _lbcWinGetStyle($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $a = DllCall("user32.dll", "int", "GetWindowLong", "hwnd", $hForm, "int", $GWL_STYLE)
Local $nStyle = $a[0]
Return $nStyle
EndFunc

Func _lbcWinGetExStyle($hForm = -1)
If $hForm = -1 Then $hForm = _lbcWinGetHandle()
Local $a = DllCall("user32.dll", "int", "GetWindowLong", "hwnd", $hForm, "int", $GWL_ExStyle)
Local $nExStyle = $a[0]
Return $nExStyle
EndFunc

Func _lbcControlMove($hForm, $sText, $vId, $nLeft, $nTop, $nWidth, $nHeight)
If not GUICtrlSetPos($vId, $nLeft, $nTop, $nWidth, $nHeight) Then ControlMove($hForm, "", $vId, $nLeft, $nTop, $nWidth, $nHeight)
EndFunc

Func _lbcIif($vCondition, $vIfTrue, $vIfFalse)
If $vCondition Then
Return $vIfTrue
Else
Return $vIfFalse
EndIf
EndFunc

Func _lbcNowCalcDate()
Local $sDate = _NowCalcDate()
$aDate = StringSplit($sDate, '/')
$sDate = $aDate[2] & '/' & $aDate[3] & '/' & $aDate[1]
Return $sDate
EndFunc
