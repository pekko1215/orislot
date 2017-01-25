goto *pn
#deffunc box int x1,int y1,int x2, int y2
	line x1,y1,x2,y1
	line x1,y1,x1,y2
	line x2,y1,x2,y2
	line x1,y2,x2,y2
return
#deffunc betlanp int inbet
	gmode 4,,,256
	color 0,255,0
	
	pos 0.7*(154+3)+1,0.7*(151-1)
	if(inbet>=3):celput 101:else:celput 100
	
	pos 0.7*(154+3)+1,0.7*231
	if(inbet>=2):celput 101:else:celput 100
	
	pos 0.7*(154+3)+1,0.7*(311+5)
	if(inbet>=1):celput 101:else:celput 100
return
#deffunc segset int num,int xp, int yp
	gmode 2
	pos xp,yp
	celput 102+num
return

#deffunc payset int pays
	color 0,0,0
	boxf 0.7*75,0.7*496,0.7*157,0.7*556
	if(pays==0):return
	boxf 0.7*75,0.7*496,0.7*157,0.7*556
	if(cnt>=10):segset 1,0.7*(122-40-5),0.7*(490+3)
	segset cnt\10,0.7*(122-5),0.7*(490+3)
	redraw
	reelwait 3
	
	repeat pays
		boxf 0.7*75,0.7*496,0.7*157,0.7*556
		if(cnt+1>=10):segset 1,0.7*(122-40-5),0.7*(490+3)
		segset (cnt+1)\10,0.7*(122-5),0.7*(490+3)
		credit++
		if(credit<=50):creditset credit:else:credit = 50
		//title "game_mode:"+game_mode+"  bonus_game_counter:"+bonus_game_counter
		redraw
		reelwait 60
	loop
	//dialog "payed"
return

#deffunc creditset int pays
	color 0,0,0
	boxf 0.7*75,0.7*404,0.7*157,0.7*(404+60)
	boxf 0.7*75,0.7*404,0.7*157,0.7*(404+60)
	if(pays>=10):segset pays/10,0.7*(122-40-5),0.7*(404+3)-2
	segset pays\10,0.7*(122-5),0.7*(404+3)-2
return

#deffunc rightset str strings
	if(oldseg == strings):return
	color 0,0,0
	_stmp = strings
	boxf int(1098.*0.7),int(0.7*179),int(0.7*(1098+140)),int(0.7*(179+366))
	repeat 3
		sstmp = strmid(_stmp,cnt,1)
		switch(sstmp)
			case "0":
			case "1":
			case "2":
			case "3":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
				i = int(sstmp)
				pos 0.7*(1098+20+10),0.7*(179+15+(114*cnt))
				celput 150+i
			swbreak
			case "-":
				pos 0.7*(1098+20+10)-13,0.7*(179+15+(114*cnt))
				celput 151
			swbreak
			case "f"
				pos 0.7*(1098+20+10),0.7*(179+15+(114*cnt))
				celput 171
		swend
		redraw
	loop
	oldseg = strings
return
#deffunc reelwait int wai
		timeGetTime
		ow = stat
		now_time = ow
		if(high_speed):return
	while now_time<ow+wai
		timeGetTime
		now_time = stat
		SetFrameTime now_time
		ReelMove
		Render
		EndScene
		Present
		await 0 : sleep 1
	wend
return
#defcfunc getStopchar int reel,int reelindex
return getReel_char((GetReelCharPos(reel)+reelindex)\21,reel)

#deffunc setRightLoop int _lo
	repeat _lo
		_str = ""
		n = cnt
		repeat 6
			if(cnt==n\6||cnt==(n+1)\6||cnt==(n+3)\6||cnt==(n+3+1)\6){
				_str = _str + "1"
			}else{
				_str = _str + "0"	
			}
		loop
		rightsetpeace _str,_str,_str
		reelwait 10
	loop
return

#deffunc RightSetPeace str _s1,str _s2,str _s3
	sdim _strtmp,3
	color 0,0,0
	boxf int(1098.*0.7),int(0.7*179),int(0.7*(1098+140)),int(0.7*(179+366))
	_strtmp(0) = _s1,_s2,_s3
	repeat 3
		i = cnt
		t = _strtmp(i)
		repeat 7
			if(strmid(t,cnt,1)=="1"){
				pos 0.7*(1098+20+10),0.7*(179+15+(114*i))
				celput 172+cnt
			}
		loop
	loop
return
#defcfunc shift_str str _s,int _i
	_strtmp = _s
	repeat abs(_i)
		if(_i<0){
			_strtmp = strmid(_strtmp,1,999)+strmid(_strtmp,0,1)
		}else{
			_strtmp = strmid(_strtmp,-1,1)+strmid(_strtmp,0,strlen(_strtmp)-1)
		}
	loop
return _strtmp
#defcfunc getHi
	i = rnd(100)
	repeat length(rt_table_table)-1
		i -= hi_table(cnt,settei)
		if(i<0){
			_rt = rt_table_table(cnt)+rnd(rt_table_table(cnt+1)-rt_table_table(cnt))
			break
		}
	loop
	if(_rt>rt&&rnd(4)<3&&rt>16):_rt = rt - 16 + rnd(3)
return _rt
#deffunc setSubFlash
	sf = 0
	switch(game_mode)
		case GM_NORMAL:
			switch(sub_mode)
				case SUB_NORMAL:
					sf = 0
				swbreak
					case SUB_HI:
					sf = 78
				swbreak
			swend
		swbreak
		case GM_BIG:
		swbreak
		case GM_JAC:
		case GM_REG:
			if(sub_mode==SUB_REG):sf = 79
	swend
	setFlash sf
return
#deffunc setUnderLanp str _s
	lanp_str = _s
	setLanpImage
return
#deffunc setLanpImage
	_size    = 32
	_start_x = 100
	_start_y = ginfo_sizey-_size-50
	_offset  = _size+32
	redraw 0
	repeat 8
		switch(strmid(lanp_str,cnt,1))
			case 0:
				color 0,0,0
			swbreak
			case 1:
				color 255,255,255
			swbreak
			case 2:
				color 255,255,0
			swbreak
			case 3:
				color 0,255,0
			swbreak
			case 4:
				color 0,0,139
				swbreak
			case 5:
				color 255,255,255
				swbreak
		swend
		circle _start_x+_offset*cnt,_start_y,_start_x+_offset*cnt+_size,_start_y+_size
		//title ""+(_start_x+_offset*cnt)+","+(_start_y)+","+(_start_x+_offset*cnt+_size)+","+(_start_y+_size)
	loop
	redraw 1
	lanp_str = Shift_str(lanp_str,1)
return
#deffunc setLanpLabel var _label,int _time,int _loop
	lanp_label = _label
	lanp_loop  = _loop
	lanp_state = _time
return
#defcfunc reversStr str _s
	dialog _s
	_st = _s
	_stmp = ""
	repeat strlen(_st)
		_stmp = _stmp + strmid(_st,length(_st)-1-cnt,1)
	loop
return _stmp
#defcfunc lotChanceTable array _loter,int opt
i = 0
rmax = 0
repeat length(_loter)
	rmax += _loter(cnt,opt)
loop
i = rnd(rmax)
repeat length(_loter)
	i -= _loter(cnt,opt)
	if(i<0){
		i = cnt
		break
	}
loop
return i
#defcfunc getRT
	_rt = -1
	i = rnd(100)
	repeat length(rt_table_table)-1
		i -= rt_table(cnt,settei)
		if(i<0){
			_rt = rt_table_table(cnt)+rnd(rt_table_table(cnt+1)-rt_table_table(cnt))
			break
		}
	loop
return _rt
#deffunc setLanpOption int _p1,int _p2,int _p3
	pl1 = _p1
	pl2 = _p2
	pl3 = _p3
return
#defcfunc insertStr str _s,str _s2,int _p1
	_stmp = _s
	//dialog strmid(_stmp,0,_p1)+_s2+strmid(_stmp,_p1+1,9999)
	if(_p1==0){
		_stmper = _s2+strmid(_stmp,1,9999) 
	}else{
		_stmper = strmid(_stmp,0,_p1)+_s2+strmid(_stmp,_p1+1,9999)
	}
return _stmper
*pn