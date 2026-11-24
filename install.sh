#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="CallOfTheNight-SDDM"
SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="/usr/share/sddm/themes/${THEME_NAME}"
CONF_FILE="/etc/sddm.conf.d/10-callofthenight.conf"

if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run the installer with sudo:"
    echo "  sudo ./install.sh"
    exit 1
fi

if [[ "${SRC_DIR}" == "${DEST_DIR}" ]]; then
    echo "The theme is already located in ${DEST_DIR}."
else
    echo "Installing to ${DEST_DIR} ..."
    install -d "${DEST_DIR}"
    (
        cd "${SRC_DIR}"
        find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec cp -a {} "${DEST_DIR}/" \;
    )
fi

install -d "$(dirname "${CONF_FILE}")"
if [[ -f "${CONF_FILE}" ]]; then
    cp "${CONF_FILE}" "${CONF_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
fi

cat > "${CONF_FILE}" <<EOF
[Theme]
Current=${THEME_NAME}
EOF

if ! grep -q '^QtVersion=6' "${DEST_DIR}/metadata.desktop" 2>/dev/null; then
    echo
    echo "Warning: metadata.desktop does not declare QtVersion=6." >&2
    echo "SDDM may fall back to the embedded theme on a Qt 6 system." >&2
fi

echo
echo "Done. The theme is enabled in ${CONF_FILE}."
echo "Test it without logging out:"
echo "  sddm-greeter-qt6 --test-mode --theme ${DEST_DIR}"
echo
echo "Apply it on the next login/reboot:"
echo "  systemctl restart sddm"
echo "Warning: this command ends the current graphical session."
