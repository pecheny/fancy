package fu.graphics;
import a2d.Placeholder2D;
import Axis2D;
import shimp.ClicksInputSystem.ClickTargetViewState;
import mesh.providers.AttrProviders.SolidColorProvider;
import a2d.Widget;
class InteractiveBackground extends Widget {
    var colors:Map<ClickTargetViewState, Int>;
    var bg:ColouredQuad;

    public function new(w:Placeholder2D) {
        super(w);
        colors = ClickColorSet.default_set;
        bg = new ColouredQuad(w, colors[ClickTargetViewState.Idle]);
    }

    public function setColor(c:Int) {
        bg.setColor(c);
    }

    var colorProvider = new SolidColorProvider(0, 0, 0, 128);


    function rewritePos() {
        for (a in Axis2D) {
            var as = w.axisStates[a];
            as.apply(as.getPos(), as.getSize());
        }
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