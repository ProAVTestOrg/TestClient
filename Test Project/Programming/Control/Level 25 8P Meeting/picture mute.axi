PROGRAM_NAME='picture mute'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

///Switcher CommandsPicture mute all outputs to black

CHAR PICTURE_MUTE_QUERY[]	= 'B'
CHAR PICTURE_MUTE_ENABLE[]	= '1B'
CHAR PICTURE_MUTE_DISABLE[]	= '0B'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

DEFINE_FUNCTION fnResetPictureBlank(CHAR nArea, CHAR nDisplay)
{
    OFF[uSystem.uStatus[nArea].uDisplay[nDisplay].nBlank]
    fnSwitcherCommandStack (PICTURE_MUTE_DISABLE)
    fnUpdatePictureBlankFb(nArea, nDisplay)
}

DEFINE_FUNCTION fnPictureBlank(CHAR nArea, CHAR nDisplay)
{

    IF(uSystem.uStatus[ROOM_1].uDisplay[nDisplay].nPower)
    {
	IF(!uSystem.uStatus[ROOM_1].uDisplay[nDisplay].nBlank)
	{
	    ON[uSystem.uStatus[ROOM_1].uDisplay[nDisplay].nBlank]
	    fnSwitcherCommandStack (PICTURE_MUTE_ENABLE)
	}
	ELSE IF(uSystem.uStatus[ROOM_1].uDisplay[nDisplay].nBlank)
	{
	    OFF[uSystem.uStatus[ROOM_1].uDisplay[nDisplay].nBlank]
	    fnSwitcherCommandStack (PICTURE_MUTE_DISABLE)
	}
    }
    fnUpdatePictureBlankFb(nArea, nDisplay)
}
(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT
