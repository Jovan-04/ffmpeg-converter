#!/bin/bash

# created by Evan Scherrer. Last updated 08/29/2023
# you can contact me on Discord @jovan04 (legacy - Jovan04#8647)
# or by email at evanne.scherrer@gmail.com
# github: https://github.com/Jovan-04/

# these are the values you need to change: 
# sourceDirectory is the directory you want to convert *from*
# targetDirectory is the directory you want to place the converted files
# sourceType is the file extension for the files you want to convert
# targetType is the file extension that the source files will be converted *to* 
##############################################################################################################
sourceDirectory="/home/evan/Desktop/flac2mp3/larger-test/FLAC" # these should be absolute file paths
targetDirectory="/home/evan/Desktop/flac2mp3/larger-test/MP3" # do not put an ending /

sourceType="flac" # these are the file extensions for the source and target files
targetType="mp3" # do not put a preceding .
##############################################################################################################


# make sure all input strings match the spec for future operations
# file paths 
if [[ "${sourceDirectory}" == */ ]]; then
  sourceDirectory="${sourceDirectory%?}"
fi
if [[ "${targetDirectory}" == */ ]]; then
  targetDirectory="${targetDirectory%?}"
fi

# and file extensions
if [[ "${sourceType}" == .* ]]; then
  sourceType="${sourceType#?}"
fi
if [[ "${targetType}" == .* ]]; then
  targetType="${targetType#?}"
fi


# replicate directory structures
echo "synchronizing all non-.$sourceType files..."
syncStart=$(date +%s%N) # get the current time since unix epoch, with nanosecond precision

rsync -a --stats --exclude="*.$sourceType" "$sourceDirectory/" "$targetDirectory" | grep "Number of files:"

syncStop=$(date +%s%N)
syncTime=$((($syncStop - $syncStart)/1000000)) # subtract start and stop times, then convert from nanoseconds to ms
echo "synchronized in $syncTime ms"
echo ""

# see how many files need to be converted
echo ".$sourceType files to be converted:"
numberOfFiles=$(rsync -zar --dry-run --stats --include="*/" --include="*.$sourceType" --exclude="*" "$sourceDirectory/" "$targetDirectory" | grep "Number of files:" | awk -F'reg: ' '{print $2}' | awk -F', ' '{print $1}')


echo "converting $numberOfFiles .$sourceType files from $sourceDirectory to .$targetType files in $targetDirectory"
echo "starting conversion..."
convStart=$(date +%s%N)

# convert .flac files
find $sourceDirectory -type f -name "*.$sourceType" | tr -d '\r' | while IFS= read -r file; do
    echo ""
    echo "$file"
    file=$(realpath "$file")
    relativePath="${file#$sourceDirectory}" # file path relative to the source directory
    relativePathNE="${relativePath%.*}" # relative file path, without extension
    echo "converting $relativePath from .$sourceType to .$targetType"
    
    ffmpeg -nostdin -i "$sourceDirectory$relativePathNE.$sourceType" -n "$targetDirectory$relativePathNE.$targetType" > /dev/null 2>> "output.log"

    if [ $? -ne 0 ]; then
        echo "Error converting $relativePath" >> "output.log"
    else
        echo "Converted $relativePath" >> "output.log"
    fi
done

convEnd=$(date +%s%N)
convTimeMs=$((($convEnd - $convStart)/1000000)) # subtract start and stop times, then convert from nanoseconds to ms

seconds=$((convTimeMs / 1000))
milliseconds=$((convTimeMs % 1000))
hours=$((seconds / 3600))
seconds=$((seconds % 3600))
minutes=$((seconds / 60))
seconds=$((seconds % 60))

formattedTime=$(printf "%02d:%02d:%02d.%03d" $hours $minutes $seconds $milliseconds)

echo "converted $numberOfFiles files in $convTimeMs ms ($formattedTime)"