PROGRAM_NAME='system power'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

INTEGER SHUTDOWN		= 0

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

DEFINE_FUNCTION fnSystemPowerOff(CHAR nArea)
{
    OFF[uSystem.uStatus[nArea].nPower]
    OFF[uSystem.uStatus[nArea].uDisplay[DISPLAY_PANEL].nSource]
    fnPanelSystemPower(ROOM_1, DISPLAY_PANEL, DEVICE_OFF)
    fnResetPictureBlank(ROOM_1, DISPLAY_PANEL)
}	

DEFINE_FUNCTION fnSystemPowerOn(CHAR nArea, CHAR nDisplay)    
{
    ON[uSystem.uStatus[nArea].nPower] //Switch on Power Variable
    SEND_STRING 0, "'fnSystemPowerOn called --- nArea ==',ITOA(nArea)"
    fnPanelSystemPower(nArea, nDisplay, DEVICE_ON)
}
DEFINE_FUNCTION fnSystemSourceSelect(CHAR nArea, CHAR nSource, CHAR nDisplay)
{
    SEND_STRING 0, "'fnSystemSourceSelect called --- nSource ==',ITOA(nSource)"
    uSystem.uStatus[nArea].uDisplay[nDisplay].nSource = nSource
    nPanelTempInput  = PANEL_DEFAULT_INPUT[nArea][nSource]
    fnSwitch(SWITCHER_VIDEO_INPUTS[nSource])
    fnUpdateSourceFb()
    fnUpdateSignalFb()
    fnSystemPowerOn(nArea, nDisplay)
}

