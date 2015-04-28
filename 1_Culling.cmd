@echo off

Setlocal EnableDelayedExpansion

REM ask for job name
set /p jobname=Job Name: 
if [%jobname%] == [] (
	REM create timestamp
	for /f "tokens=1-3 delims=/. " %%a in ('date /t') do (set mydate=%%c%%b%%a)
	for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)
	SET jobname=!mydate!_!mytime!
)

REM ask if the job contains Fuji RAF files with star ratings
set /p rafratings=Fuji RAF with Star Ratings? (y/n) 
if "%rafratings%" == "Y" set rafratings=y

REM define directories
set dirHere=%~dp0
set dirRoot=%dirHere%CULLING_%jobname%\
set dirRawCopies=%dirRoot%raw_copies\
set dirPreview=%dirRoot%culling\
set dirImport=%dirRoot%import\

REM create folders if not existent
if not exist "%dirRoot%" mkdir "%dirRoot%"
if not exist "%dirRawCopies%" mkdir "%dirRawCopies%"
if not exist "%dirPreview%" mkdir "%dirPreview%"
if not exist "%dirImport%" mkdir "%dirImport%"



REM ----------------------------------------------------------------------------------------
REM copy all jpg/raf/cr2/nef files in all subfolders to harddisk (%dirRoot%)
REM ----------------------------------------------------------------------------------------
echo ******************************************************************
echo *** Copying jpg/raf/cr2/nef files to harddisk
echo *** Location: %dirRoot%
echo ******************************************************************
pushd "%~1"

	for /r %%g in (.) do (
		pushd "%%g"

			REM iterate over all jpg/raf/cr2/nef files
			for /f %%f in ('dir *.cr2 *.raf *.nef *.jpg /b 2^> nul') do (
				REM copy to %dirRoot% and include directory prefix in filename
				copy "%%f" "%dirRoot%%%~ng_%%f"
			)

		popd
	)
popd


REM ----------------------------------------------------------------------------------------
REM move copied files to corresponding folders
REM		- "JPG only" to %dirPreview%
REM		- "RAW+JPG"...
REM			- JPG to %dirPreview%
REM			- RAW to %dirRawCopies%
REM		- "RAW only" to %dirPreview%
REM ----------------------------------------------------------------------------------------
echo.
echo ******************************************************************
echo *** Moving files to proper sub-folders / EXIF preparation
echo ******************************************************************
pushd "%dirRoot%"

	REM move JPG files to %dirPreview%
	for /f %%f in ('dir *.jpg /b 2^> nul') do (

		REM RAW+JPG: co-existing RAW files are stored in %dirRawCopies%
		if exist "%%~nf.cr2" move "%%~nf.cr2" "%dirRawCopies%%%~nf.cr2" > nul
		if exist "%%~nf.nef" move "%%~nf.nef" "%dirRawCopies%%%~nf.nef" > nul
		if exist "%%~nf.raf" (
			REM copy "FujiFilm:Rating" from JPG to "FujiFilm:Rating" and "XMP:Rating" in RAF
			REM side note #1: for RAW+JPG Fuji stores the rating only in the JPG file...
			REM side note #2: Lightroom ignores "XMP:Rating" within RAF files and needs them in an XMP sidecard file...
			"%ProgramFiles(x86)%\exiftoolgui\exiftool.exe" -overwrite_original -tagsfromfile %%f "-FujiFilm:Rating>FujiFilm:Rating" %%~nf.raf -tagsfromfile %%f "-FujiFilm:Rating>XMP:Rating" %%~nf.xmp
			move "%%~nf.raf" "%dirRawCopies%%%~nf.raf" > nul
			move "%%~nf.xmp" "%dirRawCopies%%%~nf.xmp" > nul
		)
		
		REM copy "FujiFilm:Rating" to "XMP:Rating"
		if "%rafratings%" == "y" "%ProgramFiles(x86)%\exiftoolgui\exiftool.exe" -overwrite_original "-FujiFilm:Rating>XMP:Rating" %%f 
		
		REM move JPG file
		move "%%f" "%dirPreview%" > nul
	)

	REM move RAW files to %dirPreview%
	for /f %%f in ('dir *.cr2 *.nef /b 2^> nul') do (
		move "%%f" "%dirPreview%" > nul
	)

	REM special sauce for Fuji RAF files
	for /f %%f in ('dir *.raf /b 2^> nul') do (
		
		REM copy "FujiFilm:Rating" to "XMP:Rating" for Fuji "RAF only" files
		REM side note: Lightroom ignores "XMP:Rating" within RAF files and needs them in an XMP sidecard file...
		if "%rafratings%" == "y" "%ProgramFiles(x86)%\exiftoolgui\exiftool.exe" -overwrite_original -tagsfromfile %%f "-FujiFilm:Rating>XMP:Rating" %%~nf.xmp
		
		REM move RAF and XMP file
		move "%%f" "%dirPreview%" > nul
		move "%%~nf.xmp" "%dirPreview%" > nul
	)
popd

echo.
echo.
echo.
echo ******************************************************************
echo *** Done. Please press "Enter" to start FastStone Image Viewer
echo ******************************************************************
pause

REM ----------------------------------------------------------------------------------------
REM run FastStone Image Viewer
REM ----------------------------------------------------------------------------------------
start "Window Title" "%ProgramFiles(x86)%\FastStone Image Viewer\FSViewer.exe" "%dirPreview%"
