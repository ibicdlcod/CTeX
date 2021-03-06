﻿;Internal Headers
!include "WordFunc.nsh"
!include "Sections.nsh"
!include "TextReplace.nsh"
;TextReplace may need to be installed, see the zip in "libs\external\"
!include "TextFunc.nsh"
!include "StrFunc.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"

;External Headers
!include "libs\external\LogicLib_Ext.nsh"
!include "libs\external\EnvVarUpdate.nsh"
!include "libs\external\FileAssoc.nsh"
!include "libs\external\UninstByLog.nsh"

; Variables
Var Version
Var MiKTeX
Var Addons
Var Ghostscript
Var GSview
Var WinEdt
Var UN_INSTDIR
Var UN_Version
Var UN_MiKTeX
Var UN_Addons
Var UN_Ghostscript
Var UN_GSview
Var UN_WinEdt
Var SMCTEX

!macro _CreateURLShortCut URLFile URLSite
	WriteINIStr "${URLFile}.URL" "InternetShortcut" "URL" "${URLSite}"
!macroend
!define CreateURLShortCut "!insertmacro _CreateURLShortCut"

!macro _AppendPath DIR
	SetDetailsPrint none
	${If} ${UserIsAdmin}
		${EnvVarUpdate} $R0 "PATH" "A" "HKLM" "${DIR}"
	${Else}
		${EnvVarUpdate} $R0 "PATH" "A" "HKCU" "${DIR}"
	${EndIf}
	SetDetailsPrint both
!macroend
!define AppendPath "!insertmacro _AppendPath"

!macro _AddEnvVar NAME VALUE
	${If} ${UserIsAdmin}
		WriteRegExpandStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "${NAME}" "${VALUE}"
	${Else}
		WriteRegExpandStr HKCU "Environment" "${NAME}" "${VALUE}"
	${EndIf}
!macroend
!define AddEnvVar "!insertmacro _AddEnvVar"

!macro _RemovePath UN DIR
	SetDetailsPrint none
	${If} ${UserIsAdmin}
		${${UN}EnvVarUpdate} $R1 "PATH" "R" "HKLM" "${DIR}"
	${EndIf}
	${${UN}EnvVarUpdate} $R1 "PATH" "R" "HKCU" "${DIR}"
	SetDetailsPrint both
!macroend
!define RemovePath '!insertmacro _RemovePath ""'
!define un.RemovePath '!insertmacro _RemovePath "un."'

!macro _RemoveEnvVar NAME
	${If} ${UserIsAdmin}
		DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "${NAME}"
	${EndIf}
	DeleteRegValue HKCU "Environment" "${NAME}"
!macroend
!define RemoveEnvVar "!insertmacro _RemoveEnvVar"

!macro Define_Func_RemoveToken UN
Function ${UN}RemoveToken
	StrCpy $R9 ""
	StrCpy $R8 0
	${Do}
		${${UN}StrTok} $R7 $R0 $R2 $R8 "1"
		${If} $R7 == ""
			${ExitDo}
		${EndIf}
		${Do}
			StrCpy $R6 $R7 1
			${If} $R6 != " "
				${ExitDo}
			${EndIf}
			StrCpy $R7 $R7 "" 1                ;  Remove leading space
		${Loop}
		${Do}
			StrCpy $R6 $R7 1 -1
			${If} $R6 != " "
				${ExitDo}
			${EndIf}
			StrCpy $R7 $R7 -1                  ;  Remove trailing space
     ${Loop}
		${If} $R7 != $R1                     ;  Remove existing target
		${AndIf} $R7 != ""
			${If} $R9 != ""
				StrCpy $R9 "$R9;$R7"
			${Else}
				StrCpy $R9 "$R7"
			${EndIf}
		${EndIf}
		IntOp $R8 $R8 + 1
	${Loop}
FunctionEnd
!macroend
!insertmacro Define_Func_RemoveToken ""
!insertmacro Define_Func_RemoveToken "un."

!macro _Remove_MiKTeX_Roots
	RMDir /r "$APPDATA\MiKTeX"
	RMDir /r "$LOCALAPPDATA\MiKTeX"
	SetShellVarContext all
	RMDir /r "$APPDATA\MiKTeX"
	SetShellVarContext current
	RMDir /r "$INSTDIR\${UserData_Dir}"
!macroend

!macro Install_Config_MiKTeX
	${If} $MiKTeX != ""
		DetailPrint "Install MiKTeX configs"

		!insertmacro _Remove_MiKTeX_Roots

		StrCpy $0 "$INSTDIR\${MiKTeX_Dir}"
		StrCpy $1 "$0\miktex\bin"

		StrCpy $9 "Software\MiKTeX.org\MiKTeX\$MiKTeX"
		WriteRegStr HKLM "$9\Core" "CommonInstall" "$0"
		WriteRegStr HKLM "$9\Core" "CommonData" "$INSTDIR\${UserData_Dir}"
		WriteRegStr HKLM "$9\Core" "CommonConfig" "$INSTDIR\${UserData_Dir}"
		WriteRegStr HKLM "$9\Core" "UserData" "$INSTDIR\${UserData_Dir}"
		WriteRegStr HKLM "$9\Core" "UserConfig" "$INSTDIR\${UserData_Dir}"
		WriteRegStr HKLM "$9\Core" "UserInstall" "$INSTDIR\${UserData_Dir}"
		WriteRegStr HKLM "$9\MPM" "AutoInstall" "1"
		WriteRegStr HKLM "$9\MPM" "RemoteRepository" "http://mirrors.ustc.edu.cn/CTAN/systems/win32/miktex/tm/packages/"
		WriteRegStr HKLM "$9\MPM" "RepositoryType" "remote"

		${AppendPath} "$INSTDIR\${UserData_Dir}\miktex\bin"
		${AppendPath} "$1"

; ShortCuts
		StrCpy $9 "$SMCTEX\MiKTeX"
		CreateDirectory "$9"
		CreateShortCut "$9\Previewer.lnk" "$1\yap.exe"
		CreateShortCut "$9\TeXworks.lnk" "$1\miktex-texworks.exe"

		StrCpy $9 "$SMCTEX\MiKTeX\Maintenance"
		CreateDirectory "$9"
		CreateShortCut "$9\Package Manager.lnk" "$1\mpm_mfc.exe"
		CreateShortCut "$9\Settings.lnk" "$1\mo.exe"
		CreateShortCut "$9\Update.lnk" "$1\internal\copystart.exe" '"$1\internal\miktex-update.exe"'

		StrCpy $9 "$SMCTEX\MiKTeX\Maintenance (Admin)"
		CreateDirectory "$9"
		CreateShortCut "$9\Package Manager (Admin).lnk" "$1\mpm_mfc_admin.exe"
		CreateShortCut "$9\Settings (Admin).lnk" "$1\mo_admin.exe"
		CreateShortCut "$9\Update (Admin).lnk" "$1\internal\copystart_admin.exe" '"$1\internal\miktex-update_admin.exe"'

		StrCpy $9 "$SMCTEX\MiKTeX\Help"
		CreateDirectory "$9"
		CreateShortCut "$9\FAQ.lnk" "$0\doc\miktex\faq.chm"
		CreateShortCut "$9\Manual.lnk" "$0\doc\miktex\miktex.chm"

		StrCpy $9 "$SMCTEX\MiKTeX\MiKTeX on the Web"
		CreateDirectory "$9"
		${CreateURLShortCut} "$9\Give back" "http://miktex.org/giveback"
		${CreateURLShortCut} "$9\Known Issues" "http://miktex.org/2.8/issues"
		${CreateURLShortCut} "$9\MiKTeX Project Page" "http://miktex.org/"
		${CreateURLShortCut} "$9\Support" "http://miktex.org/support"

		DetailPrint "Update MiKTeX settings"
		nsExec::Exec "$1\mpm.exe --register-components --quiet --admin"
		nsExec::Exec "$1\initexmf.exe --force --mklinks --quiet --admin"
		nsExec::Exec "$1\yap.exe --register"
	${EndIf}
!macroend

!macro Uninstall_Config_MiKTeX UN
	${If} $UN_MiKTeX != ""
		DetailPrint "Uninstall MiKTeX configs"

		nsExec::Exec "$UN_INSTDIR\${MiKTeX_Dir}\miktex\bin\mpm.exe --unregister-components --quiet --admin"

		DeleteRegKey HKLM "Software\MiKTeX.org"
		DeleteRegKey HKCU "Software\MiKTeX.org"

		${${UN}RemovePath} "$UN_INSTDIR\${MiKTeX_Dir}\miktex\bin"
		${${UN}RemovePath} "$UN_INSTDIR\${UserData_Dir}\miktex\bin"
		${${UN}RemovePath} "$APPDATA\MiKTeX\$UN_MiKTeX\miktex\bin"

		!insertmacro _Remove_MiKTeX_Roots
		
		RMDir /r "$SMCTEX\MiKTeX"
	${EndIf}
!macroend

!macro Install_Config_Addons
	${If} $Addons != ""
		DetailPrint "Install CTeX Addons configs"

		StrCpy $0 "$INSTDIR\${Addons_Dir};$INSTDIR\${Addons_Dir}\Packages"

		StrCpy $9 "Software\MiKTeX.org\MiKTeX\$MiKTeX\Core"
		ReadRegStr $R0 HKLM "$9" "CommonRoots"
		${If} $R0 == ""
			WriteRegStr HKLM "$9" "CommonRoots" "$0"
		${Else}
			StrCpy $R1 "$0"
			StrCpy $R2 ";"
			Call RemoveToken
			WriteRegStr HKLM "$9" "CommonRoots" "$0;$R9"
		${EndIf}

		${AppendPath} "$0\ctex\bin"

; Install CCT
		${AppendPath} "$0\cct\bin"
		${AddEnvVar} "CCHZPATH" "$0\cct\fonts"
		${AddEnvVar} "CCPKPATH" "$0\fonts\pk\modeless\cct\dpi$$d"
	
		FileOpen $R0 "$0\cct\bin\cctinit.ini" "w"
		FileWrite $R0 "-T$0\fonts\tfm\cct$\n"
		FileWrite $R0 "-H$0\tex\latex\cct$\n"
		FileClose $R0
	
		nsExec::Exec "$0\cct\bin\cctinit.exe"

; Install TY
		${AppendPath} "$0\ty\bin"

		FileOpen $R0 "$0\ty\bin\tywin.cfg" "w"
		FileWrite $R0 "$0\fonts\tfm\ty\$\r$\n"
		FileWrite $R0 "$0\fonts\pk\modeless\ty\DPI@Rr\$\r$\n"
		FileWrite $R0 ".\$\r$\n"
		FileWrite $R0 "$0\ty\bin\$\r$\n"
		FileWrite $R0 "$FONTS\$\r$\n"
		FileWrite $R0 "600$\r$\n1095$\r$\n"
		FileWrite $R0 "simsun.ttc$\r$\nsimkai.ttf$\r$\nsimfang.ttf$\r$\nsimhei.ttf$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\n"
		FileWrite $R0 "simsun.ttc$\r$\nsimyou.ttf$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\nsimli.ttf$\r$\nsimsun.ttc$\r$\nsimsun.ttc$\r$\n"
		FileWrite $R0 "0$\r$\n0$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n$\r$\n0$\r$\n0$\r$\n0$\r$\n0$\r$\n0$\r$\n"
		FileClose $R0

; ShortCuts
		CreateShortCut "$SMCTEX\FontSetup.lnk" "$0\CTeX\bin\FontSetup.exe"

		StrCpy $9 "$SMCTEX\Help"
		StrCpy $8 "$0\CTeX\doc"
		CreateDirectory "$9"
		CreateShortCut "$9\插图指南.lnk" "$8\graphics.pdf"
		CreateShortCut "$9\LaTeX 笔记第二版.lnk" "$8\lnotes2.pdf"
		CreateShortCut "$9\(English)Mathematics.lnk" "$8\ch8.pdf"
		
		;CreateShortCut "$9\CTeX 常见问题.lnk" "$8\ctex-faq.pdf"
		;ctex-faq is deprecated
		
		;CreateShortCut "$9\Symbols.lnk" "$8\symbols.pdf"
		;But where is this symbol.pdf?
		
		;CreateShortCut "$9\LaTeX Short.lnk" "$8\lshort-cn.pdf"
		;lshort is deprecated
		
	${EndIf}
!macroend

!macro Uninstall_Config_Addons UN
	${If} $UN_Addons != ""
		DetailPrint "Uninstall CTeX Addons configs"

		StrCpy $0 "$UN_INSTDIR\${Addons_Dir}"
	
		StrCpy $9 "Software\MiKTeX.org\MiKTeX\$UN_MiKTeX\Core"
		ReadRegStr $R0 HKLM "$9" "Roots"
		${If} $R0 != ""
			StrCpy $R1 "$0"
			StrCpy $R2 ";"
			Call ${UN}RemoveToken
			WriteRegStr HKLM "$9" "Roots" "$R9"
		${EndIf}

		${${UN}RemovePath} "$0\ctex\bin"

; Uninstall CCT
		${${UN}RemovePath} "$0\cct\bin"
		${RemoveEnvVar} "CCHZPATH"
		${RemoveEnvVar} "CCPKPATH"

; Uninstall TY
		${${UN}RemovePath} "$0\ty\bin"

; Uninstall ShortCuts
		Delete "$SMCTEX\FontSetup.lnk"
		RMDir /r "$SMCTEX\Help"
	${EndIf}
!macroend

!macro Install_Config_Ghostscript
	${If} $Ghostscript != ""
		DetailPrint "Install Ghostscript configs"

		StrCpy $0 "$INSTDIR\${Ghostscript_Dir}"
		StrCpy $1 "$0\gs$Ghostscript"
		
		StrCpy $9 "Software\GPL Ghostscript\$Ghostscript"
		WriteRegStr HKLM "$9" "GS_DLL" "$1\bin\gsdll32.dll"
		WriteRegStr HKLM "$9" "GS_LIB" "$1\lib;$0\fonts;$FONTS"
	
		${AppendPath} "$1\bin"
	
; ShortCuts
		StrCpy $9 "$SMCTEX\Ghostcript"
		CreateDirectory "$9"
		CreateShortCut "$9\Ghostscript.lnk" "$1\bin\gswin32.exe" '"-I$1\lib;$0\fonts;$FONTS"'
		CreateShortCut "$9\Ghostscript Readme.lnk" "$1\doc\Readme.htm"
	${EndIf}
!macroend

!macro Uninstall_Config_Ghostscript UN
	${If} $UN_Ghostscript != ""
		DetailPrint "Uninstall Ghostscript configs"

		DeleteRegKey HKLM "Software\GPL Ghostscript"
	
		${${UN}RemovePath} "$UN_INSTDIR\${Ghostscript_Dir}\gs$UN_Ghostscript\bin"

		RMDir /r "$SMCTEX\Ghostscript"
	${EndIf}
!macroend

!macro Install_Config_GSview
	${If} $GSview != ""
		DetailPrint "Install GSview configs"

		StrCpy $0 "$INSTDIR\${GSview_Dir}"
	
		${AppendPath} "$0\gsview"
	
		StrCpy $9 "$0\gsview\resources"
		!insertmacro APP_ASSOCIATE "ps" "CTeX.PS" "PS $(Desc_File)" "$9\pagePS.ico,0" "Open with GSview" '$9 "%1"'
		!insertmacro APP_ASSOCIATE "eps" "CTeX.EPS" "EPS $(Desc_File)" "$9\pageEPS.ico,0" "Open with GSview" '$9 "%1"'
	
; ShortCuts
		StrCpy $9 "$SMCTEX\gsview"
		CreateDirectory "$9"
		CreateShortCut "$9\GSview.lnk" "$0\gsview\bin\gsview.exe"
		CreateShortCut "$9\PS to text.lnk" "$0\pstotext\pstotxt.exe"
	${EndIf}
!macroend

!macro Uninstall_Config_GSview UN
	${If} $UN_GSview != ""
		DetailPrint "Uninstall GSview configs"

		DeleteRegKey HKLM "Software\Ghostgum"
	
		${${UN}RemovePath} "$UN_INSTDIR\${GSview_Dir}\gsview"
	
		!insertmacro APP_UNASSOCIATE "ps" "CTeX.PS"
		!insertmacro APP_UNASSOCIATE "eps" "CTeX.EPS"

		RMDir /r "$SMCTEX\Ghostgum"
	${EndIf}
!macroend

!macro Install_Config_WinEdt
	${If} $WinEdt != ""
		DetailPrint "Install WinEdt configs"

		RMDir /r "$APPDATA\WinEdt"

		StrCpy $0 "$INSTDIR\${WinEdt_Dir}"
		WriteRegStr HKLM "Software\WinEdt" "Install Root" "$0"
		WriteRegStr HKCU "Software\VB and VBA Program Settings\TexFriend\Options" "StartupByWinEdt" "False"

		${AppendPath} "$0"
	
		StrCpy $9 "$0\WinEdt.exe"
		!insertmacro APP_ASSOCIATE "tex" "CTeX.TeX" "TeX $(Desc_File)" "$9,0" "Open with WinEdt" '$9 "%1"'
	
; ShortCuts
		StrCpy $9 "$SMCTEX"
		CreateDirectory "$9"
		CreateShortCut "$9\WinEdt.lnk" "$INSTDIR\${WinEdt_Dir}\WinEdt.exe"
		CreateShortCut "$9\切换WinEdt默认编码.lnk" "$INSTDIR\${WinEdt_Dir}\切换编码.exe"

		${If} $MiKTeX != ""
			WriteRegStr HKCU "Software\MiKTeX.org\MiKTeX\$MiKTeX\Yap\Settings" "Editor" '$INSTDIR\${WinEdt_Dir}\winedt.exe "[Open(|%f|);SelPar(%l,8)]"'
			CreateDirectory "$INSTDIR\${UserData_Dir}\miktex\config"
			WriteINIStr "$INSTDIR\${UserData_Dir}\miktex\config\yap.ini" "Settings" "Editor" '$INSTDIR\${WinEdt_Dir}\winedt.exe "[Open(|%f|);SelPar(%l,8)]"'
		${EndIf}
	${EndIf}
!macroend

!macro Uninstall_Config_WinEdt UN
	${If} $UN_WinEdt != ""
		DetailPrint "Uninstall WinEdt configs"

		DeleteRegKey HKLM "Software\WinEdt"
		DeleteRegKey HKCU "Software\VB and VBA Program Settings\TexFriend"
	
		${${UN}RemovePath} "$UN_INSTDIR\${WinEdt_Dir}"

		!insertmacro APP_UNASSOCIATE "tex" "CTeX.TeX"

		RMDir /r "$APPDATA\WinEdt"

		Delete "$SMCTEX\WinEdt.lnk"
	${EndIf}
!macroend

!macro Install_Config_CTeX
	DetailPrint "Install general configs"

	!insertmacro Save_Install_Information

	StrCpy $9 "Software\${APP_NAME}"
	WriteRegStr HKLM "$9" "" "${APP_NAME} ${APP_VERSION}"
	WriteRegStr HKLM "$9" "Install" "$INSTDIR"
	WriteRegStr HKLM "$9" "Version" "$Version"
	WriteRegStr HKLM "$9" "MiKTeX" "$MiKTeX"
	WriteRegStr HKLM "$9" "Addons" "$Addons"
	WriteRegStr HKLM "$9" "Ghostscript" "$Ghostscript"
	WriteRegStr HKLM "$9" "GSview" "$GSview"
	WriteRegStr HKLM "$9" "WinEdt" "$WinEdt"

	StrCpy $9 "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
	WriteRegStr HKLM "$9" "DisplayName" "${APP_NAME}"
	WriteRegStr HKLM "$9" "DisplayVersion" "$Version"
	WriteRegStr HKLM "$9" "DisplayIcon" "$INSTDIR\Uninstall.exe,0"
	WriteRegStr HKLM "$9" "Publisher" "${APP_COMPANY}"
	WriteRegStr HKLM "$9" "Readme" "$INSTDIR\Readme.txt"
	WriteRegStr HKLM "$9" "HelpLink" "http://bbs.ctex.org"
	WriteRegStr HKLM "$9" "URLInfoAbout" "http://www.ctex.org"
	WriteRegStr HKLM "$9" "UninstallString" "$INSTDIR\Uninstall.exe"

	StrCpy $9 "$INSTDIR\${MiKTeX_Dir}\miktex\bin"
	DetailPrint "Update MiKTeX file name database"
	nsExec::Exec "$9\initexmf.exe --update-fndb --quiet --admin"
	nsExec::Exec "$9\initexmf.exe --update-fndb --quiet"
	DetailPrint "Update MiKTeX updmap database"
	nsExec::Exec "$9\initexmf.exe --mkmaps --quiet --admin"

	!insertmacro UPDATEFILEASSOC
!macroend

!macro Uninstall_Config_CTeX UN
	DetailPrint "Uninstall general configs"

	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
	DeleteRegKey HKLM "Software\${APP_NAME}"

	Delete "$UN_INSTDIR\${Logs_Dir}\install.ini"

	RMDir /r "$SMCTEX"

	!insertmacro UPDATEFILEASSOC
!macroend

!macro _Install_Files Files Log_File
	CreateDirectory "$INSTDIR\${Logs_Dir}"
	LogSet on
	File /r "${Files}"
	LogSet off
	Delete "$INSTDIR\${Logs_Dir}\${Log_File}"
	Rename "$INSTDIR\install.log" "$INSTDIR\${Logs_Dir}\${Log_File}"
	!insertmacro Compress_Log "$INSTDIR\${Logs_Dir}\${Log_File}"
!macroend
!define Install_Files "!insertmacro _Install_Files"

!macro _Begin_Install_Files
	CreateDirectory "$INSTDIR\${Logs_Dir}"
	LogSet on
!macroend
!define Begin_Install_Files "!insertmacro _Begin_Install_Files"

!macro _End_Install_Files Log_File
	LogSet off
	Delete "$INSTDIR\${Logs_Dir}\${Log_File}"
	Rename "$INSTDIR\install.log" "$INSTDIR\${Logs_Dir}\${Log_File}"
	!insertmacro Compress_Log "$INSTDIR\${Logs_Dir}\${Log_File}"
!macroend
!define End_Install_Files "!insertmacro _End_Install_Files"

!macro Uninstall_All_Configs UN
	${If} $UN_INSTDIR != ""
		!insertmacro Uninstall_Config_CTeX "${UN}"
		!insertmacro Uninstall_Config_WinEdt "${UN}"
		!insertmacro Uninstall_Config_GSview "${UN}"
		!insertmacro Uninstall_Config_Ghostscript "${UN}"
		!insertmacro Uninstall_Config_Addons "${UN}"
		!insertmacro Uninstall_Config_MiKTeX "${UN}"
	${EndIf}
!macroend

!macro Uninstall_All_Files UN
	${If} $UN_INSTDIR != ""
		DetailPrint "Uninstall old files"
		${${UN}Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install.log"
		${${UN}Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_winedt.log"
		${${UN}Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_gsview.log"
		${${UN}Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_ghostscript.log"
		${${UN}Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_addons.log"
		${${UN}Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_miktex.log"
		RMDir "$UN_INSTDIR\${Logs_Dir}"
		RMDir "$UN_INSTDIR\${WinEdt_Dir}"
		RMDir "$UN_INSTDIR\${GSview_Dir}"
		RMDir "$UN_INSTDIR\${Ghostscript_Dir}"
		RMDir "$UN_INSTDIR\${Addons_Dir}"
		RMDir "$UN_INSTDIR\${MiKTeX_Dir}"
	${EndIf}
!macroend

!macro Save_Install_Information
	StrCpy $9 "$INSTDIR\${Logs_Dir}\install.ini"
	WriteINIStr "$9" "CTeX" "Install" "$INSTDIR"
	WriteINIStr "$9" "CTeX" "Version" "$Version"
	WriteINIStr "$9" "CTeX" "MiKTeX" "$MiKTeX"
	WriteINIStr "$9" "CTeX" "Addons" "$Addons"
	WriteINIStr "$9" "CTeX" "Ghostscript" "$Ghostscript"
	WriteINIStr "$9" "CTeX" "GSview" "$GSview"
	WriteINIStr "$9" "CTeX" "WinEdt" "$WinEdt"
!macroend

!macro Restore_Install_Information
	StrCpy $9 "$INSTDIR\${Logs_Dir}\install.ini"
	${If} ${FileExists} "$9"
		ReadINIStr $Version "$9" "CTeX" "Version"
		ReadINIStr $MiKTeX "$9" "CTeX" "MiKTeX"
		ReadINIStr $Addons "$9" "CTeX" "Addons"
		ReadINIStr $Ghostscript "$9" "CTeX" "Ghostscript"
		ReadINIStr $GSview "$9" "CTeX" "GSview"
		ReadINIStr $WinEdt "$9" "CTeX" "WinEdt"
	${Else}
		StrCpy $Version ${APP_BUILD}
		StrCpy $MiKTeX ${MiKTeX_Version}
		StrCpy $Addons ${MiKTeX_Version}
		StrCpy $Ghostscript ${Ghostscript_Version}
		StrCpy $GSview ${GSview_Version}
		StrCpy $WinEdt ${WinEdt_Version}
	${EndIf}
!macroend

!macro Set_All_Sections_Selection
	${If} $MiKTeX != ""
		!insertmacro SelectSection ${Section_MiKTeX}
	${EndIf}
	${If} $Addons != ""
		!insertmacro SelectSection ${Section_Addons}
	${EndIf}
	${If} $Ghostscript != ""
		!insertmacro SelectSection ${Section_Ghostscript}
	${EndIf}
	${If} $GSview != ""
		!insertmacro SelectSection ${Section_GSview}
	${EndIf}
	${If} $WinEdt != ""
		!insertmacro SelectSection ${Section_WinEdt}
	${EndIf}
!macroend

!macro Set_All_Sections_ReadOnly
	!insertmacro SetSectionFlag ${Section_MiKTeX} ${SF_RO}
	!insertmacro SetSectionFlag ${Section_Addons} ${SF_RO}
	!insertmacro SetSectionFlag ${Section_Ghostscript} ${SF_RO}
	!insertmacro SetSectionFlag ${Section_GSview} ${SF_RO}
	!insertmacro SetSectionFlag ${Section_WinEdt} ${SF_RO}
!macroend

!macro Update_Install_Information
	StrCpy $Version ${APP_BUILD}
	${If} ${SectionIsSelected} ${Section_MiKTeX}
		StrCpy $MiKTeX ${MiKTeX_Version}
	${EndIf}
	${If} ${SectionIsSelected} ${Section_Addons}
		StrCpy $Addons ${MiKTeX_Version}
	${EndIf}
	${If} ${SectionIsSelected} ${Section_Ghostscript}
		StrCpy $Ghostscript ${Ghostscript_Version}
	${EndIf}
	${If} ${SectionIsSelected} ${Section_GSview}
		StrCpy $GSview ${GSview_Version}
	${EndIf}
	${If} ${SectionIsSelected} ${Section_WinEdt}
		StrCpy $WinEdt ${WinEdt_Version}
	${EndIf}
!macroend

!macro Get_Uninstall_Information
	ReadRegStr $UN_INSTDIR HKLM "Software\${APP_NAME}" "Install"
	ReadRegStr $UN_Version HKLM "Software\${APP_NAME}" "Version"
	ReadRegStr $UN_MiKTeX HKLM "Software\${APP_NAME}" "MiKTeX"
	ReadRegStr $UN_Addons HKLM "Software\${APP_NAME}" "Addons"
	ReadRegStr $UN_Ghostscript HKLM "Software\${APP_NAME}" "Ghostscript"
	ReadRegStr $UN_GSview HKLM "Software\${APP_NAME}" "GSview"
	ReadRegStr $UN_WinEdt HKLM "Software\${APP_NAME}" "WinEdt"
!macroend

!macro Update_Uninstall_Information
	${If} $UN_INSTDIR != ""
		StrCpy $INSTDIR $UN_INSTDIR
	${Else}
		StrCpy $UN_INSTDIR $INSTDIR
		StrCpy $UN_MiKTeX ${MiKTeX_Version}
		StrCpy $UN_Addons ${MiKTeX_Version}
		StrCpy $UN_Ghostscript ${Ghostscript_Version}
		StrCpy $UN_GSview ${GSview_Version}
		StrCpy $UN_WinEdt ${WinEdt_Version}
	${EndIf}
!macroend

!macro Update_Log LogFile
	${If} ${FileExists} ${LogFile}
		ReadINIStr $R0 "$INSTDIR\${Logs_Dir}\install.ini" "CTeX" "Install"
		${If} $R0 != ""
			DetailPrint "Update install log: ${LogFile}"
			${textreplace::ReplaceInFile} "${LogFile}" "${LogFile}.new" "$R0" "$INSTDIR" "/S=1" $R1
			${textreplace::Unload}
			Delete "${LogFile}"
			Rename "${LogFile}.new" "${LogFile}"
		${EndIf}
	${EndIf}
!macroend

!macro Update_All_Logs
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_winedt.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_gsview.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_ghostscript.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_packages.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_ty.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_cct.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_cjk.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_ctex.log"
	!insertmacro Update_Log "$INSTDIR\${Logs_Dir}\install_miktex.log"
!macroend

!macro Compress_Log LogFile
	${If} ${FileExists} ${LogFile}
		DetailPrint "Compress install log: ${LogFile}"
		FileOpen $0 "${LogFile}" "r"
		FileOpen $1 "${LogFile}.new" "w"
		${Do}
			FileRead $0 $9
			${If} $9 == ""
				${ExitDo}
			${EndIf}
			StrCpy $8 $9 11
			${If} $8 == "File: overw"
				${Continue}
			${EndIf}
			StrCpy $7 $9 7 -9
			${If} $8 == "CreateDirec"
			${AndIf} $7 == "created"
				${Continue}
			${EndIf}
			FileWrite $1 "$9"
		${Loop}
		FileClose $1
		FileClose $0
		Delete "${LogFile}"
		Rename "${LogFile}.new" "${LogFile}"
	${EndIf}
!macroend

!macro Check_Admin_Rights
	${IfNot} ${UserIsAdmin}
		MessageBox MB_OK|MB_ICONSTOP "$(Msg_AdminRequired)"
		Abort
	${EndIf}
!macroend

!macro Get_StartMenu_Dir
	${If} ${UserIsAdmin}
		SetShellVarContext all
	${EndIf}
	StrCpy $SMCTEX "$SMPROGRAMS\CTeX"
	SetShellVarContext current
!macroend
