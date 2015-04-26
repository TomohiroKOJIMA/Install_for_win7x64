rem Title: install_for_win7x64.bat
rem Date: 2015-04-15
rem Author: Tomohiro KOJIMA

rem 個々のコマンドは表示しない．
@echo off

if "%~1"=="update" (
rem updateオプションなら.emacs.dをGitの最新状態に更新する．
echo ********************************************************
echo Emacs update
echo ********************************************************
echo;

call :Emacs_Clone

exit /b 1

) else if "%~1"=="install" (
rem 環境変数の設定からすべて実行する．
echo ********************************************************
echo Full install
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
rem 上記以外のオプションだとヘルプを表示する．
echo Undefinded option
echo [install]...Full install
echo [uptate]...Update ".emacs.d" settings

exit /b 1
)


rem 環境変数HOME, App, ChocolateyInstall, ChocolateyBinRootを追加する．
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

exit /b


rem パッケージ管理ソフトChocolateyをインストールする．
:Choco
echo ***** Install Chocolatey *****

rem PowerShellを起動してChocolateyをインストールする．
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ChocolateyInstall%\bin
if errorlevel 1 goto CHOCO_FAILURE
tasklist | find "powershell.exe" > nul
if not errorlevel 1  (
	echo Kill "powershell.exe"
	taskkill /IM powershell.exe
) else (
 echo "powershell.exe" not exist
)

rem Chocolateyのコマンドへのパスを通す．
set PATH=%PATH%;%ChocolateyInstall%\bin
setx PATH "%PATH%;%ChocolateyInstall%\bin"

exit /b


rem 今後必要になりそうなパッケージを一斉インストールする．
:Package
echo ***** Install packages *****

rem ChocolateyGUIは何故かエラーする場合がある．
rem echo Install ChocolateyGUI
rem cinst chocolateygui -y
rem if errorlevel 1 goto FAILURE
rem AdobeReaderは再起動が必要なのでバッチ化に不向き．
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
echo Install StrawberryPerl
choco install strawberryperl -y
if errorlevel 1 goto FAILURE
rem GSviewは選択項目が多いのでバッチ化に不向き．
rem echo Install GSview
rem cinst gsview -y
rem if errorlevel 1 goto FAILURE

exit /b


rem ChocolateyでMinGWをインストールする．
:Mingw
echo ***** Install MinGW *****

rem Chocolatey経由でインストールする．
cinst mingw -y
if errorlevel 1 goto FAILURE
cinst mingw-get -y
if errorlevel 1 goto FAILURE
rem MinGWのコマンドへの環境変数の設定
set PATH=%PATH%;%ChocolateyBinRoot%\MinGW\bin
setx PATH "%PATH%;%ChocolateyBinRoot%\MinGW\bin"
rem ここはChocolateyのMinGWパッケージの不備でエラーする．
echo MinGW-get Error
echo Modify MinGW-get
rem 一度MinGW-getをアンインストールする．
cuninst mingw-get -y
rem 解凍されていないファイルを自前で展開する．
cd %HOME%\AppData\Local\Temp\chocolatey\mingw-get
7za e -y *.xz
7za x -y *.tar
xcopy /S /Y bin %ChocolateyBinRoot%\MinGW\bin\
xcopy /S /Y libexec %ChocolateyBinRoot%\MinGW\libexec\
xcopy /S /Y share %ChocolateyBinRoot%\MinGW\share\
xcopy /S /Y var %ChocolateyBinRoot%\MinGW\var\
if errorlevel 1 goto FAILURE
rem 再インストールする．
cinst mingw-get -y
if errorlevel 1 goto FAILURE
rem MinGWを最新の状態へ更新する．
mingw-get update
mingw-get upgrade
mingw-get list

exit /b


rem MinGWでgcc/g++コンパイラをインストールする．
:Gcc
echo ***** Install gcc & g++ *****

mingw-get install gcc g++
if errorlevel 1 goto FAILURE

exit /b


rem MinGWでUNIX環境を使えるようにmsysをインストールする．
:Msys
echo ***** Install MSYS-base *****

mingw-get install msys-base
if errorlevel 1 goto FAILURE
rem msysのコマンドへのパスを設定する．
set PATH=%PATH%;%ChocolateyBinRoot%\MinGW\msys\1.0\bin
setx PATH "%PATH%;%ChocolateyBinRoot%\MinGW\msys\1.0\bin"
rem wgetコマンドを使うためにmsys-wgetをインストールする．
mingw-get install msys-wget
if errorlevel 1 goto FAILURE

exit /b


rem Gitコマンドが使えるようにMsys-Gitをインストールする．
:Git
echo ***** Install MSYS-git *****

cinst msysgit -y
rem Gitコマンドへのパスを設定する．
set PATH=%PATH%;C:\Program Files (x86)\Git\bin
setx PATH "%PATH%;C:\Program Files (x86)\Git\bin"

if errorlevel 1 goto FAILURE

exit /b


:Unzip
echo ***** Install MSYS-unzip *****
rem MinGWでUnzipコマンドが使えるようにインストールする．

mingw-get install msys-unzip
if errorlevel 1 goto FAILURE

exit /b


rem Emacs用にフォントをインストールする．
:Font
echo ***** Install Fonts *****

rem フォントをネットからダウンロードする．
cd %HOME%\downloads
wget http://web1.nazca.co.jp/hp/nzkchicagob/m6x9801/rmk4br6/meiryo602.7z
wget http://web1.nazca.co.jp/hp/nzkchicagob/m6x9801/rmk4br6/meiryoKe_gen_6.02rev1.zip
if errorlevel 1 goto CHOCO_FAILURE
rem ファイルを展開して処理を実行する．
7za x -y meiryo602.7z
unzip -o meiryoKe_gen_6.02rev1.zip
meiryoKe_gen_6.02rev1.exe
rem フォントをWindowsにインストールする（手作業が必要）．
meiryoKeB_602r1.ttc
meiryoKe_602r1.ttc

exit /b


rem ChoocolateyでEmacsをインストールする．
:Emacs
echo ***** Install Emacs *****

rem ChocolateyでEmacsをインストールする．
cinst emacs -y
if errorlevel 1 goto FAILURE
rem IMEパッチ適用済のものをダウンロードする．
cd %HOME%\downloads
wget --no-check-certificate -o master.zip http://github.com/chuntaro/NTEmacs64/archive/master.zip
rem 解凍して置き換える．
unzip -o master.zip
cd NTEmacs64-master
unzip -o emacs-24.4-IME-patched.zip
cd emacs-24.4
cp -rf bin var libexec share %ChocolateyBinRoot%\Chocolatey\lib\Emacs*\tools

exit /b


rem Emacsの設定に必要なファイルをダウンロードする．
:Emacs_Setting
echo ***** Install Emacs setting *****

call :Emacs_Clone

rem Markdwon用のPerlファイルをダウンロードする．
wget http://daringfireball.net/projects/downloads/Markdown_1.0.1.zip
if errorlevel 1 goto CHOCO_FAILURE
unzip Markdown_1.0.1.zip
rem StrawberryPerlの設定フォルダに置く．
cd Markdown_1.0.1\Markdown.pl \strawberry\perl\site\bin\Markdown.pl

exit /b


rem Emacsの設定ファイルをGitのものに更新する．
:Emacs_Clone
echo ***** Install Emacs setting *****

rem Gitからクローンする場合はこちら．
cd %HOME%
rm -rf .emacs.d
git clone https://github.com/TomohiroKOJIMA/.emacs.d.git
if errorlevel 1 goto CHOCO_FAILURE
rem ZIPファイルでダウンロードする場合はこちら．
rem cd %HOME%\Downloads
rem C:\Users\Tomohiro\Downloads>wget --no-check-certificate https://github.com/TomohiroKOJIMA/.emacs.d/archive/master.zip
rem mv master master.zip
rem unzip master.zip
rem mv -f .\.emacs.d-master %HOME%\.emacs.d
rem rm -f master.zip
rem if errorlevel 1 goto CHOCO_FAILURE
echo "update emacs settings complete"

exit /b


rem TeXをインストールする．
:Tex
echo ***** Install TeX *****

rem TeXのファイルをダウンロードする．
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
rem インストールファイルを実行する．
texinst2015.exe %App%\tex\archives
rem TeXへのパスを設定する．
set PATH=%PATH%;%App%\TeX\bin;%App%\TeX\bin64
setx PATH "%PATH%;%App%\TeX\bin;%App%\TeX\bin64"
rem TeXの実行テスト
platex --version
if errorlevel 1 goto CHOCO_FAILURE

exit /b


rem TeXでEPS画像を処理するためにGhostScriptをインストールする．
:Gs
echo ***** Install GhostScript *****

rem GhostScriptのインストールファイルをダウンロードする．
cd %HOME%\downloads
wget -nc http://www.ring.gr.jp/archives/text/TeX/ptex-win32/gs/gs915w64full-gpl.exe
rem インストールファイルを実行する．
gs915w64full-gpl.exe /S /D=%App%\gs9.15
rem GhostScriptのコマンドへのパスを設定する．
set PATH=%PATH%;%App%\gs9.15\bin;%App%\gs9.15\lib
setx PATH "%PATH%;%App%\gs9.15\bin;%App%\gs9.15\lib"
rem 他アプリケーションからGhostScriptを利用するためのパスを設定する．
set GS_LIB=%App%\gs9.15\bin;%App%\gs9.15\lib;%App%\gs9.15\Resource\Font;%App%\gs9.15\Resource\Init;%App%\gs9.15\kanji
setx GS_LIB "%App%\gs9.15\bin;%App%\gs9.15\lib;%App%\gs9.15\Resource\Font;%App%\gs9.15\Resource\Init;%App%\gs9.15\kanji"

exit /b

rem dviファイルを開くためにDVIOUTをダウンロードする．
:Dviout
echo ***** Install Dviout *****

rem DVIOUT本体をダウンロードして解凍する．
mkdir %App%\dviout
cd %App%\dviout
wget -nc http://www.tex.ac.uk/tex-archive/dviware/dviout/dviout3184-inst.zip
unzip -o dviout3184-inst.zip
rem DVIOUTのコマンドへのパスを設定する．
set PATH=%PATH%;%App%\dviout
setx PATH "%PATH%;%App%\dviout"

exit /b


rem すべてが終わったら終了メッセージを表示する．
:End
echo ********************************************************
echo Everything is OK
echo Goto setting Dviout
echo ********************************************************
pause
exit


rem 途中でエラーがあった場合にはここにジャンプする．
:FAILURE

rem パワーシェルが起動している場合には終了させる．
tasklist | find "powershell.exe" > nul
if not errorlevel 1  (
	echo Kill "powershell.exe"
	taskkill /IM powershell.exe
)
rem エラーメッセージを表示してボタンを待機する．
echo ***** Error Stop *****
pause
exit
