PROGRAM_NAME='timelines'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// timelines

INTEGER DISPLAY_PANEL_WARMUP_TL			= 1
INTEGER WARMUP_TIMER_TL				= 2
INTEGER PANEL_STACK_TL				= 3
INTEGER PANEL_POLL_TL				= 4
INTEGER PANEL_COMMS_TO_TL			= 5
INTEGER SWITCHER_STACK_TL			= 6
INTEGER SWITCHER_POLL_TL			= 7
                                             
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lWarmupTimerTLTriggers[]			= {0,1000}
LONG lPanelWarmupTLTriggers[]			= {0,16000, 8000}
LONG lSwitcherPollTLTriggers[]			= {0,5000}
LONG lSwitcherTOTLTriggers[]			= {0,10000}
LONG lCommsTLTriggers[]				= {0,300}
LONG lDevicePollTLTriggers[]			= {0,29000}
LONG lCommsTimeoutTLTriggers[]			= {0,30000}

INTEGER PANEL_WARMUP_TL[NUM_AREAS] 	= {DISPLAY_PANEL_WARMUP_TL}

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)

DEFINE_FUNCTION fnTimelineStart (INTEGER nTimeline)
{
    SWITCH (nTimeline)
    {
	CASE WARMUP_TIMER_TL:
	{
	    IF (!TIMELINE_ACTIVE(WARMUP_TIMER_TL))
	    {
		TIMELINE_CREATE (WARMUP_TIMER_TL,lWarmupTimerTLTriggers,LENGTH_ARRAY(lWarmupTimerTLTriggers),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	    }
	}	
	CASE DISPLAY_PANEL_WARMUP_TL:
	{
	    IF (!TIMELINE_ACTIVE(DISPLAY_PANEL_WARMUP_TL))
	    {
		TIMELINE_CREATE (DISPLAY_PANEL_WARMUP_TL,lPanelWarmupTLTriggers,LENGTH_ARRAY(lPanelWarmupTLTriggers),TIMELINE_RELATIVE,TIMELINE_ONCE)
	    }
	}
	CASE SWITCHER_STACK_TL:
	{
	    IF (!TIMELINE_ACTIVE(SWITCHER_STACK_TL))
	    {
		TIMELINE_CREATE (SWITCHER_STACK_TL,lCommsTLTriggers,LENGTH_ARRAY(lCommsTLTriggers),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	    }
	}
	CASE SWITCHER_POLL_TL:
	{
	    IF (!TIMELINE_ACTIVE(SWITCHER_POLL_TL))
	    {
		TIMELINE_CREATE (SWITCHER_POLL_TL,lSwitcherPollTLTriggers,LENGTH_ARRAY(lSwitcherPollTLTriggers),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	    }
	}
	CASE PANEL_STACK_TL:
	{
	    IF (!TIMELINE_ACTIVE(PANEL_STACK_TL))
	    {
		TIMELINE_CREATE (PANEL_STACK_TL,lCommsTLTriggers,LENGTH_ARRAY(lCommsTLTriggers),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	    }
	}
	CASE PANEL_POLL_TL:
	{
	    IF (!TIMELINE_ACTIVE(PANEL_POLL_TL))
	    {
		TIMELINE_CREATE (PANEL_POLL_TL,lDevicePollTLTriggers,LENGTH_ARRAY(lDevicePollTLTriggers),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	    }
	}
	CASE PANEL_COMMS_TO_TL:
	{
	    IF (!TIMELINE_ACTIVE(PANEL_COMMS_TO_TL))
	    {
		TIMELINE_CREATE (PANEL_COMMS_TO_TL,lCommsTimeoutTLTriggers ,LENGTH_ARRAY(lCommsTimeoutTLTriggers),TIMELINE_RELATIVE,TIMELINE_ONCE)
	    }
	}
    }
}

DEFINE_FUNCTION fnTimelineStop (INTEGER nTimeline)
{
    IF (TIMELINE_ACTIVE(nTimeline)) TIMELINE_KILL (nTimeline)
}
