@ECHO OFF
SETLOCAL

ECHO Activate venv...
CALL %USERPROFILE%\venv_hy\Scripts\activate.bat

SET THISDIR=%~dp0
SET PYTHONPATH=%THISDIR%\modules;%PYTHONPATH%

hy search_keywords.hy %*
IF NOT %ERRORLEVEL%==0 (
    ECHO エラーが発生しました。
) ELSE (
    ECHO 正常終了しました。
)

ECHO Deactivate venv...
CALL %USERPROFILE%\venv_hy\Scripts\deactivate.bat