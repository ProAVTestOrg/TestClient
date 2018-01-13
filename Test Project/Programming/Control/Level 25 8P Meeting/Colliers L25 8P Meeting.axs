PROGRAM_NAME='Colliers International'
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/05/2006  AT: 09:00:25        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

// Touch Panel -- 
dvTP		= 10001:1:0						// Touch Panel 
dvAppleTV 	= 10001:7:0						// Apple TV
dvTPMain	= 10001:9:0						// Touch Panel Navigation

dvPanelIR 	= 5001:11:0						// Promethean Activ Touch Panel 55 Panel IR


dvSwitcher	= 5001:2:0						// Extron IN1608	
dvPanel		= 5001:1:0						// Promethean Activ Touch Panel 55

vdvVolume 	= 33003:1:0						// Virtual Device Volume
vdvPanel 	= 33004:1:0						// Virtual Device Volume


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


// sources
CHAR FIXED_PC				= 1
CHAR TABLEBOX				= 2
CHAR APPLE_TV				= 3

//Rooms

CHAR NUM_AREAS				= 1 		//Areas - Indvidual systems
CHAR NUM_SOURCES			= 3		//Number of video sources
CHAR NUM_TOUCHPANELS			= 1		//Number of Touch Panels
CHAR NUM_DISPLAYS			= 1		//Number of DISPLAY 
CHAR NUM_ACTIVE_INPUTS			= 3		//Number of active switcher inputs 
CHAR NUM_SWITCHER_INPUTS 		= 8		//Number of total switcher inputs

//Displays
CHAR DISPLAY_PANEL			= 1
//Room Names
CHAR ROOM_1				= 1		

//Touch Panel Names

CHAR TOUCH_PANEL_1			= 1

//Device Constants

CHAR DEVICE_OFF				= 0
CHAR DEVICE_ON				= 1
CHAR DEVICE_WARMING			= 2
CHAR DEVICE_COOLING			= 3

//Touch Panel popups
CHAR POPUP_COMBINE[]			= '_combine'
CHAR POPUP_WARMUP[]			= '_warmup'
CHAR POPUP_COOLDOWN[]			= '_cooldown'

//TOUCH PANEL BUTTONS

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

STRUCTURE _sAudio
{
    INTEGER nMin
    INTEGER nMax
    INTEGER nInc
    INTEGER nLevel
    INTEGER nScaledLevel
    CHAR    nMuted
}

STRUCTURE _sDisplayStatus
{
    CHAR nSource
    CHAR nBlank				
    CHAR nOnline
    CHAR nPower
    CHAR sInput[16]
    INTEGER nLampHours
}
STRUCTURE _sBasicDeviceStatus
{
    CHAR nOnline
    CHAR nPower
}
STRUCTURE _sConnection
{
    CHAR nSignal
    CHAR nOnline
}
STRUCTURE _sRoomStatus
{
    CHAR nPower
    _sDisplayStatus uDisplay[NUM_DISPLAYS]
    _sBasicDeviceStatus uTP[NUM_TOUCHPANELS]
    _sConnection uVideoSignal[NUM_SOURCES]
    
}
STRUCTURE _sSystemStatus
{
    _sAudio uAudio[NUM_AREAS]
    _sRoomStatus uStatus[NUM_AREAS]	 	// Number of rooms//areas
}  

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

PERSISTENT _sSystemStatus uSystem

DEVLEV dlRoomVolume[] 	= {{vdvVolume,1}}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
(*
*)
INCLUDE 'DEFINITIONS_moduleCommands.axi'
INCLUDE 'SNAPI.axi'
INCLUDE 'timelines.axi'
INCLUDE 'display panel.axi' 
INCLUDE 'volume.axi'
INCLUDE 'Extron Comms.axi'
INCLUDE 'system power.axi'
INCLUDE 'touch panel.axi'
INCLUDE 'picture mute.axi'


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

DEFINE_MODULE 'Promethean_ActivPanel_Comm_1_0_0' PanelComm(vdvPanel, dvPanel)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

