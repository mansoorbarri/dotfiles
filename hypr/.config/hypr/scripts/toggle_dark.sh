#!/bin/bash

# Get current GTK color scheme
current=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$current" == "'prefer-dark'" ]]; then
    # Switch to Light Mode

    # GTK gsettings
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'

    # GTK 3.0 settings.ini
    mkdir -p ~/.config/gtk-3.0
    cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-application-prefer-dark-theme=false
gtk-theme-name=Adwaita
EOF

    # GTK 4.0 settings.ini
    mkdir -p ~/.config/gtk-4.0
    cat > ~/.config/gtk-4.0/settings.ini << EOF
[Settings]
gtk-application-prefer-dark-theme=false
gtk-theme-name=Adwaita
EOF

    # Qt5
    sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/qt5ct/colors/airy.conf|' ~/.config/qt5ct/qt5ct.conf

    # Qt6
    sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/airy.conf|' ~/.config/qt6ct/qt6ct.conf

    # Restart portal so Flatpaks pick up the change
    systemctl --user restart xdg-desktop-portal-gtk.service &

    notify-send -t 2000 "Theme" "Switched to Light Mode" -i weather-clear
else
    # Switch to Dark Mode

    # GTK gsettings
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

    # GTK 3.0 settings.ini
    mkdir -p ~/.config/gtk-3.0
    cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-application-prefer-dark-theme=true
gtk-theme-name=Adwaita-dark
EOF

    # GTK 4.0 settings.ini
    mkdir -p ~/.config/gtk-4.0
    cat > ~/.config/gtk-4.0/settings.ini << EOF
[Settings]
gtk-application-prefer-dark-theme=true
gtk-theme-name=Adwaita-dark
EOF

    # Qt5
    sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/qt5ct/colors/darker.conf|' ~/.config/qt5ct/qt5ct.conf

    # Qt6
    sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/qt6ct/colors/darker.conf|' ~/.config/qt6ct/qt6ct.conf

    # Restart portal so Flatpaks pick up the change
    systemctl --user restart xdg-desktop-portal-gtk.service &

    notify-send -t 2000 "Theme" "Switched to Dark Mode" -i weather-clear-night
fi
