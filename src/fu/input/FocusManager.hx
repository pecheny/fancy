package fu.input;

import fu.ui.Properties.EnabledProp;
import ec.Component;
import ec.CtxWatcher.CtxBinder;
import ec.Entity;
import fu.input.ButtonSignals;
import fu.input.NavigationButtons;
import fu.input.AutoFocusComponent;

interface FocusManager extends CtxBinder {}

class LinearFocusManager implements FocusManager extends Component {
    public var loop:Bool = true;

    @:once(gen) var input:ButtonSignals<NavigationButtons>;
    var buttons:Array<WidgetFocus> = [];
    var activeButton:Int = -1;
    var autoFocusOn = -1;

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
                traverseButtons(-1);
            case forward:
                traverseButtons(1);
            case _:
        }
    }

    function traverseButtons(delta:Int) {
        if (buttons.length == 0)
            return;
        if (activeButton < 0 && delta < 0)
            activeButton = 0;
        activeButton += delta;
        if (loop)
            activeButton = (activeButton +
                buttons.length) % buttons.length; // assuming delta magnitude not greater number of buttons, sum for cases activeButton < 0
        else
            activeButton = utils.Mathu.clamp(activeButton, 0, buttons.length - 1);
        var toFocus = buttons[activeButton];
        if (toFocus.entity.hasComponent(EnabledProp) && !toFocus.entity.getComponent(EnabledProp).value)
            traverseButtons(delta);
        else
            focusOn(activeButton);
    }

    function focusOn(on:Int) {
        if (on < 0 || on > buttons.length - 1)
            return;
        this.activeButton = on;
        var toFocus = buttons[on];
        toFocus.focus();
    }

    public function bind(e:Entity) {
        var button = e.getComponent(WidgetFocus);
        var autoFocus = e.hasComponent(AutoFocusComponent);
        if (button != null) {
            if (autoFocus)
                autoFocusOn = buttons.length;
            buttons.push(button);
            focusOn(autoFocusOn);
        }
    }

    public function unbind(e:Entity) {
        var button = e.getComponent(WidgetFocus);
        if (button != null) {
            buttons.remove(button);
            focusOn(autoFocusOn);
        }
    }
}
