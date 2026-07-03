@echo off
REM ============================================================================
REM  Piomar Pomoc - instalacja / aktualizacja koncowki (Windows)
REM ----------------------------------------------------------------------------
REM  Uzycie:
REM    1. Skopiuj nowy plik .exe pobrany z GitHub Actions (np.
REM       rustdesk-1.4.8-x86_64.exe) do TEGO SAMEGO folderu co ten skrypt.
REM    2. Kliknij skrypt prawym przyciskiem -> "Uruchom jako administrator".
REM
REM  Cicha instalacja nadpisuje starsza wersje i ZACHOWUJE konfiguracje oraz ID
REM  komputera (ten sam folder konfiguracyjny). Domyslne haslo jest juz wbudowane
REM  w plik .exe, wiec nowe komputery od razu maja ustawione haslo stale.
REM ============================================================================

setlocal enabledelayedexpansion

REM --- sprawdzenie uprawnien administratora ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [BLAD] Uruchom skrypt jako administrator.
    pause
    exit /b 1
)

REM --- automatyczne wykrycie pliku .exe obok skryptu (pomijamy sam skrypt) ---
set "EXE="
for %%F in ("%~dp0*.exe") do (
    if /I not "%%~nxF"=="%~nx0" set "EXE=%%~fF"
)

if not defined EXE (
    echo [BLAD] Nie znaleziono zadnego pliku .exe obok skryptu.
    echo        Skopiuj tutaj nowa wersje pobrana z GitHub Actions.
    pause
    exit /b 1
)

echo Znaleziono: !EXE!
echo Instaluje / aktualizuje Piomar Pomoc...
"!EXE!" --silent-install
if %errorlevel% neq 0 (
    echo [BLAD] Instalacja nie powiodla sie.
    pause
    exit /b 1
)

echo.
echo Gotowe. Komputer zachowal swoje ID i konfiguracje.
echo.
echo UWAGA: Jesli to STARY komputer, ktory mial juz recznie ustawione wlasne
echo haslo stale, wbudowane haslo domyslne go NIE nadpisze (lokalne ma pierwszenstwo).
echo Aby wymusic haslo domyslne na takim komputerze, odkomentuj ponizsza linie
echo i wpisz haslo (to samo, co w sekrecie DEFAULT_PERMANENT_PASSWORD):
echo.
REM "!EXE!" --password "TUTAJ_HASLO"
echo.
pause
endlocal
