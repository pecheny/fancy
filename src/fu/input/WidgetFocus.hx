package fu.input;

import fu.input.FocusManager;
import fu.input.FocusInputRoot;
import ec.CtxWatcher;
import shimp.Point;
import fu.input.FocusInputRoot.FocusDispatcher;
import a2d.Widget;
import fu.Signal;

class WidgetFocus extends Widget implements FocusDispatcher {
    var pos = new Point();
    public var focusRequest(default, null):Signal<Point->Void> = new Signal();
    public function new(ph) {
        super(ph);
        ph.entity.addComponentByType(FocusDispatcher, this);
        ph.entity.addComponent(this);
        new CtxWatcher(FocusInputRoot, entity);
        new CtxWatcher(FocusManager, entity);
    }
    
    public function focus() {
        for (a in Axis2D) {
            var as = ph.axisStates[a];
            pos.vec[a] = as.getPos() + as.getSize() / 2;
        }
        focusRequest.dispatch(pos);
    }
}
