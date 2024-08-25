package fu.ui;
import al.al2d.Placeholder2D;
import ec.CtxWatcher;
import ec.Entity;
import ecbind.ClickInputBinder;
import shimp.ClicksInputSystem.ClickTarget;
import shimp.ClicksInputSystem.ClickTargetViewState;
import shimp.Point;
import widgets.Widget;
import widgets.utils.WidgetHitTester;

class ButtonBase implements ClickTarget<Point> extends Widget implements ClickViewProcessor {
    var hittester:WidgetHitTester;
    public var clickHandler:Void -> Void;
    var interactives:Array<ClickTargetViewState -> Void> = [];

    public function new(w:Placeholder2D, handler:Void -> Void = null) {
        super(w);
        clickHandler = handler;
        hittester = new WidgetHitTester(w);
        w.entity.addComponentByName(Entity.getComponentId(ClickTarget), this);
        w.entity.addComponentByName(Entity.getComponentId(ClickViewProcessor), this);
        new CtxWatcher(ClickInputBinder, w.entity);
    }

    public function isUnder(pos:Point):Bool {
        return hittester.isUnder(pos);
    }

    public function changeViewState(st:ClickTargetViewState):Void {
        for (iv in interactives)
            iv(st);
    }

    public function handler():Void {
        if (clickHandler != null)
            clickHandler();
    }

    public function addHandler(h:ClickTargetViewState -> Void):Void {
        interactives.push(h);
    }
}
interface ClickViewProcessor {
    function addHandler(h:ClickTargetViewState->Void):Void;
}