SECRETS_PATH=~/.sharedsecrets/
if [ -e "$SECRETS_PATH" ] && which shared-secrets &> /dev/null ; then
	export OPENAI_TOKEN="$(shared-secrets get openai.token)"
	export OPENAI_ORGANISATION="$(shared-secrets get openai.organisation)"
	export OPENROUTER_TOKEN="$(shared-secrets get openrouter.token)"
fi

# EOF
