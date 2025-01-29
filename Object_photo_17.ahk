#SingleInstance, Force

SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
SetBatchLines, -1
FileEncoding , UTF-8
;==================================================
;Read the values for preference file
;==================================================
 
 ;~ read the saved positions or center if not previously saved
IniRead, gui_position, %A_ScriptDir%\settings.ini, window position, gui_position, Center



;~ get the window's ID so you can get its position later
Gui, 1: +Hwndgui_id

 $xpos := 100
 $ypos := 100				; får å unngå feil feil hvis bilde ikke vises

$_Bilde_vist := 0			; Skal brukes i Rename: for å sjekk om man har hentet et bile med Vis_Bilde: da skal den ha verdien 1

Suff := 1

  FileReadLine, Prefix, %A_ScriptDir%\Preferences.txt, LineNum 1                                           	 ; the prefix of the files to search for
  FileReadLine, NyPrefix, %A_ScriptDir%\Preferences.txt, LineNum 2                                        	 ; The prefix tha will be given to the new filenames
  ;FileReadLine, Suffix, %A_ScriptDir%\Preferences.txt, LineNum 3                                         	 ; the suffix the will be added to the files when the name is changed
  FileReadLine, mappe, %A_ScriptDir%\Preferences.txt, LineNum 4                                           	 ; Working directory
  FileReadLine, dest, %A_ScriptDir%\Preferences.txt, LineNum 5                                            	 ; destination folder
  FileReadLine, $_Export_dest, %A_ScriptDir%\Preferences.txt, LineNum 6										; Export folder
  FileReadLine, $_Fotostasjon, %A_ScriptDir%\Preferences.txt, LineNum 7										; fotostasjonnummer
  FileReadLine, $filetype, %A_ScriptDir%\Preferences.txt, LineNum 8										; mom det er tif eller jpg osv som er bildeformatet
  

$fileExt := $filetype



SetWorkingDir %mappe%                               														 ; Ensures a consistent starting directory.

Gui, 1:  Add, Tab2,h857 w1167, Program||Settings
Gui, 1:  tab, Program

Gui,  1: Add, Progress, x20 y60 w120 h210 Backgroundc8b4a7 Disabled ; for å gi farge rundt knappene
Gui, 1:  Add, Button, x30 y65 w100 h50 gNytt_Vis_bilde v$VisBilde Default , &Hent bilde `nNytt objekt
Gui, 1:  Add, Button, x30 y135 w100 h50 gSammeobj_Vis_bilde v$VisBilde_sammeobj +Disabled, Hent bilde `n&Samme objekt
Gui, 1: Add, Button, x30 y205 w100 h50 gLabel v$_LabelKnapp +Disabled, Hent bilde `nLabel


Gui, 1: Add, Text, x232 y60 w90 h20 , Filnavn
Gui, 1: Add, Edit, r1 x232 y90 w90 h30 VOldName +disabled, 
Gui, 1: Add, Text, x342 y60 w120 h20 , MUSIT nr.:
Gui, 1: Add, Edit, r1 x342 y90 w120 h30 vNewName limit20,
Gui, 1: Add, Text, x475 y60 w80 h30 , Bilde nr.
Gui, 1: Add, Edit, r1 x475 y90 w40 h30 vSuffix , %Suff%

Gui, 1: font, s13 cRed w700, Arial
Gui, 1: Add, Text, x232 y130 w90 h30 , QR-kode (UUID)
Gui, 1: Add, Edit, r1 x232 y150 w300 h30 v$_Taxon hwndTaN, %$_Taxon%
Gui, 1: font, 			; tilbake til default font

Gui, 1: Add, Text, x232 y200 w90 h20 , Kommentar
Gui, 1: Add, Edit, r2 x232 y220 w400 h20 v$_Kommentar, 


Gui,  1: Add, Progress, x550 y65 w120 h60 Backgroundc8b4a7 Disabled ; for å gi farge rundt knappen
Gui, 1: Add, Button, x560 y70 w100 h50 gRenameFiles v$_RenameFiles +Disabled, Gi nytt navn!



Gui, Add, CheckBox, x560 y150 w100 h30 vbox , Validering av Musit nummer
;===============================================================================
;Listview over objekter og navn
;===============================================================================


Gui, 1: Add, ListView, x500 y350 w490 h490 Grid v$_Objekt_taxa, nummerliste|Musit nr|Bilde nr.|UUID|Kommentar
gosub List_taxa_objects
 

gui, 1: Add, Button, x500 y300 w120 h40 gList_taxa_objects, Oppdater DataListe

;===============================================================================


Gui, 1: Add, Picture, x40 y400 vPic ,



;===============================================================================
;ListView over filene i arbeidsmappa og destinasjonsmappa
;===============================================================================
Gui, 1: Add, GroupBox, x1000 y335 w160 h520 , Bildefoldere

Gui, 1: Add, Button, x1040 y360 w100 h30 gRefresh, Oppdater filliste

Gui, 1: Add, ListView, x1030 y400 w120 h240 v$destview, Filer destination folder
Loop, %dest%\*.%$fileExt%						; Gather a list of file names from a folder and put them into the ListView:
    LV_Add("", A_LoopFileName)

Gui, 1: Add, Button,  x1040 y650 w100 h30 gOpendest, Åpne Destination folder

Gui, 1: Add, ListView, x1030 y700 w120 h100  v$worklist , Filer Working folder
Loop, %mappe%\*.%$fileExt%						; Gather a list of file names from a folder and put them into the ListView:
   LV_Add("", A_LoopFileName)


Gui, 1: Add, Button, x1040 y820 w100 h30 gOpenwork, Åpne Working folder






NewName := $aa  ;Bruker verdien 0 for å sjekke om man har husket å legge inn et nytt navn, se slutten av programmet

;===============================================================================
;Motivation part
;===============================================================================

Gui, 1: Add, GroupBox, x900 y50 w220 h240 , Antall bilder

Gui, 1: Add, Text, x930 y90 w40 h30 , Totalt
Gui, 1: Add, Edit, Right r1 x930 y120 w40 h30 v$tot +disabled, 
Gui, 1: Add, Text, x990 y90 w40 h30 , I går
Gui, 1: Add, Edit, Right r1 x990 y120 w40 h30 v$Gaar +disabled, 
Gui, 1: Add, Text, x1050 y90 w40 h30 , I dag
Gui, 1: Add, Edit, Right r1 x1050 y120 w40 h30 v$Dags +disabled, 
Gui, 1: Add, Progress, Vertical  vMyProgressGaard x1000 y160 w30 h110 , 
Gui, 1: Add, Progress, Vertical vMyProgressDags x1060 y160 w30 h110 , 



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

if ($ddato = $Yesterday)  ; Sjekk om gårsdagensdato (i virkeligheten) er det samme som det som er skrevet som dagensdato i fila
{
	gosub , UpdateFromYesterday
}
IF ( $dagensdato != $ddato) 
{
	gosub , UpdateFromEarlier
}

gosub, UpdateMotivation




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


Gui, Add, GroupBox,  x62 y280 w350 h60,
Gui, 1: Add, Text, x72 y305 w80 h30 , Set filtype
;~ Gui, 1: Add, Edit, x172 y300 w50 h30 v$filetype +disabled, %$filetype%
Gui, 1: Add, Radio, v$filetype x172 y300 w50 h30 , tif
Gui, 1: Add, Radio, x222 y300 w50 h30 , jpg
Gui, 1: Add, Radio, x272 y300 w50 h30 , pdf

Gui, 1: Add, Button, gSavePref x172 y450 w100 h30 , Save Settings



Gui, 1: Show, %gui_position% h880 w1190, Object_photo

GuiControl, , %$filetype%, 1

OnMessage( 0x111, "WM_Command" )                ; Når det sendes en beskjed fra windows om at en WM_command er sendt , kjør da WM_Command for å finne ut hvilken kontroll

Gui, 3: Add, Progress, -Smooth vWorking 0x8 w250 h18 ; PBS_MARQUEE = 0x8

return
;============================================================
;WM_Command vil oppdage når noen klikker i taxa feltet og slettet innholdet der
;==========================================================

WM_Command( wp, lp ) {
  Global TaN
  If ( (wp >> 16) = 0x100 && lp = TaN ) { ; EN_SETFOCUS = 0x100  Bit shift left (<<) and right (>>). hexadecimal (also base 16, or hex) 0x100 =  SS_NOTIFY
    GuiControl,,$_Taxon  
	
}}


;===============================================================================
;Motivation part GUI progress bars
;===============================================================================

UpdateFromYesterday:

$gantall =
$gantall := $dantall
$dantall =

  FileDelete, %A_ScriptDir%\Motivation_dag.txt
  FileAppend, %$dagensdato%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 	; dagensdato
  FileAppend, %$dantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 		; antall bilder tatt i dag
  FileAppend, %$Yesterday%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 	; dagensdato
  FileAppend, %$gantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 		; antall bilder tatt i dag
  FileAppend, %$totantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       	 		; antall bilder tatt i dag

return


UpdateFromEarlier:

$gantall =
$dantall =

  FileDelete, %A_ScriptDir%\Motivation_dag.txt
  FileAppend, %$dagensdato%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
  FileAppend, %$dantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       		 ; antall bilder tatt i dag
  FileAppend, %$Yesterday%`n, %A_ScriptDir%\Motivation_dag.txt,                                         	 ; dagensdato
  FileAppend, %$gantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       		 ; antall bilder tatt i dag
  FileAppend, %$totantall%`n, %A_ScriptDir%\Motivation_dag.txt,                                       		 ; antall bilder tatt i dag

return


UpdateMotivation:

					GuiControl, 1:, $tot, %$totantall%
					GuiControl, 1:, $Gaar, %$gantall%
					GuiControl, 1:, $Dags, %$dantall%
					;=============================================================
					;Status bar
					;=============================================================
						
							
						if $gantall < 100
						{
						GuiControl, 1: +cRed, MyProgressGaard,
						GuiControl, 1:, MyProgressGaard, %$gantall%
						}
						else if $gantall < 200
						{
						GuiControl, 1:+cBlue, MyProgressGaard,
						GuiControl, 1:, MyProgressGaard, %$gantall%
						}
						else if $gantall < 300
						{
						GuiControl, 1:+cYellow, MyProgressGaard,
						GuiControl, 1:, MyProgressGaard, %$gantall%
						}
						else if $gantall < 400
						{
						GuiControl, 1:+cSilver, MyProgressGaard,
						GuiControl, 1:, MyProgressGaard, %$gantall%
						}
						else if $gantall < 500
						{
						GuiControl, 1:+cLime, MyProgressGaard,
						GuiControl, 1:, MyProgressGaard, %$gantall%
						}
						else 
						{
						GuiControl, 1:+cGreen, MyProgressGaard,
						GuiControl, 1:, MyProgressGaard, %$gantall%
						}
;---- Dagens søyle
						if $dantall < 100
						{
						GuiControl, 1: +cRed, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
						else if $dantall < 200
						{
						GuiControl, 1:+cBlue, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
						else if $dantall < 300
						{
						GuiControl, 1:+cYellow, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
						else if $dantall < 400
						{
						GuiControl, 1:+cSilver, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
						else if $dantall < 500
						{
						GuiControl, 1:+cLime, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
						else if $dantall < 600
						{
						GuiControl, 1:+cBlack, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
						else if $dantall < 700
						{
						GuiControl, 1:+cMaroon, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
						else 
						{
						GuiControl, 1:+cGreen, MyProgressDags,
						GuiControl, 1:, MyProgressDags, %$dantall%
						}
return



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
Loop, %mappe%\*.%$fileExt%						; Gather a list of file names from a folder and put them into the ListView:
    LV_Add("", A_LoopFileName)

Gui, 1: Listview, $destview
LV_Delete()
Listdest =
Loop, %dest%\*.%$fileExt%
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

;------ Finn ut hvlike filtype vi skal ha fra radioboksene
if $filetype = 1
	$filetype = tif
if $filetype = 2
	$filetype = jpg
if $filetype = 3
	$filetype = pdf
			
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
					  FileAppend, %$filetype%`n, %A_ScriptDir%\Preferences.txt
					  Reload 
					  
Return

;----------------------------------------------------
List_taxa_objects:

Gui, 1: ListView, $_Objekt_taxa		; denne lista heter $_Taxa_Objekter
LV_Delete()
Loop, read, %dest%\TaxonName_Object_list.txt
{
if a_index = 1
	continue

else
{
	StringSplit, item, A_LoopReadLine, `|
	LV_Add("",A_index,item1,item2,item3,item4)
}
}
LV_ModifyCol(1, 0)
LV_ModifyCol(2, 100)
LV_ModifyCol(3, 50)	
LV_ModifyCol(4, 200)		 
LV_ModifyCol(5, 300)			 


LV_ModifyCol(1, "Integer")
LV_ModifyCol(1, "SortDesc")
LV_ModifyCol(2, "Left")
LV_ModifyCol(3, "Left")
LV_ModifyCol(4, "left") 
LV_ModifyCol(5, "Left")

Return



;===========================================================================================
; Her sjekker programmet om det finnes 1 eller flere jpg filer og hvis det bare er 1 så vises denne
;===========================================================================================


Vis_bilde:

Number =   ;setter variabelen Number til å inneholde ingenting 
WinGetPos , $xpos, $ypos
$xpos := $xpos+200
$ypos := $ypos+400
$_Bilde_vist = 0
GuiControl, 1:, Pic, *w400 *h-1 %A_ScriptDir%\vent.jpg            ; Viser Vent bildet

GuiControl, 1: Show, Pic


gosub, PleaseWait
	
	

; Sjekk om fila er fredig skrevet

						FileGetSize, $BildeFilSize, %mappe%\*.%$fileExt% , K
						Sleep 1000
						FileGetSize, $NyBildeFilStize, *.%$fileExt% , K
						If ($BildeFilSize <> $NyBildeFilStize)
						{
						goto , Vis_bilde
						}							
							

; først oppdater listview

		Gosub, Refresh
		
; Så sjekk om det finnes 1 jpg fil 
;	

		
loop, %mappe%\*.%$fileExt%
{ 
	SplitPath, A_LoopFileName, , , , OutNameNoExt, 				; ta bort .jpg exstention fra variabel, slik at bare det forand punktum blir lastet inn som variabel
	Number := A_Index
}

	if Number < 1
	{
		
		gosub, PleaseWaitOff
		MsgBox , 262160, , Det finnes ingen bilder i mappa!
		GuiControl, 1:, Pic, *w400 *h-1, $aa
		Gui, 1: Show,,
		Return
	}

	else if	Number > 1		;teller hvor mage jpg filer det er i working directory og hvis det er mer enn 1 så gir den feilmelding og åpner folderen
	{
		gosub, PleaseWaitOff
		GuiControl, 1:, Pic, *w400 *h-1, $aa
		Gui, 1: Show,,
		MsgBox , 262160, , Du har flere enn 1 bilderfiler i "Image mappa" di, vennligst rydd opp.
		Run %mappe%
		Return
	}
	
	else 								;hvis det bare et jpg bilde i mappa
	{
							GuiControl, 1:, Pic, *w400 *h-1 %A_ScriptDir%\go.jpg            ; Viser Vent bildet
							GuiControl, 1:, OldName,  %OutNameNoExt%
							GuiControl, 1: Show, Pic
							gosub, PleaseWaitOff
							$_Bilde_vist = 1
							GuiControl , 1: enable, $_RenameFiles
							GuiControl , 1: enable, $_LabelKnapp
							GuiControl , 1: enable, $VisBilde_sammeobj
							GuiControl , 1: +Default, $_RenameFiles
							GuiControl, Focus, $_Taxon
	
	}

Return



;
;==========================================================================
;Strekkodeleseren sender et enter, her fanges det opp
;===========================================================================

#IfWinActive , Object_photo
Enter::
$StrekFelt =
GuiControlGet, $StrekFelt, FocusV			;finner ut fokus og lagrer det til variablen $Strekfelt

if $StrekFelt = $_Taxon
{
	sleep , 500
	GuiControl , focus , NewName			; Flytter focus fra Taxonfeltet til filnavn
}

else if $StrekFelt = NewName
{
	Sleep , 1000
	gosub RenameFiles
}
else
{
Send , {enter}
}
return

;===========================================================================================
;Rename filer og flytt dem
;===========================================================================================

Nytt_Vis_bilde:

$_Same_or_New = 1
gosub , EmptyEdits
gosub Vis_bilde

return

Sammeobj_Vis_bilde:

$_Same_or_New = 2
gosub Vis_bilde
gosub RenameFiles

return

;=========================================================================00
;Label sjekker om det er et etikett bilde og i såfall legger til Label i navnet på fila
;===========================================================================

Label:

global $_label
$_label = 1
$_Same_or_New = 2
gosub Vis_bilde
gosub NotEmptyEdits
gosub RenameFiles

return



RenameFiles:

Gui 1:  submit, NoHide

If		($_Bilde_vist <> 1)
{
	MsgBox Ingen bilde er funnet. Trykk "Hent bilde"
	return
}

if ($_Taxon = $aa) 			; sjekk om det er skrevet inn et taxon navn
{
	SoundSet, 100
	;~ SoundPlay, %A_ScriptDir%\uhoh.wav ;
	MsgBox , 262160, , Du har glemt UUID (QR kode)!
	return
}

 if (NewName = $aa)
{
	MsgBox , 262160, , Du har glemt filnavn!
	return
}

;===========================================================================================
;Trimme Strekkodenummer og splitte det
;===========================================================================================
 $_deltnavn1 := NewName

;===========================================================================================
;Vis Please wait bar
;===========================================================================================
		
		gosub, pleaseWait

	global	$_Filnavn



FileSetTime , , %OutNameNoExt%.%$fileExt% , A
if ($_label = 1)
{
		if (Suffix <> "")
		{
			FileMove ,%OutNameNoExt%.%$fileExt%, %dest%\%$_deltnavn1%_%$_deltnavn2%_%Suffix%_Label.%$fileExt%, 0
			$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_%Suffix%_Label.%$fileExt%
		}
		else
		{
		FileMove ,%OutNameNoExt%.%$fileExt%, %dest%\%$_deltnavn1%_%$_deltnavn2%_Label.%$fileExt%, 0
		$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_Label.%$fileExt%
		}
}

else
{
		if (Suffix <> "")
		{
			FileMove ,%OutNameNoExt%.%$fileExt%, %dest%\%NyPrefix%%$_deltnavn1%-0%Suffix%.%$fileExt%, 0
			$_Filnavn = %NyPrefix%%$_deltnavn1%-0%Suffix%.%$fileExt%
		}
		else
		{

		FileMove ,%OutNameNoExt%.%$fileExt%, %dest%\%$_deltnavn1%_%$_deltnavn2%.%$fileExt%, 0
		$_Filnavn = %$_deltnavn1%_%$_deltnavn2%.%$fileExt%
		}
}

ErrorCount := ErrorLevel

if ErrorCount <> 0
{
	gosub PleaseWaitOff
	MsgBox , 262160, ,  %ErrorCount% files/folders could not be moved and renamed
	NewName := ""
	GuiControl, 1:, NewName,  %NewName%
	Gui, 1: Show,,
	Return
}
else
{
				gosub , UpDateMotivationCount				;Oppdaterer motivasjonsdelen

				GuiControl, 1: Hide, Pic, 
				
				IfExist %dest%\TaxonName_Object_list.txt			; så det ikke blir problemer med tomme linjer
				{
				FileAppend , `n%$_deltnavn1%|%Suffix%|%$_Taxon%|%$_Kommentar%|%$_Filnavn%|%$_Fotostasjon%, %dest%\TaxonName_Object_list.txt
				}
				else
				{
					; AccNo|ItemNo|BildeNo|Skuff|Kommentar|Bildefilnavn|Stasjon
				FileAppend , MUSIT nummer|BildeNo|UUID|Kommentar|Bildefilnavn|Stasjon`n%$_deltnavn1%|%Suffix%|%$_Taxon%|%$_Kommentar%|%$_Filnavn%|%$_Fotostasjon%, %dest%\TaxonName_Object_list.txt	
				}
				
				gosub , UpdateMotivation
				gosub , List_taxa_objects		
				gosub , Refresh			;oppdaterer listview
				gosub PleaseWaitOff				
}
$_label = 0
$_Bilde_vist = 0			; Skal brukes i Rename: for å sjekk omman har hentet et bile med Vis_Bilde: da skal den ha verdien 1
GuiControl, 1: focus , NewName
GuiControl, 1: Disable, $_RenameFiles

return

EmptyEdits:				;tøm skrivefeltene
						$null :=
						GuiControl, 1:, NewName, %$null% 
						GuiControl, 1:, OldName, %$null%
						GuiControl, 1:, $_Kommentar, %$null%
						GuiControl, 1:, $NorskNavn, %$null%
						GuiControl, 1:, $EngelskNavn, %$null%
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



UpDateMotivationCount:

				;==============================================
				; lagre antall filer tatt til motivasjonsdelen
				; 
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



;===========================================================================================
;Vis Please wait bar
;===========================================================================================
PleaseWait:
		Gui, 3: Show,  , Please wait...
		SetTimer Scroll, 1 , 100
		Sleep 200
return

PleaseWaitOff:
		SetTimer Scroll, Off
		Gui, 3: Hide
return

Scroll:
		GuiControl, 3:, Working, +3
Return	



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

