@echo off

if "%~1"=="update" (
echo ********************************************************
echo Windows7 Emacs update
echo ********************************************************
echo;

call :Emacs_Setting

exit /b 1

) else if "%~1"=="" (
echo ********************************************************
echo Windows7 Emacs full install
echo ********************************************************
echo;

call :Var
call :Choco
call :Package
call :Mingw
call :Gcc
call :Msys
call :Git
call :Unzip
call :Font
call :Emacs
call :Emacs_Setting
call :Tex
call :Gs
call :Dviout
call :End

) else (
echo Undefinded option
echo [none]...Full install
echo [uptate]...Update ".emacs.d" settings

exit /b 1
)


:Var
echo ***** Set the environment variables *****

echo Set "HOME"
set HOME=C:\Users\%username%
setx HOME "C:\Users\%username%"

echo Set "App"
set App=C:\Applications
setx App "C:\Applications"

echo Set "ChocolateyInstall"
set ChocolateyInstall=%App%\Chocolatey\Chocolatey
setx ChocolateyInstall "%App%\Chocolatey\Chocolatey"

echo Set "ChocolateyBinRoot"
set ChocolateyBinRoot=%App%\Chocolatey
setx ChocolateyBinRoot "%App%\Chocolatey"

echo Make directories
mkdir %ChocolateyInstall%

echo Complete!

exit /b


:Choco
echo ***** Install Chocolatey *****

@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ChocolateyInstall%\bin
if errorlevel 1 goto CHOCO_FAILURE

tasklist | find "powershell.exe" > nul
if not errorlevel 1  (
	echo Kill "powershell.exe"
	taskkill /IM powershell.exe
) else (
 echo "powershell.exe" not exist
)

set PATH=%PATH%;%ChocolateyInstall%\bin
setx PATH "%PATH%;%ChocolateyInstall%\bin"

exit /b


:Package
echo ***** Install packages *****

rem echo Install ChocolateyGUI
rem cinst chocolateygui -y
rem if errorlevel 1 goto FAILURE

rem echo Install AdobeReader
rem cinst adobereader -y
rem if errorlevel 1 goto FAILURE

echo Install Python
cinst python -y
if errorlevel 1 goto FAILURE

echo Install Ruby
cinst ruby -y
if errorlevel 1 goto FAILURE

echo Install 7zip
cinst 7zip -y
if errorlevel 1 goto FAILURE

echo Install Gnuplot
cinst gnuplot -y
if errorlevel 1 goto FAILURE

rem echo Install GSview
rem cinst gsview -y
rem if errorlevel 1 goto FAILURE

exit /b


:Mingw
echo ***** Install MinGW *****
cinst mingw -y
if errorlevel 1 goto FAILURE

cinst mingw-get -y

echo MinGW-get Error
echo Modify MinGW-get

set PATH=%PATH%;%ChocolateyBinRoot%\MinGW\bin
setx PATH "%PATH%;%ChocolateyBinRoot%\MinGW\bin"

cuninst mingw-get -y
cd %HOME%\AppData\Local\Temp\chocolatey\mingw-get
7za e -y *.xz
7za x -y *.tar

xcopy /S /Y bin %ChocolateyBinRoot%\MinGW\bin\
xcopy /S /Y libexec %ChocolateyBinRoot%\MinGW\libexec\
xcopy /S /Y share %ChocolateyBinRoot%\MinGW\share\
xcopy /S /Y var %ChocolateyBinRoot%\MinGW\var\
if errorlevel 1 goto FAILURE

cinst mingw-get -y
if errorlevel 1 goto FAILURE

mingw-get update
mingw-get upgrade
mingw-get list

exit /b


:Gcc
echo ***** Install gcc & g++ *****

mingw-get install gcc g++
if errorlevel 1 goto FAILURE

exit /b


:Msys
echo ***** Install MSYS-base *****

mingw-get install msys-base
if errorlevel 1 goto FAILURE

set PATH=%PATH%;%ChocolateyBinRoot%\MinGW\msys\1.0\bin
setx PATH "%PATH%;%ChocolateyBinRoot%\MinGW\msys\1.0\bin"

mingw-get install msys-wget
if errorlevel 1 goto FAILURE

exit /b


:Git
echo ***** Install MSYS-git *****

cinst msysgit -y

set PATH=%PATH%;C:\Program Files (x86)\Git\bin
setx PATH "%PATH%;C:\Program Files (x86)\Git\bin"

if errorlevel 1 goto FAILURE

exit /b


:Unzip
echo ***** Install MSYS-unzip *****

mingw-get install msys-unzip
if errorlevel 1 goto FAILURE

exit /b


:Font
echo ***** Install Fonts *****

cd %HOME%\downloads

wget http://web1.nazca.co.jp/hp/nzkchicagob/m6x9801/rmk4br6/meiryo602.7z
wget http://web1.nazca.co.jp/hp/nzkchicagob/m6x9801/rmk4br6/meiryoKe_gen_6.02rev1.zip
if errorlevel 1 goto CHOCO_FAILURE

7za x -y meiryo602.7z
unzip -o meiryoKe_gen_6.02rev1.zip

meiryoKe_gen_6.02rev1.exe

meiryoKeB_602r1.ttc
meiryoKe_602r1.ttc

exit /b


:Emacs
echo ***** Install Emacs *****

cinst emacs -y
if errorlevel 1 goto FAILURE

echo Installed Emacs

cd %HOME%\downloads

wget --no-check-certificate -o master.zip http://github.com/chuntaro/NTEmacs64/archive/master.zip
unzip -o master.zip

cd NTEmacs64-master

unzip -o emacs-24.4-IME-patched.zip

cd emacs-24.4
cp -rf bin var libexec share %ChocolateyBinRoot%\Chocolatey\lib\Emacs*\tools


:Emacs_Setting
echo ***** Install Emacs setting *****

rem Git version
cd %HOME%
rm -rf .emacs.d
git clone https://github.com/TomohiroKOJIMA/.emacs.d.git
if errorlevel 1 goto CHOCO_FAILURE

rem ZIP version
rem cd %HOME%\Downloads
rem C:\Users\Tomohiro\Downloads>wget --no-check-certificate https://github.com/TomohiroKOJIMA/.emacs.d/archive/master.zip
rem mv master master.zip
rem unzip master.zip
rem mv -f .\.emacs.d-master %HOME%\.emacs.d
rem rm -f master.zip
rem if errorlevel 1 goto CHOCO_FAILURE

echo "update emacs settings complete"

exit /b


:Tex
echo ***** Install TeX *****

mkdir %App%\tex
cd %App%\tex

wget ftp://core.ring.gr.jp/pub/text/TeX/ptex-win32/current/texinst2015.zip
unzip texinst2015.zip

mkdir archives
cd archives

wget ftp://core.ring.gr.jp/pub/text/TeX/ptex-win32/current/*.xz
wget ftp://core.ring.gr.jp/pub/text/TeX/ptex-win32/current/win64/*.xz
rm luatex-dev-w64.tar.xz

cd ..
texinst2015.exe %App%\tex\archives

set PATH=%PATH%;%App%\TeX\bin;%App%\TeX\bin64
setx PATH "%PATH%;%App%\TeX\bin;%App%\TeX\bin64"

platex --version

exit /b


:Gs
echo ***** Install GhostScript *****

cd %HOME%\downloads
wget -nc http://www.ring.gr.jp/archives/text/TeX/ptex-win32/gs/gs915w64full-gpl.exe

gs915w64full-gpl.exe /S /D=%App%\gs9.15

set PATH=%PATH%;%App%\gs9.15\bin;%App%\gs9.15\lib
setx PATH "%PATH%;%App%\gs9.15\bin;%App%\gs9.15\lib"

set GS_LIB=%App%\gs9.15\bin;%App%\gs9.15\lib;%App%\gs9.15\Resource\Font;%App%\gs9.15\Resource\Init;%App%\gs9.15\kanji
setx GS_LIB "%App%\gs9.15\bin;%App%\gs9.15\lib;%App%\gs9.15\Resource\Font;%App%\gs9.15\Resource\Init;%App%\gs9.15\kanji"

exit /b


:Dviout
echo ***** Install Dviout *****

mkdir %App%\dviout
cd %App%\dviout

wget -nc http://www.tex.ac.uk/tex-archive/dviware/dviout/dviout3184-inst.zip

unzip -o dviout3184-inst.zip

set PATH=%PATH%;%App%\dviout
setx PATH "%PATH%;%App%\dviout"


:End
echo ********************************************************
echo Everything is OK
echo Goto setting Dviout
echo ********************************************************
pause
exit


:FAILURE
rem ********************************************************
tasklist | find "powershell.exe" > nul
if not errorlevel 1  (
	echo Kill "powershell.exe"
	taskkill /IM powershell.exe
)

echo ***** Error Stop *****
pause
exit
