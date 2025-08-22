package fu.input;

import ec.Component;
import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import fu.input.ButtonSignals;
import fu.input.NavigationButtons;

interface FocusManager extends CtxBinder {}

class LinearFocusManager implements FocusManager extends Component {
    public var loop:Bool = true;

    var buttons:Array<WidgetFocus> = [];
    @:once(gen) var input:ButtonSignals<NavigationButtons>;

    public function new(ctx:Entity) {
        ctx.addComponentByType(FocusManager, this);
        super(ctx);
    }

    override function init() {
        super.init();
        input.onPress.listen(buttonHandler);
    }

    function buttonHandler(b) {
        switch b {
            case backward:
                gotoButton(-1);
            case forward:
                gotoButton(1);
            case _:
        }
    }

    var activeButton:Int = -1;

    function gotoButton(delta:Int) {
        activeButton += delta;
        if (loop)
            activeButton = (activeButton + buttons.length) % buttons.length; // assuming delta magnitude not greater number of buttons, sum for cases activeButton < 0 
        else
            activeButton = utils.Mathu.clamp(activeButton, 0, buttons.length - 1);
        buttons[activeButton].focus();
    }

    public function bind(e:Entity) {
        var button = e.getComponent(WidgetFocus);
        if (button != null) {
            buttons.push(button);
            activeButton = -1;
        }
    }

    public function unbind(e:Entity) {
        var button = e.getComponent(WidgetFocus);
        if (button != null) {
            buttons.remove(button);
            activeButton = -1;
        }
    }
}
