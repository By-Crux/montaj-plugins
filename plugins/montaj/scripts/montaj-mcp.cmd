@echo off
if not exist "%APPDATA%\Montaj\mcp-launch.cmd" goto missing
"%APPDATA%\Montaj\mcp-launch.cmd" %*
rem The line above hands over to the launcher and does not come back here; if one ever did, this keeps it out of :missing.
exit /b %ERRORLEVEL%
:missing
echo Montaj isn't set up on this computer yet. Install it from montaj.ag and open it once. 1>&2
exit /b 127
