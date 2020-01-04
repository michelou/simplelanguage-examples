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

call :msvs_2010
rem call :msvs
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
set _BASH=0
set _JAVA_INSTALL=java8
set _SDK=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-bash" ( set _BASH=1
    ) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-java11" ( set _JAVA_INSTALL=java11
    ) else if /i "%__ARG%"=="-sdk" ( set _SDK=1
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
if %_DEBUG%==1 echo %_DEBUG_LABEL% _HELP=%_HELP% _BASH=%_BASH% _SDK=%_SDK% _VERBOSE=%_VERBOSE%
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -bash       start Git bash shell instead of Windows command prompt
echo     -debug      show commands executed by this script
echo     -java11     use Java 11 installation of GraalVM ^(instead of Java 8^)
echo     -sdk        setup Windows SDK environment ^(SetEnv.cmd^)
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
    for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%_JAVA_INSTALL%*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
    if not defined _GRAAL_HOME (
        set __PATH=C:\Progra~1
        for /f %%f in ('dir /ad /b "!__PATH!\graalvm-ce-%_JAVA_INSTALL%*" 2^>NUL') do set "_GRAAL_HOME=!__PATH!\%%f"
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
    for %%i in ("%__MVN_CMD%") do set "__MVN_BIN_DIR=%%~dpi"
    for %%f in ("!__MVN_BIN_DIR!..") do set "_MAVEN_HOME=%%f"
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
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Maven installation directory "%_MAVEN_HOME%" 1>&2

set "_MAVEN_PATH=;%_MAVEN_HOME%\bin"
goto :eof

rem output paramters: _MSVC_HOME, _MSVS_HOME
rem Visual Studio 10
:msvs_2010
set _MSVC_HOME=
set _MSVS_HOME=

for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio 10.0") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __VC_BATCH_FILE=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" vcvarsall.bat') do set "__VC_BATCH_FILE=%%f"
if not exist "%__VC_BATCH_FILE%" (
    echo %_ERROR_LABEL% Could not find file vcvarsall.bat in directory "%_MSVS_HOME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
set _MSVC_HOME=%_MSVS_HOME%\VC
rem set __MSBUILD_HOME=
rem set "__FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework"
rem for /f %%f in ('dir /ad /b "%__FRAMEWORK_DIR%\*" 2^>NUL') do set "__MSBUILD_HOME=%__FRAMEWORK_DIR%\%%f"
goto :eof

rem output parameters: _MSVC_HOME, _MSVC_HOME
rem Visual Studio 2017/2019
:msvs
set _MSVC_HOME=
set _MSVS_HOME=

set __MSVS_VERSION=2019
for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio\%__MSVS_VERSION%") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio %__MSVS_VERSION% 1>&2
    set _EXITCODE=1
    goto :eof
)
set __VC_BATCH_FILE=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" vcvarsall.bat') do set "__VC_BATCH_FILE=%%f"
if not exist "%__VC_BATCH_FILE%" (
    echo %_ERROR_LABEL% Could not find file vcvarsall.bat in directory "%_MSVS_HOME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
if "%__VC_BATCH_FILE:Community=%"=="%__VC_BATCH_FILE%" ( set "_MSVC_HOME=%_MSVS_HOME%\BuildTools\VC"
) else ( set "_MSVC_HOME=%_MSVS_HOME%\Community\VC"
)
rem call :subst_path "%_MSVS_HOME%"
rem if not %_EXITCODE%==0 goto :eof
rem set "_MSVS_HOME=%_SUBST_PATH%"
goto :eof

rem input parameter: %1=directory path
rem output parameter: _SUBST_PATH
:subst_path
for %%f in (%~1) do set "_SUBST_PATH=%%f"

set __DRIVE_NAME=X:
set __ASSIGNED_PATH=
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    if not "%%h"=="%_SUBST_PATH%" (
        echo %_WARNING_LABEL% Drive %__DRIVE_NAME% already assigned to %%h 1>&2
        goto :eof
    )
    set "__ASSIGNED_PATH=%%h"
)
if not defined __ASSIGNED_PATH (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% subst "%__DRIVE_NAME%" "%_SUBST_PATH%" 1>&2
    subst "%__DRIVE_NAME%" "%_SUBST_PATH%"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
set _SUBST_PATH=%__DRIVE_NAME%
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

rem output parameter(s): _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f %%f in ('where git.exe 2^>NUL') do set __GIT_CMD=%%f
if defined __GIT_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    for %%i in ("%__GIT_CMD%") do set __GIT_BIN_DIR=%%~dpsi
    for %%f in ("!__GIT_BIN_DIR!..") do set _GIT_HOME=%%~sf
    rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for %%f in ("!_GIT_HOME!\..") do set _GIT_HOME=%%~sf
    )
    rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set _GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%ProgramFiles%"
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^(%_GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_GIT_HOME%") do set _GIT_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory %_GIT_HOME% 1>&2

set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

:print_env
set __VERBOSE=%1
set __GIT_HOME=%~2
set "__VERSIONS_LINE1=  "
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
where /q "%__GIT_HOME%\bin":bash.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('"%__GIT_HOME%\bin\bash.exe" --version ^| findstr bash') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% bash %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% "%__GIT_HOME%\bin:bash.exe"
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE3%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    rem if %_DEBUG%==1 echo %_DEBUG_LABEL% where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p 1>&2
)
if %__VERBOSE%==1 if defined MSVS_HOME (
    echo Environment variables: 1>&2
    echo    MSVC_HOME="%MSVC_HOME%" 1>&2
    echo    MSVS_HOME="%MSVS_HOME%" 1>&2
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined GRAAL_HOME set "GRAAL_HOME=%_GRAAL_HOME%"
        rem http://www.graalvm.org/docs/graalvm-as-a-platform/implement-language/
        if not defined JAVA_HOME set "JAVA_HOME=%_GRAAL_HOME%"
        if not defined MAVEN_HOME set "MAVEN_HOME=%_MAVEN_HOME%"
        if not %_SDK%==1 (
            if not defined MSVS_HOME set "MSVS_HOME=%_MSVS_HOME%"
            if not defined MSVC_HOME set "MSVC_HOME=%_MSVC_HOME%"
            if not defined SDK_HOME set "SDK_HOME=%_SDK_HOME%"
        )
        set "PATH=%_GRAAL_PATH%%PATH%%_MAVEN_PATH%%_SDK_PATH%%_GIT_PATH%"
        call :print_env %_VERBOSE% "%_GIT_HOME%"
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
    rem must be called last
    if %_BASH%==1 (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_HOME%\bin\bash.exe --login 1>&2
        cmd.exe /c "%_GIT_HOME%\bin\bash.exe --login"
    ) else if %_SDK%==1 if not defined WindowsSDKDir (
        timeout /t 2 1>NUL
        cmd.exe /E:ON /V:ON /T:0E /K %_SDK_HOME%\bin\setEnv.cmd
    )
)
