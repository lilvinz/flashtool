
@echo off

REM read in version information
set /p VERSION=<version.txt

call include_windows.cmd

tools\win32\wget.exe -q --spider %VERSION_CHECK_URL%

if not %ERRORLEVEL% == 0 (
    echo ******************************************************************************
    echo ******************************************************************************
    echo ******************************************************************************
    echo ******************************************************************************
    echo WARNING, THIS IS NOT THE LATEST VERSION!!!!
    echo Get the latest version at
    echo %VERSION_UPDATE_URL%
    echo ******************************************************************************
    echo ******************************************************************************
    echo ******************************************************************************
    echo ******************************************************************************

)

openocd_win32\bin\openocd.exe -s openocd_win32 %OPENOCD_COMMANDLINE%

echo ****************************
echo * F I N I S H E D !        *
echo ****************************


pause
