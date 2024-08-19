package fui.ui;

import fui.graphics.ColouredQuad;

class Button extends ButtonBase {
    public function new(w, h, text, style) {
        super(w, h);
        ColouredQuad.flatClolorQuad(w);
        new Label(w, style).withText(text);
    }
}
