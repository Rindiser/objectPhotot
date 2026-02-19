#SingleInstance, Force

SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
FileEncoding , UTF-8

;==================================================
; Read settings
;==================================================

IniRead, guiPosition, %A_ScriptDir%\settings.ini, window position, gui_position, Center

Gui, 1: +HwndguiId

xPos := 100
yPos := 100
imageShown := 0
suffix := 1

IniRead, prefix, %A_ScriptDir%\settings.ini, Settings, Prefix, %A_Space%
IniRead, newPrefix, %A_ScriptDir%\settings.ini, Settings, NyPrefix, %A_Space%
IniRead, suffix, %A_ScriptDir%\settings.ini, Settings, Suffix, 1
IniRead, workingFolder, %A_ScriptDir%\settings.ini, Settings, WorkingFolder, %A_ScriptDir%
IniRead, destinationFolder, %A_ScriptDir%\settings.ini, Settings, DestinationFolder, %A_ScriptDir%
IniRead, exportFolder, %A_ScriptDir%\settings.ini, Settings, ExportFolder, %A_Space%
IniRead, stationNumber, %A_ScriptDir%\settings.ini, Settings, Station, %A_Space%
IniRead, fileType, %A_ScriptDir%\settings.ini, Settings, FileType, jpg
IniRead, catalogPrefix, %A_ScriptDir%\settings.ini, Validation, CatalogPrefix, %A_Space%
IniRead, catalogStart, %A_ScriptDir%\settings.ini, Validation, CatalogStart, 0
IniRead, catalogEnd, %A_ScriptDir%\settings.ini, Validation, CatalogEnd, 0
IniRead, uuidPrefix, %A_ScriptDir%\settings.ini, Validation, UUIDPrefix, http://purl.org/nhmuio/id/
IniRead, boxPrefix, %A_ScriptDir%\settings.ini, Validation, BoxPrefix, %A_Space%
IniRead, boxStart, %A_ScriptDir%\settings.ini, Validation, BoxStart, 0
IniRead, boxEnd, %A_ScriptDir%\settings.ini, Validation, BoxEnd, 0

fileExt := fileType

SetWorkingDir %workingFolder%

Gui, 1:  Add, Tab2,h857 w1080, Program||Settings
Gui, 1:  tab, Program

Gui, 1: Add, Progress, x20 y60 w120 h210 Backgroundc8b4a7 Disabled
Gui, 1: Add, Button, x30 y65 w100 h50 gNytt_Vis_bilde vBtnGetImage Default, &Get Image `nNew Object
Gui, 1: Add, Button, x30 y135 w100 h50 gSammeobj_Vis_bilde vBtnSameObject +Disabled, Get Image `n&Same Object
Gui, 1: Add, Button, x30 y205 w100 h50 gLabel vBtnLabel +Disabled, Get Image `nLabel

Gui, 1: Add, Text, x192 y60 w90 h20, Filename
Gui, 1: Add, Edit, r1 x192 y90 w90 h30 vOldName +disabled,
Gui, 1: Add, Text, x302 y60 w120 h20, Catalog No.:
Gui, 1: Add, Edit, r1 x302 y90 w120 h30 vNewName limit20,
Gui, 1: Add, Text, x435 y60 w80 h30, Image No.
Gui, 1: Add, Edit, r1 x435 y90 w40 h30 vSuffix, %suffix%

Gui, 1: font, s13 cRed w700, Arial
Gui, 1: Add, Text, x192 y130 w90 h30, QR-code (UUID)
Gui, 1: Add, Edit, r1 x192 y150 w300 h50 vTaxonUUID hwndHwndTaxon, %taxonUUID%
Gui, 1: font

Gui, 1: Add, Text, x192 y200 w90 h20, Boks nummer
Gui, 1: Add, Edit, r1 x192 y220 w100 h30 vBoxNumber,

Gui, 1: Add, Progress, x510 y65 w120 h60 Backgroundc8b4a7 Disabled
Gui, 1: Add, Button, x520 y70 w100 h50 gRenameFiles vBtnRename +Disabled, Rename!

Gui, Add, CheckBox, x520 y150 w100 h30 Checked vbox, Validate Input

;===============================================================================
; ListView objects
;===============================================================================

Gui, 1: Add, ListView, x440 y350 w460 h490 Grid vObjectList, No.|Box No.|Catalog No.|Img No.|UUID
gosub List_taxa_objects

Gui, 1: Add, Button, x780 y300 w120 h40 gList_taxa_objects, Update Data List

;===============================================================================

Gui, 1: Add, Progress, x80 y370 w320 cBlue vWorking Hidden -Smooth 0x8 +Border
Gui, 1: Add, Picture, x40 y400 vPicControl,
Gui, 1: font, s14 cRed w700, Arial
Gui, 1: Add, Text, x40 y400 w400 h400 vErrorText Hidden BackgroundTrans,
Gui, 1: font

;===============================================================================
; File ListViews
;===============================================================================
Gui, 1: Add, GroupBox, x910 y335 w160 h520, Image Folders

Gui, 1: Add, Button, x950 y360 w100 h30 gRefresh, Update File List

Gui, 1: Add, ListView, x940 y400 w120 h240 vDestView, Destination Files
Loop, %destinationFolder%\*.%fileExt%
	LV_Add("", A_LoopFileName)

Gui, 1: Add, Button,  x950 y650 w100 h30 gOpendest, Open Dest. Folder

Gui, 1: Add, ListView, x940 y700 w120 h100 vWorkList, Working Files
Loop, %workingFolder%\*.%fileExt%
	LV_Add("", A_LoopFileName)

Gui, 1: Add, Button, x950 y820 w100 h30 gOpenwork, Open Work Folder

newName := ""

;===============================================================================
; Motivation part
;===============================================================================

Gui, 1: Add, GroupBox, x660 y50 w250 h240, Image Count

Gui, 1: Add, Text, x690 y90 w40 h30, Total
Gui, 1: Add, Edit, Right r1 x690 y120 w40 h30 vTotalCount +disabled,
Gui, 1: Add, Text, x750 y90 w50 h30, Yesterday
Gui, 1: Add, Edit, Right r1 x750 y120 w40 h30 vYesterdayCount +disabled,
Gui, 1: Add, Text, x810 y90 w40 h30, Today
Gui, 1: Add, Edit, Right r1 x810 y120 w40 h30 vTodayCount +disabled,
Gui, 1: Add, Progress, Vertical vProgressYesterday x760 y160 w30 h110,
Gui, 1: Add, Progress, Vertical vProgressToday x820 y160 w30 h110,

;=============================================================
; Date Logic
;=============================================================
FormatTime, todaysDate, ,MMdd
yesterdayDate = %a_now%
yesterdayDate += -1, days
FormatTime, yesterdayDate, %yesterdayDate%, MMdd
;=============================================================

IniRead, storedDate, %A_ScriptDir%\settings.ini, Motivation, Date, %A_Space%
IniRead, storedDailyCount, %A_ScriptDir%\settings.ini, Motivation, DailyCount, 0
IniRead, storedYesterdayDate, %A_ScriptDir%\settings.ini, Motivation, YesterdayDate, %A_Space%
IniRead, storedYesterdayCount, %A_ScriptDir%\settings.ini, Motivation, YesterdayCount, 0
IniRead, storedTotalCount, %A_ScriptDir%\settings.ini, Motivation, TotalCount, 0

if (storedDate = yesterdayDate)
{
	gosub, UpdateFromYesterday
}
IF (todaysDate != storedDate)
{
	gosub, UpdateFromEarlier
}

gosub, UpdateMotivation

;===============================================================================
; Settings
;===============================================================================
Gui, 1: tab, Settings

Gui, 1: Add, Text, x72 y60 w80 h30, Show files with prefix
Gui, 1: Add, Edit, r1 x172 y60 w80 h30 vPrefix, %prefix%
Gui, 1: Add, Text, x272 y60 w80 h30, New filename prefix
Gui, 1: Add, Edit, r1 x372 y60 w80 h30 vNewPrefix, %newPrefix%
Gui, 1: Add, Text, x500 y60 w80 h30, Suffix
Gui, 1: Add, Edit, r1 x542 y60 w80 h30 vSettingsSuffix, %suffix%

Gui, 1: Add, Text, x72 y120 w150 h30, Set Station No
Gui, 1: Add, Edit, r1 x170 y120 w50 h30 vStationNumber, %stationNumber%

Gui, 1: Add, Text, x72 y150 w80 h30, Set working folder
Gui, 1: Add, Edit, x172 y150 w450 h30 vWorkingFolder +disabled, %workingFolder%
Gui, 1: Add, Button, gArbeidsmappe x652 y150 w80 h30, Browse

Gui, 1: Add, Text, x72 y200 w80 h30, Set destination folder
Gui, 1: Add, Edit, x172 y200 w450 h30 vDestinationFolder +disabled, %destinationFolder%
Gui, 1: Add, Button, gDestmappe x652 y200 w80 h30, Browse

Gui, Add, GroupBox, x62 y280 w350 h60,
Gui, 1: Add, Text, x72 y305 w80 h30, Set file type
Gui, 1: Add, Radio, vFileType x172 y300 w50 h30, tif
Gui, 1: Add, Radio, x222 y300 w50 h30, jpg
Gui, 1: Add, Radio, x272 y300 w50 h30, pdf

Gui, Add, GroupBox, x62 y350 w550 h140, Validation Settings
Gui, 1: Add, Text, x72 y375 w150 h20, Catalog Prefix/Range
Gui, 1: Add, Edit, r1 x182 y370 w150 h20 vCatalogPrefix, %catalogPrefix%
Gui, 1: Add, Edit, r1 x342 y370 w60 h20 vCatalogStart, %catalogStart%
Gui, 1: Add, Text, x407 y375 w10 h20, -
Gui, 1: Add, Edit, r1 x422 y370 w60 h20 vCatalogEnd, %catalogEnd%

Gui, 1: Add, Text, x72 y405 w100 h20, UUID Prefix
Gui, 1: Add, Edit, r1 x182 y400 w300 h20 vUUIDPrefix, %uuidPrefix%

Gui, 1: Add, Text, x72 y435 w100 h20, Box Prefix/Range
Gui, 1: Add, Edit, r1 x182 y430 w150 h20 vBoxPrefix, %boxPrefix%
Gui, 1: Add, Edit, r1 x342 y430 w60 h20 vBoxStart, %boxStart%
Gui, 1: Add, Text, x407 y435 w10 h20, -
Gui, 1: Add, Edit, r1 x422 y430 w60 h20 vBoxEnd, %boxEnd%

Gui, 1: Add, Button, gSavePref x172 y510 w100 h30, Save Settings

Gui, 1: Show, %guiPosition% h880 w1100, Object_photo

GuiControl, , %fileType%, 1

OnMessage(0x111, "WM_Command")

return

;============================================================
; WM_Command
;============================================================
WM_Command(wp, lp) {
	Global HwndTaxon
	If ((wp >> 16) = 0x100 && lp = HwndTaxon) {
		GuiControl,,TaxonUUID
	}
}

;===============================================================================
; Motivation part GUI progress bars
;===============================================================================

UpdateFromYesterday:
	storedYesterdayCount := storedDailyCount
	storedDailyCount =

	IniWrite, %todaysDate%, %A_ScriptDir%\settings.ini, Motivation, Date
	IniWrite, %storedDailyCount%, %A_ScriptDir%\settings.ini, Motivation, DailyCount
	IniWrite, %yesterdayDate%, %A_ScriptDir%\settings.ini, Motivation, YesterdayDate
	IniWrite, %storedYesterdayCount%, %A_ScriptDir%\settings.ini, Motivation, YesterdayCount
	IniWrite, %storedTotalCount%, %A_ScriptDir%\settings.ini, Motivation, TotalCount
return

UpdateFromEarlier:
	storedYesterdayCount =
	storedDailyCount =

	IniWrite, %todaysDate%, %A_ScriptDir%\settings.ini, Motivation, Date
	IniWrite, %storedDailyCount%, %A_ScriptDir%\settings.ini, Motivation, DailyCount
	IniWrite, %yesterdayDate%, %A_ScriptDir%\settings.ini, Motivation, YesterdayDate
	IniWrite, %storedYesterdayCount%, %A_ScriptDir%\settings.ini, Motivation, YesterdayCount
	IniWrite, %storedTotalCount%, %A_ScriptDir%\settings.ini, Motivation, TotalCount
return

UpdateMotivation:
	GuiControl, 1:, TotalCount, %storedTotalCount%
	GuiControl, 1:, YesterdayCount, %storedYesterdayCount%
	GuiControl, 1:, TodayCount, %storedDailyCount%

	UpdateProgressBarColor("ProgressYesterday", storedYesterdayCount, false)
	UpdateProgressBarColor("ProgressToday", storedDailyCount, true)
return

UpdateProgressBarColor(ControlName, Count, IsToday) {
	ControlColor := "Green"
	if (Count < 100)
		ControlColor := "Red"
	else if (Count < 200)
		ControlColor := "Blue"
	else if (Count < 300)
		ControlColor := "Yellow"
	else if (Count < 400)
		ControlColor := "Silver"
	else if (Count < 500)
		ControlColor := "Lime"
	else if (IsToday) {
		if (Count < 600)
			ControlColor := "Black"
		else if (Count < 700)
			ControlColor := "Maroon"
	}
	GuiControl, 1: +c%ControlColor%, %ControlName%
	GuiControl, 1:, %ControlName%, %Count%
}

;===============================================================================
; Open work and dest folder
;===============================================================================

Openwork:
	Run %workingFolder%
return

Opendest:
	Run %destinationFolder%
return

Refresh:
	Gui, 1: Listview, WorkList
	LV_Delete()
	Loop, %workingFolder%\*.%fileExt%
		LV_Add("", A_LoopFileName)

	Gui, 1: Listview, DestView
	LV_Delete()
	listDest =
	Loop, %destinationFolder%\*.%fileExt%
	{
		If A_index < 2
			listDest = %listDest%%A_LoopFileTimeAccessed%|%A_LoopFileName%
		else
			listDest = %listDest%`n%A_LoopFileTimeAccessed%|%A_LoopFileName%
	}

	Sort, listDest, R
	FileDelete, Listdest.txt
	FileAppend, %listDest%, Listdest.txt
	Loop, parse, listDest, `n,
	{
		StringSplit, item, A_LoopField, `|
		LV_Add("",item2)
	}
return

;===============================================================================
; Directories
;===============================================================================

Arbeidsmappe:
	FileSelectFolder, workingFolder, , 3, Select Folder
	workingFolder := RegExReplace(workingFolder, "\\$")
	if workingFolder =
	{
		SetWorkingDir %A_ScriptDir%
		GuiControl, 1:, WorkingFolder, %A_ScriptDir%
	}
	else
	{
		SetWorkingDir %workingFolder%
		GuiControl, 1:, WorkingFolder, %workingFolder%
	}
Return

Destmappe:
	FileSelectFolder, destinationFolder, , 3, Select Folder
	destinationFolder := RegExReplace(destinationFolder, "\\$")
	if destinationFolder =
		MsgBox Choose destination folder!
	else
		GuiControl, 1:, DestinationFolder, %destinationFolder%
return

;===============================================================================
; Save Settings
;===============================================================================

SavePref:
	Gui 1: submit, NoHide

	if fileType = 1
		fileType = tif
	if fileType = 2
		fileType = jpg
	if fileType = 3
		fileType = pdf

	IniWrite, %prefix%, %A_ScriptDir%\settings.ini, Settings, Prefix
	IniWrite, %newPrefix%, %A_ScriptDir%\settings.ini, Settings, NyPrefix
	IniWrite, %SettingsSuffix%, %A_ScriptDir%\settings.ini, Settings, Suffix
	IniWrite, %workingFolder%, %A_ScriptDir%\settings.ini, Settings, WorkingFolder
	IniWrite, %destinationFolder%, %A_ScriptDir%\settings.ini, Settings, DestinationFolder
	IniWrite, %exportFolder%, %A_ScriptDir%\settings.ini, Settings, ExportFolder
	IniWrite, %stationNumber%, %A_ScriptDir%\settings.ini, Settings, Station
	IniWrite, %fileType%, %A_ScriptDir%\settings.ini, Settings, FileType

	IniWrite, %catalogPrefix%, %A_ScriptDir%\settings.ini, Validation, CatalogPrefix
	IniWrite, %catalogStart%, %A_ScriptDir%\settings.ini, Validation, CatalogStart
	IniWrite, %catalogEnd%, %A_ScriptDir%\settings.ini, Validation, CatalogEnd
	IniWrite, %uuidPrefix%, %A_ScriptDir%\settings.ini, Validation, UUIDPrefix
	IniWrite, %boxPrefix%, %A_ScriptDir%\settings.ini, Validation, BoxPrefix
	IniWrite, %boxStart%, %A_ScriptDir%\settings.ini, Validation, BoxStart
	IniWrite, %boxEnd%, %A_ScriptDir%\settings.ini, Validation, BoxEnd

	Reload
Return

;----------------------------------------------------
List_taxa_objects:
	Gui, 1: ListView, ObjectList
	LV_Delete()
	Loop, read, %destinationFolder%\TaxonName_Object_list.txt
	{
		if (A_Index = 1)
			continue

		StringSplit, item, A_LoopReadLine, `|
		; Heuristic: Check if item3 is long (UUID -> Old format) or short (Suffix -> New format)
		if (StrLen(item3) > 15) {
			; Old Format: Name|Suffix|UUID... -> Display: Index, EmptyBox, Name, Suffix, UUID
			LV_Add("", A_index, "", item1, item2, item3)
		} else {
			; New Format: Box|Name|Suffix|UUID... -> Display: Index, Box, Name, Suffix, UUID
			LV_Add("", A_index, item1, item2, item3, item4)
		}
	}
	LV_ModifyCol(1, 0)
	LV_ModifyCol(2, 50)
	LV_ModifyCol(3, 100)
	LV_ModifyCol(4, 50)
	LV_ModifyCol(5, 200)
	LV_ModifyCol(1, "Integer")
	LV_ModifyCol(1, "SortDesc")
	LV_ModifyCol(2, "Left")
	LV_ModifyCol(3, "Left")
	LV_ModifyCol(4, "Left")
	LV_ModifyCol(5, "left")
Return

;===========================================================================================
; View Image
;===========================================================================================

Vis_bilde:
	GuiControl, 1: Hide, ErrorText
	GuiControl, 1:, PicControl, *w400 *h-1 %A_ScriptDir%\vent.jpg
	GuiControl, 1: Show, PicControl
	gosub, PleaseWait

	; Timeout configuration (5 seconds)
	maxRetries := 10
	retryInterval := 500
	foundValidFile := false

	Loop %maxRetries% {
		fileCount := 0
		firstFile := ""

		; Count files and get the first one found
		Loop, %workingFolder%\*.%fileExt% {
			fileCount := A_Index
			if (A_Index = 1)
				firstFile := A_LoopFileFullPath
		}

		; If no files, wait and retry
		if (fileCount = 0) {
			Sleep %retryInterval%
			continue
		}

		; If too many files, we can stop immediately (logic requires exactly 1)
		if (fileCount > 1) {
			break ; Proceed to validation checks below which handle >1
		}

		; Check if the single file is ready/readable (not locked by camera writing)
		f := FileOpen(firstFile, "r")
		if (IsObject(f)) {
			f.Close()
			foundValidFile := true
			break ; File is ready
		}

		Sleep %retryInterval%
	}

	gosub, PleaseWaitOff

	if (!foundValidFile && fileCount = 0) {
		ShowError("No images found in the folder after 5 seconds!")
		Gui, 1: Show,,
		Return
	}

	if (fileCount > 1) {
		ShowError("You have more than 1 image in your ""Work folder"", please clean up.")
		Gui, 1: Show,,
		Run %workingFolder%
		Return
	}

	; Success (Exactly 1 file found and readable)
	ClearError() ; Clear any previous errors
	SplitPath, firstFile, , , , outNameNoExt

	Gosub, Refresh ; Update ListView

	GuiControl, 1:, PicControl, *w400 *h-1 %A_ScriptDir%\go.jpg
	GuiControl, 1:, OldName, %outNameNoExt%
	GuiControl, 1: Show, PicControl

	imageShown := 1
	GuiControl, 1: enable, BtnRename
	GuiControl, 1: enable, BtnLabel
	GuiControl, 1: enable, BtnSameObject
	GuiControl, 1: +Default, BtnRename
	GuiControl, Focus, TaxonUUID

Return

;==========================================================================
; Barcode Enter Catch
;==========================================================================

#IfWinActive, Object_photo
	Enter::
		barcodeField =
		GuiControlGet, barcodeField, FocusV

		if barcodeField = TaxonUUID
		{
			sleep, 500
			GuiControl, focus, NewName
		}
		else if barcodeField = NewName
		{
			Sleep, 1000
			gosub RenameFiles
		}
		else
		{
			Send, {enter}
		}
	return

	;===========================================================================================
	; Rename/Move
	;===========================================================================================

	Nytt_Vis_bilde:
		sameOrNew = 1
		gosub, EmptyEdits
		gosub Vis_bilde
	return

	Sammeobj_Vis_bilde:
		sameOrNew = 2
		gosub Vis_bilde
		gosub NotEmptyEdits
		gosub RenameFiles
	return

	Label:
		global isLabel
		isLabel = 1
		sameOrNew = 2
		gosub Vis_bilde
		gosub NotEmptyEdits
		gosub RenameFiles
	return

	RenameFiles:
		Gui 1: submit, NoHide

		If (imageShown <> 1) {
			ShowError("No image found. Press ""Get Image""")
			return
		}

		if (taxonUUID = "" && sameOrNew != 2) {
			ShowError("You have forgotten the UUID (QR code)!")
			return
		}

		if (newName = "") {
			ShowError("You have forgotten the filename!")
			return
		}

		if (BoxNumber = "") {
			ShowError("You have forgotten the Box Number!")
			return
		}

		; --- Validation Logic ---

		; Only run validation if "Validate Input" is checked
		if (box = 1) {

			; 1. Catalog Number Validation
			; Strict Prefix Check
			if (CatalogPrefix != "" && !RegExMatch(newName, "^" . CatalogPrefix)) {
				ShowError("Catalog Number must start with prefix: " . CatalogPrefix)
				return
			}

			; Strict Range Check
			if (CatalogStart != 0 || CatalogEnd != 0) {
				; Extract numeric part by removing prefix
				numPart := newName
				if (CatalogPrefix != "")
					StringReplace, numPart, numPart, %CatalogPrefix%,, All

				if numPart is not number
				{
					ShowError("Catalog Number must contain a valid number after prefix!")
					return
				}

				; Check Min (Inclusive)
				if (CatalogStart != 0 && numPart < CatalogStart) {
					ShowError("Catalog Number is too low! Min: " . CatalogStart . " (Value: " . numPart . ")")
					return
				}
				; Check Max (Inclusive)
				if (CatalogEnd != 0 && numPart > CatalogEnd) {
					ShowError("Catalog Number is too high! Max: " . CatalogEnd . " (Value: " . numPart . ")")
					return
				}
			}

			; 2. UUID Validation
			if (UUIDPrefix != "") {
				if (!RegExMatch(taxonUUID, "^" . UUIDPrefix)) {
					ShowError("UUID must start with prefix: " . UUIDPrefix)
					return
				}

				; Check valid UUID format (8-4-4-4-12 hex) after prefix
				uuidSuffix := taxonUUID
				StringReplace, uuidSuffix, uuidSuffix, %UUIDPrefix%,, All
				if (!RegExMatch(uuidSuffix, "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")) {
					ShowError("Invalid UUID format after prefix!")
					return
				}
			}

			; 3. Box Number Validation
			if (BoxPrefix != "" || BoxStart != 0 || BoxEnd != 0) {
				; Strict Prefix Check
				if (BoxPrefix != "" && !RegExMatch(BoxNumber, "^" . BoxPrefix)) {
					ShowError("Box Number must start with prefix: " . BoxPrefix)
					return
				}

				; Strict Range Check
				if (BoxStart != 0 || BoxEnd != 0) {
					numPart := BoxNumber
					if (BoxPrefix != "")
						StringReplace, numPart, numPart, %BoxPrefix%,, All

					if numPart is not number
					{
						ShowError("Box Number must contain a valid number after prefix!")
						return
					}

					; Check Min (Inclusive)
					if (BoxStart != 0 && numPart < BoxStart) {
						ShowError("Box Number is too low! Min: " . BoxStart . " (Value: " . numPart . ")")
						return
					}
					; Check Max (Inclusive)
					if (BoxEnd != 0 && numPart > BoxEnd) {
						ShowError("Box Number is too high! Max: " . BoxEnd . " (Value: " . numPart . ")")
						return
					}
				}
			}
		}

		; ------------------------

		gosub, pleaseWait

		global finalFilename
		FileSetTime, , %outNameNoExt%.%fileExt%, A

		; --- Improved Naming Logic ---
		; Ensure suffix is formatted correctly using implicit zero padding if length is 1
		formattedSuffix := ""
		if (suffix <> "") {
			formattedSuffix := (StrLen(suffix) = 1) ? "0" . suffix : suffix
		}

		targetName := ""

		if (isLabel = 1) {
			; Label Logic
			targetName := newName
			if (formattedSuffix <> "")
				targetName .= "_" . formattedSuffix
			targetName .= "_Label." . fileExt

		} else {
			; Standard Logic
			targetName := newName
			if (newPrefix <> "")
				targetName := newPrefix . targetName

			if (formattedSuffix <> "")
				targetName .= "-" . formattedSuffix

			targetName .= "." . fileExt
		}

		finalFilename := targetName
		targetPath := destinationFolder . "\" . finalFilename

		FileMove, %outNameNoExt%.%fileExt%, %targetPath%, 0
		; -----------------------------

		errorCount := ErrorLevel

		if (errorCount != 0) {
			gosub PleaseWaitOff
			ShowError(errorCount . " files/folders could not be moved`nand renamed to:`n" . targetPath)
			newName := ""
			GuiControl, 1:, NewName, %newName%
			Gui, 1: Show,,
			Return
		} else {
			gosub, UpDateMotivationCount
			GuiControl, 1:, PicControl, *w400 *h-1 %A_ScriptDir%\done.jpg
			GuiControl, 1: Show, PicControl
			GuiControl, 1: Hide, ErrorText

			; Log to file
			logEntry := "Boks nr|MUSIT nummer|BildeNo|UUID|Bildefilnavn|Stasjon`n"
			dataRow := boxNumber . "|" . newName . "|" . suffix . "|" . taxonUUID . "|" . finalFilename . "|" . stationNumber

			IfExist %destinationFolder%\TaxonName_Object_list.txt
			{
				FileAppend, `n%dataRow%, %destinationFolder%\TaxonName_Object_list.txt
			} else {
				FileAppend, %logEntry%%dataRow%, %destinationFolder%\TaxonName_Object_list.txt
			}

			gosub, UpdateMotivation
			gosub, List_taxa_objects
			gosub, Refresh
			gosub PleaseWaitOff
		}
		isLabel = 0
		imageShown = 0
		GuiControl, 1: focus, NewName
		GuiControl, 1: Disable, BtnRename
	return

	EmptyEdits:
		GuiControl, 1:, NewName, % ""
		GuiControl, 1:, OldName, % ""
		GuiControl, 1:, Suffix, 1

		GuiControl, 1: focus, NewName
		Gui, 1: Show,,
	return

	NotEmptyEdits:
		suffix := suffix + 1
		GuiControl, 1:, Suffix, %suffix%
		GuiControl, 1: focus, BtnSameObject
		Gui, 1: Show,,
	return

	UpDateMotivationCount:
		if (storedDailyCount < 1)
			storedDailyCount := 1
		else
			storedDailyCount ++

		if (storedTotalCount < 1)
			storedTotalCount := storedDailyCount
		else
			storedTotalCount ++

		IniWrite, %todaysDate%, %A_ScriptDir%\settings.ini, Motivation, Date
		IniWrite, %storedDailyCount%, %A_ScriptDir%\settings.ini, Motivation, DailyCount
		IniWrite, %yesterdayDate%, %A_ScriptDir%\settings.ini, Motivation, YesterdayDate
		IniWrite, %storedYesterdayCount%, %A_ScriptDir%\settings.ini, Motivation, YesterdayCount
		IniWrite, %storedTotalCount%, %A_ScriptDir%\settings.ini, Motivation, TotalCount
	return

	PleaseWait:
		GuiControl, 1: Show, Working
		SetTimer Scroll, 20
	return

	PleaseWaitOff:
		SetTimer Scroll, Off
		GuiControl, 1: Hide, Working
	return

	Scroll:
		GuiControl, 1:, Working, +2
	Return

	Esc::
	GuiClose:
		WinGetPos, guiX, guiY,,, ahk_id %guiId%
		if (guiX > -800) {
			IniWrite, x%guiX% y%guiY%, %A_ScriptDir%\settings.ini, window position, gui_position
			ExitApp
		} else {
			IniWrite, x100 y100, %A_ScriptDir%\settings.ini, window position, gui_position
			ExitApp
		}

		;===========================================================================================
		; Error Handling
		;===========================================================================================

		ShowError(msg) {
			GuiControl, 1: Hide, PicControl
			GuiControl, 1:, ErrorText, %msg%
			GuiControl, 1: Show, ErrorText
			SoundPlay, *48 ; Play warning sound
		}

		ClearError() {
			GuiControl, 1: Hide, ErrorText
			GuiControl, 1: Show, PicControl
		}
