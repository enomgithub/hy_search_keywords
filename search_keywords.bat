@ECHO OFF
SETLOCAL

ECHO Activate venv...
CALL %USERPROFILE%\venv_hy\Scripts\activate.bat

SET THISDIR=%~dp0
SET PYTHONPATH=%THISDIR%\modules;%PYTHONPATH%

hy search_keywords.hy %*
SET STATE=%ERRORLEVEL%

ECHO Deactivate venv...
CALL %USERPROFILE%\venv_hy\Scripts\deactivate.bat

IF NOT %STATE%==0 (
    ECHO エラーが発生しました。
    EXIT /b 1
) ELSE (
    ECHO 正常終了しました。
    EXIT /b 0
)

