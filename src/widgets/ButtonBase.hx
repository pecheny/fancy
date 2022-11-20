package widgets;
import al.al2d.Widget2D;
import ec.CtxWatcher;
import ec.Entity;
import input.al.WidgetHitTester;
import input.core.ClicksInputSystem.ClickTarget;
import input.core.ClicksInputSystem.ClickTargetViewState;
import input.ec.binders.ClickInputBinder;
import input.Point;
import widgets.Widgetable;
class ButtonBase implements ClickTarget<Point> extends Widgetable {
    var hittester:WidgetHitTester;
    public var clickHandler:Void -> Void;

    public function new(w:Widget2D, handler:Void -> Void = null) {
        super(w);
        clickHandler = handler;
        hittester = new WidgetHitTester(w);
        w.entity.addComponentByName(Entity.getComponentId(ClickTarget), this);
        new CtxWatcher(ClickInputBinder, w.entity);
        this.w = w;
    }

    public function isUnder(pos:Point):Bool {
        return hittester.isUnder(pos);
    }

    public function viewHandler(st:ClickTargetViewState):Void {
        throw "Do implement viewHandler, ButtonBase is kinda abstract";
    }

    public function handler():Void {
        if (clickHandler != null)
            clickHandler();
    }
}