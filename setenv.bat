@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

set _GRAAL_PATH=
set _MAVEN_PATH=
set _GIT_PATH=
set _MSVC_PATH=
set _SDK_PATH=

call :graal
if not %_EXITCODE%==0 goto end

call :maven
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

call :msvc
rem call :msvc_2019
if not %_EXITCODE%==0 goto end

call :sdk
if not %_EXITCODE%==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem output parameter(s): _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:
goto :eof

rem input parameter: %*
:args
set _HELP=0
set _USE_SDK=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-usesdk" ( set _USE_SDK=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N+=1
    if /i "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _HELP=%_HELP% _USE_SDK=%_USE_SDK% _VERBOSE=%_VERBOSE%
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -debug      show commands executed by this script
echo     -usesdk     setup Windows SDK environment ^(SetEnv.cmd^)
echo     -verbose    display environment settings
echo.
echo   Subcommands:
echo     help        display this help message
goto :eof

rem output parameter(s): _GRAAL_HOME, _GRAAL_PATH
:graal
set _GRAAL_HOME=
set _GRAAL_PATH=

set __JAVAC_EXE=
for /f %%f in ('where javac.exe 2^>NUL') do set "__JAVAC_EXE=%%f"
if defined __JAVAC_EXE (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of javac executable found in PATH 1>&2
    for %%i in ("%__JAVAC_CMD%") do set __GRAAL_BIN_DIR=%%~dpsi
    for %%f in ("!__GRAAL_BIN_DIR!..") do set _GRAAL_HOME=%%~sf
    rem keep _GRAAL_PATH undefined since executable already in path
    goto :eof
) else if defined GRAAL_HOME (
    set _GRAAL_HOME=%GRAAL_HOME%
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GRAAL_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    if not defined _GRAAL_HOME (
        set __PATH=C:\Progra~1
        for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    )
)
if not exist "%_GRAAL_HOME%\bin\javac.exe" (
    echo %_ERROR_LABEL% javac executable not found ^(%_GRAAL_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem Here we use trailing separator because it will be prepended to PATH
set "_GRAAL_PATH=%_GRAAL_HOME%\bin;"
goto :eof

rem output parameter(s): _MAVEN_HOME, _MAVEN_PATH
:maven
set _MAVEN_HOME=
set _MAVEN_PATH=

set __MVN_CMD=
for /f %%f in ('where mvn.cmd 2^>NUL') do set "__MVN_CMD=%%f"
if defined __MVN_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Maven executable found in PATH 1>&2
    for %%i in ("%__MVN_CMD%") do set __MVN_BIN_DIR=%%~dpsi
    for %%f in ("!__MVN_BIN_DIR!..") do set _MAVEN_HOME=%%~sf
    rem keep _MAVEN_PATH undefined since executable already in path
    goto :eof
) else if defined MAVEN_HOME (
    set _MAVEN_HOME=%MAVEN_HOME%
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable MAVEN_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f %%f in ('dir /ad /b "!__PATH!\apache-maven-*" 2^>NUL') do set "_MAVEN_HOME=!__PATH!\%%f"
    if not defined _MAVEN_HOME (
        set __PATH=C:\Progra~1
        for /f %%f in ('dir /ad /b "!__PATH!\apache-maven-*" 2^>NUL') do set "_MAVEN_HOME=!__PATH!\%%f"
    )
)
if not exist "%_MAVEN_HOME%\bin\mvn.cmd" (
    echo %_ERROR_LABEL% Maven executable not found ^(%_MAVEN_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_MAVEN_HOME%") do set _MAVEN_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Maven installation directory %_MAVEN_HOME% 1>&2

set "_MAVEN_PATH=;%_MAVEN_HOME%\bin"
goto :eof

rem output parameter(s): _GIT_PATH
:git
set _GIT_PATH=

set __GIT_HOME=
set __GIT_EXE=
for /f %%f in ('where git.exe 2^>NUL') do set "__GIT_EXE=%%f"
if defined __GIT_EXE (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "__GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set __GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "__GIT_HOME=!__PATH!\%%f"
        if not defined __GIT_HOME (
            set __PATH=C:\Progra~1
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "__GIT_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%__GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^(%__GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%__GIT_HOME%") do set __GIT_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory %__GIT_HOME% 1>&2

set "_GIT_PATH=;%__GIT_HOME%\bin;%__GIT_HOME%\usr\bin;%__GIT_HOME%\mingw64\bin"
goto :eof

rem native-image dependency
:msvc
set "_MSVS_HOME=C:\Program Files (x86)\Microsoft Visual Studio 10.0"
if not exist "%_MSVS_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of MSVS installation path
for %%f in ("%_MSVS_HOME%") do set _MSVS_HOME=%%~sf

set _MSVC_HOME=%_MSVS_HOME%\VC
set __MSVC_ARCH=
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set __MSVC_ARCH=\amd64
set "_MSVC_PATH=;%_MSVC_HOME%\bin%__MSVC_ARCH%"
goto :eof

rem native-image dependency
:msvc_2019
set "_VSWHERE_CMD=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%_VSWHERE_CMD%" (
    echo %_ERROR_LABEL% Could not find any Microsoft Visual Studio installation 1>&2
    set _EXITCODE=1
    goto :eof
)
rem 15.x --> 2017, 16.x --> 2019
for /f %%f in ('"%_VSWHERE_CMD%" -property installationPath -version [16.0^,17.0^)') do set _MSVS_HOME=%%~f
if not exist "%_MSVS_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 2019 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of MSVS installation path
for %%f in ("%_MSVS_HOME%") do set _MSVS_HOME=%%~sf

set __MSVC_BIN_DIR=
set __MSVC_ARCH=x86\x86
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set __MSVC_ARCH=x64\x64
for /f %%f in ('where /r "%_MSVS_HOME%" cl.exe ^| findstr "%__MSVC_ARCH%"') do (
    for %%i in (%%f) do set __MSVC_BIN_DIR=%%dpi
)
if not exist "%__MSVC_BIN_DIR%" (
    echo %_ERROR_LABEL% Could not find Microsoft C/C++ compiler for architecture %__MSVC_ARCH% 1>&2
    set _EXITCODE=1
    goto :eof
)
for %%f in ("%__MSVC_BIN_DIR%\..\..\..") do set _MSVC_HOME=%%f
set "_MSVC_PATH=;%__MSVC_BIN_DIR%"
goto :eof

rem native-image dependency
:sdk
set "_SDK_HOME=C:\Program Files\Microsoft SDKs\Windows\v7.1"
if not exist "%_SDK_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Windows SDK 7.1 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of WinSDK installation path
for %%f in ("%_SDK_HOME%") do set _SDK_HOME=%%~sf
set __SDK_ARCH=
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set __SDK_ARCH=\x64
set "_SDK_PATH=;%_SDK_HOME%\bin%__SDK_ARCH%"
goto :eof

:print_env
set __VERBOSE=%1
set "__VERSIONS_LINE1=  "
set "__VERSIONS_LINE2=  "
set "__VERSIONS_LINE3=  "
set __WHERE_ARGS=
where /q javac.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('javac.exe -version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% javac %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% javac.exe
)
where /q mvn.cmd
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('mvn.cmd -version ^| findstr Apache') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% mvn %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% mvn.cmd
)
rem Microsoft Visual Studio 10
where /q cl.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-6,*" %%i in ('cl.exe 2^>^&1 ^| findstr Version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% cl %%o"
    set __WHERE_ARGS=%__WHERE_ARGS% cl.exe
)
rem Microsoft Visual Studio 10
where /q dumpbin.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-5,*" %%i in ('dumpbin.exe 2^>^&1 ^| findstr Version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% dumpbin %%n,"
    set __WHERE_ARGS=%__WHERE_ARGS% dumpbin.exe
)
where /q link.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-5,*" %%i in ('link.exe ^| findstr Version 2^>^NUL') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% link %%n"
    set __WHERE_ARGS=%__WHERE_ARGS% link.exe
)
rem Microsoft Windows SDK v7.1
where /q uuidgen.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%f in ('uuidgen.exe /v') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% uuidgen %%i,"
    set __WHERE_ARGS=%__WHERE_ARGS% uuidgen.exe
)
where /q git.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1,2,*" %%i in ('git.exe --version') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% git %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% git.exe
)
where /q diff.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-3,*" %%i in ('diff.exe --version ^| findstr /B diff') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% diff %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% diff.exe
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE2%
echo %__VERSIONS_LINE3%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    rem if %_DEBUG%==1 echo %_DEBUG_LABEL% where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p 1>&2
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if not defined GRAAL_HOME set GRAAL_HOME=%_GRAAL_HOME%
    rem http://www.graalvm.org/docs/graalvm-as-a-platform/implement-language/
    if not defined JAVA_HOME set JAVA_HOME=%_GRAAL_HOME%
    if not defined MAVEN_HOME set MAVEN_HOME=%_MAVEN_HOME%
    if not %_USE_SDK%==1 (
        if not defined MSVS_HOME set MSVS_HOME=%_MSVS_HOME%
        if not defined MSVC_HOME set MSVC_HOME=%_MSVC_HOME%
        if not defined SDK_HOME set SDK_HOME=%_SDK_HOME%
    )
    set "PATH=%_GRAAL_PATH%%PATH%%_MAVEN_PATH%%_MSVC_PATH%%_SDK_PATH%%_GIT_PATH%"
    if %_EXITCODE%==0 call :print_env %_VERBOSE%
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
    rem must be called last
    if %_USE_SDK%==1 if not defined WindowsSDKDir (
        timeout /t 2 1>NUL
        cmd.exe /E:ON /V:ON /T:0E /K %_SDK_HOME%\bin\setEnv.cmd
    )
)
