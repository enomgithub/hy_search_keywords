@ECHO OFF
SETLOCAL

ECHO Activate venv...
CALL %USERPROFILE%\venv_hy\Scripts\activate.bat

hy main.hy %*
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
