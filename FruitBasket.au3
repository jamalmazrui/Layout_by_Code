; Fruit Basket program

; include extra listbox functions from default AutoIt location
#Include <GUIListBox.au3>

; include Layout by Code library from same folder as the current .au3 program
#Include "lbc.au3"

; create form window with title, saving its handle
$hForm = _lbcCreate("Fruit Basket")

; create labeled input box for entering a fruit item, saving its control ID
$vIdFruit = _lbcCtrlCreateInput("&Fruit:")

; create labeled listbox for storing fruit items, ensuring that Alt+B sets focus to it
$vIdBasket = _lbcCtrlCreateList("&Basket:")

; start a new group of buttons below the previous band of controls
_lbcStartVGroup()
; make Add the default button of the dialog, invocable with the Enter key
; before the style parameter, the optional parameters for data, left, top, width, and height are -1 for defaults
$vIdAdd = _lbcCtrlCreateButton("&Add", -1, -1, -1, -1, -1, $BS_DEFPUSHBUTTON)
; create delete button to the right
$vIdDelete = _lbcCtrlCreateButton("&Delete")
; center the buttons horizontally
_lbcBandHCenter()

; ensure that focus is initially set to the fruit input box
_lbcCtrlSetState($vIdFruit, $GUI_Focus)

; show the form, which will be centered on the screen
_lbcShow()

; enter the GUI event loop
While 1
$Msg = GUIGetMsg()
Switch $Msg

; process invocation of Add button
; get fruit from input box, add to basket, point to it, and then clear input box
Case $vIdAdd
$sFruit = GUICtrlRead($vIdFruit)
If StringLen($sFruit) == 0 Then
_lbcTest("No fruit to add!", "Alert")
Else
$i = _GUICtrlListBox_GetCurSel($vIdBasket) + 1
_GUICtrlListBox_InsertString($vIdBasket, $sFruit, $i)
_GUICtrlListBox_SetCurSel($vIdBasket, $i)
GUICtrlSetData($vIdFruit, "")
EndIf

; process Delete button
; delete current fruit from basket and reset listbox pointer
Case $vIdDelete
$iCount = _GUICtrlListBox_GetCount($vIdBasket)
If $iCount == 0 Then
_lbcTest("No fruit to delete!", "Alert")
Else
$i = _GUICtrlListBox_GetCurSel($vIdBasket)
;_lbcTest($i, "index")
_GUICtrlListBox_DeleteString($vIdBasket, $i)
$iCount = _GUICtrlListBox_GetCount($vIdBasket)
If $i >= $iCount Then $i = $iCount - 1
_GUICtrlListBox_SetCurSel($vIdBasket, $i)
EndIf

; process click of Close icon or press of Escape key
Case $GUI_Event_Close
_lbcTest("Quitting program!", "Alert")
ExitLoop
EndSwitch
WEnd

; delete form and exit program
_lbcDelete()
Exit
