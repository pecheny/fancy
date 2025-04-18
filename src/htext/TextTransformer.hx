package htext;

import a2d.Placeholder2D;
import a2d.transform.TransformatorAxisApplier;
import htext.style.TextStyleContext;
import a2d.transform.TransformerBase;

class TextTransformer extends TransformerBase {
    var textStyleContext:TextStyleContext;

    public var scale:Float = 1;
    public var align:Map<Axis2D, Align> = new Map();

    function new(w, ar, ts) {
        super(ar);
        textStyleContext = ts;
    }

    override public function transformValue(c:Axis2D, input:Float):Float {
        var sign = c == 0 ? 1 : -1;
        var r = sign * ((textStyleContext.getPivot(c, this, align[c]) + input * textStyleContext.getFontScale(this) * scale) / aspects[c] // aspect ratio correction
            - 1); // gl offset
        return r;
    }

    public static function withTextTransform(w:Placeholder2D, aspectRatio, style) {
        var transformer = new TextTransformer(w, aspectRatio, style);
        for (a in Axis2D) {
            var applier2 = new TransformatorAxisApplier(transformer, a);
            w.axisStates[a].addSibling(applier2);
        }
        w.entity.addComponent(transformer);
        return w;
    }
}
