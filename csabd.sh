PAGE_NUM=1
ARRAY_OF_ALL_ALERTS=()
ARRAY_OF_ALERTS_INDEXES=$(curl -u $OWNER:$ACCESS_TOKEN -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/$OWNER/$PROJECT_NAME/code-scanning/alerts?state=open&page=$PAGE_NUM&per_page=$ALERTS_PER_PAGE"| jq .[].number )

while [ -n "$ARRAY_OF_ALERTS_INDEXES" ]
do
	ARRAY_OF_ALL_ALERTS=( "${ARRAY_OF_ALL_ALERTS[@]}" "${ARRAY_OF_ALERTS_INDEXES[@]}" )

	((PAGE_NUM=PAGE_NUM+1))

	ARRAY_OF_ALERTS_INDEXES=$(curl -u $OWNER:$ACCESS_TOKEN -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/$OWNER/$PROJECT_NAME/code-scanning/alerts?state=open&page=$PAGE_NUM&per_page=$ALERTS_PER_PAGE"| jq .[].number )
done

echo $ARRAY_OF_ALL_ALERTS

for index in ${ARRAY_OF_ALL_ALERTS[@]}
do
	REGEX_PAT='[0-9]*'
	[[ $index =~ $REGEX_PAT ]]

	echo "${BASH_REMATCH[0]}"

	echo "${BASH_REMATCH[1]}"

	ALERT_PATH=$(curl -u "$OWNER":"$ACCESS_TOKEN" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/$OWNER/$PROJECT_NAME/code-scanning/alerts/${BASH_REMATCH[1]}" | jq .instances[0].location.path)

	if [[ "$ALERT_PATH" == *"$ALERT_DIS_PATH"* ]]; then

		ALERT_URL="https://api.github.com/repos/$OWNER/$PROJECT_NAME/code-scanning/alerts/${BASH_REMATCH[1]}"

		curl -u "$OWNER":"$ACCESS_TOKEN" -X PATCH -H "Accept: application/vnd.github.v3+json" $ALERT_URL -d '{"state":"dismissed","dismissed_reason":"'"$DISMISS_REASON"'"}'

		echo Alert \#${BASH_REMATCH[1]} is at "$ALERT_DIS_PATH"

	else
		echo Alert \#${BASH_REMATCH[1]} is not at "$ALERT_DIS_PATH"
	fi
done