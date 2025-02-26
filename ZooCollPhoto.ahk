#SingleInstance, Force
#NoEnv

;==================================================
;Read the values for preference file
;==================================================
 
 ;~ read the saved positions or center if not previously saved
IniRead, gui_position, %A_ScriptDir%\settings.ini, window position, gui_position, Center

;~ get the window's ID so you can get its position later
Gui, 1: +Hwndgui_id

 $xpos := 100
 $ypos := 100				; får å unngå feil feil hvis bilde ikke vises

$_Bilde_vist := 0			; Skal brukes i Rename: for å sjekk omman har hentet et bile med Vis_Bilde: da skal den ha verdien 1

Suff := 1
tabStop = 


  FileReadLine, Prefix, %A_ScriptDir%\Preferences.txt, LineNum 1                                           	 ; the prefix of the files to search for
  FileReadLine, NyPrefix, %A_ScriptDir%\Preferences.txt, LineNum 2                                        	 ; The prefix tha will be given to the new filenames
  FileReadLine, mappe, %A_ScriptDir%\Preferences.txt, LineNum 4                                           	 ; Working directory
  FileReadLine, dest, %A_ScriptDir%\Preferences.txt, LineNum 5                                            	 ; destination folder
  FileReadLine, $_Export_dest, %A_ScriptDir%\Preferences.txt, LineNum 6										; Export folder
  FileReadLine, $_Fotostasjon, %A_ScriptDir%\Preferences.txt, LineNum 7										; fotostasjonnummer
  FileReadLine, umappe, %A_ScriptDir%\Preferences.txt, LineNum 8										; mappe der bildene skal valideres av zbar
  FileReadLine, motivValg, %A_ScriptDir%\Preferences.txt, LineNum 9
  
SetWorkingDir %mappe%                               														 ; Ensures a consistent starting directory.

Gui, 1:  Add, Tab2,h857 w1167, Program||Settings|About
Gui, 1:  tab, Program

Gui, 1: font, s25 cRed Bold, Arial
Gui, 1: Add, Text, x30 y50 w300 h50 , Zoo Foto
Gui, 1: font, 	; tilbake til default font



Gui, 1:  Add, Button, x30 y110 w100 h50 gNytt_Vis_bilde v$VisBilde Default , &Hent bilde `nNytt objekt
Gui, 1:  Add, Button, x30 y170 w100 h50 gSammeobj_Vis_bilde v$VisBilde_sammeobj +Disabled, Hent bilde `n&Samme objekt
Gui, 1: Add, Button, x30 y230 w100 h50 gLabel v$_LabelKnapp +Disabled, Hent bilde `nLabel

Gui, 1: font, Bold, Arial
Gui, 1: Add, Text, x140 y110 w90 h20 , Originalt filnavn
Gui, 1: Add, Edit, r1 x140 y130 w150 h20 VOldName +disabled, 

Gui, 1: font, s10 cRed Bold, Arial
Gui, 1: Add, Text, x140 y170 w140 h30 , AccNo (= nytt filnavn)
Gui, 1: font, 	; tilbake til default font
Gui, 1: Add, Edit, r1 x140 y190 w150 h20 vNewName limit20,
Gui, 1: Add, Text, x298 y170 w80 h20 , Bilde nr.
Gui, 1: Add, Edit, r1 x298 y190 w40 h20 vSuffix , %Suff%


Gui, 1: Add, Text, x360 y110 w90 h20 , Kommentar 
Gui, 1: Add, Edit, x360 y130 w310 h60 vbildeKommentar, 

;- motiv
Gui, 1: Add, Text, x360 y200 w140 h30 , Motiv
Gui, 1: Add, ComboBox, x360 y215 w310 vmotiv, %motivValg%

;--  Tab stop
Gui, 1: font, s12 cNavy, Arial
Gui, 1: Add, GroupBox, x730 y110 w100 h100 , Tab stop
Gui, 1: font, 
Gui, 1: Add, Radio, x740 y140 vRadioVar1 gRadioTab Checked, AccNo
Gui, 1: Add, Radio, vRadioVar2 gRadioTab,Kommetar
Gui, 1: Add, Radio,vRadioVar3 gRadioTab,Motiv


Gui, 1: Add, Button, x730 y230 w100 h50 gRenameFiles v$_RenameFiles +Disabled, Endre navn og flytt fila!



;===============================================================================
;Listview over objekter og navn
;===============================================================================
Gui, 1: font, s10 cNavy w700, Arial
Gui, Add, GroupBox, x460 y300 w530 h555 , Prosesserte filer
Gui, 1: font, 	; tilbake til default font

Gui, 1: Add, Button, x470 y320 w150 h30 gList_taxa_objects, Oppdater Prosesserte filer

Gui, 1: font, Italic, Arial
Gui, 1: Add, Text, x765 y335 w220 h20 , Working folder\TaxonName_Object_list.txt
Gui, 1: font, 	; tilbake til default font

Gui, 1: Add, ListView, x470 y360 w510 h480 Grid v$_Objekt_taxa, lnr|AccNo|ItemNo|BildeNo|Bildefilnavn|Kommentar
gosub List_taxa_objects
 

;===============================================================================
Gui, 1: tab, Program

Gui, 1: Add, Picture, x40 y400 vPic ,


;===============================================================================
;ListView over filene i arbeidsmappa og destinasjonsmappa
;===============================================================================
Gui, 1: font, s10 cNavy w700, Arial
Gui, Add, GroupBox, x1000 y300 w160 h555 , Bildefoldere
Gui, 1: font, 	; tilbake til default font

Gui, 1: Add, Button, x1010 y320 w140 h30 gRefresh, Oppdater filliste

;------------------------------------------------------------------------------
; Working folder
;------------------------------------------------------------------------------
Gui, 1: font, s12 cNavy w140, Arial
Gui, 1: Add, Text, x1010 y360 w140 h30 , Working folder
Gui, 1: font, 	; tilbake til default font

Gui, 1: Add, ListView, x1010 y382 w140 h100  v$worklist , Alle bildefiler (*.jpg):
Loop, %mappe%\*.jpg						; Gather a list of file names from a folder and put them into the ListView:
   LV_Add("", A_LoopFileName)

Gui, 1: Add, Button, x1010 y492 w140 h30 gOpenwork,Åpne Working folder

;------------------------------------------------------------------------------
; Destination folder
;------------------------------------------------------------------------------
Gui, 1: font, s12 cNavy w140, Arial
Gui, 1: Add, Text, x1010 y540 w140 h30 , Destination folder
Gui, 1: font, 	; tilbake til default font

Gui, 1: Add, ListView, x1010 y562 w140 h240 v$destview, Alle bildefiler (*.jpg):
Loop, %dest%\*.jpg						; Gather a list of file names from a folder and put them into the ListView:
    LV_Add("", A_LoopFileName)

Gui, 1: Add, Button,  x1010 y812 w140 h30 gOpendest, Åpne Destination folder




NewName := $aa  ;Bruker verdien 0 for å sjekke om man har husket å legge inn et nytt navn, se slutten av programmet

;===============================================================================
;Motivation part
;===============================================================================
Gui, 1: font, s10 cNavy w700, Arial
Gui, Add, GroupBox, x900 y50 w260 h240 , Antall bilder
Gui, 1: font, 	; tilbake til default font

Gui, 1: Add, Text, x910 y70 w40 h30 , Totalt
Gui, 1: Add, Edit, Right r1 x910 y90 w40 h30 v$tot +disabled, 
Gui, 1: Add, Text, x1000 y70 w40 h30 , I går
Gui, 1: Add, Edit, Right r1 x1000 y90 w40 h30 v$Gaar +disabled, 
Gui, 1: Add, Progress, Vertical  vMyProgressGaard x1007 y200 w30 h80 , 
Gui, 1: Add, Text, x1090 y70 w40 h30 , I dag
Gui, 1: Add, Edit, Right r1 x1090 y90 w40 h30 v$Dags +disabled, 
Gui, 1: Add, Progress, Vertical vMyProgressDags x1097 y200 w30 h80 , 



	;=============================================================
	;Dagens dato
	;=============================================================
	FormatTime, $dagensdato, ,MMdd

	$Yesterday = %a_now%
	$Yesterday += -1, days
	FormatTime, $Yesterday, %$Yesterday%, MMdd

	;=============================================================



  FileReadLine, $ddato, %A_ScriptDir%\Motivation_dag.txt, LineNum 1                                           	 ; dagensdato
  FileReadLine, $dantall,%A_ScriptDir%\Motivation_dag.txt, LineNum 2                              		     	 ; antall bilder tatt i dag
  FileReadLine,  $Yday, %A_ScriptDir%\Motivation_dag.txt, LineNum 3                                     		    	; gårsdagensdato
  FileReadLine, $gantall, %A_ScriptDir%\Motivation_dag.txt, LineNum 4                                           	 ; antall bilder tatt i går
  FileReadLine, $totantall, %A_ScriptDir%\Motivation_dag.txt, LineNum 5                                           	 ; antall bilder tatt totalt
					
if ($dagensdato = $ddato) {
    ; No action is specified for this condition
} else if ($ddato = $Yesterday) {
    ; If the date in the file matches yesterday's date, update
    Gosub, UpdateFromYesterday
} else {
    ; If the date is older, use a different update method
    Gosub, UpdateFromEarlier
}

; Always update motivation, regardless of the date
Gosub, UpdateMotivation


;===============================================================================
;Settings for programmet
;===============================================================================
Gui, 1: tab, Settings


Gui, 1: Add, Text, x72 y60 w80 h30 , Vis filer med følgende prefiks
Gui, 1: Add, Edit, r1 x172 y60 w80 h30 vPrefix, %Prefix%
Gui, 1: Add, Text, x272 y60 w80 h30 , Prefiks på de nye fil navnene
Gui, 1: Add, Edit, r1 x372 y60 w80 h30 vNyPrefix, %NyPrefix%
Gui, 1: Add, Text, x500 y60 w80 h30 , Suffix
Gui, 1: Add, Edit, r1 x542 y60 w80 h30 vSuff, %Suff%

Gui, 1: Add, Text, x72 y120 w150 h30 , Set Stasjonsnr
Gui, 1: Add, Edit, r1 x170 y120 w50 h30 v$_Fotostasjon , %$_Fotostasjon%

Gui, 1: Add, Text, x72 y150 w80 h30 , Set working folder
Gui, 1: Add, Edit, x172 y150 w450 h30 vmappe +disabled, %mappe%
Gui, 1: Add, Button, gArbeidsmappe x652 y150 w80 h30 , Browse

Gui, 1: Add, Text, x72 y200 w80 h30 , Set destination folder
Gui, 1: Add, Edit, x172 y200 w450 h30 vdest +disabled, %dest%
Gui, 1: Add, Button,x652 y200 w80 h30 gDestmappe, Browse

;-- Motiv
Gui, 1: font, bold, Arial
Gui, 1: Add, Text, r1 x72 y300 , Skriv inn valg til motivfeltet, skill valgene dine med | For eksempel: `n`n 
Gui, 1: font,
Gui, 1: Add, Text, r3 x72 y320 ,Lateral|Ventral|Habitus
Gui, 1: Add, Edit, r1 x72 y340 w450  vmotivValg , %motivValg%


Gui, 1: Add, Button, gSavePref x650 y500 w100 h50 , Save Settings

;===============================================================================
;About the programmet
;===============================================================================
Gui, 1: tab, About
Gui, 1: font, s12 Bold, Arial

Gui, 1: Add, Link, x70 y60 w700 h60 , Dette programmet er lagd for å enkelt omdøpe bildefiler som er tatt av samlingsobjekter. Programmets hjemmeside finner du <a href="https://github.com/Rindiser/objectPhotot">her</a>.

Gui, 1: Add, Link,, Finner du bugs, har ønsker om ny funksjonalitet eller liknende, register en  <a href="https://github.com/Rindiser/objectPhotot/issues">Issue på Github</a>


Gui, 1: Add, Link,, `n`n Eirik Rindal 2014-2025, lisens: <a href="https://creativecommons.org/publicdomain/zero/1.0/">CC0</a> 
;----------

Gui, 1: Show, %gui_position% h880 w1190, ZooCollPhoto
OnMessage( 0x111, "WM_Command" )                ; Når det sendes en beskjed fra windows om at en WM_command er sendt , kjør da WM_Command for å finne ut hvilken kontroll

Gui, 3: Add, Progress, -Smooth vWorking 0x8 w250 h18 ; PBS_MARQUEE = 0x8

return

;set tabStops
RadioTab:
	Gui, Submit, NoHide
		; Determine which radio button is selected by checking each variable
		if (RadioVar1)
			tabStop := "NewName"
		else if (RadioVar2)
			tabStop := "bildeKommentar"
		else if (RadioVar3)
			tabStop := "motiv"
Return



;===================================================================================
;WM_Command vil oppdage når noen klikker i skuffenr.-feltet og slettet innholdet der
;===================================================================================

WM_Command( wp, lp ) {
  Global TaN
  If ( (wp >> 16) = 0x100 && lp = TaN ) { ; EN_SETFOCUS = 0x100  Bit shift left (<<) and right (>>). hexadecimal (also base 16, or hex) 0x100 =  SS_NOTIFY
    GuiControl,,$_Skuffenummer  	
}}


;===============================================================================
;Motivation part GUI progress bars
;===============================================================================

UpdateFromYesterday:
 
	$gantall =
	$gantall := $dantall
	$dantall =

	FileDelete, %A_ScriptDir%\Motivation_dag.txt
	FileAppend, %$dagensdato%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
	FileAppend, %$dantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag
	FileAppend, %$Yesterday%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
	FileAppend, %$gantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag
	FileAppend, %$totantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag

return

UpdateFromEarlier:
 
	$gantall =
	$dantall =

	FileDelete, %A_ScriptDir%\Motivation_dag.txt
	FileAppend, %$dagensdato%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
	FileAppend, %$dantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag
	FileAppend, %$Yesterday%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
	FileAppend, %$gantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag
	FileAppend, %$totantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag

return

UpdateMotivation:

    ; Update GUI Controls
    GuiControl, 1:, $tot, %$totantall%
    GuiControl, 1:, $Gaar, %$gantall%
    GuiControl, 1:, $Dags, %$dantall%

    ; Update Status Bar for MyProgressGaard
    UpdateProgressBar($gantall, "MyProgressGaard")
    
    ; Update Status Bar for MyProgressDags
    UpdateProgressBar($dantall, "MyProgressDags")

return

UpdateProgressBar(Count, ControlName) {
    if Count < 100
        Color := "Red"
    else if Count < 200
        Color := "Blue"
    else if Count < 300
        Color := "Purple"
    else if Count < 400
        Color := "Silver"
    else if Count < 500
        Color := "Lime"
    else if Count < 600 && ControlName = "MyProgressDags"
        Color := "Black"
    else if Count < 700 && ControlName = "MyProgressDags"
        Color := "Maroon"
    else
        Color := "Green"

    GuiControl, 1:+c%Color%, %ControlName%
    GuiControl, 1:, %ControlName%, %Count%
}



;===============================================================================
;Open work and dest folder
;===============================================================================

Openwork:
	Run %mappe%
return

Opendest:
	Run %dest%
return

Refresh:
	Gui, 1: Listview, $worklist
	LV_Delete()
	Loop, %mappe%\*.jpg						; Gather a list of file names from a folder and put them into the ListView:
		LV_Add("", A_LoopFileName)

	Gui, 1: Listview, $destview
	LV_Delete()
	Listdest =
	Loop, %dest%\*.jpg
	{
		If A_index < 2 				; for å unngå blank linje
		{
		Listdest = %Listdest%%A_LoopFileTimeAccessed%|%A_LoopFileName%	
		}
		else
		{
		Listdest = %Listdest%`n%A_LoopFileTimeAccessed%|%A_LoopFileName%
		}

	}					; Gather a list of file names from a folder and put them into the ListView:

	Sort, Listdest, R ; Sort by date.
	FileDelete , Listdest.txt

	FileAppend ,  %Listdest%,  Listdest.txt
	Loop, parse, Listdest, `n,
	{
		StringSplit, item, A_LoopField, `|
		LV_Add("",item2)
		
	}
return

;===============================================================================
;Sett arbeidsfolder og destinasjonsfolder
;===============================================================================

Arbeidsmappe:
	FileSelectFolder, mappe , , 3, Velg mappe
	mappe := RegExReplace(mappe, "\\$")  ; Removes the trailing backslash, if present.
	if mappe = 
	{
		SetWorkingDir %A_ScriptDir% 
		GuiControl, 1:, mappe, %A_ScriptDir%
	}
	else
	{
		SetWorkingDir %mappe%
		GuiControl, 1:, mappe, %mappe%
	}
Return
  
Destmappe:
  FileSelectFolder, dest , , 3, Velg mappe

	dest := RegExReplace(dest, "\\$")  ; Removes the trailing backslash, if present.
	if dest = 
	{
		MsgBox Choose destination folder!
	}
	else
	{
	GuiControl, 1:, dest, %dest%
	}

return
  
  
;===============================================================================
;Save changes to settings
;===============================================================================

SavePref:
  FileDelete, %A_ScriptDir%\Preferences.txt
  Gui 1:  submit, NoHide
			
	;======================================
	;Write variables to file
	;======================================
	
	FileAppend, %Prefix%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %NyPrefix%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %Suff%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %mappe%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %dest%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %$_Export_dest%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %$_Fotostasjon%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %umappe%`n, %A_ScriptDir%\Preferences.txt
	FileAppend, %motivValg%`n, %A_ScriptDir%\Preferences.txt
	
	Reload 
					  
Return


List_taxa_objects:

	Gui, 1: ListView, $_Objekt_taxa		; denne lista heter $_Taxa_Objekter
	LV_Delete()
	Loop, read, %dest%\TaxonName_Object_list.txt
	{
		StringSplit, item, A_LoopReadLine, `|
		LV_Add("",A_index,item1,item2,item3,item4,item5,item6)	
	}

	LV_ModifyCol(1, "0 Integer Center SortDesc")			 
	LV_ModifyCol(2, "100 Left")		 
	LV_ModifyCol(3, "50 Integer Center")		 ; For sorting purposes, indicate that column 2 is an integer.
	LV_ModifyCol(4, "50 Integer Center")
	LV_ModifyCol(5, "50 Center")		 
	LV_ModifyCol(6, "140 Left")			 
	LV_ModifyCol(7, "1000 Left")				 

Return




;===========================================================================================
; Her sjekker programmet om det finnes 1 eller flere jpg filer og hvis det bare er 1 så vises denne
;===========================================================================================

Vis_bilde:

	Number := 0  ;setter variabelen Number til å inneholde ingenting
	WinGetPos , $xpos, $ypos
    xpos += 200
    ypos += 400
	$_Bilde_vist := 0
	GuiControl, 1:, Pic, *w400 *h-1 %A_ScriptDir%\vent.jpg            ; Viser Vent bildet
	GuiControl, 1: Show, Pic

;===========================================================================================
;Vis Please wait bar
;===========================================================================================

	Gui, 3: +AlwaysOnTop
	Gui, 3: Show,  x%$xpos% y%$ypos%, Please wait...
	SetTimer Scroll, 10

; Sjekk om fila er fredig skrevet
	FileGetSize, BildeFilSize, %mappe%\*.jpg, K
	Sleep, 1000
	FileGetSize, NyBildeFilSize, *.jpg, K
	If (BildeFilSize <> NyBildeFilSize) {
		Goto, Vis_bilde
	}						
							

; først oppdater listview
	Gosub, Refresh
		
; Så sjekk om det finnes 1 jpg fil 
		
	loop, %mappe%\*.jpg
	{ 
		Number := A_Index
	}

	if (Number < 1) {
        MsgBox, 262160, , Det finnes ingen bilder i mappa!
        Cleanup()
        Exit
    } else if (Number > 1) {
        MsgBox, 262160, , Du har flere enn 1 jpg filer i "Image mappa" di, vennligst rydd opp.
        Run, %mappe%
        Cleanup()
        Exit
    } else {
        ; If only one jpg file exists
        Loop, %Prefix%*.jpg
        {
			Gui, 3: Hide
			SetTimer, Scroll, Off
			SplitPath, A_LoopFileName, , , , OutNameNoExt
            GuiControl, 1:, Pic, *w400 *h-1 %A_ScriptDir%\go.jpg
            GuiControl, 1:, OldName, %OutNameNoExt%
            GuiControl, 1: Show, Pic
            $_Bilde_vist := 1
            EnableControls()
            Goto, EndOfLoop
        }
        ; If no jpg files with the correct prefix
        MsgBox, Ingen bilder med riktig Prefiks i mappa
        Cleanup()
    }

Return

EnableControls() {
    GuiControl, 1: enable, $_RenameFiles
    GuiControl, 1: enable, $_LabelKnapp
    GuiControl, 1: enable, $VisBilde_sammeobj
    GuiControl, 1: +Default, $_RenameFiles
}

Cleanup() {
    Gui, 3: Hide
    SetTimer, Scroll, Off
    GuiControl, 1:, Pic, *w400 *h-1, $aa  ; Assuming $aa should be cleared
    Gui, 1: Show
}

EndOfLoop:
GuiControl, Focus, %tabStop%
return

; progressbar update

Scroll:
	GuiControl,3:, Working, +1
Return


;==========================================================================
; Entrer fra strekkodeleseren oppdages og håndteres under det aktive vinduet ZooCollPhoto
;==========================================================================

#IfWinActive, ZooCollPhoto
    Enter::
        ; Henter gjeldende fokuserte kontroll
        GuiControlGet, SkannerFokus, FocusV

        if (SkannerFokus = "NewName") {
            Sleep, 1000
            Gosub, RenameFiles
        } 
        else {
            Send, {Enter}
        }
	return


;===========================================================================================
;Rename filer og flytt dem
;===========================================================================================

Nytt_Vis_bilde:
	$_Same_or_New := 1

	gosub , EmptyEdits
	goto Vis_bilde
	return

	Sammeobj_Vis_bilde:

	$_Same_or_New := 2


	gosub Vis_bilde

	if $ManueltBilde = 0
	{
	gosub , NotEmptyEdits
	}
	else
	{
		InputBox, $ManeueltBildeNummer, Bilde nummer, skriv inn bildenummer, , , 
	if ErrorLevel
	return
	else
	
		gosub, NotEmptyEditsManual
	}

	goto RenameFiles
return

;===========================================================================
; Label sjekker om det er et etikett bilde og i såfall legger til Label i navnet på fila
;===========================================================================

Label:
	global $_label
	$_label := 1
	$_Same_or_New := 2
	gosub Vis_bilde
	gosub , NotEmptyEdits
	goto , RenameFiles
return



RenameFiles:
	Gui 1:  submit, NoHide
	StringLen, filNavnLengde, NewName ; for å sjekkat at filnavnet er riktig lengde

    if ($_Bilde_vist <> 1) {
        MsgBox, Ingen bilde er funnet. Trykk "Hent bilde"
        return
    }
    
    if (!testNyttFilNavn(NewName, filNavnLengde)) {
        return
    }


    ; Trim barcode number and split it
    StringTrimRight, NewName, NewName, 2
    StringSplit, $_deltnavn, NewName, /

	;===========================================================================================
	;Vis Please wait bar
	;===========================================================================================
			
	Gui, 3: +AlwaysOnTop
	Gui, 3: Show,  x%$xpos% y%$ypos%, Please wait...
	SetTimer Scroll, 10

	global	$_Filnavn
		
	FileSetTime , , %OutNameNoExt%.jpg , A
	if ($_label = 1) {
		if (Suffix <> "") {
			FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%_%Suffix%_Label.jpg, 0
			$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_%Suffix%_Label.jpg				
		}
		else {
		FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%_Label.jpg, 0
		$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_Label.jpg
		}
	} else {

		if (Suffix <> "") {
			FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%_%Suffix%.jpg, 0
			$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_%Suffix%.jpg
		}
		else {
			FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%.jpg, 0
			$_Filnavn = %$_deltnavn1%_%$_deltnavn2%.jpg
		}
	}

	ErrorCount := ErrorLevel

	if ErrorCount <> 0
	{
		Gui, 3: Hide
		SetTimer , Scroll , Off
		MsgBox , 262160, ,  %ErrorCount% files/folders could not be moved and renamed
		NewName :=
		GuiControl, 1:, NewName,  %NewName%
		Gui, 1: Show,,
		Return
	} else {
		gosub , UpDateMotivationCount				;Oppdaterer motivasjonsdelen
		Gui, 3: Hide
		SetTimer , Scroll , Off
		GuiControl, 1: Hide, Pic, 
		
		MsgBox, %dest%
		; så det ikke blir problemer med tomme linjer
		filePath = %dest%\TaxonName_Object_list.txt
		if FileExist(filePath) {
			FileAppend , `n%$_deltnavn1%|%$_deltnavn2%|%Suffix%|%$_Filnavn%|%$_Kommentar%|%$_Fotostasjon%, %dest%\TaxonName_Object_list.txt
		} else {
			; AccNo|ItemNo|BildeNo|Kommentar|Bildefilnavn|Stasjon
			FileAppend , AccNo|ItemNo|BildeNo|Bildefilnavn|Kommentar|Stasjon`n%$_deltnavn1%|%$_deltnavn2%|%Suffix%|%$_Filnavn%|%$_Kommentar%|%$_Fotostasjon%, %dest%\TaxonName_Object_list.txt	
		}
		gosub , UpdateMotivation
		gosub , List_taxa_objects		
		gosub , Refresh			;oppdaterer listview		
	}

	$_label := 0
	$_Bilde_vist := 0			; Skal brukes i Rename: for å sjekk omman har hentet et bile med Vis_Bilde: da skal den ha verdien 1
	GuiControl, 1: focus , NewName
	GuiControl, 1: Disable, $_RenameFiles

return

testNyttFilNavn(NewName, filNavnLengde) {
return true
    ; Validate that NewName isn't empty
    if (!NewName) {
        MsgBox, 262160, , Du har glemt fil navn!
        return False
    }

    ; Check the length of NewName
    filNavnLengde := StrLen(NewName)
    if (filNavnLengde < 13) {
        ShowError("Filnavn har feil format (for kort)!")
        return False
    }

    if (filNavnLengde > 19) {
        ShowError("Filnavn har feil format (for langt)!")
        return False
    }

    ; Ensure NewName starts with 'NHMO-BI-'
    if (SubStr(NewName, 1, 8) != "NHMO-BI-") {
        ShowError("Filnavn har feil format (begynner ikke med 'NHMO-BI-')!")
        return False
    }

    ; Check '/' appearance position
    SlashPos := InStr(NewName, "/")
    if (SlashPos < 10 || SlashPos > 15) {
        ShowError("Filnavn har feil format (trolig feil i prefix eller aksesjonsnummer)!")
        return False
    }

    return True
}

ShowError(ErrorMessage) {
    SoundSet, 100
    SoundPlay, %A_ScriptDir%\uhoh.wav
    MsgBox, 262160, , %ErrorMessage%
}






EmptyEdits:				;tøm skrivefeltene
	$null :=
	GuiControl, 1:, NewName, %$null% 
	GuiControl, 1:, OldName, %$null%
	GuiControl, 1:, $_Kommentar, %$null%
	GuiControl, 1:, Suffix, 1
	GuiControl, 1: focus , NewName
	Gui, 1: Show,,
return
		
NotEmptyEdits:
	Suffix:=Suffix+1
	GuiControl, 1:, $_Kommentar, %$null%
	GuiControl, 1:, Suffix,%Suffix%
	GuiControl, 1: focus ,$VisBilde_sammeobj
	Gui, 1: Show,,
return


NotEmptyEditsManual:
	gui, 5: submit
	gui, 5: Destroy

	GuiControl, 1:, $_Kommentar, %$null%
	GuiControl, 1:, Suffix,%$ManeueltBildeNummer%
	GuiControl, 1: focus ,$VisBilde_sammeobj
	Gui, 1: Show,,
return


UpDateMotivationCount:
	;==============================================
	; lagre antall filer tatt til motivasjonsdelen
	;==============================================
	if ($dantall < 1)
	{
		$dantall := 1
	}
	else
	{
		$dantall ++				; teller i motivasjonsdelen
	}

	if ($totantall < 1)
	{
		$totantall := $dantall
	}

	else
	{
		$totantall ++			; teller i motivasjonsdelen
	}

	FileDelete, %A_ScriptDir%\Motivation_dag.txt

	FileAppend, %$dagensdato%`n,%A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
	FileAppend, %$dantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag
	FileAppend, %$Yesterday%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
	FileAppend, %$gantall%`n,%A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag
	FileAppend, %$totantall%`n,%A_ScriptDir%\Motivation_dag.txt,                                       	 ; antall bilder tatt i dag
	;========================================================
return


;==================================================================

;~ when you close the window, get its position and save it
Esc::
GuiClose:
	WinGetPos, gui_x, gui_y,,, ahk_id %gui_id%

	; if window position is outside the screen it centeres it
	if (gui_x>-800) 
	{
		IniWrite, x%gui_x% y%gui_y%, %A_ScriptDir%\settings.ini, window position, gui_position
		ExitApp
	}
	else
	{
		IniWrite, x100 y100, %A_ScriptDir%\settings.ini, window position, gui_position
		ExitApp
	}

