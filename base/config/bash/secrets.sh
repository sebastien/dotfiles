SECRETS_PATH=~/.sharedsecrets/
if [ -e "$SECRETS_PATH" ] && which littlesecrets &>/dev/null; then
	export OPENAI_TOKEN="$(littlesecrets get openai.token)"
	export OPENAI_ORGANISATION="$(littlesecrets get openai.organisation)"
	export OPENROUTER_TOKEN="$(littlesecrets get openrouter.token)"
	export OPENAI_API_KEY="$OPENAI_TOKEN"
	export ANTHROPIC_API_KEY="$(littlesecrets get claude.token)"
fi

# EOF
