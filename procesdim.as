InitModule@FileMapping
	
#module FileMapping m_objname , m_info

#uselib "Kernel32.dll"
	#cfunc	c_CreateFileMapping "CreateFileMappingA" int , int , int , int , int , sptr
	#cfunc	c_GetLastError "GetLastError"
	#cfunc	c_MapViewOfFile "MapViewOfFile" int , int, int, int, int
	#func	f_UnmapViewOfFile "UnmapViewOfFile" int
	#func	f_CloseHandle "CloseHandle" int

	#define INVALID_HANDLE_VALUE	$FFFFFFFF
	#define PAGE_READWRITE			$00000004
	#define ERROR_ALREADY_EXISTS	$000000B7
	#define FILE_MAP_WRITE			$00000002
	
//	InitModule@FileMapping
;[引数無し]
;[戻り値無し]
;[説明]
;	AllocSharedMemory を使用するための初期化
#deffunc local InitModule
	SharedMemoryKey = "Hsp_MyFileMapObjModule_"	;	オブジェクト名の先頭に追加する文字列
	dim TotalNumberOfObjectsCreatedEver				;	今までつくられた共有変数の総数である。
	return

//	sharedkey str 
;	1	鍵と成る文字列
;[戻り値無し]
;[説明]
;	鍵と成る文字列を設定する
#deffunc sharedkey str sotn_string_
	SharedMemoryKey = sotn_string_
	return
	
//	gdimtype var , int , int
//	gdim var , int
//	gsdim var , int
//	gddim var , int
;	1	共有変数と成るする変数名
;	2	共有変数の配列数
;			一次元配列までしか指定できない。
;	3	vartype() 関数で返る定数の値を指定する。
;[戻り値]
;	エラーコード
;[使用例]
//	プロセス間共有変数を作成する
;	sharedkey "sk_test"
;		gdimtype sm_Flg , 1 , vartype( "int" ) ; int 型の共有変数を作成する。
;		gdimtype sm_Flg , 300 , vartype( "str" ) ; str 型の共有変数を作成する。

#deffunc gdimtype var asm_var_ , int asm_length_ , int asm_type_
	objname = strf("%s[%01x%08x%08x]" , SharedMemoryKey , asm_type_ , asm_length_ , TotalNumberOfObjectsCreatedEver)
	TotalNumberOfObjectsCreatedEver++
	newmod ModvarFileMap , FileMapping , asm_var_ , asm_length_ , asm_type_ , objname
	return stat

#define global gdim(%1,%2)\
	gdimtype %1,%2,vartype("int")

#define global gsdim(%1,%2)\
	gdimtype %1,%2,vartype("str")

#define global gddim(%1,%2)\
	gdimtype %1,%2,vartype( "double" )

//	newmod modvar , FileMapping , svar , length , vartype() , objname
;	1	共有変数と成る変数名
;	2	要素数
;	3	タイプ
;	4	オブジェクトの名前
;[戻り値]
;	エラーコード
;	負数である限りエラーが発生している。
;[説明]
;	プロセス間共有変数を作成する。
#modinit var nm_var_ , int nm_size_ , int nm_type_ , str nm_objname_
	
	dim m_info , 6
		#define m_hMapObj	m_info.0
		#define m_lpData	m_info.1
		#define m_length	m_info.2
		#define m_type		m_info.3
		#define m_elesize	m_info.4
		#define m_bufsize	m_info.5
	
	m_objname	= nm_objname_
	m_length	= nm_size_
	m_type		= nm_type_
	
	switch m_type
		case vartype( "int" )	: m_EleSize = 4 : swbreak
		case vartype( "str" )	: m_EleSize = 1 : swbreak
		case vartype( "double" ): m_EleSize = 8 : swbreak
		default
			dialog "変数タイプの指定が無効です。",1,"newmod modvar , filemapping" : end
	swend
	
	m_bufsize	= ( m_length * m_elesize )
	
	if c_CreateFileMapping( INVALID_HANDLE_VALUE , 0 , PAGE_READWRITE , 0 , m_bufsize , varptr( m_objname ) ) {
		m_hMapObj	= stat		
		ErrCode		= c_GetLastError()
		
		if c_MapViewOfFile( m_hMapObj , FILE_MAP_WRITE , 0,0,0 ) {
			m_lpData = stat
			
			dupptr nm_var_ , m_lpData , m_bufsize , m_type
			if ErrCode = ERROR_ALREADY_EXISTS { return ErrCode } else { return 0 }
			
		}else{ return -1 }
		
	}else{ return -2 }

//	オブジェクトとメモリーをcloseする
;	任意に使用しなくても終了時に自動的に実行される
#modterm
	f_UnmapViewOfFile m_lpData
	f_CloseHandle m_hMapObj
	return

#global