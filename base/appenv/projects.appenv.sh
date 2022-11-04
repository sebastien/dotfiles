appenv_declare projects
PROJECTS_DIR="$HOME/Workspace"
PROJECTS="cuisine retro reporter cells sink texto snap macme multiplex sdoc smalldoc shared-secrets"
for project in $PROJECTS; do
	for parent in $PROJECTS_DIR; do
		path="$parent/$project"
		if [ -d "$path" ]; then
			if [ ! -z "$(ls $path/src/py/*/*.py 2> /dev/null)" ]; then
				appenv_prepend PYTHONPATH "$path/src/py"
			elif [ ! -z "$(ls $parent/$project/src/*/*.py 2> /dev/null)" ]; then
				appenv_prepend PYTHONPATH "$path/src"
			fi
			if [ -d "$path/bin" ]; then
				appenv_prepend PATH "$path/bin"
			fi
		fi
	done
done
# EOF
