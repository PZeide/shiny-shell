#!/usr/bin/env bash
# shiny-hyprland-share-picker bridge for shiny-shell
# Bridges the custom shiny-shell share-picker IPC protocol to the
# hyprland-share-picker input / output expected by xdg-desktop-portal-hyprland.

ALLOW_TOKEN=false
for arg in "$@"; do
	[[ "$arg" == "--allow-token" ]] && ALLOW_TOKEN=true
done

OPTIONS=$(jq -cn \
	--argjson allowRestoreTokenDefault "$ALLOW_TOKEN" \
	'{allowRestoreTokenDefault: $allowRestoreTokenDefault}')

RESPONSE=$(shiny-shell ipc --any-display call share-picker request "$OPTIONS" 2>/dev/null) || {
	echo "error" >&2
	exit 1
}

STATUS=$(echo "$RESPONSE" | jq -r '.status // empty')
if [[ "$STATUS" != "ok" ]]; then
	echo "error" >&2
	exit 1
fi

REQUEST_ID=$(echo "$RESPONSE" | jq -r '.data // empty')
if [[ -z "$REQUEST_ID" ]]; then
	echo "error" >&2
	exit 1
fi

echo "listening" >> /home/thibaud/test.txt
while IFS= read -r line || break; do
    echo "received $line" >> /home/thibaud/test.txt
	[[ -z "$line" ]] && continue

	KEY=$(echo "$line" | jq -r '.key // empty' 2>/dev/null)
	[[ "$KEY" != "$REQUEST_ID" ]] && continue

	RESULT_STATUS=$(echo "$line" | jq -r '.status // empty')

	if [[ "$RESULT_STATUS" == "cancelled" ]]; then
		echo "cancelled" >&2
		exit 1
	fi

	if [[ "$RESULT_STATUS" != "selected" ]]; then
		echo "error" >&2
		exit 1
	fi

	TYPE=$(echo "$line" | jq -r '.result.type // empty')
	RESTORE=$(echo "$line" | jq -r '.result.allowRestoreToken // false')
	SELECTION_FLAGS=""
	[[ "$RESTORE" == "true" ]] && SELECTION_FLAGS="r"

	case "$TYPE" in
	monitor)
		MONITOR=$(echo "$line" | jq -r '.result.monitor // empty')
		if [[ -z "$MONITOR" ]]; then
			echo "error" >&2
			exit 1
		fi

		echo "[SELECTION]${SELECTION_FLAGS}/screen:${MONITOR}"
		;;
	window)
		WINDOW=$(echo "$line" | jq -r '.result.window // empty')
		if [[ -z "$WINDOW" ]]; then
			echo "error" >&2
			exit 1
		fi

		DEC_WINDOW=$((16#$WINDOW))
		XDPH_ID=""

		while IFS= read -r block; do
			if [[ "$block" == *"[HE>]${DEC_WINDOW}" ]]; then
				XDPH_ID="${block%%"[HC>]"*}"
				break
			fi
		done < <(echo -n "${XDPH_WINDOW_SHARING_LIST//"[HA>]"/$'\n'}")

		if [[ -z "$XDPH_ID" ]]; then
			echo "error" >&2
			exit 1
		fi

		echo "[SELECTION]${SELECTION_FLAGS}/window:${XDPH_ID}"
		;;
	custom)
		MON=$(echo "$line" | jq -r '.result.region.monitor // empty')
		X=$(echo "$line" | jq -r '.result.region.x // empty')
		Y=$(echo "$line" | jq -r '.result.region.y // empty')
		W=$(echo "$line" | jq -r '.result.region.width // empty')
		H=$(echo "$line" | jq -r '.result.region.height // empty')
		if [[ -z "$MON" || -z "$X" || -z "$Y" || -z "$W" || -z "$H" ]]; then
			echo "error" >&2
			exit 1
		fi

		echo "[SELECTION]${SELECTION_FLAGS}/region:${MON}@${X},${Y},${W},${H}"
		;;
	*)
		echo "error" >&2
		exit 1
		;;
	esac

	exit 0

done < <(shiny-shell ipc --any-display listen share-picker result 2>/dev/null)

# Listener exited without delivering our result (shell shutdown, etc.)
echo "cancelled" >&2
exit 1
