@echo off
setlocal enabledelayedexpansion

TITLE PocketMine-MP server software for Minecraft: Bedrock Edition
cd /d %~dp0

REM Define the list
set "PLUGIN_PATH[0]=Claims"
set "PLUGIN_PATH[1]=PokeSidebar"
set "PLUGIN_PATH[2]=PokemonUI"

set PHP_BINARY=

where /q php.exe
if %ERRORLEVEL%==0 (
	set PHP_BINARY=php
)

if exist bin\php\php.exe (
	rem always use the local PHP binary if it exists
	set PHPRC=""
	set PHP_BINARY=bin\php\php.exe
)

if "%PHP_BINARY%"=="" (
	echo Couldn't find a PHP binary in system PATH or "%~dp0bin\php"
	echo Please refer to the installation instructions at https://doc.pmmp.io/en/rtfd/installation.html
	pause
	exit 1
)

if exist PocketMine-MP.phar (
	set POCKETMINE_FILE=PocketMine-MP.phar
) else (
	echo PocketMine-MP.phar not found
	echo Downloads can be found at https://github.com/pmmp/PocketMine-MP/releases
	pause
	exit 1
)

REM Iterate through the list
for /L %%i in (0, 1, 2) do (
	echo Item %%i: !PLUGIN_PATH[%%i]!
	%PHP_BINARY% -dphar.readonly=0 pharynx.phar -c -i plugin_source/!PLUGIN_PATH[%%i]! -p=plugins\!PLUGIN_PATH[%%i]!.phar
)

%PHP_BINARY% -dphar.readonly=0 bootstrap-plugin-dev.php plugins\pharynx-output.phar

if exist bin\mintty.exe (
	start "" bin\mintty.exe -o Columns=88 -o Rows=32 -o AllowBlinking=0 -o FontQuality=3 -o Font="Consolas" -o FontHeight=10 -o CursorType=0 -o CursorBlinks=1 -h error -t "PocketMine-MP" -i bin/pocketmine.ico -w max %PHP_BINARY% %POCKETMINE_FILE% --enable-ansi %*
) else (
	REM pause on exitcode != 0 so the user can see what went wrong
	%PHP_BINARY% %POCKETMINE_FILE% %* || pause
)
