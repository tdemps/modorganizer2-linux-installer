#!/usr/bin/env bash

# Add MO2 required winetricks to game_protontricks.
game_protontricks=("fontsmooth=rgb" "${game_protontricks[@]}")

do_wineprefix_work() {
	case "$game_launcher" in
	steam)
		log_info "applying protontricks ${game_protontricks[@]}"
		"$utils/protontricks.sh" apply "$game_steam_id" "${game_protontricks[@]}"
		;;
	heroic)
		(
			log_info "applying winetricks ${game_protontricks[@]}"
			export WINEPREFIX="$heroic_game_wineprefix"
			if [ "$(basename "$heroic_game_wine")" = proton ]; then
				# Proton is a wrapper - find the actual wine executable for winetricks
				export WINE="$(dirname "$heroic_game_wine")/files/bin/wine"
			else
				# User picked a Wine release, not a Proton release
				export WINE="$heroic_game_wine"

			fi
			export executable_winetricks
			"$utils/winetricks.sh" apply "${game_protontricks[@]}"
		)
		;;
	esac | "$dialog" loading "Configuring game prefix\nThis may take a while.\n\nFailure at this step may indicate an issue with Winetricks/Protontricks."
}

if [ "${#game_protontricks[@]}" -gt 0 ]; then
	if ! do_wineprefix_work; then
		confirm_ignore_protontricks=$(
			"$dialog" dangerquestion \
				"Error while installing winetricks, check the terminal for more details. Would you like to ignore this error and continue?"
		)

		if [ "$confirm_ignore_protontricks" != "0" ]; then
			expect_exit=1
			exit 1
		fi

		log_warn "error occurred while running winetricks, user chose to ignore and continue"
	fi
fi
