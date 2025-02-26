#SingleInstance, Force
#NoEnv

;===========================================================================
;'BirdCollPhoto' er basert på og videreutviklet fra 'Object_photo_130_bird'
;===========================================================================
 
;==================================================
;Endringer etter BirdCollPhoto_001
;==================================================
;002: Kommenterte ut første rad i avsnittet "Trimme Strekkodenummer og splitte det" for å beholde "NHMO-BI-" i filnavnene etter renaming og flytting til server
;003: Endret sjekk av lengde på scannet AccNo, slik at lengde 16 til 18 aksepteres, ikke kun 17. Rad 864: if ($_leng < 16 or $_leng > 17)
;003: Endret navnet på bakgrunnsdatafila slik at dette ikke trenger å endres i koden hver gang denne oppdateres (fjernet måned og år). Rad 28
;004: Div. endringer, bl.a. flere nye sjekk av innscannet AccNo (ca. rad. 867), endringer i layout
 
;==================================================
;Read the values for preference file
;==================================================
 
 ;~ read the saved positions or center if not previously saved
IniRead, gui_position, %A_ScriptDir%\settings.ini, window position, gui_position, Center


;==================================================
;Read les inn fila med objektnummer og hylleplassering inn i variablen  $_DataListe og finn ut hvor mange linjer det er i fila og skriv det til $_LastLineNumber
;==================================================
global $_DataListe

FileRead , $_DataListe, %A_ScriptDir%\BirdColl_BackgroundData.txt


global $_LastLineNumber

Loop, Parse, $_DataListe , `n, `r
{
	
	$_LastLineNumber := A_Index
}


;~ get the window's ID so you can get its position later
Gui, 1: +Hwndgui_id

 $xpos := 100
 $ypos := 100				; får å unngå feil feil hvis bilde ikke vises

$_Bilde_vist := 0			; Skal brukes i Rename: for å sjekk omman har hentet et bile med Vis_Bilde: da skal den ha verdien 1

Suff := 1

  FileReadLine, Prefix, %A_ScriptDir%\Preferences.txt, LineNum 1                                           	 ; the prefix of the files to search for
  FileReadLine, NyPrefix, %A_ScriptDir%\Preferences.txt, LineNum 2                                        	 ; The prefix tha will be given to the new filenames
  ;FileReadLine, Suffix, %A_ScriptDir%\Preferences.txt, LineNum 3                                         	 ; the suffix the will be added to the files when the name is changed
  FileReadLine, mappe, %A_ScriptDir%\Preferences.txt, LineNum 4                                           	 ; Working directory
  FileReadLine, dest, %A_ScriptDir%\Preferences.txt, LineNum 5                                            	 ; destination folder
  FileReadLine, $_Export_dest, %A_ScriptDir%\Preferences.txt, LineNum 6										; Export folder
  FileReadLine, $_Fotostasjon, %A_ScriptDir%\Preferences.txt, LineNum 7										; fotostasjonnummer
  FileReadLine, umappe, %A_ScriptDir%\Preferences.txt, LineNum 8										; mappe der bildene skal valideres av zbar


SetWorkingDir %mappe%                               														 ; Ensures a consistent starting directory.

Gui, 1:  Add, Tab2,h857 w1167, Program||Settings
Gui, 1:  tab, Program

Gui, 1: font, s25 cRed Bold, Arial
Gui, 1: Add, Text, x30 y30 w160 h50 , Fuglefoto
Gui, 1: font, 	; tilbake til default font

Gui, 1: font, s10 cBlue , Arial
Gui, 1: Add, Text, x30 y75 w120 h20 , Utbredelse
Gui, 1: Add, Text, x30 y95 w90 h20 , Art
Gui, 1: Add, Text, x30 y115 w90 h20 , Taksonomi
Gui, 1: Add, Text, x30 y135 w160 h20 , Land
Gui, 1: font, s10 cGreen , Arial
Gui, 1: Add, Text, r1 x140 y75 w750 h20 v$Utbredelse,
Gui, 1: Add, Text, r1 x140 y95 w500 h20 v$NorskNavn,
Gui, 1: Add, Text, r1 x140 y115 w500 h20 v$Taxonomi,
Gui, 1: Add, Text, r1 x140 y135 w500 h20 v$Land,
Gui, 1: font, 	; tilbake til default font

Gui, 1: Add, CheckBox, x140 y154 w150 h20 vbox Checked , Validering av AccNo

Gui, 1:  Add, Button, x30 y180 w100 h50 gNytt_Vis_bilde v$VisBilde Default , &Hent bilde `nNytt objekt
Gui, 1:  Add, Button, x30 y260 w100 h50 gSammeobj_Vis_bilde v$VisBilde_sammeobj +Disabled, Hent bilde `n&Samme objekt
Gui, 1: Add, Button, x30 y340 w100 h50 gLabel v$_LabelKnapp +Disabled, Hent bilde `nLabel

;Gui, 1: Add, CheckBox, x350 y240 w150 h30 vbox Checked , Validering av AccNo

Gui, 1: font, Bold, Arial
Gui, 1: Add, Text, x140 y180 w170 h20 , Skuff/Plassering (hvis kjent)
Gui, 1: font, 	; tilbake til default font
Gui, 1: Add, Edit, r1 x140 y200 w150 h20 v$_Skuffenummer hwndTaN, %$_Skuffenummer%

Gui, 1: Add, Text, x140 y230 w90 h20 , Originalt filnavn
Gui, 1: Add, Edit, r1 x140 y250 w150 h20 VOldName +disabled, 

Gui, 1: font, s10 cRed Bold, Arial
Gui, 1: Add, Text, x140 y278 w140 h30 , AccNo (= nytt filnavn)
Gui, 1: font, 	; tilbake til default font
Gui, 1: Add, Edit, r1 x140 y298 w150 h20 vNewName limit20,
Gui, 1: Add, Text, x298 y280 w80 h20 , Bilde nr.
Gui, 1: Add, Edit, r1 x298 y298 w40 h20 vSuffix , %Suff%
Gui, 1: Add, CheckBox, x298 y327 w150 h20 v$Bildebox , Manuelt bildenr.

Gui, 1: Add, Button, x350 y270 w100 h50 gRenameFiles v$_RenameFiles +Disabled, Endre navn på`nog flytt fila!

Gui, 1: Add, Text, x140 y330 w90 h20 , Kommentar
Gui, 1: Add, Edit, r2 x140 y350 w310 h20 v$_Kommentar, 


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

Gui, 1: Add, ListView, x470 y360 w510 h480 Grid v$_Objekt_taxa, lnr|AccNo|ItemNo|BildeNo|Skuff|Bildefilnavn|Kommentar
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
					
IF ( $dagensdato = $ddato) ; sjekk om dagensdato (i virkeligheten) er det samme som det som er skrevet som dagensdato i fila
{
	
}
		

else if ($ddato = $Yesterday)  ; Sjekk om gårsdagensdato (i virkeligheten) er det samme som det som er skrevet som dagensdato i fila
{
	gosub , UpdateFromYesterday
}
else
{
	gosub , UpdateFromEarlier
}

gosub, UpdateMotivation

;===============================================================================
;Valider & Exporter
;===============================================================================

;Gui, 1:  Add, Button,  x800 y670 w100 h50 gExport, &Exporter  !



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


;~ Gui, 1: Add, Text, x72 y250 w80 h30 , Set export folder
;~ Gui, 1: Add, Edit, x172 y250 w480 h30 v$_Export_dest +disabled, %$_Export_dest%
;~ Gui, 1: Add, Button,x652 y250 w80 h30 gExportmappe, Browse

Gui, 1: Add, Text, x72 y300 w80 h30 , Set validering folder
Gui, 1: Add, Edit, x172 y300 w450 h30 vumappe +disabled, %umappe%
Gui, 1: Add, Button,x652 y300 w80 h30 gumappeSet, Browse

Gui, 1: Add, Button, gSavePref x172 y370 w100 h30 , Save Settings



Gui, 1: Show, %gui_position% h880 w1190, BirdCollPhoto_004
OnMessage( 0x111, "WM_Command" )                ; Når det sendes en beskjed fra windows om at en WM_command er sendt , kjør da WM_Command for å finne ut hvilken kontroll

Gui, 3: Add, Progress, -Smooth vWorking 0x8 w250 h18 ; PBS_MARQUEE = 0x8
;====================================================
; Gui for når qr kodern ikke kan leses
;====================================================

Gui, 4: Add, Picture, x22 y20 v$_ErrorPic , 
Gui, 4: Add, Button, x650 y110 w200 h30 gAgain, Slett Blide
Gui, 4: font, s15 cRed, Arial
Gui, 4: Add, Text, x650 y30 w250 h80 v$_Feilmelding, %$_Feilmelding%
Gui, 4: font, s15 cRed, Arial

return
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
						GuiControl, 1:+cPurple, MyProgressGaard,
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
						GuiControl, 1:+cPurple, MyProgressDags,
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
  
  
  
  umappeSet:
  FileSelectFolder, umappe , , 3, Velg mappe
  
  
umappe := RegExReplace(umappe, "\\$")  ; Removes the trailing backslash, if present.
if umappe = 
{
	MsgBox Choose destination folder!
}
else
{
GuiControl, 1:, umappe, %umappe%
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


;LV_ModifyCol(3, "Integer Center")  ; For sorting purposes, indicate that column 2 is an integer.
;LV_ModifyCol(3, "Integer Center") ; få tallet i kollone 1 til å bil sentrert
;LV_ModifyCol(1, "Integer Center")
;LV_ModifyCol(1, "SortDesc")




Return




;===========================================================================================
; Her sjekker programmet om det finnes 1 eller flere jpg filer og hvis det bare er 1 så vises denne
;===========================================================================================





Vis_bilde:

Number = $aa  ;setter variabelen Number til å inneholde ingenting ($aa er tom)
WinGetPos , $xpos, $ypos
$xpos := $xpos+200
$ypos := $ypos+400
$_Bilde_vist := 0
GuiControl, 1:, Pic, *w400 *h-1 %A_ScriptDir%\vent.jpg            ; Viser Vent bildet

GuiControl, 1: Show, Pic

;===========================================================================================
;Vis Please wait bar
;===========================================================================================
		
		;~ Gui, 3: Add, Progress, -Smooth vWorking 0x8 w250 h18 ; PBS_MARQUEE = 0x8
		Gui, 3: +AlwaysOnTop
		Gui, 3: Show,  x%$xpos% y%$ypos%, Please wait...
		SetTimer Scroll, 10
	
	
	

; Sjekk om fila er fredig skrevet

						FileGetSize, $BildeFilSize, %mappe%\*.jpg , K
						Sleep 1000
						FileGetSize, $NyBildeFilStize, *.jpg , K
						If ($BildeFilSize <> $NyBildeFilStize)
						{
						goto , Vis_bilde
						}							
							

; først oppdater listview

		Gosub, Refresh
		
; Så sjekk om det finnes 1 jpg fil 
;	

		
loop, %mappe%\*.jpg
{ 
	Number := A_Index
}

	if Number < 1
	{
		
		MsgBox , 262160, , Det finnes ingen bilder i mappa!
		Gui, 3: hide
		SetTimer , Scroll , Off
		GuiControl, 1:, Pic, *w400 *h-1, $aa
		Gui, 1: Show,,
		Exit
		
		
	}
	else if	Number > 1		;teller hvor mage jpg filer det er i working directory og hvis det er mer enn 1 så gir den feilmelding og åpner folderen
	{
	
	
	Gui, 3: hide
	SetTimer , Scroll , Off
	GuiControl, 1:, Pic, *w400 *h-1, $aa
	Gui, 1: Show,,
	MsgBox , 262160, , Du har flere enn 1 jpg filer i "Image mappa" di, vennligst rydd opp.
	Run %mappe%
	Exit
	
	
	}
	
	else 								;hvis det bare et jpg bilde i mappa
	{
	
		
							Loop, %Prefix%*.jpg, 0, 0
							{ 


							SplitPath, A_LoopFileName, , , , OutNameNoExt, 				; ta bort .jpg exstention fra variabel, slik at bare det forand punktum blir lastet inn som variabel

							jpg_files = %OutNameNoExt%
									
													
													
							;GuiControl, 1:, Pic, *w600 *h-1 %OutNameNoExt%.jpg             ; Viser bildet som er funnet og resizer det tili bredde 600
							GuiControl, 1:, Pic, *w400 *h-1 %A_ScriptDir%\go.jpg            ; Viser Vent bildet
							;Gui, 1: Show, ,
							GuiControl, 1:, OldName,  %OutNameNoExt%
							GuiControl, 1: Show, Pic
							Gui, 3: Hide
							SetTimer , Scroll , Off
							;~ GuiControl, focus, NewName
							$_Bilde_vist := 1
							GuiControl , 1: enable, $_RenameFiles
							GuiControl , 1: enable, $_LabelKnapp
							GuiControl , 1: enable, $VisBilde_sammeobj
							GuiControl , 1: +Default, $_RenameFiles
							
							
							/
								
							Goto EndOfLoop
												

							}
							
								Gui, 3: Hide
								GuiControl, 1:, Pic, *w400 *h-1, $aa
								Gui, 1: Show,,
								MsgBox Ingen bilder med riktig Prefiks i mappa
								 
								
							



	
}

Return


	EndOfLoop:

	GuiControl, Focus, NewName
	return

; progressbar update

Scroll:
GuiControl,3:, Working, +1

Return


;
;==========================================================================
;Strekkodeleseren sender et enter, her fanges det opp
;===========================================================================

#IfWinActive , BirdCollPhoto_004
Enter::
$StrekFelt =
GuiControlGet, $StrekFelt, FocusV			;finner ut fokus og lagrer det til variablen $Strekfelt

if $StrekFelt = $_Skuffenummer
{
	sleep , 500
	GuiControl , focus , NewName			; Flytter focus fra Skuffenr.-feltet til filnavn
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

$_Same_or_New := 1

;GuiControl , , box, 0
GuiControl , , $Bildebox, 0
gosub , EmptyEdits
goto Vis_bilde
return

Sammeobj_Vis_bilde:

$_Same_or_New := 2

GuiControlGet, $ManueltBilde, , $Bildebox 
gosub Vis_bilde

if $ManueltBilde = 0
{
;~ MsgBox ikke manuelt
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

;=========================================================================00
;Label sjekker om det er et etikett bilde og i såfall legger til Label i navnet på fila
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
StringLen, $_leng, NewName ; for å sjekkat at filnavnet er riktig lengde



If		($_Bilde_vist <> 1)
{
	MsgBox Ingen bilde er funnet. Trykk "Hent bilde"
	return
}

GuiControlGet , $_Skuff, , $_Skuffenummer			;hent skuffenr.

/*
if ($_Skuff = $aa) 			; sjekk om det er skrevet inn et skuffenr.
{
	SoundSet, 100
	SoundPlay, %A_ScriptDir%\uhoh.wav ;
	MsgBox , 262160, , Du har glemt skuffenr.!
	return
}
*/
 if (NewName = $aa)
{
	
	MsgBox , 262160, , Du har glemt fil navn!
	return
}

if ($_leng < 13)
{
	SoundSet, 100
	SoundPlay, %A_ScriptDir%\uhoh.wav ;
	MsgBox , 262160, , Filnavn har feil format (for kort)!
	return
}

if ($_leng > 19)
{
	SoundSet, 100
	SoundPlay, %A_ScriptDir%\uhoh.wav ;
	MsgBox , 262160, , Filnavn har feil format (for langt)!
	return
}

if (InStr(NewName,"NHMO-BI-") < 1 or InStr(NewName,"NHMO-BI-") > 1)
{
	SoundSet, 100
	SoundPlay, %A_ScriptDir%\uhoh.wav ;
	MsgBox , 262160, , Filnavn har feil format (begynner ikke med 'NHMO-BI-')!
	return
}

;Alternativ kode for å sjekke at "NHMO-BI-" finnes i variabel:
;IfNotInString NewName, NHMO-BI-
;	{
;	MsgBox Filnavn har feil format (begynner ikke med 'NHMO-BI-')!
;	return
;	}

if (InStr(NewName,"/") < 10 or InStr(NewName,"/") > 15)
{
	SoundSet, 100
	SoundPlay, %A_ScriptDir%\uhoh.wav ;
	MsgBox , 262160, , Filnavn har feil format (trolig feil i prefix eller aksesjosnummer)!
	return
}


;===========================================================================================
;Sjekk om innskrevet skuffenummer er det samme som i basen
;===========================================================================================


if (box = 1)
{
	gosub , SjekkOmFinesiBasen
	
}




;===========================================================================================
;Trimme Strekkodenummer og splitte det
;===========================================================================================

;StringTrimLeft, NewName, NewName, 8
StringTrimRight, NewName, NewName, 2
Stringsplit , $_deltnavn, NewName, '/




;===========================================================================================
;Vis Please wait bar
;===========================================================================================
		
		Gui, 3: +AlwaysOnTop
		Gui, 3: Show,  x%$xpos% y%$ypos%, Please wait...
		SetTimer Scroll, 10

	global	$_Filnavn
		
FileSetTime , , %OutNameNoExt%.jpg , A
if ($_label = 1)
{
		if (Suffix <> "")
		{
			FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%_%Suffix%_Label.jpg, 0
			$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_%Suffix%_Label.jpg
			
		}
		else
		{

		FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%_Label.jpg, 0
		$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_Label.jpg
		}
	
	
	
}

else
{

		if (Suffix <> "")
		{
			FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%_%Suffix%.jpg, 0
			$_Filnavn = %$_deltnavn1%_%$_deltnavn2%_%Suffix%.jpg
		}
		else
		{

		FileMove ,%OutNameNoExt%.jpg, %dest%\%$_deltnavn1%_%$_deltnavn2%.jpg, 0
		$_Filnavn = %$_deltnavn1%_%$_deltnavn2%.jpg
		}

}

ErrorCount := ErrorLevel

if ErrorCount <> 0
{
	Gui, 3: Hide
	SetTimer , Scroll , Off
;Gui, 2: Destroy
	MsgBox , 262160, ,  %ErrorCount% files/folders could not be moved and renamed
	NewName :=
	GuiControl, 1:, NewName,  %NewName%
	Gui, 1: Show,,
	Return
}
else
{
				gosub , UpDateMotivationCount				;Oppdaterer motivasjonsdelen

				Gui, 3: Hide
				SetTimer , Scroll , Off
							;Gui, 2: Destroy			;Fjern please wait winduet
				GuiControl, 1: Hide, Pic, 
				
				IfExist %dest%\TaxonName_Object_list.txt			; så det ikke blir problemer med tomme linjer
				{
				FileAppend , `n%$_deltnavn1%|%$_deltnavn2%|%Suffix%|%$_Skuff%|%$_Filnavn%|%$_Kommentar%|%$_Fotostasjon%, %dest%\TaxonName_Object_list.txt
				}
				else
				{
					; AccNo|ItemNo|BildeNo|Skuff|Kommentar|Bildefilnavn|Stasjon
				FileAppend , AccNo|ItemNo|BildeNo|Skuff|Bildefilnavn|Kommentar|Stasjon`n%$_deltnavn1%|%$_deltnavn2%|%Suffix%|%$_Skuff%|%$_Filnavn%|%$_Kommentar%|%$_Fotostasjon%, %dest%\TaxonName_Object_list.txt	
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


SjekkOmFinesiBasen:

; $_DataListe har blitt lest inn helt i begynnelsen av programmet


Loop, Parse, $_DataListe , `n, `r	
	{
	$_DataLinje := A_LoopField
		
    Loop, parse, A_LoopField, |
		
    {
	
		
		GuiControl, 2:, $_SearchShow,  %A_LoopField%
		$ID = %A_LoopField%
		$IDD = %A_Index%
		
		
		if ($ID = NewName and $IDD = 1)
		{
						
						StringSplit , datafelter, $_DataLinje, |
						
						$_objektnummer := datafelter1
						$_Skuffenummer_fra_basen := datafelter2
						$Enavn := datafelter3
						$NNavn := datafelter4
						$Country := datafelter5
						$TaxDistr := datafelter6
						$Order := datafelter7
						$Family := datafelter8
						
							;====================================================
							; Sammenliknger om innskrevet skuffenummer er det samme som skuffenummer registrert i basen
							;====================================================	
							
							
							if (($_Skuffenummer <> $_Skuffenummer_fra_basen) AND ($_Skuffenummer <> $aa) )
							{
							SoundSet, 100
							;~ SoundPlay *16  ;
							SoundPlay, %A_ScriptDir%\uhoh.wav ;
							MsgBox, 4356, , Skuffenummeret du har oppgitt stemmer ikke med basen.`n`nEr du sikker på at det er riktig?
							IfMsgBox Yes
							{
							;Hvis vi alikevel er sikre går vi ut av denne subrutine og tilbake til der vi kom fra for aa rename og flyte fila
								;~ GuiControl, 1:, $EngelskNavn, %$Enavn%
								GuiControl, 1:, $NorskNavn, %$NNavn% | %$Enavn% 
								GuiControl, 1:, $Taxonomi, %$Order% | %$Family%  
								GuiControl, 1:, $Land, %$Country%  
								GuiControl, 1:, $Utbredelse, %$TaxDistr%  
							break , 2 ; Går ut av begge loopen og tilbake til ReNameFiles
							}
							else
							{							
							GuiControl, 1:, NewName, %$null%
								GuiControl, 1: focus , NewName
								Exit
							}
							}
						else
							{
								;Hvis alt stemmer går vi ut av denne subrutine og tilbake til der vi kom fra for aa rename og flyte fila
								;~ GuiControl, 1:, $EngelskNavn, %$Enavn%
								GuiControl, 1:, $NorskNavn, %$NNavn% | %$Enavn% 
								GuiControl, 1:, $Taxonomi, %$Order% | %$Family%  
								GuiControl, 1:, $Land, %$Country%  
								GuiControl, 1:, $Utbredelse, %$TaxDistr%  
								break , 2 ; Går ut av begge loopen og tilbake til ReNameFiles
							}
						
						
						
						
						
						
			
		
    }
	}
		if ($_LastLineNumber = A_Index)
		{
		;~ Etter å ha lest igjennom lista med nummer havner vi her på denne feilmeldingen hvis ikke nummeret blir funnet
		SoundSet, 100
		SoundPlay, %A_ScriptDir%\uhoh.wav ;
		MsgBox AccNo er ikke registrert i BirdCollPhoto. `nHvis du er sikker på at AccNo er korrekt,`nfjern avhuking for 'Validering av AccNo' og prøv på nytt.`n`nHvis ikke, kontakt Lars Erik!
		;GuiControl, 1:, NewName, %$null%
		GuiControl, 1: focus , NewName
		Send ^a
		Exit
		}
		
}

return


EmptyEdits:				;tøm skrivefeltene
						$null :=
						GuiControl, 1:, NewName, %$null% 
						GuiControl, 1:, OldName, %$null%
						GuiControl, 1:, $_Kommentar, %$null%
						GuiControl, 1:, $Utbredelse, %$null%
						GuiControl, 1:, $NorskNavn, %$null%
						GuiControl, 1:, $EngelskNavn, %$null%
						GuiControl, 1:, $Taxonomi, %$null%
						GuiControl, 1:, $Land, %$null%
						GuiControl, 1:, Suffix, 1
						;GuiControl, 1: disable, $RenameEnable
						;GuiControl, 1: disable, $ValidateEnable
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

;~ GetManualBildeNummer:
;~ Gui, 5: Add, Text, x50 y50 w180 h40 , Nytt bildenummer:
;~ Gui, 5: Add, Edit, r1 x240 y50 w100 h30 v$ManeueltBildeNummer, 
;~ Gui, 5: Add, Button, x352 y40 w100 h30 gNotEmptyEditsManual, Ok

;~ Gui, 5: Show, w479 h379, Manuelt bildenummer

;~ return
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



Export:
FormatTime, $_Time_now, ,yyyy_MM_dd_HH_mm_ss
FileCreateDir, %$_Export_dest%\Fotostasjon%$_Fotostasjon%_%$_Time_now%


FileMove ,%dest%\*.*, %$_Export_dest%\Fotostasjon%$_Fotostasjon%_%$_Time_now%\*.*, 0
ErrorCount := ErrorLevel


if ErrorCount <> 0
{
	Gui, 2: Destroy
	MsgBox , 262160, ,  ErrorLevel %ErrorCount% 'n All files/folders could not be moved
	
	
	Return
}
else
{
MsgBox , 262208, ,  All files/folders have been moved	
}


return


Again:

FileDelete , %umappe%\%OutNameNoExt%.jpg

MsgBox sletta  %umappe%\%OutNameNoExt%.jpg

GuiControl, 4:, $_ErrorPic, *w600 *h-1, $aa
Gui, 4: Show,,
Gui, 4: Hide
GuiControl, 1: focus , NewName
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

