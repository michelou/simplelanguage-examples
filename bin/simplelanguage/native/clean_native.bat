@echo off

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _TARGET_DIR=%_ROOT_DIR%target

rem ##########################################################################
rem ## Main

if exist "%_TARGET_DIR%\" ( rmdir /s /q "%_TARGET_DIR%"
) else ( echo Directory %_TARGET_DIR% not found.
)

goto end

rem ##########################################################################
rem ## Cleanups

:end
exit /b %_EXITCODE%
