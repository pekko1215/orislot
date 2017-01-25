#regcmd "_hsp3cmdinit@4","aviplay2.dll"
#cmd dshow_init					$000
#cmd dshow_end					$001
#cmd dshow_load					$002
#cmd dshow_play					$003
#cmd dshow_pause				$004
#cmd dshow_stop					$005
#cmd dshow_getvideosize			$006
#cmd dshow_setvideopos			$007
#cmd dshow_setalphabitmap		$008
#cmd dshow_updatealphabitmap	$009
#cmd dshow_setvisible			$00A
#cmd dshow_setvolume			$00B
#cmd dshow_setbalance			$00C
#cmd dshow_getpositions			$00D
#cmd dshow_settimeformat		$00E
#cmd dshow_getbufferstate		$00F
#cmd dshow_setposition			$010
#cmd dshow_setrendertarget		$011

//TimeFormat
#const TF_MEDIATIME	0
#const TF_FRAME		1
#const TF_SAMPLE	2

//BufferState
#const BS_UNUSED	0
#const BS_STOPPED	1
#const BS_PAUSED	2
#const BS_RUNNING	3
#const BS_INIT		4
