; GUI form to test Layout by Code
; by Jamal Mazrui

;Include file with function definitions, global variables, and constants
#Include "lbc.au3"

;The following function may be used to produce speech that does not occur automatically with a popular screen reader
;_lbcSay("Speak this via the API of JAWS, NVDA, or Window-Eyes")

;Begin creation of the GUI form
;It will automatically be centered and sized based on the controls added
;The parameter is the window title
$hForm = _lbcCreate("Testing Layout by Code")

;Create a single line input box with a label to its left
;The label is sized according to the actual display width of the text in the current font
;Save the resulting ID to conveniently reference the same control again
$vIdFirstName = _lbcCtrlCreateInput("First name:")

;The possible parameters of an LbC control are caption, data, left, top, width, height, style, and extended style
; All parameters are optional
;If a parameter is specified, then those before it must be specified as well
;A value of -1 means that the default should be used
;Since read-only is not a default style, it must be specified
;Also the tabstop style is added since AutoIt otehrwise drops it with read-only
_lbcCtrlCreateInput("Last name:", "Mazrui", -1, -1,-1, -1, BitOr($ES_READONLY, $WS_TABSTOP))

;Start a new group of controls lower on the form
_lbcStartVGroup()
;Make the check box initially turned on
$vIdNewsletter = _lbcCtrlCreateCheckbox("Receive newsletter", 1)
$vIdAds = _lbcCtrlCreateCheckbox("Receive advertizing")

_lbcStartVGroup()
$vIdOverNight = _lbcCtrlCreateRadio("Overnight shipping")
;Start a new band but not group for subsequent radio buttons
_lbcStartBand()
_lbcCtrlCreateRadio("Two day shipping")
_lbcStartBand()
;This will be the default radio button
_lbcCtrlCreateRadio("Week-long shipping", 1)

;Create a multiple selection list box to the right of the vertical group of radio buttons
_lbcStartHGroup()
_lbcCtrlCreateList("Recreational Interests:", "basketball|tennis|fishing|football|baseball")

;Create a multi line edit box in a new group below the radio buttons
;The 0 parameter references the whole form so far rather than a particular band
_lbcStartVGroup(0)
_lbcCtrlCreateEdit("Notes:", "")

_lbcStartVGroup()
$vIdOK = _lbcCtrlCreateButton("OK", -1, -1, -1, -1, -1, $BS_DEFPUSHBUTTON)
$vIdCancel = _lbcCtrlCreateButton("Cancel")

;The buttons look better if horizontally centered on the bottom band
;Uncomment to check coordinates of OK button before and after
;_lbcTestCoord($vIdOK)
_lbcBandHCenter()
;_lbcTestCoord($vIdOK)

;create a status bar at bottom of form, initialized with "Ready" text
_lbcCtrlCreateStatusBar("Ready")

;Set focus on first control
GUICtrlSetState($vIdFirstName, $GUI_Focus)

;Display the form
_lbcShow()

;Enter the GUI message loop
While 1
$msg = GUIGetMsg()
Switch $msg
Case $vIdOK
;Generate native AutoIt code to create the same form
$s = _lbcWinGenCode()
ClipPut($s)
_LbcTest("The code is also in the file test2.au3", "Native AutoIt code for this dialog layout has just been generated and copied to the clipboard")
ExitLoop
Case $GUI_EVENT_CLOSE
ExitLoop
EndSwitch
WEnd
_lbcDelete()

Exit
