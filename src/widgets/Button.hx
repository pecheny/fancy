package widgets;
import input.core.ClicksInputSystem.ClickTargetViewState;
class Button extends ButtonBase {
    var bg:InteractiveBackground;
    public function new(w, h, text, style) {
        super(w, h);
        bg = new InteractiveBackground(w);
        new Label(w, style).withText(text);
    }

    override public function viewHandler(st:ClickTargetViewState):Void {
        bg.viewHandler(st);
    }

}
