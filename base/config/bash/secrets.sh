SECRETS_PATH=~/.sharedsecrets/
if [ -e "$SECRETS_PATH" ] && which shared-secrets &> /dev/null ; then
	export OPENAI_TOKEN="$(shared-secrets get openai.token)"
	export OPENAI_API_KEY="$OPENAI_TOKEN"
fi
# EOF
