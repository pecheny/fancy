package fu.input;

import Axis2D;
import al2d.WidgetHitTester2D;
import shimp.Point;
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
    @:once var pointer:MainPointer<Point>;
    var buttons:Array<WidgetFocus> = [];
    var pointerListeners:Map<WidgetFocus, Void->Void> = new Map();
    var activeButton:Int = -1;

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
        this.activeButton = on;
        if (on < 0 || on > buttons.length - 1)
            return;
        var toFocus = buttons[on];
        toFocus.focus();
    }

    function resetFocus() {
        for (i in 0...buttons.length) {
            var button = buttons[i];
            var hits = button.entity.getComponent(WidgetHitTester2D);
            if (hits != null && hits.isUnder(pointer.getPos())) {
                focusOn(i);
                return;
            }
            var autoFocus = button.entity.hasComponent(AutoFocusComponent);
            if(autoFocus) {
                focusOn(i);
                return;
            }
        }
        focusOn(-1);
    }
    
    public function bind(e:Entity) {
        var button = e.getComponent(WidgetFocus);
        if (button != null) {
            var idx = buttons.length;
            var listener = () -> focusOn(buttons.indexOf(button)) ;
            pointerListeners.set(button, listener);
            button.focusReceivedFromPointer.listen(listener);
            buttons.push(button);
            resetFocus();
        }
    }

    public function unbind(e:Entity) {
        var button = e.getComponent(WidgetFocus);
        if (button != null) {
            var listener = pointerListeners.get(button);
            button.focusReceivedFromPointer.remove(listener);
            pointerListeners.remove(button);
            buttons.remove(button);
            resetFocus();
        }
    }
}
