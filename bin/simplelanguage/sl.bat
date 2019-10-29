@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

set _VERSION=19.2.0

set _MAIN_CLASS=com.oracle.truffle.sl.launcher.SLMain
rem set SCRIPT_HOME="$(cd "$(dirname "$0")" && pwd -P)"
for %%f in ("%~dp0") do set _SCRIPT_HOME=%%~sf

call :init
if not %_EXITCODE%==0 goto end

rem ##########################################################################
rem # Locations of the language and launcher jars as well as the java command are
rem # different if I'm running from the repository or as a component in GraalVM
rem ##########################################################################
call :graalvm_version "%_SCRIPT_HOME%\..\release"
if defined _GRAALVM_VERSION (
    set _LANGUAGE_PATH=
    set _LAUNCHER_PATH=%_SCRIPT_HOME%..\jre\languages\sl\launcher\sl-launcher.jar
    set _JAVACMD=%_JAVA_HOME%\bin\java.exe
    if not "%_GRAALVM_VERSION%"=="%_VERSION%" (
        echo Installed in wrong version of GraalVM. Expected: %_VERSION%, found %_GRAALVM_VERSION%
        set _EXITCODE=1
        goto end
    )
) else (
    set _LANGUAGE_PATH=%_SCRIPT_HOME%language\target\simplelanguage-%_VERSION%-SNAPSHOT.jar
    set _LAUNCHER_PATH=%_SCRIPT_HOME%launcher\target\launcher-%_VERSION%-SNAPSHOT.jar
    rem # Check the GraalVM version in JAVA_HOME
    if defined JAVA_HOME (
        call :graalvm_version "%JAVA_HOME%\release"
        if defined _GRAALVM_VERSION (
            if not "!_GRAALVM_VERSION!"=="%_VERSION%" (
                echo Wrong version of GraalVM in %JAVA_HOME%. Expected: %_VERSION%, found !_GRAALVM_VERSION!
                set _EXITCODE=1
                goto end
            )
        )
        if defined JAVACMD ( set _JAVACMD=%JAVACMD%
        ) else ( set _JAVACMD=%JAVA_HOME%\bin\java.exe
        )
        if not exist "!_LANGUAGE_PATH!" (
            echo Could not find language on !_LANGUAGE_PATH!. Did you run mvn package? 1>&2
            set _EXITCODE=1
            goto end
        )
        if not exist "!_LAUNCHER_PATH!" (
            echo Could not find launcher on !_LAUNCHER_PATH!. Did you run mvn package? 1>&2
            set _EXITCODE=1
            goto end
        )
    ) else (
        echo JAVA_HOME is not set 1>&2
        set _EXITCODE=1
        goto end
    )
)

rem ##########################################################################
rem # Parse arguments, prepare Java command and execute
rem ##########################################################################
if defined _GRAALVM_VERSION (
    set _PROGRAM_ARGS=
    set _JAVA_ARGS=

    for %%i in (%*) do (
        set "_ARG=%%~i"
        if "!_ARG!"=="-debug" (
            set _JAVA_ARGS=!_JAVA_ARGS! -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=y
        ) else if "!_ARG!"=="-dump" (
            set _JAVA_ARGS=!_JAVA_ARGS! -Dgraal.Dump=Truffle:1 -Dgraal.TruffleBackgroundCompilation=false -Dgraal.TraceTruffleCompilation=true -Dgraal.TraceTruffleCompilationDetails=true
        ) else if "!_ARG!"=="-disassemble" (
            set _JAVA_ARGS=!_JAVA_ARGS! -XX:CompileCommand=print,*OptimizedCallTarget.callRoot -XX:CompileCommand=exclude,*OptimizedCallTarget.callRoot -Dgraal.TruffleBackgroundCompilation=false -Dgraal.TraceTruffleCompilation=true -Dgraal.TraceTruffleCompilationDetails=true
        ) else if "!_ARG:~0,2!"=="-J" (
            set _JAVA_ARGS=!_JAVA_ARGS! !_ARG:~2!
        ) else (
            set _PROGRAM_ARGS=!_PROGRAM_ARGS! !_ARG!
        )
    )
    set _CPATH=%_LANGUAGE_PATH%;%_ANTLR_PATH%

    if %_DEBUG%==1 echo [%_BASENAME%] %_JAVACMD% !_JAVA_ARGS! -Dtruffle.class.path.append=!_CPATH! -cp %_LAUNCHER_PATH% %_MAIN_CLASS% !_PROGRAM_ARGS!
    call %_JAVACMD% !_JAVA_ARGS! -Dtruffle.class.path.append=!_CPATH! -cp %_LAUNCHER_PATH% %_MAIN_CLASS% !_PROGRAM_ARGS!
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto end
    )
) else (
    echo Warning: Could not find GraalVM on %_JAVA_HOME%. Running on JDK without support for compilation.
    echo.
    set _PROGRAM_ARGS=
    set _JAVA_ARGS=

    for %%i in (%*) do (
        set "_ARG=%%~i"
        if "!_ARG!"=="-debug" (
            set _JAVA_ARGS=!_JAVA_ARGS! -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=y
        ) else if "!_ARG!"=="-dump" (
            echo NOTE: Ignoring -dump, only supported on GraalVM.
        ) else if "!_ARG!"=="-disassemble" (
            echo NOTE: Ignoring -disassemble
        ) else if "!_ARG:~0,2!"=="-J" (
            set _JAVA_ARGS=!_JAVA_ARGS! !_ARG:~2!
        ) else (
            set _PROGRAM_ARGS=!_PROGRAM_ARGS! !_ARG!
        )
    )
    set _GRAAL_SDK_PATH=%_MAVEN_LOCAL_DIR%\repository\org\graalvm\graal-sdk\%_VERSION%\graal-sdk-%_VERSION%.jar
    set _TRUFFLE_API_PATH=%_MAVEN_LOCAL_DIR%\repository\com\oracle\truffle\truffle-api\%_VERSION%\truffle-api-%_VERSION%.jar
    set _CPATH=!_GRAAL_SDK_PATH!;!_LAUNCHER_PATH!;!_LANGUAGE_PATH!;!_TRUFFLE_API_PATH!;%_ANTLR_PATH%

    if %_DEBUG%==1 echo [%_BASENAME%] %_JAVACMD% !_JAVA_ARGS! -cp !_CPATH! %_MAIN_CLASS% !_PROGRAM_ARGS!
    call %_JAVACMD% !_JAVA_ARGS! -cp !_CPATH! %_MAIN_CLASS% !_PROGRAM_ARGS!
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto end
    )
)

goto end

rem ##########################################################################
rem ## Subroutines

rem output parameter(s): _JAVA_HOME, _MAVEN_LOCAL_DIR, _ANTLR_PATH
:init
rem search two directories (variable __PATH) for a Graal CE installation 
set __PATH=c:\opt
for /f %%f in ('dir /b "%__PATH%\graalvm-ce*" 2^>NUL') do set _JAVA_HOME=%__PATH%\%%f
if not exist "%_JAVA_HOME%" (
    set __PATH=C:\Progra~1
    for /f %%f in ('dir /b "!__PATH!\graalvm-ce*" 2^>NUL') do set _JAVA_HOME=!__PATH!\%%f
    if not exist "!_JAVA_HOME!" (
        echo Error: Could not find GraalVM installation directory 1>&2
        set _EXITCODE=1
        goto :eof
    )
)
if %_DEBUG%==1 echo [%_BASENAME%] _JAVA_HOME=%_JAVA_HOME%
set _MAVEN_LOCAL_DIR=%USERPROFILE%\.m2
if not exist "%_MAVEN_LOCAL_DIR%\" (
    echo Error: Could not find mvn cache at %_MAVEN_LOCAL_DIR% 1>&2
    set _EXITCODE=1
    goto :eof
)
set _ANTLR_PATH=%_MAVEN_LOCAL_DIR%\repository\org\antlr\antlr4-runtime\4.7.2\antlr4-runtime-4.7.2.jar
if not exist "%_ANTLR_PATH%" (
    for %%f in ("%_ANTLR_PATH%") do set __ANTLR_DIR=%%~dpf
    if not exist "!__ANTLR_DIR!" mkdir "!__ANTLR_DIR!"
    set __ANTLR_URL=https://repo1.maven.org/maven2/org/antlr/antlr4-runtime/4.7.2/antlr4-runtime-4.7.2.jar
    rem see Invoke-WebRequest params on https://go.microsoft.com/fwlink/?LinkID=217035
    if %_DEBUG%==1 echo [%_BASENAME%] powershell -c "Invoke-WebRequest -OutFile '%_ANTLR_PATH%' '!__ANTLR_URL!'"
    powershell -c "Invoke-WebRequest -OutFile '%_ANTLR_PATH%' '!__ANTLR_URL!'"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
goto :eof

rem output parameter: _GRAALVM_VERSION
rem Unix: GRAALVM_VERSION=$(grep "GRAALVM_VERSION" "$SCRIPT_HOME/../release" 2> /dev/null)
:graalvm_version
set _GRAALVM_VERSION=

rem resolve ".." if pressent in path
for %%f in ("%~1") do set __RELEASE_FILE=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] __RELEASE_FILE=%__RELEASE_FILE%
if not exist "%__RELEASE_FILE%" goto :eof

for /f "tokens=1,* delims==" %%i in ('powershell -C "(Get-Content '%__RELEASE_FILE%') -match 'GRAALVM_VERSION'" 2^>NUL') do set _GRAALVM_VERSION=%%j
if %_DEBUG%==1 echo [%_BASENAME%] _GRAALVM_VERSION=%_GRAALVM_VERSION%
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal

