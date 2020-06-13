@echo off
setlocal enabledelayedexpansion

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if not "%SL_BUILD_NATIVE%"=="true" (
    echo Skipping the native image build because SL_BUILD_NATIVE is set to false.
    goto end
)
set "_CPATH=%_LANGUAGE_DIR%\target\simplelanguage.jar;%_LAUNCHER_DIR%\target\sl-launcher.jar"

if exist "%_TARGET_DIR%\" rmdir /s /q "%_TARGET_DIR%"
mkdir "%_TARGET_DIR%"

@rem native-image tool generates files %_TARGET_DIR%\slnative.{exe,exp,lib,obj,pdb,tmp}
call "%_NATIVE_CMD%" %_NATIVE_OPTS% -cp "%_CPATH%" com.oracle.truffle.sl.launcher.SLMain "%_TARGET_DIR%\slnative"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

:env
set _BASENAME=%~n0
for %%f in ("%~dp0\.") do set "_ROOT_DIR=%%~dpf"

set "_LANGUAGE_DIR=%_ROOT_DIR%language"
set "_LAUNCHER_DIR=%_ROOT_DIR%launcher"

set "_TARGET_DIR=%_ROOT_DIR%native\target"

set "_NATIVE_CMD=%JAVA_HOME%\bin\native-image.cmd"
if not exist "%_NATIVE_CMD%" (
    echo Error: Command file 'native-image.cmd' not found 1>&2
    set _EXITCODE=1
    goto end
)
rem 2496K <= -XX:ReservedCodeCacheSize <= 2048M
set _NATIVE_OPTS=--macro:truffle --no-fallback --initialize-at-build-time -J-XX:ReservedCodeCacheSize=3000K
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
exit /b %_EXITCODE%
endlocal
