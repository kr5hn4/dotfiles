#!/bin/bash

# Get speaker volume and mute status
SPEAKER_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
SPEAKER_VOL=$(echo "$SPEAKER_INFO" | awk '{print int($2 * 100)}')
SPEAKER_MUTE=$(echo "$SPEAKER_INFO" | grep -o '[MUTED]')

# Get microphone volume and mute status
MIC_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
MIC_VOL=$(echo "$MIC_INFO" | awk '{print int($2 * 100)}')
MIC_MUTE=$(echo "$MIC_INFO" | grep -o '[MUTED]')

# Format speaker status
if [ "$SPEAKER_MUTE" == "[MUTED]" ]; then
	 SPEAKER_STATUS=" Muted"
else
    SPEAKER_STATUS="   $SPEAKER_VOL%"   # Unicode for speaker active icon
fi

# Format microphone status
if [ "$MIC_MUTE" == "[MUTED]" ]; then
    MIC_STATUS=" Muted"
else
    MIC_STATUS="   $MIC_VOL%"
fi

# Output both statuses
echo "$SPEAKER_STATUS | $MIC_STATUS"
