@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)
if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_UPDATE%==1 (
    call :update
    if not !_EXITCODE!==0 goto end
)
if %_DIST%==1 (
    call :dist
    if not !_EXITCODE!==0 goto end
)
if %_PARSER%==1 (
    call :parser
    if not !_EXITCODE!==0 goto end
)
if %_TEST%==1 (
    call :test
    if not !_EXITCODE!==0 goto end
)
goto :end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
@rem                    _COMPONENT_DIR, _LANGUAGE_DIR, _LAUNCHER_DIR, _NATIVE_DIR
@rem                    _TARGET_DIR, _TARGET_BIN_DIR, _TARGET_LIB_DIR
@rem                    _MVN_CMD, _MVN_OPTS
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

set "_COMPONENT_DIR=%_ROOT_DIR%component"
set "_LANGUAGE_DIR=%_ROOT_DIR%language"
set "_LAUNCHER_DIR=%_ROOT_DIR%launcher"
set "_NATIVE_DIR=%_ROOT_DIR%native"

set "_LAUNCHER_SCRIPTS_DIR=%_LAUNCHER_DIR%\src\main\scripts"
set "_LAUNCHER_TARGET_DIR=%_LAUNCHER_DIR%\target"
set "_NATIVE_TARGET_DIR=%_NATIVE_DIR%\target"

set "_TARGET_DIR=%_ROOT_DIR%target"
set "_TARGET_BIN_DIR=%_TARGET_DIR%\sl\bin"
set "_TARGET_LIB_DIR=%_TARGET_DIR%\sl\lib"

for /f "delims=" %%f in ('where /r "%MSVS_HOME%" vcvarsall.bat') do set "_VCVARSALL_FILE=%%f"
if not exist "%_VCVARSALL_FILE%" (
    echo %_ERROR_LABEL% Internal error ^(vcvarsall.bat not found^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set _GIT_CMD=git.exe
set _GIT_OPTS=

if not exist "%MAVEN_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Maven 3 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MVN_CMD=%MAVEN_HOME%\bin\mvn.cmd"
set _MVN_OPTS=
goto :eof

:env_colors
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _RESET=[0m
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m

@rem normal foreground colors
set _NORMAL_FG_BLACK=[30m
set _NORMAL_FG_RED=[31m
set _NORMAL_FG_GREEN=[32m
set _NORMAL_FG_YELLOW=[33m
set _NORMAL_FG_BLUE=[34m
set _NORMAL_FG_MAGENTA=[35m
set _NORMAL_FG_CYAN=[36m
set _NORMAL_FG_WHITE=[37m

@rem normal background colors
set _NORMAL_BG_BLACK=[40m
set _NORMAL_BG_RED=[41m
set _NORMAL_BG_GREEN=[42m
set _NORMAL_BG_YELLOW=[43m
set _NORMAL_BG_BLUE=[44m
set _NORMAL_BG_MAGENTA=[45m
set _NORMAL_BG_CYAN=[46m
set _NORMAL_BG_WHITE=[47m

@rem strong foreground colors
set _STRONG_FG_BLACK=[90m
set _STRONG_FG_RED=[91m
set _STRONG_FG_GREEN=[92m
set _STRONG_FG_YELLOW=[93m
set _STRONG_FG_BLUE=[94m
set _STRONG_FG_MAGENTA=[95m
set _STRONG_FG_CYAN=[96m
set _STRONG_FG_WHITE=[97m

@rem strong background colors
set _STRONG_BG_BLACK=[100m
set _STRONG_BG_RED=[101m
set _STRONG_BG_GREEN=[102m
set _STRONG_BG_YELLOW=[103m
set _STRONG_BG_BLUE=[104m
goto :eof

@rem input parameter: %*
@rem output parameter(s): _CLEAN, _DIST, _PARSER, _DEBUG,  _NATIVE, _UPDATE, _VERBOSE
:args
set _CLEAN=0
set _DIST=0
set _PARSER=0
set _DEBUG=0
set _HELP=0
set _NATIVE=0
set _TEST=0
set _TIMER=0
set _UPDATE=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    @rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-native" ( set _NATIVE=1
    ) else if /i "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
   )
) else (
    @rem subcommand
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="dist" ( set _DIST=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="parser" ( set _PARSER=1
    ) else if /i "%__ARG%"=="test" ( set _DIST=1& set _TEST=1
    ) else if /i "%__ARG%"=="update" ( set _UPDATE=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _DIST=%_DIST% _PARSER=%_PARSER% _NATIVE=%_NATIVE% _TEST=%_TEST% _UPDATE=%_UPDATE% _VERBOSE=%_VERBOSE% 1>&2
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%%_UNDERSCORE%
    set __BEG_O=%_STRONG_FG_GREEN%
    set __BEG_N=%_NORMAL_FG_YELLOW%
    set __END=%_RESET%
) else (
    set __BEG_P=
    set __BEG_O=
    set __BEG_N=
    set __END=
)
echo Usage: %__BEG_O%%_BASENAME% { ^<option^> ^| ^<subcommand^> }%__END%
echo.
echo   %__BEG_P%Options:%__END%
echo     %__BEG_O%-debug%__END%      show commands executed by this script
echo     %__BEG_O%-native%__END%     generate native executable ^(%__BEG_O%native-image%__END%^)
echo     %__BEG_O%-timer%__END%      display total elapsed time
echo     %__BEG_O%-verbose%__END%    display progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%clean%__END%       delete generated files
echo     %__BEG_O%dist%__END%        generate binary distribution
echo     %__BEG_O%help%__END%        display this help message
echo     %__BEG_O%parser%__END%      generate ANTLR parser for SL
echo     %__BEG_O%test%__END%        test binary distribution
echo     %__BEG_O%update%__END%      fetch/merge local directories simplelanguage
goto :eof

:clean
for %%f in ("%_COMPONENT_DIR%\target" "%_LANGUAGE_DIR%\target" "%_LAUNCHER_TARGET_DIR%" "%_NATIVE_TARGET_DIR%" "%_TARGET_DIR%") do (
    call :rmdir "%%~f"
)
goto :eof

@rem input parameter: %1=directory path
:rmdir
set "__DIR=%~1"
if not exist "!__DIR!\" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "!__DIR!" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory !__DIR! 1>&2
)
rmdir /s /q "!__DIR!"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:update
if not exist "%_ROOT_DIR%\.travis.yml" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is %_ROOT_DIR% 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Current directory is %_ROOT_DIR% 1>&2
)
pushd "%_ROOT_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GIT_CMD%" %_GIT_OPTS% fetch upstream master 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update local directory %_ROOT_DIR% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% fetch upstream master
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GIT_CMD%" %_GIT_OPTS% merge upstream/master 1>&2
) else if %_VERBOSE%==1 ( echo %_VERBOSE_LABEL% Update local directory %_ROOT_DIR% 1>&2
)
call "%_GIT_CMD%" %_GIT_OPTS% merge upstream/master
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:dist
set "__TIMESTAMP_FILE=%_TARGET_DIR%\.latest-build"

call :compile_required "%__TIMESTAMP_FILE%" "%_LAUNCHER_TARGET_DIR%\launcher-*.jar"
if %_COMPILE_REQUIRED%==0 goto :eof

setlocal
call :dist_env

if %_DEBUG%==1 ( set __MVN_OPTS=%_MVN_OPTS%
) else if %_VERBOSE%==1 ( set __MVN_OPTS=%_MVN_OPTS%
) else ( set __MVN_OPTS=--quiet %_MVN_OPTS%
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MVN_CMD%" %__MVN_OPTS% package 1>&2
) else if %_VERBOSE%==1 ( echo %_MVN_CMD% package 1>&2
)
call "%_MVN_CMD%" %__MVN_OPTS% package
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution of maven package failed 1>&2
    set _EXITCODE=1
    goto dist_done
)
set __LANGUAGE_JAR_FILE=
for %%f in (%_LANGUAGE_DIR%\target\*language-*.jar) do set "__LANGUAGE_JAR_FILE=%%~f"
call :dist_copy "%__LANGUAGE_JAR_FILE%" "%_TARGET_LIB_DIR%\"
if not %_EXITCODE%==0 goto dist_done

set __LAUNCHER_JAR_FILE=
for %%f in (%_LAUNCHER_TARGET_DIR%\launcher-*.jar) do set "__LAUNCHER_JAR_FILE=%%~f"
call :dist_copy "%__LAUNCHER_JAR_FILE%" "%_TARGET_LIB_DIR%\"
if not %_EXITCODE%==0 goto dist_done

set __ANTLR4_JAR_FILE=
for /f "delims=" %%f in ('where /r "%USERPROFILE%\.m2\repository\org\antlr" *.jar') do set "__ANTLR4_JAR_FILE=%%~f"
call :dist_copy "%__ANTLR4_JAR_FILE%" "%_TARGET_LIB_DIR%\"
if not %_EXITCODE%==0 goto dist_done

call :dist_copy "%_LAUNCHER_SCRIPTS_DIR%\sl.bat" "%_TARGET_BIN_DIR%\"
if not %_EXITCODE%==0 goto dist_done

if %_NATIVE%==1 (
    call :dist_copy "%_NATIVE_TARGET_DIR%\slnative.exe" "%_TARGET_BIN_DIR%\"
    if not !_EXITCODE!==0 goto dist_done
)
:dist_done
endlocal

for /f %%i in ('powershell -C "Get-Date -uformat %%Y%%m%%d%%H%%M%%S"') do (
    echo %%i> "%__TIMESTAMP_FILE%"
)
goto :eof

:dist_env
set SL_BUILD_NATIVE=
if %_NATIVE%==0 goto :eof

set SL_BUILD_NATIVE=true

@rem check if MSVS 2010 installation is complete
if exist "%MSVC_HOME%\bin\amd64\vcvars64.bat" (
    call :dist_env_vcvarsall
) else (
    echo %_WARNING_LABEL% File bin\amd64\vcvars64.bat not found; use fallback solution 1>&2
    call :dist_env_fallback
)
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% ===== B U I L D   V A R I A B L E S ===== 1>&2
    echo %_DEBUG_LABEL% INCLUDE="%INCLUDE%" 1>&2
    echo %_DEBUG_LABEL% LIB="%LIB%" 1>&2
    echo %_DEBUG_LABEL% LIBPATH="%LIBPATH%" 1>&2
    echo %_DEBUG_LABEL% SL_BUILD_NATIVE=%SL_BUILD_NATIVE% 1>&2
    echo %_DEBUG_LABEL% ========================================= 1>&2
)
goto :eof

:dist_env_vcvarsall
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_VCVARSALL_FILE%" amd64 1>&2
) else if %_VERBOSE%==1 ( echo Set up environment for Microsoft Visual Studio tools 1>&2
)
call "%_VCVARSALL_FILE%" amd64
if not !ERRORLEVEL!==0 (
    echo %_ERROR_LABEL% Failed to set up environment for Microsoft Visual Studio tools 1>&2
    set _EXITCODE=1
    goto :eof
)
set "PATH=%PATH%;%MSVC_HOME%\bin\amd64"
goto :eof

@rem Fallback solution in case MSVS 2010 installation is incomplete, i.e.
@rem files bin\vcvars32.bat, bin\amd64\vcvars64.bat, etc. are missing.
:dist_env_fallback
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    set __MSVC_BIN=bin\amd64
    set __MSVC_LIB=Lib\amd64
    set __NET_FRAMEWORK=Framework64\v4.0.30319
    set __SDK_LIB=lib\x64
) else (
    set __MSVC_BIN=bin
    set __MSVC_LIB=Lib
    set __NET_FRAMEWORK=Framework\v4.0.30319
    set __SDK_LIB=lib
)
@rem Variables MSVC_HOME and SDK_HOME are defined by setenv.bat
set "INCLUDE=%MSVC_HOME%\INCLUDE;%SDK_HOME%\INCLUDE;%SDK_HOME%\INCLUDE\gl"
set "LIB=%MSVC_HOME%\%__MSVC_LIB%;%SDK_HOME%\%__SDK_LIB%"
set "LIBPATH=c:\WINDOWS\Microsoft.NET\%__NET_FRAMEWORK%;%MSVC_HOME%\%__MSVC_LIB%"
set "PATH=%PATH%;%MSVC_HOME%\%__MSVC_BIN%"
goto :eof

@rem input parameter: 1=timestamp file 2=path (wildcards accepted)
@rem output parameter: _COMPILE_REQUIRED
:compile_required
set __TIMESTAMP_FILE=%~1
set __PATH=%~2

set __SOURCE_TIMESTAMP=
for /f "usebackq" %%i in (`powershell -c "gci -recurse '%__PATH%' | sort LastWriteTime | select -last 1 -expandProperty LastWriteTime | Get-Date -uformat %%Y%%m%%d%%H%%M%%S" 2^>NUL`) do (
    set __SOURCE_TIMESTAMP=%%i
)
if not defined __SOURCE_TIMESTAMP (
   set _COMPILE_REQUIRED=1
   goto :eof
)
if exist "%__TIMESTAMP_FILE%" ( set /p __GENERATED_TIMESTAMP=<%__TIMESTAMP_FILE%
) else ( set __GENERATED_TIMESTAMP=00000000000000
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% %__GENERATED_TIMESTAMP% %__TIMESTAMP_FILE% 1>&2

call :newer %__SOURCE_TIMESTAMP% %__GENERATED_TIMESTAMP%
set _COMPILE_REQUIRED=%_NEWER%
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% _COMPILE_REQUIRED=%_COMPILE_REQUIRED% 1>&2
) else if %_VERBOSE%==1 if %_COMPILE_REQUIRED%==0 if %__SOURCE_TIMESTAMP% gtr 0 (
    echo No compilation needed ^("!__PATH:%_ROOT_DIR%=!"^) 1>&2
)
goto :eof

@rem output parameter: _NEWER
:newer
set __TIMESTAMP1=%~1
set __TIMESTAMP2=%~2

set __TIMESTAMP1_DATE=%__TIMESTAMP1:~0,8%
set __TIMESTAMP1_TIME=%__TIMESTAMP1:~-6%

set __TIMESTAMP2_DATE=%__TIMESTAMP2:~0,8%
set __TIMESTAMP2_TIME=%__TIMESTAMP2:~-6%

if %__TIMESTAMP1_DATE% gtr %__TIMESTAMP2_DATE% ( set _NEWER=1
) else if %__TIMESTAMP1_DATE% lss %__TIMESTAMP2_DATE% ( set _NEWER=0
) else if %__TIMESTAMP1_TIME% gtr %__TIMESTAMP2_TIME% ( set _NEWER=1
) else ( set _NEWER=0
)
goto :eof

:dist_copy
set __SOURCE_FILE=%~1
set __DEST_DIR=%~2
if not "%__DEST_DIR:~-1%"=="\" set __DEST_DIR=%__DEST_DIR%\

if exist "%__SOURCE_FILE%" (
    for %%f in (%__SOURCE_FILE%) do set __SOURCE_NAME=%%~nxf
    if not exist "%__DEST_DIR%\" mkdir "%__DEST_DIR%"
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% copy /y "%__SOURCE_FILE%" "%__DEST_DIR%" 1>&2
    ) else if %_VERBOSE%==1 ( echo Copy file !__SOURCE_NAME! to directory "!__DEST_DIR:%_ROOT_DIR%=!" 1>&2
    )
    copy /y "%__SOURCE_FILE%" "%__DEST_DIR%" 1>NUL
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
) else (
    echo %_ERROR_LABEL% Source file not found ^(%__SOURCE_FILE%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:parser
set "__BATCH_FILE=%_ROOT_DIR%generate_parser.bat"
if not exist "%__BATCH_FILE%" (
    echo %_ERROR_LABEL% Batch script 'generate_parser.bat' not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __BATCH_ARGS=
if %_DEBUG%==1 set __BATCH_ARGS=%__BATCH_ARGS% -debug
if %_VERBOSE%==1 set __BATCH_ARGS=%__BATCH_ARGS% -verbose

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %__BATCH_FILE% %__BATCH_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Generate ANTLR parser for SL 1>&2
)
call "%__BATCH_FILE%" %__BATCH_ARGS%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test
set "__SL_CMD=%_TARGET_BIN_DIR%\sl.bat"
if not exist "%__SL_CMD%" (
    echo %_ERROR_LABEL% Command sl.bat not found 1>&2
    set _EXITCODE=1
    goto :eof
)
for %%f in (Add Arithmetic Fibonacci) do (
    set "__SL_FILE=%_LANGUAGE_DIR%\tests\%%f.sl"
    if not exist "!__SL_FILE!" (
        echo %_ERROR_LABEL% SL source file "!__SL_FILE:%_ROOT_DIR%=!" not found 1>&2
        set _EXITCODE=1
        goto :eof
    )
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__SL_CMD%" "!__SL_FILE!" 1>&2
    ) else if %_VERBOSE%==1 ( echo Execute SL command with "!__SL_FILE:%_ROOT_DIR%=!" 1>&2
    )
    call "%__SL_CMD%" "!__SL_FILE!"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
goto :eof

@rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('powershell -c "$interval = New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total elapsed time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
