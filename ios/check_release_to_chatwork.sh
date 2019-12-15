#!/bin/bash
#
# This is the SHELL to check if the APP is released.
# The APP is updated, you can receive the notification in your chatwork room.

# your settings
IOS_APP_ID="your ios app id"
CHATWORK_API_ID="your chatwork api id"
CHATWORK_ROOM_ID="your chatwork room id"

# fixed settings
APP_STORE_API_BASE_URL="https://itunes.apple.com/lookup?id="
APP_STORE_URL="https://apps.apple.com/us/app/id"$IOS_APP_ID
CHATWORK_BASE_URI="https://api.chatwork.com/v2"
FIX_URL=$APP_STORE_API_BASE_URL$IOS_APP_ID
SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUTPUT_DIR=$SCRIPT_DIR"/output/"
OUTPUT_FILE=$OUTPUT_DIR"ios_"$IOS_APP_ID"_version.txt"

# get and create json object
DATA=$( curl -s $FIX_URL | jq -r -c '.results[] | {trackName, version, trackViewUrl}' )
TITLE=$( echo $DATA | jq -r -c '.trackName')
STORE_VERSION=$( echo $DATA | jq -r -c '.version')

# if output.json is empty, create it
if [ ! -f $OUTPUT_FILE ]; then

    mkdir $OUTPUT_DIR
    echo "$STORE_VERSION" > $OUTPUT_FILE

    echo "current store version : $STORE_VERSION"
    echo "Initialize Completed !!"

else
    LOCAL_VERSION=`cat $OUTPUT_FILE`

    # check version
    # if current output.json isnt match it, that APP was updated
    if [ "$STORE_VERSION" = "$LOCAL_VERSION" ]; then
        # echo "equal"
        echo $TITLE" current version --> "$LOCAL_VERSION
    else
        # echo "not equal"
        echo $TITLE" version up !! --> "$STORE_VERSION
        echo "$STORE_VERSION" > $OUTPUT_FILE

        # Chatwork : iOS version up notification
        MSG_TITLE="iOS「"$TITLE"」Update Notification"
        MSG_INFO="ver : "$STORE_VERSION"%0D%0A"$APP_STORE_URL
        MSG_BODY="%5Binfo%5D%5Btitle%5D$MSG_TITLE%5B%2Ftitle%5D$MSG_INFO%5B%2Finfo%5D"
        CW_MSG_RESULT=$(curl -s -X POST -H "X-ChatWorkToken: $CHATWORK_API_ID" -d "body=$MSG_BODY&self_unread=0" "$CHATWORK_BASE_URI/rooms/$CHATWORK_ROOM_ID/messages")
        echo $CW_MSG_RESULT
    fi
fi
