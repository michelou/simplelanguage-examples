@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _LANGUAGE_DIR=%_ROOT_DIR%language
set _LAUNCHER_DIR=%_ROOT_DIR%launcher
set _TARGET_DIR=%_ROOT_DIR%target

set _PARSER_DIR=%_TARGET_DIR%\parser
set _PARSER_CLASSES_DIR=%_PARSER_DIR%\classes
set _PARSER_LIBS_DIR=%_PARSER_DIR%\libs
set _PARSER_SOURCE_DIR=%_PARSER_DIR%\src

set _ANTLR_JAR_NAME=antlr-4.7.2-complete.jar
set _ANTLR_JAR_URL=https://www.antlr.org/download/%_ANTLR_JAR_NAME%
set _ANTLR_JAR_FILE=%_PARSER_LIBS_DIR%\%_ANTLR_JAR_NAME%

set _CURL_CMD=curl.exe
set _CURL_OPTS=
if not %_DEBUG%==1 set _CURL_OPTS=--silent

set _JAVA_CMD=java.exe
set _JAVA_OPTS=

set _JAVAC_CMD=javac.exe
set _JAVAC_OPTS=-Xlint:deprecation

set _TAIL_CMD=tail.exe
set _TAIL_OPTS=

set _DIFF_CMD=diff.exe
set _DIFF_OPTS=--ignore-all-space

set _G4_FILE=%_LANGUAGE_DIR%\src\main\java\com\oracle\truffle\sl\parser\SimpleLanguage.g4
rem see https://github.com/antlr/antlr4/blob/master/doc/tool-options.md
set _G4_PACKAGE_NAME=com.oracle.truffle.sl.parser

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

call :init
if not %_EXITCODE%==0 goto end

if %_CLEAN%==1 (
   call :clean
   if not !_EXITCODE!==0 goto end
)
if %_BUILD%==1 (
    call :build
    if not !_EXITCODE!==0 goto end
)
if %_TEST%==1 (
    call :test com.oracle.truffle.sl.launcher.SLMain
    if not !_EXITCODE!==0 goto end
)
if %_INSTALL%==1 (
    call :install
    if not !_EXITCODE!==0 goto end
)

rem call :test com.oracle.truffle.sl.launcher.SLMainViewer
rem if not !_EXITCODE!==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
rem output parameter(s): _CLEAN, _DEBUG, _HELP, _INSTALL, _TEST, _VERBOSE
:args
set _BUILD=0
set _CLEAN=0
set _DEBUG=0
set _HELP=0
set _INSTALL=0
set _TEST=0
set _TEST_COUNT=
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    rem if !__N!==0 set _HELP=1
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( set _HELP=1
) else if /i "%__ARG%"=="build" ( set _BUILD=1
) else if /i "%__ARG%"=="clean" ( set _CLEAN=1
) else if /i "%__ARG%"=="install" ( set _BUILD=1& set _TEST=1& set _INSTALL=1
) else if /i "%__ARG%"=="test" ( set _BUILD=1& set _TEST=1
) else if /i "%__ARG:~0,5%"=="test:" (
    set /a "__NUMBER=%__ARG:~5%" + 0
    if !__NUMBER! gtr 0 ( set "_TEST_COUNT=!__NUMBER!"
    ) else (
        echo Error: ignore invalid or missing argument: %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set _BUILD=1& set _TEST=1
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-help" ( set _HELP=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto args_done
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _BUILD=%_BUILD% _DEBUG=%_DEBUG% _TEST=%_TEST% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug     display commands executed by this script
echo     -verbose   display progress messages
echo   Subcommands:
echo     build      generatre ANTLR parser for SL
echo     clean      delete generated files
echo     help       display this help message
echo     install    copy lexer/parser files to language directory
echo     test       execute all tests for generated ANTLR parser
echo     test[:^<n^>] execute 1..n test^(s^) for generated ANTLR parser
goto :eof

:init
if exist "%_ANTLR_JAR_FILE%" goto :eof

if not exist "%_PARSER_LIBS_DIR%" (
    if %_DEBUG%==1 echo [%_BASENAME%] mkdir "%_PARSER_LIBS_DIR%"
     mkdir "%_PARSER_LIBS_DIR%"
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_CURL_CMD% %_CURL_OPTS% --output %_ANTLR_JAR_FILE% %_ANTLR_JAR_URL% 1>&2
) else if %_VERBOSE%==1 ( echo Download file %_ANTLR_JAR_NAME% to directory %_PARSER_LIBS_DIR% 1>&2
)
call %_CURL_CMD% %_CURL_OPTS% --output %_ANTLR_JAR_FILE% %_ANTLR_JAR_URL%
if not !ERRORLEVEL!==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:clean
call :rmdir "%_PARSER_CLASSES_DIR%"
call :rmdir "%_PARSER_SOURCE_DIR%"
goto :eof

rem input parameter: %1=directory path
:rmdir
set __DIR=%~1
if not exist "!__DIR!\" goto :eof
if %_DEBUG%==1 ( echo [%_BASENAME%] rmdir /s /q "!__DIR!" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory !__DIR! 1>&2
)
rmdir /s /q "!__DIR!"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:build
if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVA_CMD% -cp %_ANTLR_JAR_FILE% org.antlr.v4.Tool -package %_G4_PACKAGE_NAME% -no-listener %_G4_FILE% -o %_PARSER_SOURCE_DIR% 1>&2
) else if %_VERBOSE%==1 ( echo Generate ANTLR parser files into directory %_PARSER_SOURCE_DIR% 1>&2
)
call "%_JAVA_CMD%" -cp %_ANTLR_JAR_FILE% org.antlr.v4.Tool -package %_G4_PACKAGE_NAME% -no-listener %_G4_FILE% -o %_PARSER_SOURCE_DIR%
if not %ERRORLEVEL%==0 (
    echo Error: Generation of ANTLR parser failed 1>&2
    set _EXITCODE=1
    goto :eof
)

set __PS_SCRIPT_FILE=%_ROOT_DIR%%_BASENAME%.ps1
if not exist "%__PS_SCRIPT_FILE%" (
    echo Error: PS1 script file not found ^(%__PS_SCRIPT_FILE%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
for %%f in (%_PARSER_SOURCE_DIR%\*.java) do (
    set __SOURCE_FILE=%%f
    if %_DEBUG%==1 ( echo [%_BASENAME%] powershell -f %__PS_SCRIPT_FILE% "!__SOURCE_FILE!" 1>&2
    ) else if %_VERBOSE%==1 ( echo Add copyright notice to source file !__SOURCE_FILE:%_ROOT_DIR%=! 1>&2
    )
    powershell -f %__PS_SCRIPT_FILE% "!__SOURCE_FILE!"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
goto :eof

rem input parameter(s): %1=main class
:test
set __MAIN_CLASS=%~1

if not exist "%_PARSER_CLASSES_DIR%" mkdir "%_PARSER_CLASSES_DIR%"

set __CPATH=
for /f %%f in ('where /r "%JAVA_HOME%\jre\lib\truffle" *.jar') do (
    set __CPATH=!__CPATH!%%f;
)
for /f %%f in ('where /r "%_PARSER_LIBS_DIR%" *.jar') do (
    set __CPATH=!__CPATH!%%f;
)
set __CPATH=%__CPATH%%_PARSER_CLASSES_DIR%

set __SOURCE_LIST_FILE=%_PARSER_DIR%\source_list.txt
if exist "%__SOURCE_LIST_FILE%" del "%__SOURCE_LIST_FILE%"

for /f %%f in ('where /r "%_LANGUAGE_DIR%\src\main\java" *.java') do (
    set __SOURCE_FILE_NAME=%%~nxf
    if "!__SOURCE_FILE_NAME!"=="SimpleLanguageParser.java" (
        rem ignore
    ) else if "!__SOURCE_FILE_NAME!"=="SimpleLanguageLexer.java" (
        rem ignore
    ) else (
        echo %%f>> "%__SOURCE_LIST_FILE%"
    )
)
for /f %%f in ('where /r "%_LAUNCHER_DIR%\src\main\java" *.java') do (
    echo %%f>> "%__SOURCE_LIST_FILE%"
)
for /f %%f in ('where /r "%_PARSER_SOURCE_DIR%" *.java') do (
    echo %%f>> "%__SOURCE_LIST_FILE%"
)

if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVAC_CMD% %_JAVAC_OPTS% -cp %__CPATH% -d "%_PARSER_CLASSES_DIR%" @"%__SOURCE_LIST_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Compile Java source files to directory %_PARSER_CLASSES_DIR% 1>&2
)
call %_JAVAC_CMD% %_JAVAC_OPTS% -cp %__CPATH% -d "%_PARSER_CLASSES_DIR%" @"%__SOURCE_LIST_FILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
set __OUTPUT_DIR=%_PARSER_DIR%\output
if not exist "%__OUTPUT_DIR%" mkdir "%__OUTPUT_DIR%"

rem see https://github.com/oracle/graal/issues/1474
set __JAVA_OPTS=%_JAVA_OPTS% -Dtruffle.class.path.append=%_ANTLR_JAR_FILE%;%_PARSER_CLASSES_DIR%

if %_VERBOSE%==1 echo Execute test suite for SL 1>&2

set __N=0
for %%f in (%_LANGUAGE_DIR%\tests\*.sl) do (
    set __SL_FILE=%%f
    set __OUTPUT_FILE=%__OUTPUT_DIR%\%%~nf.output
    set __CHECK_FILE=!__SL_FILE:~0,-2!output

    if %_DEBUG%==1 ( echo [%_BASENAME%] %_JAVA_CMD% %__JAVA_OPTS% -cp %__CPATH% %__MAIN_CLASS% "!__SL_FILE!" ^> !__OUTPUT_FILE! 1>&2
    ) else if %_VERBOSE%==1 ( echo    Compile !__SL_FILE:%_LANGUAGE_DIR%\=! and check output with !__CHECK_FILE:%_LANGUAGE_DIR%\=! 1>&2
    )
    call %_JAVA_CMD% %__JAVA_OPTS% -cp %__CPATH% %__MAIN_CLASS% !__SL_FILE! > !__OUTPUT_FILE! 2>&1
    if not !ERRORLEVEL!==0 (
        rem some tests may contain errors
        rem set _EXITCODE=1
    )
    if %_DEBUG%==1 echo [%_BASENAME%] %_DIFF_CMD% %_DIFF_OPTS% -I "^^==.*" !__OUTPUT_FILE! !__CHECK_FILE! 1>&2
    call %_DIFF_CMD% %_DIFF_OPTS% -I "^==.*" !__OUTPUT_FILE! !__CHECK_FILE!
    if not !ERRORLEVEL!==0 (
        echo Error: Output file differs from !__CHECK_FILE:%_LANGUAGE_DIR%\=! 1>&2
        rem set _EXITCODE=1
        rem goto :eof
    )
    set /a __N+=1
    if defined _TEST_COUNT if !__N! geq %_TEST_COUNT% goto test_done
)
:test_done
if %_VERBOSE%==1 echo Finished test suite ^(%__N% files^) 1>&2
goto :eof

:install
set __PARSER_FROM_DIR=%_PARSER_SOURCE_DIR%
set __PARSER_TO_DIR=%_LANGUAGE_DIR%\src\main\java\com\oracle\truffle\sl\parser
if %_DEBUG%==1 ( set __XCOPY_OPTS=/y
) else ( set __XCOPY_OPTS=/y /q
)
if %_DEBUG%==1 ( echo [%_BASENAME%] xcopy %__XCOPY_OPTS% "%__PARSER_FROM_DIR%\*.java" "%__PARSER_TO_DIR%\" 1^>NUL 1>&2
) else if %_VERBOSE%==1 ( echo Copy lexer/parser files to directory !__PARSER_TO_DIR:%_ROOT_DIR%=! 1>&2
)
xcopy %__XCOPY_OPTS% "%__PARSER_FROM_DIR%\*.java" "%__PARSER_TO_DIR%\" 1>NUL
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
