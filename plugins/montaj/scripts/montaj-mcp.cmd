@echo off
if not exist "%APPDATA%\Montaj\mcp-launch.cmd" goto missing
"%APPDATA%\Montaj\mcp-launch.cmd" %*
:missing
echo Montaj isn't set up on this computer yet. Install it from montaj.ag and open it once. 1>&2
exit /b 127
