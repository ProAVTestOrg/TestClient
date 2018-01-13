PROGRAM_NAME='Extron Comms'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


CHAR NUM_SWITCHER_INPUTS 		= 8

// sources
CHAR INPUT_FIXED_PC			= 3
CHAR INPUT_TABLEBOX			= 7
CHAR INPUT_APPLE_TV			= 4

CHAR SWITCHER_VIDEO_INPUTS[NUM_SOURCES]	= {INPUT_FIXED_PC,INPUT_TABLEBOX,INPUT_APPLE_TV}

// stack
INTEGER MAX_NUM_STACK_COMMANDS		= 20
INTEGER MAX_LENGTH_SWITCHER_COMMAND	= 20
INTEGER MAX_LENGTH_SWITCHER_BUFFER	= 999

//COMMANDS

CMD_CR			= $0D
CMD_LF			= $0A
CMD_ESC			= $1B
CMD_SPACE		= ' '
CMD_ASTERISK		= '*'

CMD_OUTPUT_ALL			= '!'
CMD_QUERY_INPUT_SIGNAL		= '0LS'

CMD_PARAM_SET_VOLUME		= 'GRPM'
CMD_PARAM_AUDIO			= 'AU'

CMD_GROUP_PROGRAM_VOLUME	= 'D1'
CMD_GROUP_MIC_VOLUME		= 'D3'
CMD_GROUP_VARIABLE_VOLUME	= 'D8'

CMD_GROUP_PROGRAM_MUTE		= '2'
CMD_GROUP_OUTPUT_MUTE		= '7'
CMD_GROUP_MIC_MUTE		= '4'

CMD_RESP_CHANGE			= 'Reconfig'
CMD_RESP_INPUT			= 'In'
CMD_RESP_OUTPUT_ALL		= 'All'
CMD_RESP_ASTERISK		= '*'

CMD_MIC_1_VOLUME_CTRL		= '40100'
CMD_MIC_1_MUTE_CTRL		= '40000'
CMD_MIC_2_VOLUME_CTRL		= '40101'
CMD_MIC_2_MUTE_CTRL		= '40001'
CMD_OUTPUT_1_CTRL		= '60000'
CMD_OUTPUT_2_CTRL		= '60002'
CMD_VAR_OUTPUT_L_CTRL		= '60004'
CMD_VAR_OUTPUT_R_CTRL		= '60005'


(***********************************************************)
(*              STRUCTURE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

STRUCTURE _sSwitcherCommandStack						// structure to store the commands to be sent out to the switcher
{
    CHAR sStackCommand[MAX_LENGTH_SWITCHER_COMMAND]				// char array to store a command string 10 chars long
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE INTEGER nDevConnected
VOLATILE INTEGER nDevOnline

VOLATILE CHAR nInputSignal[NUM_SWITCHER_INPUTS] 
VOLATILE INTEGER nCurrentInputSelected

CHAR sExtronBuffer[MAX_LENGTH_SWITCHER_BUFFER]

VOLATILE CHAR sSwitcherBuffer[MAX_LENGTH_SWITCHER_BUFFER]

VOLATILE _sSwitcherCommandStack uSwitcherCommandStack[MAX_NUM_STACK_COMMANDS]	// Instantiate the command stack and allow 10 RS-232 commands to be stored

VOLATILE INTEGER nSwitcherStackPointer = 1					// The stack requires 2 integers which need to be initialised to 1 (0 will cause a runtime error):
VOLATILE INTEGER nSwitcherStackCounter = 1					// 1. A counter to keep track of what element of the structure to store the next Code

DEFINE_FUNCTION fnSwitcherCommandStack(CHAR sEnteredCommand[])			// The code is added to the stack here. If the stack is empty,
{										// the code will be added at position 1 and the associated timeline
    uSwitcherCommandStack[nSwitcherStackCounter].sStackCommand = sEnteredCommand// will start. If the timeline is running, the stack counter keeps track of the next
    IF (nSwitcherStackCounter < MAX_NUM_STACK_COMMANDS) nSwitcherStackCounter ++// position in the structure to populate. Once the stack has reached 50 and the timeline
    ELSE nSwitcherStackCounter = 1						// is still running the next code will be added to position 1.
    
    fnTimeLineStart(SWITCHER_STACK_TL)
}
DEFINE_FUNCTION fnSwitcherVolumeControl(INTEGER nLevel)
{
    STACK_VAR SINTEGER nRecalcLevel
    
    nLevel = (nLevel * 10)
    nRecalcLevel = TYPE_CAST(nLevel - 1000)
    SEND_STRING 0, "'fnSwitcherVolumeControl | nRecalcLevel is',ITOA(nRecalcLevel)"
    fnSwitcherCommandStack ("CMD_ESC,CMD_GROUP_PROGRAM_VOLUME,CMD_ASTERISK,ITOA(uSystem.uAudio[ROOM_1].nInc),CMD_PARAM_SET_VOLUME,CMD_LF,CMD_CR")
}
DEFINE_FUNCTION fnSwitcherVolumeMute(CHAR nState)
{
    SEND_STRING 0, "'fnSwitcherVolumeMute running | Outbound String is',CMD_ESC,'M',CMD_OUTPUT_1_CTRL,CMD_ASTERISK,ITOA(nState),CMD_PARAM_AUDIO,CMD_LF,CMD_CR"
    fnSwitcherCommandStack ("CMD_ESC,'M',CMD_OUTPUT_1_CTRL,CMD_ASTERISK,ITOA(nState),CMD_PARAM_AUDIO,CMD_LF,CMD_CR")
}
DEFINE_FUNCTION fnSwitch(INTEGER nInput)
{
    fnSwitcherCommandStack ("ITOA(nInput),CMD_OUTPUT_ALL")
    SEND_STRING 0, "'fnSwitch running | Outbound String is',ITOA(nInput),CMD_OUTPUT_ALL"
}

DEFINE_FUNCTION fnQuerySignal()
{
    fnSwitcherCommandStack ("CMD_ESC,CMD_QUERY_INPUT_SIGNAL,CMD_LF,CMD_CR")
    SEND_STRING 0, "'fnQuerySignal running | Outbound String is',CMD_ESC,CMD_QUERY_INPUT_SIGNAL,CMD_LF,CMD_CR"
}

DEFINE_FUNCTION fnProcessString()
{
    STACK_VAR INTEGER i
    STACK_VAR CHAR sString[64]
    STACK_VAR INTEGER nInput
    
    WHILE(FIND_STRING(sExtronBuffer, "CMD_CR,CMD_LF", 1))
    {
	sString = REMOVE_STRING(sExtronBuffer, "CMD_LF", 1)
	SEND_STRING 0, "'fnProcessString running | delimiter found | sString ==',sString"
	
	SET_LENGTH_ARRAY(sString, LENGTH_ARRAY(sString) - 2)
	SEND_STRING 0, "'sString minus CRLF ==',sString"
	
	    IF(FIND_STRING(sString, CMD_RESP_INPUT, 1))
	    {
		REMOVE_STRING(sString, CMD_RESP_INPUT, 1)
		nInput = ATOI(sString)
		nCurrentInputSelected = nInput
		SEND_STRING 0, "'fnProcessString running | CMD_RESP_INPUT found | nInput ==',ITOA(nInput)"
		REMOVE_STRING(sString, CMD_RESP_OUTPUT_ALL, 1)
		
	    }
	    ELSE IF(FIND_STRING(sString, CMD_RESP_ASTERISK, 1))
	    {
		fnUpdateInputSignalStatus(sString)
		
		SEND_STRING 0, "'fnProcessInputQuery called | CMD_RESP_ASTERISK found | sString ==',sString"
		SEND_STRING 0, "'Length array of SString ==',ITOA(LENGTH_ARRAY(sString))"
	    }
	    ELSE IF(FIND_STRING(sString, CMD_RESP_CHANGE, 1))
	    {
		SEND_STRING 0, "'fnProcessInputQuery called --- CMD_RESP_CHANGE | sString Found ==',sString"
		fnQuerySignal()
		SEND_STRING 0, 'fnQuerySignal called'
	    }
    }
}
DEFINE_FUNCTION fnUpdateInputSignalStatus(CHAR sString[64])
{
    STACK_VAR INTEGER i
    
    FOR(i = 1; i <= NUM_SWITCHER_INPUTS; i ++)
    {
	nInputSignal[i] = ATOI(LEFT_STRING(sString, 1))
	SEND_STRING 0, "'nInputSignal[',ITOA(i),'] = ',ITOA(nInputSignal[i])"
	REMOVE_STRING(sString, CMD_RESP_ASTERISK, 1)
    }
    fnUpdateSignalFb()
    //AutoPower
    IF(nInputSignal[INPUT_TABLEBOX] == DEVICE_ON) 
    {
	IF(!uSystem.uStatus[ROOM_1].uDisplay[DISPLAY_PANEL].nPower && !
	   uSystem.uStatus[ROOM_1].nPower)
	   {
		fnSystemSourceSelect(ROOM_1, TABLEBOX, DISPLAY_PANEL)
	   }
	
    }
}
(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT


DATA_EVENT[dvSwitcher]
{
    ONLINE:  
    {
	SEND_STRING 0, "'DATA_EVENT[dvSwitcher] ONLINE'"
	SEND_COMMAND dvSwitcher, 'SET BAUD 9600,N,8,1 485 DISABLE'		// initialise the port
	SEND_COMMAND dvSwitcher, 'RXON'
	ON[nDevConnected]
    }
    OFFLINE: 
    {
	OFF[nDevConnected]
	OFF[nDevOnline]	
    }
    STRING:
    {
	SEND_STRING 0, "'DATA_EVENT[dvSwitcher] STRING | String = ', DATA.TEXT"
	ON[nDevOnline]
	ON[nDevConnected]
	SELECT
	{
	    ACTIVE(FIND_STRING(sExtronBuffer, 'Copyright', 1)):
	    {
		CLEAR_BUFFER sExtronBuffer
	    }
	}
	fnProcessString()
    }
    ONERROR: 
    {
	OFF[nDevOnline]
    }
}

TIMELINE_EVENT [SWITCHER_STACK_TL]								// for the command stack timeline
{
    SWITCH(TIMELINE.SEQUENCE)
    {
	CASE 1:											// at the first timeline event
	{
	    SEND_STRING dvSwitcher, "uSwitcherCommandStack[nSwitcherStackPointer].sStackCommand"// send the string stored in the command stack structure at the index indicated by the 
	    uSwitcherCommandStack[nSwitcherStackPointer].sStackCommand = NULL_STR		// For housekeeping, when a string is sent - delete the string immediately
												// this allows the element to be used again if the number of strings exceeds
												// 50 and the counter needs to restart at position 1
	    IF (nSwitcherStackPointer < MAX_NUM_STACK_COMMANDS) nSwitcherStackPointer ++	// While there are less than 50 strings in the strcture, then increment the pointer var
	    ELSE nSwitcherStackPointer = 1							// Otherwise reset it to 1
	    IF (nSwitcherStackPointer = nSwitcherStackCounter)					// if the pointer reaches the counter, then this means that there are no more strings
	    {											// left in the stack
		nSwitcherStackCounter = 1							// in this case reset the pointer var and the counter var
		nSwitcherStackPointer = 1							// note that the counter var is used in the stack command function to load strings into the structure
		
		fnTimelineStop(SWITCHER_STACK_TL)
	    }
	}						
    }							
}
TIMELINE_EVENT [SWITCHER_POLL_TL]
{
    SWITCH(TIMELINE.SEQUENCE)
    {
	CASE 2: 
	{
	    fnQuerySignal()
	}
    }
}

(***********************************************************)
(*                 STARTUP CODE GOES BELOW                 *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER dvSwitcher, sExtronBuffer					//Buffer for extron device
fnTimelineStart (SWITCHER_POLL_TL)
