@echo off
setlocal enabledelayedexpansion

:: Check if yt-dlp is installed
if not exist "yt-dlp.exe" (
    echo Downloading yt-dlp...
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; $WebClient = New-Object System.Net.WebClient; $WebClient.DownloadFile('https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe', 'yt-dlp.exe')"
    if %errorlevel% neq 0 (
        echo Error during yt-dlp installation
        pause
        exit /b 1
    )
    echo yt-dlp installed successfully!
)

:: Check if ffmpeg is installed
if not exist "ffmpeg.exe" (
    echo Downloading ffmpeg...
    powershell -Command "$ProgressPreference = 'SilentlyContinue'; $WebClient = New-Object System.Net.WebClient; $WebClient.DownloadFile('https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip', 'ffmpeg.zip')"
    if %errorlevel% neq 0 (
        echo Error downloading ffmpeg
        pause
        exit /b 1
    )
    echo Extracting ffmpeg...
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath '.' -Force"
    if %errorlevel% neq 0 (
        echo Error extracting ffmpeg
        pause
        exit /b 1
    )
    move "ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe" .
    move "ffmpeg-master-latest-win64-gpl\bin\ffprobe.exe" .
    rmdir /s /q "ffmpeg-master-latest-win64-gpl"
    del "ffmpeg.zip"
    echo ffmpeg installed successfully!
)

:start
cls
:: Ask for playlist URL
echo.
set /p "playlist_url=Enter the YouTube playlist URL: "
if "%playlist_url%"=="" (
    echo Invalid URL
    pause
    goto start
)

:choose_type
cls
:: Ask for download type
echo.
echo Select download type:
echo [1] Video
echo [2] Audio
set /p "choice=Choose (1/2): "

if "%choice%"=="1" (
    goto video_format
) else if "%choice%"=="2" (
    goto audio_format
) else (
    echo Invalid choice
    pause
    goto choose_type
)

:video_format
cls
echo.
echo You chose: Video
echo.
echo Select video format:
echo [1] MP4 (standard)
echo [2] MKV (high quality)
echo [3] WEBM
set /p "format=Choose format (1/2/3): "

if "%format%"=="1" (
    set "format_cmd=-f bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
) else if "%format%"=="2" (
    set "format_cmd=-f bestvideo+bestaudio --merge-output-format mkv"
) else if "%format%"=="3" (
    set "format_cmd=-f bestvideo[ext=webm]+bestaudio[ext=webm]/best[ext=webm]"
) else (
    echo Invalid format, MP4 will be used
    set "format_cmd=-f bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
)
goto download

:audio_format
cls
echo.
echo You chose: Audio
echo.
echo Select audio format:
echo [1] MP3 (standard)
echo [2] M4A (high quality)
echo [3] OPUS
set /p "format=Choose format (1/2/3): "

if "%format%"=="1" (
    set "format_cmd=-x --audio-format mp3 --audio-quality 0"
) else if "%format%"=="2" (
    set "format_cmd=-x --audio-format m4a --audio-quality 0"
) else if "%format%"=="3" (
    set "format_cmd=-x --audio-format opus --audio-quality 0"
) else (
    echo Invalid format, MP3 will be used
    set "format_cmd=-x --audio-format mp3 --audio-quality 0"
)
goto download

:download
:: Create downloads directory if it doesn't exist
if not exist "downloads" mkdir "downloads"

:: Create temporary file for yt-dlp output
set "temp_file=%temp%\yt_dlp_output.txt"

cls
if "%choice%"=="1" (
    echo.
    echo Downloading videos...
    echo.
    yt-dlp %format_cmd% -o "downloads/%%(playlist_title)s/%%(title)s.%%(ext)s" --newline "%playlist_url%" | findstr /r "^\[download\]"
) else (
    echo.
    echo Downloading audio...
    echo.
    yt-dlp %format_cmd% -o "downloads/%%(playlist_title)s/%%(title)s.%%(ext)s" --newline "%playlist_url%" | findstr /r "^\[download\]"
)

if %errorlevel% neq 0 (
    echo.
    echo ============================================
    echo               DOWNLOAD ERROR!
    echo ============================================
    echo.
    echo An error occurred during the download.
    echo Verify the URL and try again.
    echo.
    pause
    goto start
)

:: Show completion message
echo.
echo ============================================
echo            DOWNLOAD COMPLETED!
echo ============================================
echo.
echo Files have been successfully saved to:
echo downloads\[playlist_name]
echo.
echo Press any key to download another playlist...
pause
goto start 