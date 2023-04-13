SECRETS_PATH=~/.sharedsecrets/
if [ -e "$SECRETS_PATH" ] && which shared-secrets &> /dev/null ; then
	export OPENAI_TOKEN="$(shared-secrets get openai.token)"
fi
# EOF
