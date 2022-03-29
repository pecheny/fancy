package text.transform;
import FuiBuilder.Size2D;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import FuiBuilder.TextStyleContext;
import haxe.ds.ReadOnlyArray;
import transform.TransformerBase;
using transform.LiquidTransformer.BoundboxConverters;
class TextTransformer extends TransformerBase {
    var textStyleContext:TextStyleContext;

    function new(w, ar, ts) {
        super(ar);
        textStyleContext = ts;
    }

    override public function transformValue(c:Axis2D, input:Float):Float {
        var sign = c == 0 ? 1 : -1;
        var r = sign *
        (
            (textStyleContext.getPivot(c, this) +
            input * textStyleContext.getFontScale(this))
            / aspects.getFactor(c) // aspect ratio correction
            - 1); // gl offset
        return r;
    }

    public static function withTextTransform(w:Widget2D, aspectRatio, style) {
        var transformer = new TextTransformer(w, aspectRatio, style);
        for (a in Axis2D.keys) {
            var applier2 = transformer.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        w.entity.addComponent(transformer);
        return w;
    }
}

interface TextPivot {
    public function getPivot(a:Axis2D, transform:TransformerBase, style:TextStyleContext):Float;
}

class ForwardPivot implements TextPivot {
    public var offset:Float;

    public function new(o) {
        this.offset = o;
    }

    public function getPivot(a:Axis2D, transform:TransformerBase, style:TextStyleContext):Float {
        var offset = this.offset;
        if (a == vertical)
            offset += ( style.getFont().getLineHeight() * style.getFontScale(transform) );
        return transform.pos[a] + offset * style.getFontScale(transform);
    }
}

class MiddlePivot implements TextPivot {
    public function new() {}

    public function getPivot(a:Axis2D, transform:TransformerBase, style:TextStyleContext):Float {
        var offset = 0.;
        if (a == vertical)
            offset = style.getFontScale(transform) / 2;
        return transform.pos[a] + transform.size[a] / 2 + offset;
    }
}


interface FontScale {
    function getValue(tr:TransformerBase):Float;
}

class ScreenPercentHeightFontHeightCalculator implements FontScale {
    var ar:ReadOnlyArray<Float>;
    var base:Float;

    public function new(ar, base = 0.25) {
        this.ar = ar;
        this.base = base;
    }

    public function getValue(tr) {
        return base * ar[vertical];
    }
}

class PixelFontHeightCalculator implements FontScale {
    var ar:ReadOnlyArray<Float>;
    var windowSize:Size2D;
    var px:Int;

    public function new(ar, ws, px) {
        this.ar = ar;
        this.windowSize = ws;
        this.px = px;
    }

    public function getValue(tr):Float {
        return 2 * px * ar[vertical] / windowSize.getValue(vertical);
    }
}

class FitFontScale implements FontScale {
    var base:Float;

    public function new(base) {
        this.base = base;
    }

    public function getValue(tr:TransformerBase):Float {
        return tr.size[vertical] * base;
    }
}
