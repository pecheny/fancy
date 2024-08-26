package htext;
import al.al2d.Placeholder2D;
import al.core.AxisApplier;
import Axis2D;
import htext.style.TextStyleContext;
import a2d.transform.TransformerBase;
class TextAutoWidth implements AxisApplier {
    var textLayouter:TextLayouter;
    var tr:TextTransformer;
    var ctx:TextStyleContext;

    public function new(w:Placeholder2D, l:TextLayouter, tr:TextTransformer, ctx) {
        this.textLayouter = l;
        this.tr = tr;
        this.ctx = ctx;
        w.axisStates[horizontal].addSibling(this);
        w.axisStates[vertical].addSibling(this);
        // ? valign-related fix
    }

    public function apply(_:Float, _:Float):Void {
        update();
    }

    function update() {
        var val = ctx.getContentSize(horizontal, tr) / (ctx.getFontScale(tr) );//tr.size[horizontal] / ctx.getFontScale(tr);
        textLayouter.setWidthConstraint(val / tr.scale);
    }

}
