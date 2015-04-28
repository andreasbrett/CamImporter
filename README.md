# CamImporter

This script allows to quickly download all photos (Canon/Nikon/Fujifilm for now) from my SD card onto my hdd, cull them quickly with FastStone and import only the good ones into Adobe Lightroom. To make culling even faster JPG files are used for the culling process for RAW+JPG pairs. Since I'm a Fujifilm shooter most of the time there's additional support for the star ratings you can apply in-camera. Since Fujifilm sucks at implementing them as any other camera manufacturer I make use of exiftool to fix things so Adobe Lightroom will recognize the star ratings after import.

To make this fit your needs you will have to customize the paths to FastStone, Adobe Lightroom and exiftool. Please get the latest exiftool to have full compatibility for newer camera models.

## How it works

### 1. Downloading / Culling
Drag and drop your DCIM folder (check your SD card) onto the "1_Culling.cmd" script. You will be asked for a job name. All files are then downloaded into a folder with that job name. The folder location is directly ABOVE the script folder. This is because I use the CamImporter scripts directly on my Desktop. If the DCIM folder contains several subfolders (you know those nasty 101, 102, ... folders) the folder name will be put into the filename (as a prefix). Once all the files are downloaded FastStone is powered up and you can cull through all the images. If you have RAW+JPG file pairs you will only have to cull through the JPG files for even faster displaying speeds. Script #2 will take care of the rest and only import the corresponding RAW files into Adobe Lightroom.

### 2. Importing
After culling through your images and deleting all the unsharp and sh*tty ones drag and drop the job folder onto the "2_Importing.cmd" script. This will move all the necessary files to a folder that will be passed to Adobe Lightroom's import dialog. The rest is up to you.
