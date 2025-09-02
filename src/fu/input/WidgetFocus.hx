package fu.input;

import ec.DebugInit;
import shimp.ClicksInputSystem.ClickTargetViewState;
import shimp.ClicksInputSystem.ClickViewProcessor;
import fu.input.FocusManager;
import fu.input.FocusInputRoot;
import ec.CtxWatcher;
import shimp.Point;
import fu.input.FocusInputRoot.FocusDispatcher;
import a2d.Widget;
import fu.Signal;

class WidgetFocus extends Widget implements FocusDispatcher {
    public var focusRequest(default, null):Signal<Point->Void> = new Signal();
    public var focusReceivedFromPointer(default, null):Signal<Void->Void> = new Signal();

    @:once var stateProcessor:ClickViewProcessor;
    var pos = new Point();

    public function new(ph) {
        super(ph);
        ph.entity.addComponentByType(FocusDispatcher, this);
        ph.entity.addComponent(this);
        new CtxWatcher(FocusInputRoot, entity);
        new CtxWatcher(FocusManager, entity);
        DebugInit.initCheck.listen((_)->trace(stateProcessor, entity.getComponents()));
    }

    override function init() {
        stateProcessor.addHandler(onViewStateChanged);
    }

    function onViewStateChanged(s:ClickTargetViewState) {
        switch s {
            case Hovered, Pressed:
                focusReceivedFromPointer.dispatch();
            case _:
        }
    }

    public function focus() {
        for (a in Axis2D) {
            var as = ph.axisStates[a];
            pos.vec[a] = as.getPos() + as.getSize() / 2;
        }
        pos.x += (Math.random() * 0.001) - 0.0005; // focus changed with keyboard within a scrollbox can keep axact position but still need reevaluation
        focusRequest.dispatch(pos);
    }
}
