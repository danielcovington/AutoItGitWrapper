#Region ;**** Directives created by AutoIt3Wrapper_GUI *****
#AutoIt3Wrapper_Versioning=v
#AutoIt3Wrapper_Versioning_Parameters=/Comments %fileversion%
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI *****
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <WinAPI.au3>



Global $AutoIt3WapperIni
Global Const $tagIMAGE_FILE_HEADER = _
		"ushort Machine;" & _
		"ushort NumberOfSections;" & _
		"dword TimeDateStamp;" & _
		"dword PointerToSymbolTable;" & _
		"dword NumberOfSymbols;" & _
		"ushort SizeOfOptionalHeader;" & _
		"ushort Characteristics"
Global $tagTEMP = _
		"ushort Magic;" & _ ; Standard fields
		"byte MajorLinkerVersion;" & _
		"byte MinorLinkerVersion;" & _
		"dword SizeOfCode;" & _
		"dword SizeOfInitializedData;" & _
		"dword SizeOfUninitializedData;" & _
		"dword AddressOfEntryPoint;" & _
		"dword BaseOfCode;" & _
		"dword BaseOfData;" & _
		"dword ImageBase;" & _ ; NT additional fields
		"dword SectionAlignment;" & _
		"dword FileAlignment;" & _
		"ushort MajorOperatingSystemVersion;" & _
		"ushort MinorOperatingSystemVersion;" & _
		"ushort MajorImageVersion;" & _
		"ushort MinorImageVersion;" & _
		"ushort MajorSubsystemVersion;" & _
		"ushort MinorSubsystemVersion;" & _
		"dword Win32VersionValue;" & _
		"dword SizeOfImage;" & _
		"dword SizeOfHeaders;" & _
		"dword CheckSum;" & _
		"ushort Subsystem;" & _
		"ushort DllCharacteristics;" & _
		"dword SizeOfStackReserve;" & _
		"dword SizeOfStackCommit;" & _
		"dword SizeOfHeapReserve;" & _
		"dword SizeOfHeapCommit;" & _
		"dword LoaderFlags;" & _
		"dword NumberOfRvaAndSizes"
; assign indexes to each IMAGE_DATA_DIRECTORY struct so we can find them later
For $i = 0 To 15
	$tagTEMP &= ";ulong VirtualAddress" & $i & ";ulong Size" & $i
Next
Global Const $tagIMAGE_OPTIONAL_HEADER = $tagTEMP
$tagTEMP = 0
Global Const $tagIMAGE_NT_HEADERS = _
		"dword Signature;" & _
		$tagIMAGE_FILE_HEADER & ";" & _ ; offset = 4
		$tagIMAGE_OPTIONAL_HEADER ; offset = 24
Global $g_aResNamesAndLangs[1][2] = [[0, 0]] ; reset array
Global $rh, $hLangCallback
Global $aVersionInfo, $aManifestInfo, $aTemp
Global $IconFileInfo
Global $ScriptFile_In = "", $ScriptFile_In_Ext = "", $ScriptFile_In_stripped = "", $ScriptFile_Out = "", $ScriptFile_Out_x86 = "", $ScriptFile_Out_x64 = "", $ScriptFile_Out_Type = ""
Global $INP_Compile_Both = 0
Global $INP_Icon = "", $INP_Compression = "", $INP_AutoIt3_Version = ""
Global $AutoIt3_PGM = "", $AUT2EXE_PGM = "", $INP_AutoItDir = ""
Global $Pragma_Used = 0
Global $Pragma_Out = "", $Pragma_Icon = "n", $Pragma_RES_requestedExecutionLevel = "", $Pragma_UseUpx = "", $Pragma_Change2CUI = "", $Pragma_Compression = "", $Pragma_RES_Compatibility = ""
Global $Pragma_Out_x64 = "", $Pragma_Comment = "", $Pragma_Company = "", $Pragma_Description = "", $Pragma_Fileversion = "", $Pragma_InternalName = "", $Pragma_LegalCopyright = "", $Pragma_LegalTradeMarks = ""
Global $Pragma_Productname = "", $Pragma_ProductVersion = ""
Global $INP_Run_Debug_Mode = 0, $INP_UseUpx = "", $INP_Upx_Parameters = "", $INP_UseAnsi = "n", $INP_UseX64 = "", $INP_Comment = "", $INP_Description = "", $INP_Res_SaveSource = ""
Global $INP_Res_Language = "", $INP_Res_requestedExecutionLevel = "", $INP_Res_Compatibility = "", $INP_Fileversion = "", $INP_Fileversion_New = "", $INP_Fileversion_AutoIncrement = "", $INP_Fileversion_First_Increment = "", $INP_LegalCopyright = ""
Global $INP_ProductVersion = "", $INP_CompiledScript = "", $INP_FieldName1 = "", $INP_FieldValue1 = "", $INP_FieldName2 = "", $INP_FieldValue2 = "", $INP_Res_FieldCount = 0, $INP_FieldName[16]
Global $INP_FieldValue[16], $INP_Run_Tidy = "", $INP_Run_Au3Stripper = "", $INP_Tidy_Stop_OnError = "Y", $INP_Run_AU3Check = "", $INP_Jump_To_First_Error = "Y", $INP_Add_Constants = "", $INP_Run_SciTE_Minimized = "n", $INP_Run_SciTE_OutputPane_Minimized = "n"
Global $INP_AU3Check_Stop_OnWarning, $INP_AU3Check_Parameters, $INP_Run_Before[2], $INP_Run_After[2], $INP_Run_Before_Admin[2], $INP_Run_After_Admin[2], $INP_Run_Versioning, $INP_Versioning_Parameters
Global $INP_Plugin, $INP_Change2CUI, $INP_Icons[1], $INP_Icons_cnt = 0, $INP_Res_Files[1], $INP_Res_Files_Cnt = 0, $TempFile, $TempFile2, $TempDir
Global $INP_Au3check_Plugin, $INP_Tidy_Parameters = "", $INP_Au3Stripper_Parameters = "", $INP_AutoIt3Wrapper_LogFile = "", $INP_AutoIt3Wrapper_If = "", $INP_AutoIt3Wrapper_Testing = "N"
Global $INP_Run_PreExpand = "N"
Global $INP_ShowStatus = ""
Global $ScriptFile_In_Org
Global $H_Resource, $H_Comment, $H_Description, $H_Fileversion, $H_Fileversion_AutoIncrement_n, $H_Fileversion_AutoIncrement_p, $H_Fileversion_AutoIncrement_y
Global $H_LegalCopyright, $H_FieldNameEdit, $H_Res_Language
Global $IconResBase = 49
Global $Au3StripperCmdLine
Global $DebugIcon = ""
Global $Parameter_Mode = 0
Global $Debug = 0
Global $Registry = "HKCU\Software\AutoIt v3"
Global $RegistryLM = "HKLM\Software\AutoIt v3\AutoIt"
Global $Option = "Compile"
Global $s_CMDLine = ""
Global $ToTalFile
Global $H_Outf
Global $CurSciTEFile, $CurSciTELine, $FindVer, $CurSelection
Global $dummy, $V_Arg, $T_Var, $H_Cmp, $H_au3, $rc, $Save_Workdir, $AUT2EXE_DIR, $AUT2EXE_PGM_N, $msg, $AUT2EXE_PGM_VER
Global $LSCRIPTDIR, $AutoIt_Icon, $INP_Icon_Temp, $AutoIt_Icon_Dir
Global $InputFileIsUTF8 = 0
Global $InputFileIsUTF16 = 0
Global $InputFileIsUTF32 = 0
Global $ProcessBar_Title
Global $Pid, $Handle, $Return_Text, $ExitCode
Global $sCmd
Global $SrceUnicodeFlag, $UTFtype
Global $Found_Old_ObfuscatorDirective = 0
;
Global $CurrentAutoIt_InstallDir = _PathFull(@ScriptDir & "..\..\..")
Global $TempConsOut = _TempFile("", "~ConOut")


; Check for SCITE_USERHOME Env variable and used that when specified.
; Else use Program directory
If EnvGet("SCITE_USERHOME") <> "" And FileExists(EnvGet("SCITE_USERHOME") & "\AutoIt3Wrapper") Then
	$AutoIt3WapperIni = EnvGet("SCITE_USERHOME") & "\AutoIt3Wrapper\AutoIt3Wrapper.ini"
	$UserData = EnvGet("SCITE_USERHOME") & "\AutoIt3Wrapper"
ElseIf EnvGet("SCITE_HOME") <> "" And FileExists(EnvGet("SCITE_HOME") & "\AutoIt3Wrapper") Then
	$AutoIt3WapperIni = EnvGet("SCITE_HOME") & "\AutoIt3Wrapper\AutoIt3Wrapper.ini"
	$UserData = EnvGet("SCITE_HOME") & "\AutoIt3Wrapper"
Else
	$AutoIt3WapperIni = @ScriptDir & "\AutoIt3Wrapper.ini"
	$UserData = @ScriptDir
EndIf

;Retrieve AutoIt3Wrapper Defaults from AutoIt3Wrapper.INI
If $ScriptFile_Out_Type = "" Then $ScriptFile_Out_Type = IniRead($AutoIt3WapperIni, "AutoIt", "outfile_type", "")
If $INP_Icon = "" Then $INP_Icon = IniRead($AutoIt3WapperIni, "AutoIt", "icon", "")
If $INP_Compression = "" Then $INP_Compression = IniRead($AutoIt3WapperIni, "AutoIt", "Compression", "")
;~ If $INP_PassPhrase = "" Then $INP_PassPhrase = IniRead($AutoIt3WapperIni, "AutoIt", "PassPhrase", "")
;~ If $INP_PassPhrase2 = "" Then $INP_PassPhrase2 = IniRead($AutoIt3WapperIni, "AutoIt", "PassPhrase", "")
;~ If $INP_Allow_Decompile = "" Then $INP_Allow_Decompile = IniRead($AutoIt3WapperIni, "AutoIt", "Allow_Decompile", "")
If $INP_UseUpx = "" Then $INP_UseUpx = IniRead($AutoIt3WapperIni, "AutoIt", "UseUpx", "")
;~ If $INP_UseAnsi = "" Then $INP_UseAnsi = IniRead($AutoIt3WapperIni, "AutoIt", "UseAnsi", "")
If $INP_UseX64 = "" Then $INP_UseX64 = IniRead($AutoIt3WapperIni, "AutoIt", "UseX64", "")
If $INP_AutoItDir = "" Then $AUT2EXE_PGM = IniRead($AutoIt3WapperIni, "AutoIt", "aut2exe", "")
If $INP_Res_Language = "" Then $INP_Res_Language = IniRead($AutoIt3WapperIni, "Res", "Language", "")
If $INP_Res_requestedExecutionLevel = "" Then $INP_Res_requestedExecutionLevel = IniRead($AutoIt3WapperIni, "Res", "RequestedExecutionLevel", "")
If $INP_Res_Compatibility = "" Then $INP_Res_Compatibility = IniRead($AutoIt3WapperIni, "Res", "Compatibility", "")
If $INP_Comment = "" Then $INP_Comment = IniRead($AutoIt3WapperIni, "Res", "Comment", "")
If $INP_Description = "" Then $INP_Description = IniRead($AutoIt3WapperIni, "Res", "Description", "")
If $INP_Fileversion = "" Then $INP_Fileversion = IniRead($AutoIt3WapperIni, "Res", "Fileversion", "")
If $INP_Fileversion_AutoIncrement = "" Then $INP_Fileversion_AutoIncrement = IniRead($AutoIt3WapperIni, "Res", "Fileversion_AutoIncrement", "")
If $INP_Fileversion_First_Increment = "" Then $INP_Fileversion_First_Increment = IniRead($AutoIt3WapperIni, "Res", "Fileversion_First_AutoIncrement", "")
If $INP_ProductVersion = "" Then $INP_ProductVersion = IniRead($AutoIt3WapperIni, "Res", "ProductVersion", "")
If $INP_LegalCopyright = "" Then $INP_LegalCopyright = IniRead($AutoIt3WapperIni, "Res", "LegalCopyright", "")
If $INP_Res_SaveSource = "" Then $INP_Res_SaveSource = IniRead($AutoIt3WapperIni, "Res", "SaveSource", "")
If $INP_FieldName1 = "" Then $INP_FieldName1 = IniRead($AutoIt3WapperIni, "Res", "Field1Name", "")
If $INP_FieldValue1 = "" Then $INP_FieldValue1 = IniRead($AutoIt3WapperIni, "Res", "Field1Value", "")
If $INP_FieldName2 = "" Then $INP_FieldName2 = IniRead($AutoIt3WapperIni, "Res", "Field2Name", "")
If $INP_FieldValue2 = "" Then $INP_FieldValue2 = IniRead($AutoIt3WapperIni, "Res", "Field2Value", "")
If $INP_Run_Tidy = "" Then $INP_Run_Tidy = IniRead($AutoIt3WapperIni, "Other", "Run_Tidy", "")
If $INP_Tidy_Parameters = "" Then $INP_Tidy_Parameters = IniRead($AutoIt3WapperIni, "Other", "Tidy_Parameter", "")
If $INP_Run_Au3Stripper = "" Then $INP_Run_Au3Stripper = IniRead($AutoIt3WapperIni, "Other", "Run_Au3Stripper", "")
If $INP_Au3Stripper_Parameters = "" Then $INP_Au3Stripper_Parameters = IniRead($AutoIt3WapperIni, "Other", "Au3Stripper_Parameters", "")
If $INP_Run_AU3Check = "" Then $INP_Run_AU3Check = IniRead($AutoIt3WapperIni, "Other", "Run_AU3Check", "")
If $INP_Jump_To_First_Error = "" Then $INP_Run_AU3Check = IniRead($AutoIt3WapperIni, "Other", "Jump_To_First_Error", "")
If $INP_AU3Check_Stop_OnWarning = "" Then $INP_AU3Check_Stop_OnWarning = IniRead($AutoIt3WapperIni, "Other", "AU3Check_Stop_OnWarning", "")
If $INP_AU3Check_Parameters = "" Then $INP_AU3Check_Parameters = IniRead($AutoIt3WapperIni, "Other", "AU3Check_Parameter", "")
If $INP_Run_Before[1] = "" Then $INP_Run_Before = StringSplit(IniRead($AutoIt3WapperIni, "Other", "Run_Before", ""), "|")
If $INP_Run_After[1] = "" Then $INP_Run_After = StringSplit(IniRead($AutoIt3WapperIni, "Other", "Run_After", ""), "|")
If $INP_Run_Versioning = "" Then $INP_Run_Versioning = IniRead($AutoIt3WapperIni, "Other", "Run_Versioning", "")
If $INP_Versioning_Parameters = "" Then $INP_Versioning_Parameters = IniRead($AutoIt3WapperIni, "Other", "VersionWrapper_Parameter", "")
If $INP_Change2CUI = "" Then $INP_Change2CUI = IniRead($AutoIt3WapperIni, "Other", "Change2CUI", "")
If $INP_ShowStatus = "" Then $INP_ShowStatus = IniRead($AutoIt3WapperIni, "Other", "ShowProgress", "")
; set dir for all temporary files, fall back to @TempDir if it doesn't exist
$TempDir = _WinAPI_ExpandEnvironmentStrings(IniRead($AutoIt3WapperIni, "Other", "TempDir", ""))

#Region Versioning functions
#Region MainFunc Versioning
Func Versioning($SourceFile, $INP_Versioning_Parameters)
	;========================================================================================================================
	;Version program information
	;========================================================================================================================
	Local $Versioning = IniRead($AutoIt3WapperIni, "Versioning", "Versioning", "")
	; Check if Versioning was initialized
	If $Versioning = "" Then
		$Versioning = "SVN"
		If MsgBox(262144 + 4096 + 4, "AutoIt3Wrappper", "Versioning program information is not found yet." & @LF & _
				"Do you want to initialize the versioning setting based on using TortoiseSVN ?" & @CRLF & "You will get an UAC prompt in case this is needed.", 10) = 6 Then
			VersioningINIinit("SVN")
		EndIf
	EndIf
	;
	Local $VersionPGM = IniRead($AutoIt3WapperIni, $Versioning, "VersionPGM", "")
	Local $PromptVersionComments = "y"
	Local $VersionCommentsText = ""
	; Propmpt for version program and save in INI file
	If Not FileExists($VersionPGM) Then
		Debug("Your versioning program isn't found:" & $VersionPGM & ". Skipping task.  AutoIt3.INI:" & $AutoIt3WapperIni, 1, "!")
		Return
	EndIf
	If $PromptVersionComments = "" Then $PromptVersionComments = IniRead($AutoIt3WapperIni, "Versioning", "Prompt_Comments", "")
	If $PromptVersionComments = "" Then
		$PromptVersionComments = "y"
		IniWrite($AutoIt3WapperIni, "Versioning", "Prompt_Comments", "y")
	EndIf
	;
	FileDelete($UserData & "\AutoIt3Wrapper.log")
	Debug("==> Version program Info:")
	Debug("  Version program used  :" & $VersionPGM)
	Debug("  PromptVersionComments :" & $PromptVersionComments)
	Debug("  Parameters :" & $INP_Versioning_Parameters)
	;========================================================================================================================
	;Perform requested Version command
	;========================================================================================================================
	;Determine if source has its own version Versioning setup.
	If Not _Check_Source_versioned($SourceFile, $Versioning) Then
		Debug("Your sourcefile Directory has no " & $Versioning & " versioning setup.", 1, "!")
		Return
	EndIf
	;
	Local $vParams = StringSplit($INP_Versioning_Parameters, " ")
	Local $aTemp
	For $x = 1 To $vParams[0]
		Select
			Case $vParams[$x] = "/ShowDiff"
				Return _ShowDiff_Source($SourceFile, $Versioning)
			Case $vParams[$x] = "/NoPrompt"
				$PromptVersionComments = "n"
			Case $vParams[$x] = "/comments"
				$aTemp = StringRegExp($INP_Versioning_Parameters & @CR, '(?i)/comments\s(.*?)(\r|/noprompt|/showdiff)', 3)
				$VersionCommentsText = $aTemp[0]
				If StringLeft($VersionCommentsText, 1) = '"' Then $VersionCommentsText = StringTrimLeft($VersionCommentsText, 1)
				If StringRight($VersionCommentsText, 1) = '"' Then $VersionCommentsText = StringTrimRight($VersionCommentsText, 1)
		EndSelect
	Next
	; Commit the source
	Return _Commit_Source($SourceFile, $Versioning, $VersionCommentsText, $PromptVersionComments)
	; end of versioning func
EndFunc   ;==>Versioning
#EndRegion MainFunc Versioning
#Region Versioning Program Functions
Func _Check_Source_versioned($SourceFilename, $Versioning)
	;========================================================================================================================
	;Version program information
	;========================================================================================================================
	Debug("=========================================")
	Debug("==> Check if Directory has versioning.")
	Local $CommandChkVersioning = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandChkVersioning", ""), $SourceFilename)
	Local $CommandChkVersioning_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_txt", ""), $SourceFilename)
	Local $CommandChkVersioning_ok_rc = IniRead($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_rc", "")
	Local $STD_Output_versionProgram
	Local $rc = _RunVersionPgm($CommandChkVersioning, $STD_Output_versionProgram, 0)
	Return CheckSTDOUTFor($STD_Output_versionProgram, $CommandChkVersioning_ok_txt, $rc, $CommandChkVersioning_ok_rc)
EndFunc   ;==>_Check_Source_versioned
;
;  Commit the source to the version repository
Func _Commit_Source($SourceFilename, $Versioning, $VersionCommentsText, $PromptVersionComments)
	Debug("=========================================")
	Debug("==> Commit Source process.")
	; Check if the original source has a SVN applied ... when not then copy the file
	; Check if source was updated
	Local $CommandStatusSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandStatusSource", ""), $SourceFilename)
	Local $CommandStatusSource_ADD_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ADD_txt", ""), $SourceFilename, True)
	Local $CommandStatusSource_OK_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ok_txt", ""), $SourceFilename, True)
	Local $STD_Output_versionProgram
	Local $CommitInfo
	; Check if sourcefile is already added to versioning
	Debug("--> Check if sourcefile version status in repository.")
	Local $rc = _RunVersionPgm($CommandStatusSource, $STD_Output_versionProgram)
	Debug("Run Output:" & @CRLF & $STD_Output_versionProgram)
	;Save info for later processing
	Local $Status_Output = $STD_Output_versionProgram
	;Check If commit is needed
	Debug("--> Check if sourcefile was changed.")
	If Not CheckSTDOUTFor($STD_Output_versionProgram, $CommandStatusSource_OK_txt) Then
		ConsoleWrite("+ Your version is the same as the " & $Versioning & " version, nothing to update." & @LF)
		Exit
	EndIf
	; Get the commit comments with the option to cancel the commit
	If $PromptVersionComments = "y" Then
		Debug("--> Retrieve old Version comments ")
		; retrieve previous commit description text
		Local $CommandLogSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandLogSource", ""), $SourceFilename)
		If $CommandLogSource <> "" Then
			_RunVersionPgm($CommandLogSource, $STD_Output_versionProgram, 0)
			Debug("Run Output:" & @CRLF & $STD_Output_versionProgram)
			Local $Old_Msgs = StringSplit($STD_Output_versionProgram, @CRLF)
			Local $Prev_Msgs = ""
			Local $lev = 0
			Local $PrevMsgsCount = 0
			For $x = 1 To $Old_Msgs[0]
				If $Old_Msgs[$x] = "" Then ContinueLoop
				If StringLeft($Old_Msgs[$x], 20) = "--------------------" Then
					$lev = 1
					$PrevMsgsCount += 1
					If $PrevMsgsCount > 20 Then ExitLoop
					ContinueLoop
				EndIf
				; get the Commit status record
				If $lev = 3 Then
					$Prev_Msgs &= "\r\n" & $Old_Msgs[$x]
					ContinueLoop
				EndIf
				If $lev = 2 Then
					$Prev_Msgs &= $Old_Msgs[$x]
					$lev = 3
					ContinueLoop
				EndIf
				If $lev = 1 Then
					$CommitInfo = $Old_Msgs[$x]
					If $Prev_Msgs <> "" Then
						$Prev_Msgs &= "|"
					EndIf
					$Prev_Msgs &= StringLeft($CommitInfo, StringInStr($CommitInfo, "|") - 1) & ":"
					$lev = 2
					ContinueLoop
				EndIf
			Next
		EndIf
		Debug("--> GUI Prompt Version comments  ")
		$VersionCommentsText = CommitDescription($VersionCommentsText, $Prev_Msgs)
		If $VersionCommentsText == "-1" Then
			Debug("Version update cancelled.", 1, "!")
			Return
		EndIf
	EndIf
	;
	; Check if sourcefile is already added to versioning else ADD it.
	Debug("--> Check if sourcefile already has versioning.")
	If CheckSTDOUTFor($Status_Output, $CommandStatusSource_ADD_txt) Then
		Local $CommandAddSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandAddSource", ""), $SourceFilename, True)
		Local $CommandAddSource_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_txt", ""), $SourceFilename)
		Local $CommandAddSource_ok_rc = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_rc", ""), $SourceFilename)
		Debug("### Add source to repository.")
		$rc = _RunVersionPgm($CommandAddSource, $STD_Output_versionProgram)
		If CheckSTDOUTFor($STD_Output_versionProgram, $CommandAddSource_ok_txt, $rc, $CommandAddSource_ok_rc) Then
			Debug("Source Added succesfully to the repository.", 1, "")
		Else
			Debug("Source Add Failed.", 1, "!")
		EndIf
	EndIf
	;Check If commit is needed
	Local $CommandCommitSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource", ""), $SourceFilename, True)
	$CommandCommitSource = StringReplace($CommandCommitSource, "%commitcomment%", $VersionCommentsText)
	Local $CommandCommitSource_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_txt", ""), $SourceFilename)
	Local $CommandCommitSource_ok_rc = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_rc", ""), $SourceFilename)
	Debug("### Commit source to repository.")
	$rc = _RunVersionPgm($CommandCommitSource, $STD_Output_versionProgram)
	If CheckSTDOUTFor($STD_Output_versionProgram, $CommandCommitSource_ok_txt, $rc, $CommandCommitSource_ok_rc) Then
		; get revision
		Local $CommandCommitSource_new_revision = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource_new_revision", ""), $SourceFilename)
		Local $aResult = StringRegExp($STD_Output_versionProgram, $CommandCommitSource_new_revision, 3)
		ReDim $aResult[1] ; ensure the array is valid in case the regex isn't found
		Debug("Updated your source in the SVN repository in revision: " & $aResult[0], 1, "-")
	Else
		Debug("Commit Failed. Check the log for additional errors.", 1, "!> ")
	EndIf
EndFunc   ;==>_Commit_Source
;
Func _ShowDiff_Source($SourceFilename, $Versioning)
	Local $DiffPgm = IniRead($AutoIt3WapperIni, "Versioning", "DiffPGM", "")
	Local $DiffPgmOptions = IniRead($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "")
	Local $CommandGetLastVersion = IniRead($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion", "")
	$CommandGetLastVersion = StringReplace($CommandGetLastVersion, "%sourcefile%", $SourceFilename)
	Local $CommandGetLastVersion_ok_txt = IniRead($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_txt", "")
	Local $CommandGetLastVersion_ok_rc = IniRead($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_rc", "")
	Local $STD_Output_versionProgram
	;
	If $DiffPgm = "" Or Not FileExists($DiffPgm) Then
		Debug("Your DIFF program isn't found:" & $DiffPgm & ". Skipping task.", 1, "!")
		Return
	EndIf
	; Check if the original source has versioning
	; Use the Scripts Own repository
	; Create a tempfile to retrieve the Version source to
	Local $tmpfile = _TempFile()
	Debug("Retrieving last version from Repository to temp file: " & $tmpfile, 0, "")
	Local $rc = _RunVersionPgm($CommandGetLastVersion, $STD_Output_versionProgram, 0)
	If CheckSTDOUTFor($STD_Output_versionProgram, $CommandGetLastVersion_ok_txt, $rc, $CommandGetLastVersion_ok_rc) Then
		Debug("source retrieved:", 0, "")
	Else
		Debug("Failed to retrieve the source. Likely the file isn't versioned yet. Check the versioning.log for details.", 1, "!")
		Return 0
	EndIf
	; Write source to Tempfile
	FileWrite($tmpfile, $STD_Output_versionProgram)
	If Not FileExists($tmpfile) Or FileGetSize($tmpfile) = 0 Then
		MsgBox(48 + 262144, "VersionWrapper", "Script is not available in Versioning:" & @LF & $SourceFilename & @LF)
		FileDelete($tmpfile)
		Return
	EndIf
	Debug("Running Diff program " & '"' & $DiffPgm & '" ' & $DiffPgmOptions & ' "' & $SourceFilename & '" "' & $tmpfile & '"', 1, ">")
	RunWait('"' & $DiffPgm & '" ' & $DiffPgmOptions & ' "' & $SourceFilename & '" "' & $tmpfile & '"')
	; delete tempfile
	FileDelete($tmpfile)
EndFunc   ;==>_ShowDiff_Source
;
Func _RunVersionPgm($VersionCommand, ByRef $STD_Output_versionProgram, $ShowOutput = 0)
	Local $Versioning = IniRead($AutoIt3WapperIni, "Versioning", "Versioning", "")
	Local $VersionPGM = IniRead($AutoIt3WapperIni, $Versioning, "VersionPGM", "")
;~ 	Local $VersionPGMShortName = FileGetShortName($VersionPGM)
;~ 	Local $VersionDir = IniRead($AutoIt3WapperIni, $Versioning, "SVNDir", @ScriptDir)
	Local $Pid
	Debug("Run Version program:" & $VersionPGM & ' ' & $VersionCommand & @CRLF)
	$Pid = Run('"' & $VersionPGM & '" ' & $VersionCommand & '', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $Handle = _ProcessExitCode($Pid)
	$STD_Output_versionProgram = ShowStdOutErr($Pid, $ShowOutput)
	Local $ExitCode = _ProcessExitCode($Pid, $Handle)
	_ProcessCloseHandle($Handle)
	Debug("Run ended with rc:" & $ExitCode & @CRLF)
	Return $ExitCode
EndFunc   ;==>_RunVersionPgm
; Show input screen to add a comment to the Commit
Func CommitDescription($VersionCommentsText, $Prev_Descr = "")
	Local $nMsg
	GUICreate("Version Commit Text", 413, 298, 284, 188)
	GUICtrlCreateLabel("Description:", 16, 24, 60, 17)
	Local $Combo1 = GUICtrlCreateCombo("", 50, 5, 326, 169)
	If $Prev_Descr <> "" Then
		GUICtrlSetData(-1, $Prev_Descr, StringLeft($Prev_Descr, StringInStr($Prev_Descr, "|") - 1))
	Else
		GUICtrlSetState(-1, $GUI_HIDE)
	EndIf
	Local $Edit1 = GUICtrlCreateEdit($VersionCommentsText, 25, 40, 351, 169)
	Local $h_Ok = GUICtrlCreateButton("Ok", 72, 224, 81, 33, 0)
	Local $H_CANCEL = GUICtrlCreateButton("Cancel", 224, 224, 97, 33, 0)
	GUISetState(@SW_SHOW)
	While 1
		$nMsg = GUIGetMsg()
		Select
			Case $nMsg = $GUI_EVENT_CLOSE Or $nMsg = $H_CANCEL
				GUIDelete()
				Return -1
			Case $nMsg = $h_Ok
				Local $temp = StringReplace(GUICtrlRead($Edit1), '"', '\"')
				GUIDelete()
				Return $temp
			Case $nMsg = $Combo1
				If GUICtrlRead($Edit1) <> "" Then
					If MsgBox(4, "Confirm override", "Override the Text in the Edit control?") = 7 Then ContinueLoop
				EndIf
				GUICtrlSetData($Edit1, StringReplace(StringTrimLeft(GUICtrlRead($Combo1), StringInStr(GUICtrlRead($Combo1), ":")), "\r\n", @CRLF))
		EndSelect
	WEnd
EndFunc   ;==>CommitDescription
#EndRegion Versioning Program Functions
#Region Versioning Other functions
Func ReplaceVarsINIText($CmdText, $InSourceFilename, $Double_BackSlash = True)
	Local $SourceDrive, $SourceDir, $SourceFilename, $SourceFileExt
	_PathSplit($InSourceFilename, $SourceDrive, $SourceDir, $SourceFilename, $SourceFileExt)
	$SourceDir = $SourceDrive & StringTrimRight($SourceDir, 1)
	If $Double_BackSlash Then
		$InSourceFilename = StringReplace($InSourceFilename, "\", "\\")
		$SourceDir = StringReplace($SourceDir, "\", "\\")
	EndIf
	$CmdText = StringReplace($CmdText, "%sourcefile%", $InSourceFilename)
	$CmdText = StringReplace($CmdText, "%sourcefileonly%", $SourceFilename & $SourceFileExt)
	$CmdText = StringReplace($CmdText, "%sourcedir%", $SourceDir)
	Return $CmdText
EndFunc   ;==>ReplaceVarsINIText
;Check returned STDOUT for given text or RC from versioning program as defined in INI
Func CheckSTDOUTFor($Output, $ChkText, $PgmRC = 0, $ChkRc = 999, $ChkRegex = True)
	Local $rc = 0
	Debug("----------------------------------------------------------------------------------")
	Debug("   Version Check STDOUT and RC of version program:")
	Debug("   $ChkText :" & $ChkText)
	Debug("   $PgmRC   :" & $PgmRC)
	Debug("   $ChkRc   :" & $ChkRc)
	If $ChkRc <> "" And $PgmRC = Number($ChkRc) Then
		$rc = 1
		Debug(" Returncode is a match.")
	ElseIf $ChkRegex Then
		If $ChkText <> "" And StringRegExp($Output, $ChkText) Then
			$rc = 1
			Debug(" Regex is a match.")
		EndIf
	Else
		If $ChkText <> "" And StringInStr($Output, $ChkText) Then
			$rc = 1
			Debug(" StringInStr is a match.")
		EndIf
	EndIf
	Debug("   $Output  :" & @CRLF & $Output)
	Debug("--- End STDOUT check ---------------------------------------------------------------")
	Return $rc
EndFunc   ;==>CheckSTDOUTFor
;
Func Debug($Txt, $ShowConsole = 0, $ConsolePref = "")
	Local $Debug = Number(IniRead($AutoIt3WapperIni, "Versioning", "Debug", "1"))
	If $Debug Then _FileWriteLog($UserData & "\AutoIt3Wrapper.log", $Txt)
	If $ShowConsole Then Write_RC_Console_Msg($Txt, "", $ConsolePref)
EndFunc   ;==>Debug
;
Func RunReqAdmin($Autoit3Commands, $prompt = 0)
	Local $temp_Script = _TempFile($TempDir, "~", ".au3")
	Local $temp_check = _TempFile($TempDir, "~", ".chk")
	FileWriteLine($temp_check, 'TempFile')
	FileWriteLine($temp_Script, '#NoTrayIcon')
	If Not IsAdmin() Then
		FileWriteLine($temp_Script, '#RequireAdmin')
		If $prompt = 1 Then MsgBox(262144, "Need Admin mode", "Admin mode is needed for this update. Answer the following prompts to allow the update.")
	EndIf
	FileWriteLine($temp_Script, $Autoit3Commands)
	FileWriteLine($temp_Script, "FileDelete('" & $temp_check & "')")
	If @Compiled Then
		RunWait('"' & @ScriptFullPath & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	Else
		RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	EndIf
	; Wait for the script to finish
	While FileExists($temp_check)
		Sleep(50)
	WEnd
	FileDelete($temp_Script)
EndFunc   ;==>RunReqAdmin
;
Func RunReqAdminDosCommand($Autoit3Commands, $prompt = 0, $outfile = "")
	Local $temp_Script = _TempFile($TempDir, "~", ".au3")
	Local $temp_check = _TempFile($TempDir, "~", ".chk")
	FileDelete($outfile)
	FileWriteLine($temp_check, 'TempFile')
	FileWriteLine($temp_Script, '#NoTrayIcon')
	If Not IsAdmin() Then
		FileWriteLine($temp_Script, '#RequireAdmin')
		If $prompt = 1 Then MsgBox(262144, "Need Admin mode", "Admin mode is needed for this update. Answer the following prompts to allow the update.")
	EndIf
	ConsoleWrite(">Running AdminLevel:" & $Autoit3Commands & @CRLF)
	FileWriteLine($temp_Script, "$Pid = Run('" & @ComSpec & ' /C ' & $Autoit3Commands & "', ''," & @SW_HIDE & ", 2)")
	FileWriteLine($temp_Script, "$Handle = _ProcessExitCode($Pid)")
	FileWriteLine($temp_Script, "$ConOut = ShowStdOutErr($Pid)")
	FileWriteLine($temp_Script, "$ExitCode = _ProcessExitCode($Pid, $Handle)")
	FileWriteLine($temp_Script, "_ProcessCloseHandle($Handle)")
	If $outfile <> "" Then
		FileWriteLine($temp_Script, 'FileWrite("' & $outfile & '",$ConOut)')
	EndIf
	FileWriteLine($temp_Script, "FileDelete('" & $temp_check & "')")
	FileWriteLine($temp_Script, "Exit $ExitCode")
	FileWriteLine($temp_Script, "Func _ProcessCloseHandle($h_Process)")
	FileWriteLine($temp_Script, "	; Close the process handle of a PID")
	FileWriteLine($temp_Script, "	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $h_Process)")
	FileWriteLine($temp_Script, "	If Not @error Then Return 1")
	FileWriteLine($temp_Script, "	Return 0")
	FileWriteLine($temp_Script, "EndFunc   ;==>_ProcessCloseHandle")
	FileWriteLine($temp_Script, "Func _ProcessExitCode($i_Pid, $h_Process = 0)")
	FileWriteLine($temp_Script, "	; 0 = Return Process Handle of PID else use Handle to Return Exitcode of a PID")
	FileWriteLine($temp_Script, "	Local $v_Placeholder")
	FileWriteLine($temp_Script, "	If Not IsArray($h_Process) Then")
	FileWriteLine($temp_Script, "		; Return the process handle of a PID")
	FileWriteLine($temp_Script, "		$h_Process = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'int', 0x400, 'int', 0, 'int', $i_Pid)")
	FileWriteLine($temp_Script, "		If Not @error Then Return $h_Process")
	FileWriteLine($temp_Script, "	Else")
	FileWriteLine($temp_Script, "		; Return Process Exitcode of PID")
	FileWriteLine($temp_Script, "		$h_Process = DllCall('kernel32.dll', 'ptr', 'GetExitCodeProcess', 'ptr', $h_Process[0], 'int*', $v_Placeholder)")
	FileWriteLine($temp_Script, "		If Not @error Then Return $h_Process[2]")
	FileWriteLine($temp_Script, "	EndIf")
	FileWriteLine($temp_Script, "	Return 0")
	FileWriteLine($temp_Script, "EndFunc   ;==>_ProcessExitCode")
	FileWriteLine($temp_Script, "Func ShowStdOutErr($l_Handle, $ShowConsole = 1, $Replace = '', $ReplaceWith = '')")
	FileWriteLine($temp_Script, "	Local $Line = 'x', $Line2 = 'x', $tot_out, $err1 = 0, $err2 = 0, $cnt1 = 0, $cnt2 = 0")
	FileWriteLine($temp_Script, "	Do")
	FileWriteLine($temp_Script, "		Sleep(10)")
	FileWriteLine($temp_Script, "		$Line = StdoutRead($l_Handle)")
	FileWriteLine($temp_Script, "		$err1 = @error")
	FileWriteLine($temp_Script, "		If $Replace <> '' Then $Line = StringReplace($Line, $Replace, $ReplaceWith)")
	FileWriteLine($temp_Script, "		$tot_out &= $Line")
	FileWriteLine($temp_Script, "		If $ShowConsole Then ConsoleWrite($Line)")
	FileWriteLine($temp_Script, "		$Line2 = StderrRead($l_Handle)")
	FileWriteLine($temp_Script, "		$err2 = @error")
	FileWriteLine($temp_Script, "		If $Replace <> '' Then $Line2 = StringReplace($Line2, $Replace, $ReplaceWith)")
	FileWriteLine($temp_Script, "		$tot_out &= $Line2")
	FileWriteLine($temp_Script, "		If $ShowConsole Then ConsoleWrite($Line2)")
	FileWriteLine($temp_Script, "		; end the loop also when AutoIt3 has ended but a sub process was shelled with Run() that is still active")
	FileWriteLine($temp_Script, "		; only do this every 50 cycles to avoid cpu hunger")
	FileWriteLine($temp_Script, "		If $cnt1 = 50 Then")
	FileWriteLine($temp_Script, "			$cnt1 = 0")
	FileWriteLine($temp_Script, "			; loop another 50 times just to ensure the buffers emptied.")
	FileWriteLine($temp_Script, "			If Not ProcessExists($l_Handle) Then")
	FileWriteLine($temp_Script, "				If $cnt2 > 2 Then ExitLoop")
	FileWriteLine($temp_Script, "				$cnt2 += 1")
	FileWriteLine($temp_Script, "			EndIf")
	FileWriteLine($temp_Script, "		EndIf")
	FileWriteLine($temp_Script, "		$cnt1 += 1")
	FileWriteLine($temp_Script, "	Until ($err1 And $err2)")
	FileWriteLine($temp_Script, "	Return $tot_out")
	FileWriteLine($temp_Script, "EndFunc   ;==>ShowStdOutErr")
	If @Compiled Then
		$rc = RunWait('"' & @ScriptFullPath & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	Else
		$rc = RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	EndIf
	; Wait for the script to finish
	While FileExists($temp_check)
		Sleep(50)
	WEnd
	FileDelete($temp_Script)
	$rc = FileRead($TempConsOut)
	FileDelete($TempConsOut)
	Return $rc
EndFunc   ;==>RunReqAdminDosCommand
;; Initialise the Versiong setup using TortoiseSVN and WinMerge default setup.
Func VersioningINIinit($Versioning = "SVN", $Reshelled = 0)
	; Check if we can write to the AutoIt3Wrapper.INI
	Local $rc = IniWrite($AutoIt3WapperIni, "Versioning", "test", "1")
	If $rc Then
		IniDelete($AutoIt3WapperIni, "Versioning", "test")
	Else
		; relauch AutoItWrapper as admin
		If $Reshelled = 0 Then
			Debug("Shell into Admin mode to be able to update AutoIt3Wrapper.ini ", 1, "+")
			RunReqAdmin('RunWait(''"' & @ScriptFullPath & '" /Versioning_Init'')')
		Else
			Debug("Problems updating your AutoIt3Wrapper.ini with the needed information.", 1, "!")
			Exit
		EndIf
	EndIf
	; Check for TortoiseSVN
	If FileExists(@ProgramFilesDir & "\TortoiseSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", @ProgramFilesDir & "\TortoiseSVN\bin\svn.exe")
	ElseIf FileExists(@ProgramFilesDir & "\SilkSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", @ProgramFilesDir & "\SilkSVN\bin\svn.exe")
	ElseIf FileExists("C:\Program Files (x86)\TortoiseSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", "C:\Program Files (x86)\TortoiseSVN\bin\svn.exe")
	ElseIf FileExists("C:\Program Files\TortoiseSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", "C:\Program Files\TortoiseSVN\bin\svn.exe")
	ElseIf FileExists("C:\Program Files\SilkSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", "C:\Program Files\SilkSVN\bin\svn.exe")
	Else
		MsgBox(48, "SVN.exe Not found", "Please install TortoiseSVN and select the correct directory for SVN.exe")
		Local $VersionPGM = FileOpenDialog("Select the location of SVN.EXE program", @ProgramFilesDir, "SVN (SVN.exe)", 1)
		If @error Then
			Debug("SVN.exe program not found. Buildin versioning will not be available", 1, "!")
			Exit
		Else
			IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
			IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", $VersionPGM)
		EndIf
	EndIf
	Debug("Writing defaults to AutoIt3Wrapper.ini", 1, ">")
	; Check for WinMergeU already installed
	If FileExists(@ProgramFilesDir & "\WinMerge\WinMergeU.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", @ProgramFilesDir & "\WinMerge\WinMergeU.exe")
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
	ElseIf FileExists("C:\Program Files (x86)\WinMerge\WinMergeU.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", "C:\Program Files (x86)\WinMerge\WinMergeU.exe")
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
	ElseIf FileExists("C:\Program Files\WinMerge\WinMergeU.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", "C:\Program Files\WinMerge\WinMergeU.exe")
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
	Else
		MsgBox(48, "WinMerge Not found", "Please install WinMerge and select the correct directory")
		Local $DiffPgm = FileOpenDialog("Select the location of WinMergeU program", @ProgramFilesDir, "WinMergeU (WinMergeU.exe)", 1)
		If @error Then
			Debug("WinMerge program not found. Alt-F12 Show Diff will not be available", 1, "!")
			IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", "")
		Else
			IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", $DiffPgm)
			IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
		EndIf
	EndIf
	IniWrite($AutoIt3WapperIni, "Versioning", "Prompt_Comments", "y")
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandChkVersioning", 'info "%sourcedir%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_txt", 'Working Copy Root Path:')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_rc", '')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandStatusSource", 'status "%sourcefile%" -u')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ADD_txt", '\?\s*?%sourcefile%')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ok_txt", '[MA\?][\s\d-]*?%sourcefile%')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandLogSource", 'log "%sourcefile%" -l 5')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandAddSource", 'add "%sourcefile%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_txt", 'A.*?%sourcefileonly%')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_rc", '')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource", 'commit "%sourcefile%" --message "%commitcomment%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_txt", "")
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_rc", '0')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource_new_revision", '(?i)(?s)committed revision\s*([0-9]*)')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion", 'cat "%sourcefile%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_txt", '')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_rc", '0')
EndFunc   ;==>VersioningINIinit
;===============================================================================
;
; Function Name:    _ProcessExitCode()
; Description:      Returns a handle/exitcode from use of Run().
; Parameter(s):     $i_Pid        - ProcessID returned from a Run() execution
;                   $h_Process    - Process handle
; Requirement(s):   None
; Return Value(s):  On Success - Returns Process handle while Run() is executing
;                                (use above directly after Run() line with only PID parameter)
;                              - Returns Process Exitcode when Process does not exist
;                                (use above with PID and Process Handle parameter returned from first UDF call)
;                   On Failure - 0
; Author(s):        MHz (Thanks to DaveF for posting these DllCalls in Support Forum)
;
;===============================================================================
;
Func _ProcessExitCode($i_Pid, $h_Process = 0)
	; 0 = Return Process Handle of PID else use Handle to Return Exitcode of a PID
	Local $v_Placeholder
	If Not IsArray($h_Process) Then
		; Return the process handle of a PID
		$h_Process = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'int', 0x400, 'int', 0, 'int', $i_Pid)
		If Not @error Then Return $h_Process
	Else
		; Return Process Exitcode of PID
		$h_Process = DllCall('kernel32.dll', 'ptr', 'GetExitCodeProcess', 'ptr', $h_Process[0], 'int*', $v_Placeholder)
		If Not @error Then Return $h_Process[2]
	EndIf
	Return 0
EndFunc   ;==>_ProcessExitCode
; Get STDOUT and ERROUT from commandline tool
Func ShowStdOutErr($l_Handle, $ShowConsole = 1, $Replace = "", $ReplaceWith = "")
	Local $Line = "x", $Line2 = "x", $tot_out, $err1 = 0, $err2 = 0, $cnt1 = 0, $cnt2 = 0
	Do
		Sleep(10)
		$Line = StdoutRead($l_Handle)
		$err1 = @error
		If $Replace <> "" Then $Line = StringReplace($Line, $Replace, $ReplaceWith)
		$tot_out &= $Line
		If $ShowConsole Then ConsoleWrite($Line)
		$Line2 = StderrRead($l_Handle)
		$err2 = @error
		If $Replace <> "" Then $Line2 = StringReplace($Line2, $Replace, $ReplaceWith)
		$tot_out &= $Line2
		If $ShowConsole Then ConsoleWrite($Line2)
		; end the loop also when AutoIt3 has ended but a sub process was shelled with Run() that is still active
		; only do this every 50 cycles to avoid cpu hunger
		If $cnt1 = 50 Then
			$cnt1 = 0
			; loop another 50 times just to ensure the buffers emptied.
			If Not ProcessExists($l_Handle) Then
				If $cnt2 > 2 Then ExitLoop
				$cnt2 += 1
			EndIf
		EndIf
		$cnt1 += 1
	Until ($err1 And $err2)
	Return $tot_out
EndFunc   ;==>ShowStdOutErr
Func _ProcessCloseHandle($h_Process)
	; Close the process handle of a PID
	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $h_Process)
	If Not @error Then Return 1
	Return 0
EndFunc   ;==>_ProcessCloseHandle
Func Write_RC_Console_Msg($text, $rc = "", $symbol = "", $Time = 1)
	If $Time Then $text = @HOUR & ":" & @MIN & ":" & @SEC & " " & $text
	If $symbol <> "" Then
		If $rc == "" Then
			ConsoleWrite($symbol & ">" & $text & @CRLF)
		Else
			ConsoleWrite($symbol & ">" & $text & "rc:" & $rc & @CRLF)
		EndIf
	Else
		If $rc == "" Then
			ConsoleWrite(">" & $text & @CRLF)
		Else
			Switch $rc
				Case 0
					ConsoleWrite("+>" & $text & "rc:" & $rc & @CRLF)
				Case 1
					ConsoleWrite("->" & $text & "rc:" & $rc & @CRLF)
				Case Else
					ConsoleWrite("!>" & $text & "rc:" & $rc & @CRLF)
			EndSwitch
		EndIf
	EndIf
EndFunc   ;==>Write_RC_Console_Msg
#EndRegion Versioning Other functions
#EndRegion Versioning functions