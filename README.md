## ffmpeg-converter
A short bash script that uses ffmpeg to convert a tree of files to a different format (i.e. .flac to .mp3), preserving directory structure  

### Usage
1. Download the script and open it in a text editor
2. Change the source and target directories as you wish (lines 15 & 16); these should be absolute file paths (not relative), and should not have a trailing slash `/`
3. Change the source and destination formats; do not put a period `.` before the extension
4. If desired, change the output audio quality (see [https://trac.ffmpeg.org/wiki/Encode/MP3](https://trac.ffmpeg.org/wiki/Encode/MP3)); default is the highest quality
5. Run the script
