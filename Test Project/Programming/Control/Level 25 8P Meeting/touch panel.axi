PROGRAM_NAME='touch panel'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

DEVCHAN dcSourceSelect[] 	= {{dvTPMain,10},				// FIXED_PC  	
				   {dvTPMain,11},				// TABLEBOX	
				   {dvTPMain,12}}                               // APPLE_TV	
				   
DEVCHAN dcSignal[] 		= {{dvTPMain,201},				// FIXED_PC  	
				   {dvTPMain,202},				// TABLEBOX	
				   {dvTPMain,203}}                              // APPLE_TV
DEVCHAN dcPowerOff[]		= {{dvTPMain,28}}				//ALL OFF

DEVCHAN dcVolControls[]		= {{dvTPMain,24},{dvTPMain,25}}			//UP, DOWN
DEVCHAN dcVolMute[]		= {{dvTPMain,26}}				//MUTE

DEVCHAN dcPictureBlank[]	= {{dvTPMain,401}}				//Mute Picture

DEVLEV dlVolIndicator[] 	= {{dvTPMain,1}}				//Volume Bargraph

DEFINE_FUNCTION fnUpdatePictureBlankFb(CHAR nArea, CHAR nDisplay) //Picture Blank feedback
{
    [dcPictureBlank[nArea]]  		= uSystem.uStatus[nArea].uDisplay[nDisplay].nBlank
}
DEFINE_FUNCTION fnUpdateSourceFb()
{
    STACK_VAR CHAR i 

    FOR(i = 1; i <= NUM_SOURCES ; i ++)
    {
	[dcSourceSelect[i]] = (uSystem.uStatus[ROOM_1].uDisplay[DISPLAY_PANEL].nSource == i)
    }
}
DEFINE_FUNCTION fnUpdateTPMutefb()
{
    [dcVolMute] = (uSystem.uAudio[ROOM_1].nMuted)
}
DEFINE_FUNCTION fnUpdateTPVolFb()
{
    SEND_LEVEL dlVolIndicator, uSystem.uAudio[ROOM_1].nScaledLevel
}
DEFINE_FUNCTION fnUpdateSignalFb()
{
    STACK_VAR CHAR i
    STACK_VAR CHAR nActiveInputs
    
    FOR(i = 1; i <= NUM_SWITCHER_INPUTS ; i ++)  //This will check each possible switcher input (max total)
    {
	FOR(nActiveInputs = 1; nActiveInputs <= NUM_ACTIVE_INPUTS; nActiveInputs ++) //Against the total number of active inputs.
	{
	    IF(i = SWITCHER_VIDEO_INPUTS[nActiveInputs])	//If it matches...
	    {
		uSystem.uStatus[ROOM_1].uVideoSignal[nActiveInputs].nSignal = nInputSignal[i]	//Update the active signal variable
		[dcSignal[nActiveInputs]] = (uSystem.uStatus[ROOM_1].uVideoSignal[nActiveInputs].nSignal)		//And the button
	    }
	}
	SEND_STRING 0, "'fnUpdateSignalFb function running - [dcSignal[',ITOA(i),']] = ',ITOA(uSystem.uStatus[ROOM_1].uVideoSignal[i].nSignal)"
    }
}  

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [dvTP]
{
    ONLINE: 
    {
	ON[uSystem.uStatus[ROOM_1].uTP[ROOM_1].nPower]
	
	fnUpdateSourceFb()
	fnUpdateTPVolFb()
	fnUpdateTPMutefb()
	fnUpdateSignalFb()
    }
    OFFLINE:
    {
	OFF[uSystem.uStatus[ROOM_1].uTP[ROOM_1].nPower]
    }
}
BUTTON_EVENT [dcSourceSelect]
{
    PUSH: 
    {
	SWITCH(GET_LAST(dcSourceSelect))
	{
	    CASE FIXED_PC: 	fnSystemSourceSelect(ROOM_1, FIXED_PC, DISPLAY_PANEL)
	    CASE TABLEBOX:	fnSystemSourceSelect(ROOM_1, TABLEBOX, DISPLAY_PANEL)
	    CASE APPLE_TV: 	fnSystemSourceSelect(ROOM_1, APPLE_TV, DISPLAY_PANEL)
	}	
    }
}
BUTTON_EVENT[dcPowerOff]                                                 
{
    PUSH:
    {
	fnSystemPowerOff(ROOM_1)
	fnUpdateSourceFb()
    }
}
// -- VOL CONTROLS
BUTTON_EVENT[dcVolControls]
{
    PUSH: 
    {
	SWITCH(GET_LAST(dcVolControls))
	{
	    CASE 1: fnVolumeControl(VOL_UP)
	    CASE 2: fnVolumeControl(VOL_DN)
	}
    }
    HOLD[5,REPEAT]: 
    {
	SWITCH(GET_LAST(dcVolControls))
	{
	    CASE 1: fnVolumeControl(VOL_UP)
	    CASE 2: fnVolumeControl(VOL_DN)
	}
    }
}

BUTTON_EVENT[dcVolMute]
{
    PUSH:
    {
	fnVolumeMute()
    }
}
BUTTON_EVENT [dcPictureBlank]
{
    PUSH:
    {
	fnPictureBlank(ROOM_1, DISPLAY_PANEL)
    }
}
