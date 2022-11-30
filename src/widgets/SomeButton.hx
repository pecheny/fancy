package widgets;
import Axis2D;
import al.al2d.Placeholder2D;
import widgets.Widget;
import ec.CtxWatcher;
import ec.Entity;
import widgets.utils.WidgetHitTester;
import shimp.ClicksInputSystem.ClickTarget;
import shimp.ClicksInputSystem.ClickTargetViewState;
import ecbind.ClickInputBinder;
import widgets.utils.WidgetHitTester.Point;
import mesh.providers.AttrProviders.SolidColorProvider;
class SomeButton implements ClickTarget<Point> extends Widget {
    var hittester:WidgetHitTester;
    public var clickHandler:Void -> Void;
    var colors:Map<ClickTargetViewState, Int>;
    var bg:ColouredQuad;

    public function new(w:Placeholder2D, handler:Void -> Void = null) {
        super(w);
        colors = ClickColorSet.default_set;
        bg = new ColouredQuad(w, colors[ClickTargetViewState.Idle]);
        clickHandler = handler;
        hittester = new WidgetHitTester(w);
        w.entity.addComponentByName(Entity.getComponentId(ClickTarget), this);
        new CtxWatcher(ClickInputBinder, w.entity);
        this.w = w;
    }

    public function setColor(c:Int) {
        bg.setColor(c);
    }


    public function isUnder(pos:Point):Bool {
        return hittester.isUnder(pos);
    }

    var colorProvider = new SolidColorProvider(0, 0, 0, 128);


    function rewritePos() {
        for (a in Axis2D) {
            var as = w.axisStates[a];
            as.apply(as.getPos(), as.getSize());
        }
    }

    public function handler():Void {
        if (clickHandler != null)
            clickHandler();
    }

    public function viewHandler(st:ClickTargetViewState):Void {
        switch st {
            case Idle : release();
            case Pressed : press();
            case PressedOutside : press();
            case Hovered : release();
        }
        setColor(colors[st]);
    }



    function press():Void {
        var ox = 0.005 / w.axisStates[horizontal].getSize();
        var oy = 0.005 / w.axisStates[vertical].getSize();
        @:privateAccess bg.transformer.setBounds(ox, oy, 1 + ox * 2, 1 + oy * 2);
        rewritePos();
    }

    function release():Void {
//        if (!inited)
//            return;
        @:privateAccess bg.transformer.setBounds(0, 0, 1, 1);
        rewritePos();
    }
}

class ClickColorSet {
    @:isVar public static var default_set(default, null):Map<ClickTargetViewState, Int> = [
        Idle => 0xff0000,
        Hovered => 0xffa0a0,
        Pressed => 0xffa0a0,
        PressedOutside => 0xff0000,
    ];
}