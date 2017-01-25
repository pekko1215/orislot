#regcmd "_hsp3cmdinit@4","p2b.dll"
#cmd _pngmemload	$000

#module png
#deffunc pngmemload var prm1
	_pngmemload prm1
	hasAlpha = stat
	w = ginfo(12)
	h = ginfo(13)
	if hasAlpha==1 : w /= 2
	return

#deffunc pngload str filename
	mref ret, 64
	exist filename
	if strsize < 0 {
		dialog filename+"‚ª‚ ‚è‚Ü‚¹‚ñI", 1, "Error"
		ret = 0
		return
	}
	sdim buf, strsize
	bload filename, buf
	pngmemload buf
	sdim buf, 0
	ret = 1
	return

#deffunc getpnginfo array info
	info = w, h , hasAlpha
	return
	
#global
