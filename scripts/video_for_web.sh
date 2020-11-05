#!/bin/bash
set -e

function video_for_web {
	SOURCE_FILE="$1"
	BASE_NAME=$(basename "$SOURCE_FILE")

	# h264
	ffmpeg -i "$SOURCE_FILE" vcodec h264 -acodec aac -strict -2 "$BASE_NAME.x264.mp4"
	# h265
	ffmpeg -i "$SOURCE_FILE" -c:v libx265 -preset medium -x265-params crf=28 -c:a aac -strict experimental -b:a 128k "$BASE_NAME.x265.mp4"
	# webm vp9
	ffmpeg -i "$SOURCE_FILE" -vcodec libvpx-vp9 -b:v 1M -acodec libvorbis "$BASE_NAME.vp9.webm"
}
