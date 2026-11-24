//
// Call of the Night — SDDM theme
//
// Based on SDDM Sugar Candy by Marian Arlt (GPL-3.0-or-later)
// and the Makima-SDDM theme by Arnau029.
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or any later version.
//

import QtQuick 2.15
import QtQuick.VirtualKeyboard

InputPanel {
    id: virtualKeyboard
    property bool activated: false
    active: activated && Qt.inputMethod.visible
    visible: active
}
