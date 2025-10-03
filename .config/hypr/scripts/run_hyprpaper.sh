# 1. Forcefully kill all hyprpaper processes
pkill -9 hyprpaper

# 2. Add a very brief pause to ensure the kill completes
sleep 0.5

# 3. Start hyprpaper in the background
hyprpaper &

# 4. Wait for the socket to initialize (2 seconds is often safe)
sleep 1

# 5. Run your wallpaper script
~/.dotfiles/.config/hypr/scripts/set_random_wallpaper.sh
