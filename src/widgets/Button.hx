package widgets;
class Button extends SomeButton {
    public function new(w, h, text, style) {
        super(w, h);
        new Label(w, style).withText(text);
    }
}
