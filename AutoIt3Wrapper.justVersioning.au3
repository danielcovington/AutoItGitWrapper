#Region ;**** Directives created by AutoIt3Wrapper_GUI *****
#AutoIt3Wrapper_Versioning=v
#AutoIt3Wrapper_Versioning_Parameters=/Comments %fileversion%
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI *****

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
#EndRegion Versioning Other functions
#EndRegion Versioning functions