PROGRAM_NAME='volume'

DEFINE_FUNCTION fnVolumeControl(CHAR nDir)
{
    PULSE[dvPanelIR, nDir]
}

DEFINE_FUNCTION fnVolumeMute()
{
    PULSE[dvPanelIR, VOL_MUTE]
}
(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [dvPanelIR] 
{
    ONLINE:
    {
	SEND_COMMAND dvPanelIR,'SET MODE IR'						
	SEND_COMMAND dvPanelIR,'CARON'
	SEND_COMMAND dvPanelIR,'XCHM 1'
	SEND_COMMAND dvPanelIR,"'CTOF',5"
	SEND_COMMAND dvPanelIR,"'CTON',2"
    }
}

