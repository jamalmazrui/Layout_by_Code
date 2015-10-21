#Include <GUIConstants.au3>
#Include <GUIStatusBar.au3>
$hForm = GUICreate("Testing Layout by Code", 551, 387, 233, 164, -1798701056, 256)
GUICtrlCreateLabel("First name:", 14, 14, 51, 16, 1342308608, 0)
$vIdFirstname = GUICtrlCreateInput("", 71, 14, 200, 16, 1342242944, 0)
GUICtrlCreateLabel("Last name:", 279, 14, 52, 16, 1342177536, 0)
$vIdLastname = GUICtrlCreateInput("Mazrui", 337, 14, 200, 16, 1342244864, 0)
$vIdReceivenewsletter = GUICtrlCreateCheckbox("Receive newsletter", 14, 44, 109, 16, 1342376963, 0)
$vIdReceiveadvertizing = GUICtrlCreateCheckbox("Receive advertizing", 131, 44, 112, 16, 1342245891, 0)
$vIdOvernightshipping = GUICtrlCreateRadio("Overnight shipping", 14, 74, 106, 16, 1342311433, 0)
$vIdTwodayshipping = GUICtrlCreateRadio("Two day shipping", 14, 98, 101, 16, 1342180361, 0)
$vIdWeeklongshipping = GUICtrlCreateRadio("Week-long shipping", 14, 122, 112, 16, 1342245897, 0)
GUICtrlCreateLabel("Recreational Interests:", 140, 122, 106, 16, 1342308608, 0)
$vIdRecreationalInterests = GUICtrlCreateList("", 252, 122, 200, 93, 1350631553, 0)
GUICtrlCreateLabel("Notes:", 14, 229, 31, 16, 1342308608, 0)
$vIdNotes = GUICtrlCreateEdit("", 51, 229, 200, 100, 1345392836, 0)
$vIdOK = GUICtrlCreateButton("OK", 171, 343, 100, 16, 1342390273, 0)
$vIdCancel = GUICtrlCreateButton("Cancel", 279, 343, 100, 16, 1342263040, 0)
Local $aRight[2] = [14, -1]
Local $aText[2] = ["", "Ready"]
_GUICtrlStatusBar_Create($hForm, $aRight, $aText)
GUISetState(@SW_SHOW)
While 1
$MSG = GUIGetMsg()
Switch $MSG
Case 0
ContinueLoop
Case $GUI_EVENT_RESIZED
_GUICtrlStatusBarResize(ControlGetHandle($hForm, "msctls_statusbar321")
Case $GUI_Event_Close
ExitLoop
EndSwitch
WEnd
GUIDelete()
