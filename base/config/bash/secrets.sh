SECRETS_PATH=~/.littlesecrets/

HAS_SECRET=()
FAILED_SECRET=()
function secret_def {
	local varname="${1}"
	local secname="${2}"
	local secret
	for name in "${HAS_SECRET[@]}"; do
		if [[ "$name" == "$varname" ]]; then
			return 0
		fi
	done
	if secret=$(littlesecrets get "$secname"); then
		if [ -z "$secret" ]; then
			FAILED_SECRET+=("$varname")
		else
			eval "export $varname=$secret"
			HAS_SECRET+=("$varname")
		fi
	else
		FAILED_SECRET+=("$varname")
	fi
}

function load-secrets {
	if [ -z "${HAS_SECRETS:-}" ]; then
		secret_def OPENAI_TOKEN openai.token
		secret_def OPENAI_ORGANISATION openai.organisation
		secret_def OPENROUTER_TOKEN openrouter.token
		secret_def ANTHROPIC_API_KEY claude.token
		secret_def CODESTRAL_API_KEY codestral.token
		secret_def MISTRAL_API_KEY mistral.token
		if [ ! -z "${HAS_SECRET}" ]; then
			echo "Secrets: ${HAS_SECRET[@]}"
		fi
		if [ ! -z "${FAILED_SECRET}" ]; then
			echo "Failed secrets: ${FAILED_SECRET[@]}"
		fi
		export OPENAI_API_KEY="$OPENAI_TOKEN"
	fi
}

# EOF
