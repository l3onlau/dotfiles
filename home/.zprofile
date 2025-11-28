export DOCKER_HOST=unix:///run/user/1000/docker.sock
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export LANGGRAPH_CLI_NO_ANALYTICS=1
export NEXT_TELEMETRY_DISABLED=1

path=("$HOME/.local/bin" $path)
path=("$HOME/bin" $path) # For docker

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
	exec startx 
fi
