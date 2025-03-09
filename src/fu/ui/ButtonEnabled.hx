package fu.ui;

import a2d.Placeholder2D;
import fu.ui.ButtonBase;
import fu.ui.Properties;
import shimp.ClicksInputSystem.ClickTargetViewState;

class ButtonEnabled extends ButtonBase {
    var toggle:EnabledProp;

    public function new(w:Placeholder2D, h) {
        toggle = EnabledProp.getOrCreate(w.entity);
        super(w, h);
        toggle.onChange.listen(set_active);
        set_active();
    }

    override function handler() {
        if (!toggle.value)
            return;
        super.handler();
    }

    var st:ClickTargetViewState = ClickTargetViewState.Idle;

    override function changeViewState(st:ClickTargetViewState) {
        this.st = st;
        super.changeViewState(toggle.value ? st : Idle);
    }

    function set_active() {
        changeViewState(st);
    }
}
