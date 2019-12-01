#!/bin/bash
#
# This is the SHELL to check if the APP is released.
# The APP is updated, you can receive the notification in your chatwork room.

# your settings
IOS_APP_ID="your ios app id"
CHATWORK_API_ID="your chatwork api id"
CHATWORK_ROOM_ID="your chatwork room id"
OUTPUT_FILE="ios_"$IOS_APP_ID"_version_output.json"

# fixed settings
APP_STORE_API_BASE_URL="https://itunes.apple.com/lookup?id="
APP_STORE_URL="https://apps.apple.com/us/app/id"$IOS_APP_ID
CHATWORK_BASE_URI="https://api.chatwork.com/v2"
FIX_URL=$APP_STORE_API_BASE_URL$IOS_APP_ID


# -s : silent mode (no progress)
# jq : get value by filtering
# echo curl -s $FIX_URL | jq -c '.results[] | [.version]'

# get and create json object
DATA=$( curl -s $FIX_URL | jq -r -c '.results[] | {trackName, version, trackViewUrl}' )
TITLE=$( echo $DATA | jq -r -c '.trackName')
STORE_VERSION=$( echo $DATA | jq -r -c '.version')
# APP_URL=$( echo $DATA | jq -r -c '.trackViewUrl')
# APP_URL_ENCODED=$( echo $urlencode $APP_URL )

# if output.json is empty, create it
if [ ! -f ./$OUTPUT_FILE ]; then

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

        # notification with chatowork api
        # CW_STATUS_RESULT=$(curl -s -X GET -H "X-ChatWorkToken: $CHATWORK_API_ID" "$CHATWORK_BASE_URI/my/status")
        # echo $CW_STATUS_RESULT

        # Chatwork : iOS version up notification
        MSG_TITLE="iOS版「"$TITLE"」アップデートのお知らせ"
        MSG_INFO="バージョン : "$STORE_VERSION"%0D%0A"$APP_STORE_URL
        MSG_BODY="%5Binfo%5D%5Btitle%5D$MSG_TITLE%5B%2Ftitle%5D$MSG_INFO%5B%2Finfo%5D"
        CW_MSG_RESULT=$(curl -s -X POST -H "X-ChatWorkToken: $CHATWORK_API_ID" -d "body=$MSG_BODY&self_unread=0" "$CHATWORK_BASE_URI/rooms/$CHATWORK_ROOM_ID/messages")
        echo $CW_MSG_RESULT
    fi
fi


# urlencode
function urlencode {
    echo "$1" | nkf -WwMQ | sed 's/=$//g' | tr = % | tr -d '\n'
}
