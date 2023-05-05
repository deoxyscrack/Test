@echo off
title Meine Spiele Datenbank
setlocal EnableDelayedExpansion

:password
echo Bitte Passwort eingeben:
set "password="
for /f "delims=" %%i in ('powershell.exe -Command "$p=read-host -assecurestring ; write-host ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p)))"') do set "password=%%i"

if "%password%"=="Fernsehr123" goto menu
goto exit

:menu
color 0a
cls
echo Bitte wählen Sie eine Option aus:
echo 1. Zeige alle Daten an
echo 2. Exportiere Daten in eine Textdatei
echo 3. Datensätze manuell aktualisieren
echo 4. Datensätze aus Excel-Datei aktualisieren
echo 5. Dubletten entfernen
echo 6. Beenden

set /p option=Option auswählen:

if "%option%"=="1" goto show_data
if "%option%"=="2" goto export_data
if "%option%"=="3" goto manual_update
if "%option%"=="4" goto excel_update
if "%option%"=="5" goto remove_duplicates
if "%option%"=="6" goto exit


:show_data
color 0d

echo Spiele-Datenbank:
echo Spiel^|Typ^|Serial^|HEN or Emu^|Besitz^|Informationen
echo ------------------------------------------------
type "database.txt"

pause
goto menu

:export_data
setlocal EnableDelayedExpansion
set /p filename=Dateiname eingeben: 
echo Exportiere Daten nach %filename%.txt ...
echo Spiel^|Typ^|Serial^|HEN or Emu^|Besitz^|Informationen>"%filename%.txt"
type database.txt >> "%filename%.txt"
echo Daten erfolgreich exportiert!
powershell.exe -Command "[System.Console]::Beep(500,500)"
echo ^G

pause
goto menu

:manual_update
color 0d
setlocal EnableDelayedExpansion
set "database=database.txt"

if not exist "%database%" (
    echo Die Datenbank existiert nicht. Bitte legen Sie zuerst eine Datenbank an.
    pause
    goto menu
)

set /p model=Bitte Spiel eingeben: 

set "tempfile=%temp%\temp.txt"
set "line_found="
(for /f "usebackq tokens=* delims=" %%a in ("%database%") do (
    set "line=%%a"
    if "!line:~0,%%=!"=="%model%," (
        set "line_found=1"
        set /p "typ=Typ [!line:~%%=+1,4!]: "
        set /p "serial=Serial [!line:~%%=+6,9!]: "
        set /p "hen_emu=HEN or Emu [!line:~%%=+16,2!]: "
        set /p "besitz=Besitz [!line:~%%=+19,4!]: "
        set /p "informationen=Informationen [!line:~%%=+24!]: "
        set "newline=!model!^|!typ!^|!serial!^|!hen_emu!^|!besitz!^|!informationen!"
        echo !newline!>>"%tempfile%"
        echo Datensatz aktualisiert.
    ) else (
        echo %%a>>"%tempfile%"
    )
)) >nul

if not defined line_found (
    set /p "typ=Typ: "
    set /p "serial=Serial: "
    set /p "hen_emu=HEN or Emu: "
    set /p "besitz=Besitz: "
    set /p "informationen=Informationen: "
    echo %model%^|!typ!^|!serial!^|!hen_emu!^|!besitz!^|!informationen!>>"%tempfile%"
    echo Datensatz hinzugefügt.
)

move /y "%tempfile%" "%database%" >nul

goto menu

:excel_update
color 0d
set /p filename=Bitte Dateinamen der Excel-Datei (ohne .xlsx) eingeben: 

if exist "%filename%.xlsx" (
    echo Daten werden aus Excel-Datei importiert...
    setlocal EnableDelayedExpansion
    set "firstline=true"
    for /f "tokens=1-5 delims=," %%a in ('type "%filename%.xlsx"') do (
        if "!firstline!"=="true" (
            set "firstline=false"
        ) else (
            echo %%a^|^|%%b^|^|%%c^|^|%%d^|^|%%e
            echo %%a^|^|%%b^|^|%%c^|^|%%d^|^|%%e>>database.txt
        )
    )
    endlocal
    echo Datensätze erfolgreich importiert.
    pause
) else (
    echo Die Datei "%filename%.xlsx" existiert nicht im aktuellen Verzeichnis.
    pause
)
goto menu

:remove_duplicates
color 0d
setlocal EnableDelayedExpansion
set "database=database.txt"

if not exist "%database%" (
    echo Die Datenbank existiert nicht. Bitte legen Sie zuerst eine Datenbank an.
    pause
    goto menu
)

echo Entferne Duplikate in der Datenbank...

sort /unique "%database%" >"%temp%\temp.txt"
move /y "%temp%\temp.txt" "%database%" >nul

echo Duplikate erfolgreich entfernt.
pause
goto menu