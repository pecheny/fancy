package htext;
import al.al2d.Placeholder2D;
import al.core.AxisApplier;
import Axis2D;
import htext.style.TextStyleContext;
import transform.TransformerBase;
class TextAutoWidth implements AxisApplier {
    var textLayouter:TextLayouter;
    var tr:TransformerBase;
    var ctx:TextStyleContext;

    public function new(w:Placeholder2D, l:TextLayouter, tr, ctx) {
        this.textLayouter = l;
        this.tr = tr;
        this.ctx = ctx;
        w.axisStates[horizontal].addSibling(this);
    }

    public function apply(pos:Float, size:Float):Void {
        update();
    }

    function update() {
        var val = ctx.getContentSize(horizontal, tr) / ctx.getFontScale(tr);//tr.size[horizontal] / ctx.getFontScale(tr);
        textLayouter.setWidthConstraint(val);
    }

}
