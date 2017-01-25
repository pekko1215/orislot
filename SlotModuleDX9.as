#regcmd "_SlotModuleDX9CmdInit@4", "SlotModuleDX9.dll"
#cmd InitD3D					$000
#cmd BeginScene					$001 
#cmd EndScene					$002
#cmd Present					$003
#cmd SetBGColor					$004
#cmd SetBGImage					$005
#cmd CreateRenderTargetTexture	$006
#cmd CreateTexture2				$007
#cmd DrawSprite					$008
#cmd DrawSpriteEx				$009
#cmd Render						$00A
#cmd SetVSyncParam				$00B
#cmd SetViewPort				$00C
#cmd SetVisible					$00D
#cmd SetFont					$00E
#cmd SetFontEx					$00F
#cmd DrawString					$010
#cmd DrawStringEx				$011
#cmd BeginDrawString			$012
#cmd EndDrawString				$013
#cmd GetD3DDeviceCaps			$014

#cmd SetReelInfo				$100
#cmd DrawReel					$101
#cmd SetFlashDataPtr			$102
#cmd SetReelMask				$103
#cmd _SetBlurMode				$104
#cmd SetReelStatus				$105

#cmd pow						$200
#cmd fint2double				$201
#cmd double2fint				$202


#const global FALSE	0
#const global TRUE	1
#const global Pi		3.14

#define global ctype BlendFactor(%1, %2, %3) (%1 << 24) + (%2 << 16) + (%3 << 8)
#define global ctype BlendFactorEx(%1, %2, %3, %4) (%1 << 24) + (%2 << 16) + (%3 << 8) + %4

//D3DBLENDOP
#const global D3DBLENDOP_ADD			1
#const global D3DBLENDOP_SUBTRACT		2
#const global D3DBLENDOP_REVSUBTRACT	3
#const global D3DBLENDOP_MIN			4
#const global D3DBLENDOP_MAX			5

//D3DBLEND
#const global D3DBLEND_ZERO			1
#const global D3DBLEND_ONE			2
#const global D3DBLEND_SRCCOLOR		3
#const global D3DBLEND_INVSRCCOLOR	4
#const global D3DBLEND_SRCALPHA		5
#const global D3DBLEND_INVSRCALPHA	6
#const global D3DBLEND_DESTALPHA	7
#const global D3DBLEND_INVDESTALPHA 8
#const global D3DBLEND_DESTCOLOR	9
#const global D3DBLEND_INVDESTCOLOR 10
#const global D3DBLEND_SRCALPHASAT	11

//BlendMode
#const global BLEND_NONE	BlendFactor(D3DBLENDOP_ADD, D3DBLEND_ONE, D3DBLEND_ZERO)	
#const global BLEND_ADD		BlendFactor(D3DBLENDOP_ADD, D3DBLEND_ONE, D3DBLEND_ONE)
#const global BLEND_ADD2	BlendFactor(D3DBLENDOP_ADD, D3DBLEND_SRCALPHA, D3DBLEND_ONE)
#const global BLEND_MUL		BlendFactor(D3DBLENDOP_ADD, D3DBLEND_ZERO, D3DBLEND_SRCCOLOR)
#const global BLEND_ALPHA	BlendFactor(D3DBLENDOP_ADD, D3DBLEND_SRCALPHA, D3DBLEND_INVSRCALPHA)

//VSyncMode
#const global VSYNC_NONE	0
#const global VSYNC_D3D		1
#const global VSYNC_DDRAW	2

//DrawString DrawStringEx Format Flags
#const global DT_TOP		0
#const global DT_LEFT		0
#const global DT_CENTER		1
#const global DT_RIGHT		2
#const global DT_VCENTER	4
#const global DT_BOTTOM		8
#const global DT_WORDBREAK	$10
#const global DT_SINGLELINE	$20
#const global DT_EXPANDTABS	$40
#const global DT_NOCLIP		$100
#const global DT_CALCRECT	$400
#const global DT_RTLREADING	$20000

#const global LEFT_REEL		0
#const global CENTER_REEL	1
#const global RIGHT_REEL	2

//StopButtonStatus
#const global BS_DISABLE	0
#const global BS_ENABLE		1
	

#ifdef USE_P2B_DLL
#include "p2b.as"
#module
/*--
	int tmp
	dim info
--*/
#deffunc CreateTexture int TmpBufferID, str FileName, int TextureID
	tmp = ginfo(3)
	buffer TmpBufferID,1,1,0 
	pngload FileName
	getpnginfo info
	CreateTexture2 TmpBufferID, info(2), TextureID
	buffer TmpBufferID,1,1,0
	gsel tmp
	return

#global
#endif


#module ReelFlash loopcount, framecount, interval, reelcolor
/*--
	dim color_table
	dim defaultcolor
	int flash_starttime
	int loopcounter
	int flash_id
	int flash_count
	ReelFlash ReelFlashInfo
	label flashendcallback
--*/

#defcfunc blendcolor int color1, int color2
/*--
	int a,r,g,b
--*/
	a = (((color1 & $FF000000) >> 1) + ((color2 & $FF000000) >> 1)) & $FF000000 
	r = ((color1 & $FF0000) + (color2 & $FF0000) >> 1) & $FF0000
	g = ((color1 & $FF00) + (color2 & $FF00) >> 1) & $FF00
	b = (color1 & $FF) + (color2 & $FF) >> 1
	return a + r + g + b

#modinit var buf, var offset
/*--
	int fc_idx, bc_idx, cnt2
--*/
	loopcount = lpeek(buf, offset)
	framecount = lpeek(buf, offset+4)
	interval = lpeek(buf, offset+8)
	dim reelcolor, 30, framecount

	offset += 16
	repeat framecount
		cnt2 = cnt
		repeat 15
			fc_idx = lpeek(buf, offset + cnt * 4)
			bc_idx = lpeek(buf, offset + cnt * 4 + 60)
			if bc_idx > 16 {
				reelcolor(cnt, cnt2) = blendcolor(color_table(fc_idx), color_table(bc_idx)) 
			} else {
				reelcolor(cnt, cnt2) = blendcolor(color_table(fc_idx), $FFFFFFFF)
			}
			reelcolor(cnt+15, cnt2) = color_table(bc_idx)
		loop
		offset += 256
	loop
	return 

#modfunc SetReelColorPtr
/*--
	int idx
--*/
	idx = (frametime@SlotModule - flash_starttime) / interval
	if idx >= framecount {
		if loopcounter == 0 {
			idx = framecount - 1
			flash_id = -1
			if vartype(flashendcallback) == 1 : gosub flashendcallback
		} else {
			if loopcounter != -1 : loopcounter--
			flash_starttime += (idx / framecount) * (interval * framecount)
			idx = idx \ framecount
		}
	}
	SetFlashDataPtr varptr(reelcolor(0, idx))
	return

#modfunc SetLoopCounter
	loopcounter = loopcount
	return

#deffunc SetFlash int _flash_id
	flash_id = _flash_id
	if flash_id >= flash_count : flash_id = -1
	if flash_id < 0 : return
	flash_starttime = frametime@SlotModule
	SetLoopCounter ReelFlashInfo(flash_id)
	return

#deffunc SetReelColor
	if flash_id < 0 : return
	SetReelColorPtr ReelFlashInfo(flash_id)
	return

#defcfunc LoadFlashData str FileName
/*--
	sdim buf
	int offset
--*/
	exist FileName
	if strsize <= 0 : return FALSE 
	sdim buf, strsize
	bload FileName, buf, strsize
	if strmid(buf, 0, 8) != "FLASHDAT" : return FALSE
	if lpeek(buf, 8) != 2 : return FALSE
	flash_count = lpeek(buf, 12)

	dim color_table, 23
	repeat 16
		color_table(cnt) = $FF000000 + cnt * $10 + cnt * $1000 + cnt * $100000
	loop
	color_table(16) = $FFFFFFFF, $FF7070E0, $FFE07070, $FFE070E0, $FF70E070, $FF70E0E0, $FFE0E070

	offset = 16
	repeat flash_count
		newmod ReelFlashInfo, ReelFlash, buf, offset
	loop
	sdim buf, 0

	dim defaultcolor, 30
	repeat 30
		defaultcolor(cnt) = $FFF0F0F0
	loop
	SetFlashDataPtr varptr(defaultcolor)
	return TRUE

#deffunc _OnFlashEnd var prm1
	flashendcallback = prm1
	return
	
#define global OnFlashEnd(%1) labelname = %1 : _OnFlashEnd labelname

#global


#module SlotModule
/*
	int rpm
	double movebase
	int reel_length
	int reel_length_px
	int reel_char_h
	dim reel_pos 
	dim reel_status
	dim reel_stoppos
	dim reel_startpos
	dim reel_starttime
	dim reel_stoptime
	dim boundtime
	dim boundcycle
	dim maxbound
	dim exp
	dim boundendtime
	int frametime
	int gamemode
	int betcoin
	int laststopreel
	int rct_count
	int yaku_count
	int maxline
	dim reel_char
	dim yaku_list
	dim betline
	int startmode
	int reel_starttime2
	int reel_startpos2
	int canstop
	int stop_count
	int stop_pattern
	dim stop_pos
	int delay
	int rcc
	sdim slidetable
	sdim tablenum1st
	sdim tablenum2nd
	sdim tablenum3rd
	int initialized
	int blurmode/*
	label reelstopcallback
	label reelstopingcallback
	label allreelstopcallback
	label tenpaicallback
	int d3dx9_version
	dim D3DCaps
	int ps_version
	int blendop_fullsupport
/*--
	dim payline
	dim tenpailine
--*/


#deffunc SetRPM int _rpm
	rpm = _rpm
	movebase = double(reel_length_px * rpm) / 60000
	return

#deffunc SetReelPos int leftpos, int centerpos, int rightpos
	reel_pos = leftpos, centerpos, rightpos
	return

#deffunc SetFrameTime int _frametime
	frametime = _frametime
	return

#deffunc SetGameMode int _gamemode
	gamemode = _gamemode
	return

#deffunc SetBetCoin int _betcoin
	betcoin = _betcoin
	return

#defcfunc GetReelPos int index
	return reel_pos(index)

#defcfunc GetReelCharPos int index
	return reel_pos(index) / reel_char_h

#defcfunc GetStopButtonStatus int index
	if (canstop == TRUE) && (reel_status(index) == 3) : return BS_ENABLE
	return BS_DISABLE

#defcfunc GetLastStopReel
	return laststopreel

#defcfunc IsAllStoped
	return reel_status(0) + reel_status(1) + reel_status(2) == 0

#defcfunc GetReelStatus int index
	return reel_status(index)

#deffunc _PayCheck array lines
/*--
	int ret
	int i, j
	int line_char
	int anymask
--*/
	ret = FALSE
	for i,0,maxline,1
#ifdef FIRSTINDEX_IS_YAKU_NONE
		lines(i) = 0
#else
		lines(i) = $FFFF
#endif
		if betline(3,i) > betcoin : _continue
		line_char = 0
		for j,0,3,1
			line_char += reel_char((reel_stoppos(j) / reel_char_h + betline(j, i)) \ reel_length, j) << j * 4
		next
		for j,0,yaku_count,1
			if (yaku_list(j) >> 12 + gamemode & 1) == 0 : _continue
			anymask = yaku_list(j) >> 16
			if (yaku_list(j) & $FFF) == (line_char | anymask) {
#ifdef FIRSTINDEX_IS_YAKU_NONE
				lines(i) = j+1
#else
				lines(i) = j
#endif
				ret = TRUE
				_break
			}
		next
	next
	return ret

#deffunc PayCheck2 array lines
/*--
	int ret
	int i, j
	int line_char
	int anymask
--*/
	ret = FALSE
	for i,0,maxline,1
		lines(i) = 0
		if betline(3,i) > betcoin : _continue
		line_char = 0
		for j,0,3,1
			line_char += reel_char((reel_stoppos(j) / reel_char_h + betline(j, i)) \ reel_length, j) << j * 4
		next
		for j,0,yaku_count,1
			if (yaku_list(j) >> 12 + gamemode & 1) == 0 : _continue
			anymask = yaku_list(j) >> 16
			if (yaku_list(j) & $FFF) == (line_char | anymask) {
				lines(i) = lines(i) | (1 << j)
				ret = TRUE
			}
		next
	next
	return ret

#defcfunc PayCheck_new array lines
	_PayCheck lines
	return stat

#defcfunc PayCheck_old
	dim payline, maxline
	_PayCheck payline
	return stat

#defcfunc GetPayOut int prm1
	return payline(prm1)


#deffunc _TenpaiCheck array lines
/*--
	int ret
	int i, j
	int line_char
	int mask
--*/
	ret = FALSE
	for i,0,maxline,1
#ifdef FIRSTINDEX_IS_YAKU_NONE
		lines(i) = 0
#else
		lines(i) = $FFFF
#endif
		if betline(3,i) > betcoin : _continue
		line_char = 0
		mask = 0
		for j,0,3,1
			line_char += reel_char((reel_stoppos(j) / reel_char_h + betline(j, i)) \ reel_length, j) << j * 4
			if reel_status(j) <= 1 : mask += $0F << j * 4
		next
		for j,0,yaku_count,1
			if (yaku_list(j) >> 12 + gamemode & 1) == 0 : _continue
			if (yaku_list(j) & mask) == (line_char & mask) {
#ifdef FIRSTINDEX_IS_YAKU_NONE
				lines(i) = j+1
#else
				lines(i) = j
#endif
				ret = TRUE
				_break
			}
		next
	next
	return ret

#defcfunc TenpaiCheck_new array lines
	_TenpaiCheck lines
	return stat

#defcfunc TenpaiCheck_old
	dim tenpailine, maxline
	_TenpaiCheck tenpailine
	return stat

#defcfunc GetTenpai int prm1
	return tenpailine(prm1)


#defcfunc getboundpos int index, int time
	if time - boundtime(index) < 0 {
		return int(sin(Pi * 2 * time / boundcycle(index)) * maxbound(index) * pow(double(boundtime(index) - time) / boundtime(index), exp(index)))
	} else {
		return 0
	}
	return

#deffunc SetBoundStartParams int prm1, int prm2, int prm3
	//‰½‚à‚µ‚È‚¢
	return

#deffunc SetBoundStopParams int index, int _maxbound, int _boundtime, int _boundcycle, double _exp
	maxbound(index) = _maxbound
	boundtime(index) = _boundtime
	boundcycle(index) = _boundcycle
	exp(index) = _exp
	boundendtime(index) = 0
	repeat _boundtime
		if getboundpos(index, _boundtime - cnt) != 0 {
			boundendtime(index) = _boundtime - cnt + 1
			break
		}
	loop
	return

#deffunc SetStartMode int _startmode, int _length
	startmode = _startmode
	if startmode != 0 {
		reel_startpos2 = _length
		reel_starttime2 = int(double(reel_startpos2 * 2) / movebase)
	} else {
		reel_startpos2 = 0
		reel_starttime2 = 0
	}
	return

#deffunc ReelMove
	repeat 3
		switch(reel_status(cnt))
			case 1
				reel_pos(cnt) = reel_stoppos(cnt) - getboundpos(cnt, frametime - reel_stoptime(cnt))
				if reel_stoptime(cnt) < frametime - boundendtime(cnt) {
					reel_status(cnt) = 0
					SetReelStatus cnt, 0
					if vartype(reelstopcallback) == 1 : gosub reelstopcallback
					if reel_status(0) + reel_status(1) + reel_status(2)  == 0 {
						if vartype(allreelstopcallback) == 1 : gosub allreelstopcallback
					}
				}
				swbreak
			case 2
				if frametime - reel_stoptime(cnt) >= 0 {
					reel_pos(cnt) = reel_stoppos(cnt) - getboundpos(cnt, frametime - reel_stoptime(cnt))
					reel_status(cnt) = 1
					SetReelStatus cnt, 1
					stop_count++
					canstop = TRUE
					laststopreel = cnt
					if vartype(reelstopingcallback) == 1 : gosub reelstopingcallback
				} else {
					reel_pos(cnt) = reel_startpos(cnt) - movebase * (frametime - reel_starttime(cnt))
				}
				swbreak
			case 3
				reel_pos(cnt) = reel_startpos(cnt) - movebase * (frametime - reel_starttime(cnt))
				swbreak
			case 4
				if frametime - reel_starttime(cnt) >= reel_starttime2 {
						reel_status(cnt) = 3
						SetReelStatus cnt, 3
						reel_starttime(cnt) += reel_starttime2
						reel_startpos(cnt) -= reel_startpos2
						if reel_startpos(cnt) <= 0 : reel_startpos(cnt) += reel_length_px
						reel_pos(cnt) = reel_startpos(cnt) - movebase * (frametime - reel_starttime(cnt))
				} else {
						if startmode == 1 {
							reel_pos(cnt) = reel_startpos(cnt) - movebase * (frametime - reel_starttime(cnt)) / 2
						} else {
							reel_pos(cnt) = reel_startpos(cnt) - movebase * (frametime - reel_starttime(cnt)) * (frametime - reel_starttime(cnt)) / (reel_starttime2 * 2)
						}
				}
				swbreak
			case 5
				if frametime - reel_starttime(cnt) >= 0 {
					reel_status(cnt) = 4
					SetReelStatus cnt, 4
				}
				swbreak
		swend
		reel_pos(cnt) = reel_pos(cnt) \ reel_length_px
		if reel_pos(cnt) < 0 {
				reel_pos(cnt) += reel_length_px
		}
	loop
	setreelcolor
	DrawReel reel_pos(0), reel_pos(1), reel_pos(2)
	return

#deffunc _OnReelStop var prm1
	reelstopcallback = prm1
	return

#deffunc _OnReelStoping var prm1
	reelstopingcallback = prm1
	return

#deffunc _OnAllReelStop var prm1
	allreelstopcallback = prm1
	return

#deffunc _OnTenpai var prm1
	tenpaicallback = prm1
	return

#define global OnReelStop(%1) labelname = %1 : _OnReelStop labelname
#define global OnReelStoping(%1) labelname = %1 : _OnReelStoping labelname
#define global OnAllReelStop(%1) labelname = %1 : _OnAllReelStop labelname
#define global OnTenpai(%1) labelname = %1 : _OnTenpai labelname


#deffunc ReelStart int prm1, int prm2, int prm3
	stop_count = 0
	delay(0) = prm1, prm2, prm3
	repeat 3
		if reel_status(cnt) == 1 : reel_pos(cnt) = reel_stoppos(cnt)
		if delay(cnt) == 0 : reel_status(cnt) = 4 : else : reel_status(cnt) = 5
		SetReelStatus cnt, reel_status(cnt)
		reel_startpos(cnt) = reel_pos(cnt)
		reel_starttime(cnt) = frametime + delay(cnt)
	loop
	canstop = TRUE
	return

#deffunc SetReelControlCode int prm1
	if (prm1 < 0) || (prm1 >= rct_count) {
		dialog "”ÍˆÍŠO‚Ì’l‚Å‚·", 1, "SetReelControlCode"
		stop
	}
	rcc = prm1
	return

#defcfunc LoadRCTData str prm1
/*--
	int idx
	int i, j
	int offset
	int filesize
	int size
	int slidetable_count
	sdim buf
--*/
	exist prm1
	filesize = strsize
	if filesize <= 0 : return FALSE 
	sdim buf, 12
	bload prm1, buf, 12
	if strmid(buf, 0, 4) != "RCT1" : return FALSE
	rct_count = lpeek(buf, 4)
	reel_length = peek(buf, 9)
	yaku_count = peek(buf,10)
	maxline = peek(buf,11)

	dim reel_char, reel_length, 3
	dim yaku_list, yaku_count
	dim betline, 4, maxline 

	offset = 12
	size = reel_length * 3
	idx = 0
	sdim buf, size
	bload prm1, buf, size, offset
	for i,0,3,1
		for j,0,reel_length,1
			reel_char(j,i) = peek(buf,idx)
			idx++
		next
	next

	offset += size
	size = yaku_count * 2
	sdim buf, size
	bload prm1, buf, size, offset
	idx = 0
	for i,0,yaku_count,1
		yaku_list(i) = wpeek(buf,idx)
		idx += 2
		for j,0,3,1
			if (yaku_list(i) >> j * 4 & $0F) == $0F : yaku_list(i) += ($F0000 << j * 4)
		next
	next

	offset += size
	size = maxline * 4
	sdim buf, size
	bload prm1, buf, size, offset
	idx = 0
	for i,0,maxline,1
		for j,0,4,1
			betline(j,i) = peek(buf,idx)
			idx++
		next
	next

	offset +=size
	sdim buf, 2
	bload prm1, buf, 2, offset
	slidetable_count = wpeek(buf, 0)

	offset += 2
	size = slidetable_count * reel_length
	sdim slidetable, size
	bload prm1, slidetable, size, offset

	offset += size
	size = rct_count * 3 * 2
	sdim tablenum1st, size
	bload prm1, tablenum1st, size, offset

	offset += size
	size = rct_count * 6 * reel_length * 2
	sdim tablenum2nd, size
	bload prm1, tablenum2nd, size, offset
	
	offset += size
	size = rct_count * 6 * reel_length * reel_length * 2
	sdim tablenum3rd, size
	bload prm1, tablenum3rd, size, offset

	offset += size
	return offset == filesize

#defcfunc GetTableNum int prm1
/*--
	int ret
	int idx
--*/
	switch(stop_count)
		case 0
			ret = wpeek(tablenum1st, (rcc * 3 + prm1) * 2)
			stop_pattern = prm1 * 3
			swbreak
		case 1
			stop_pattern += prm1 - 1
			if stop_pattern > 3 : stop_pattern--
			idx = rcc * 6 * reel_length
			idx += stop_pattern * reel_length
			idx += stop_pos(0)
			ret = wpeek(tablenum2nd, idx * 2)
			swbreak
		case 2
			idx = rcc * 6 * reel_length * reel_length
			idx += stop_pattern * reel_length * reel_length
			idx += stop_pos(0) * reel_length
			idx += stop_pos(1)
			ret = wpeek(tablenum3rd, (idx) * 2)
			swbreak
	swend
	return ret
	
#deffunc _ReelStopEx int reel, int slide
/*--
	int dummy
	int slide
--*/
	if GetStopButtonStatus(reel) == BS_ENABLE {
		dummy = GetTableNum(reel)
		canstop = FALSE
		stop_pos(stop_count) = (reel_pos(reel) / reel_char_h - slide + reel_length) \ reel_length
		reel_stoppos(reel) = stop_pos(stop_count) * reel_char_h
		reel_stoptime(reel) = frametime + double(slide * reel_char_h + (reel_pos(reel) \ reel_char_h)) / movebase
		reel_status(reel) = 2
		SetReelStatus reel, 2
		return stop_pos(stop_count)		
	}
	return -1

#defcfunc ReelStopEx int prm1, int prm2
	_ReelStopEx prm1, prm2
	return stat


#deffunc _ReelStop int reel
/*--
	int slide
	int num
--*/
	if GetStopButtonStatus(reel) == BS_ENABLE {
		canstop = FALSE
		num = GetTableNum(reel)
		slide = peek(slidetable, reel_length * num + reel_pos(reel) / reel_char_h)
		stop_pos(stop_count) = (reel_pos(reel) / reel_char_h - slide + reel_length) \ reel_length
		reel_stoppos(reel) = stop_pos(stop_count) * reel_char_h
		reel_stoptime(reel) = frametime + double(slide * reel_char_h + (reel_pos(reel) \ reel_char_h)) / movebase
		reel_status(reel) = 2
		SetReelStatus reel, 2
		return stop_pos(stop_count)		
	}
	return -1

#defcfunc ReelStop_old int prm1
	_ReelStop prm1
	if stat != -1 : return TRUE
	return FALSE

#defcfunc ReelStop_new int prm1
	_ReelStop prm1
	return stat



#deffunc SetBlurMode int _blurmode
	if initialized {
		_SetBlurMode _blurmode, rpm
		blurmode = _blurmode
	} else {
		blurmode = _blurmode
	}
	return


#deffunc _InitSlotModule str prm1, str prm2, int prm3, int prm4, int prm5, int prm6, int prm7, int prm8
/*--
	dim info
--*/
	if initialized : return FALSE
	if LoadRCTData(prm1) == FALSE {
		dialog prm1+"‚Ì“Ç‚Ýž‚Ý‚ÉŽ¸”s",1
		return FALSE
	}
	
	info(0) = varptr(reel_char), reel_length, prm3, prm4, prm5, prm6, prm7, prm8
	
	reel_char_h = prm4
	reel_length_px = reel_char_h * reel_length
	SetRPM rpm 
	SetReelInfo info
	
	if prm2 != "" {
		if LoadFlashData(prm2) == FALSE : dialog prm2+"‚Ì“Ç‚Ýž‚Ý‚ÉŽ¸”s",1
	}
	SetFlash -1
	initialized = TRUE
	SetBlurMode blurmode
	SetStartMode 2, reel_char_h * 3
	return TRUE

#defcfunc InitSlotModule str prm1, str prm2, int prm3, int prm4, int prm5, int prm6, int prm7, int prm8
	_InitSlotModule prm1, prm2, prm3, prm4, prm5, prm6, prm7, prm8
	return stat


#deffunc InitD3DEx int prm1, int prm2, int prm3, int prm4, int prm5, int prm6, int prm7, int prm8, int prm9
	InitD3D prm1, prm2, prm3, prm4, prm5, prm6, prm7, prm8, prm9
	d3dx9_version = stat
	GetD3DDeviceCaps D3DCaps
	ps_version = ((D3DCaps(51) >> 8) & $FF) * 10 + (D3DCaps(51) & $FF)
	blendop_fullsupport = (D3DCaps(8) & $800) != 0
	return
#defcfunc getReel_char int i1,int j1

return reel_char(i1,j1)
#global

#ifdef USE_NEWFUNC
#define global ReelStop ReelStop_new
#define global PayCheck PayCheck_new
#define global TenpaiCheck TenpaiCheck_new
#else
#define global ReelStop ReelStop_old
#define global PayCheck PayCheck_old
#define global TenpaiCheck TenpaiCheck_old
#endif


dim reel_pos@SlotModule, 3
dim reel_status@SlotModule, 3
dim reel_stoppos@SlotModule, 3
dim reel_startpos@SlotModule, 3
dim reel_stoptime@SlotModule, 3
dim reel_starttime@SlotModule, 3
dim maxbound@SlotModule, 3
dim boundtime@SlotModule, 3
dim boundcycle@SlotModule, 3
dim exp@SlotModule, 3
dim boundendtime@SlotModule, 3

blurmode@SlotModule = 2
SetRPM 75
