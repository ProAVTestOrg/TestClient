PROGRAM_NAME='audio control'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

INTEGER TP_LEVEL_SCALE			= 255
INTEGER START_VOL_LEVEL	 		= 60



(***********************************************************)
(*              STRUCTURE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

DEVLEV dlVolLevel[]	= {{vdvVolume, VOL_LVL}}


DEFINE_FUNCTION INTEGER fnConvertFloatingLevelToInt(FLOAT fRecalcedLevel)
{
    STACK_VAR CHAR sRecalcedLevel[3]
    STACK_VAR INTEGER nRecalcedLevel
        
    sRecalcedLevel = FTOA(fRecalcedLevel)
    
    sRecalcedLevel = FORMAT('%-3.0f',fRecalcedLevel)
    nRecalcedLevel = ATOI("sRecalcedLevel")
   
    RETURN nRecalcedLevel
}

DEFINE_FUNCTION FLOAT fnRecalcVolumeLevel(INTEGER nLevel)
{
    STACK_VAR FLOAT fRecalcedLevel
    
    fRecalcedLevel = (nLevel - uSystem.uAudio[ROOM_1].nMin) * TP_LEVEL_SCALE /			
    (uSystem.uAudio[ROOM_1].nMax - uSystem.uAudio[ROOM_1].nMin)		

    RETURN fnConvertFloatingLevelToInt(fRecalcedLevel)							
}

DEFINE_FUNCTION fnUpdateLevels()
{
    uSystem.uAudio[ROOM_1].nScaledLevel = TYPE_CAST(fnRecalcVolumeLevel(uSystem.uAudio[ROOM_1].nLevel))
    SEND_LEVEL dlVolLevel, uSystem.uAudio[ROOM_1].nLevel
    
    fnUpdateTPVolFb()
}

DEFINE_FUNCTION fnVolumeControl(CHAR nDir)
{
    SWITCH(nDir)
    {
	CASE VOL_UP:
	{
	    IF(uSystem.uAudio[ROOM_1].nLevel < (uSystem.uAudio[ROOM_1].nMax - uSystem.uAudio[ROOM_1].nInc)) 
	    {
		uSystem.uAudio[ROOM_1].nLevel = uSystem.uAudio[ROOM_1].nLevel + uSystem.uAudio[ROOM_1].nInc
	    }
	    ELSE uSystem.uAudio[ROOM_1].nLevel = uSystem.uAudio[ROOM_1].nMax
	}
	CASE VOL_DN:
	{
	    IF(uSystem.uAudio[ROOM_1].nLevel > (uSystem.uAudio[ROOM_1].nMin + uSystem.uAudio[ROOM_1].nInc)) 
	    {
		uSystem.uAudio[ROOM_1].nLevel = uSystem.uAudio[ROOM_1].nLevel - uSystem.uAudio[ROOM_1].nInc
	    }
	    ELSE uSystem.uAudio[ROOM_1].nLevel = uSystem.uAudio[ROOM_1].nMin
	}
    }
    fnUpdateLevels()
}

DEFINE_FUNCTION fnVolumeMute(CHAR nState)
{
    
    [dvPanel, VOL_MUTE_ON] = nState
}

DEFINE_FUNCTION fnSetLevels(INTEGER nVol)					// function used to set levels to a particular level
{
    uSystem.uAudio[ROOM_1].nLevel = nVol							// update the var for the volume level
    fnUpdateLevels()
}										// the LEVEL_EVENT below will in turn update the levels on the ClearOne

(***********************************************************)
(*                 STARTUP CODE GOES BELOW                 *)
(***********************************************************)
DEFINE_START

uSystem.uAudio[ROOM_1].nMin = 0						
uSystem.uAudio[ROOM_1].nMax = 100					
uSystem.uAudio[ROOM_1].nInc = 10

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT

#WARN ' Fix This'

LEVEL_EVENT [dlRoomVolume]
{
    //fnPanelVolumeControl(LEVEL.VALUE)
    //fnSwitcherVolumeControl(LEVEL.VALUE)
}
CHANNEL_EVENT [dvPanel, VOL_MUTE_ON]
{
    ON:
    {
	ON[uSystem.uAudio[ROOM_1].nMuted]
	fnUpdateTPMuteFb()
    }
    OFF:
    {
	OFF[uSystem.uAudio[ROOM_1].nMuted]
	fnUpdateTPMuteFb()
    }
}
