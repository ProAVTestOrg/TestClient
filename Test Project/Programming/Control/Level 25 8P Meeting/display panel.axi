PROGRAM_NAME='display panel'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

PANEL_DEFAULT_INPUT[NUM_AREAS][NUM_SOURCES]	= {{4,4,4}} 

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE CHAR nPanelTempInput

DEFINE_FUNCTION fnPanelPower(CHAR nArea, CHAR nDisplay, CHAR nPowerState)
{
    SEND_STRING 0, "'panel power called'"
    
    SWITCH(nPowerState)
    {
	CASE DEVICE_OFF: 
	{
	    PULSE[vdvPanel, PWR_OFF] 
	    OFF[uSystem.uStatus[ROOM_1].uDisplay[TOUCH_PANEL_1].nPower]
	}
	CASE DEVICE_ON: PULSE[vdvPanel, PWR_ON]
    }
}

DEFINE_FUNCTION fnPanelInput(CHAR nArea, CHAR nDisplay, CHAR nInput)
{
    SEND_COMMAND vdvPanel, "CMD_SET_INPUTSELECT,ITOA(nInput)" 
    WAIT(30)
    {
	SEND_COMMAND vdvPanel, "CMD_SET_INPUTSELECT,ITOA(nInput)" 
    }
}

DEFINE_FUNCTION fnPanelSystemPower(CHAR nArea, CHAR nDisplay, CHAR nPowerState)
{
    SWITCH(nPowerState)
    {
	CASE DEVICE_ON: 
	{
	    SELECT
	    {
		ACTIVE(uSystem.uStatus[nArea].uDisplay[nDisplay].nPower == DEVICE_ON):      
		{
		    fnPanelPower(nArea, nDisplay, DEVICE_ON) //Turn on Anyway in case power variable is out of sync
		    fnPanelInput(ROOM_1, DISPLAY_PANEL, nPanelTempInput)
		}
		ACTIVE(uSystem.uStatus[nArea].uDisplay[nDisplay].nPower == DEVICE_OFF):     
		{
		    fnPanelPower(nArea, nDisplay, DEVICE_ON)
		    fnTimelineStart(PANEL_WARMUP_TL[nDisplay])
		    SEND_COMMAND dvTP, "'@PPN-_warmup'" 		//Popup blockout. 
		}
	    }
	}
	CASE DEVICE_OFF: fnPanelPower(ROOM_1, DISPLAY_PANEL, DEVICE_OFF)   
    }
}


(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT


CHANNEL_EVENT[vdvPanel,POWER_FB]
{
    ON: 
    {
	uSystem.uStatus[ROOM_1].uDisplay[TOUCH_PANEL_1].nPower = DEVICE_ON
    }
    OFF:
    {
	uSystem.uStatus[ROOM_1].uDisplay[TOUCH_PANEL_1].nPower  = DEVICE_OFF
    }
}

TIMELINE_EVENT [DISPLAY_PANEL_WARMUP_TL]
{
    SWITCH(TIMELINE.SEQUENCE)
    {
	CASE 2: fnPanelInput(ROOM_1, DISPLAY_PANEL, nPanelTempInput)
	CASE 3: fnPanelInput(ROOM_1, DISPLAY_PANEL, nPanelTempInput) SEND_COMMAND dvTP, "'@PPK-_warmup'" 		//Popup blockout. 
    }
}
DATA_EVENT[vdvPanel]
{
    COMMAND:
    {
	SELECT
	{
	    ACTIVE(FIND_STRING(DATA.TEXT, "RESP_INPUTSELECT", 1)):		// update the input state in projectorstatus
	    {                                                                   // and systemstatus vars
		REMOVE_STRING(DATA.TEXT, "RESP_INPUTSELECT", 1)                
	    }
	}
    }
}
CHANNEL_EVENT [vdvPanel, DEVICE_COMMUNICATING]
{
    ON: ON[uSystem.uStatus[ROOM_1].uDisplay[TOUCH_PANEL_1].nOnline]
    OFF: 
    {
	OFF[uSystem.uStatus[ROOM_1].uDisplay[TOUCH_PANEL_1].nOnline]
	uSystem.uStatus[ROOM_1].uDisplay[TOUCH_PANEL_1].nPower  = DEVICE_OFF
    }
}

