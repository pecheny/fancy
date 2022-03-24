package text.transform;
import transform.TransformerBase;
import FancyPg.Size2D;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import al.appliers.PropertyAccessors.FloatPropertyReader;
import FuiBuilder.TextStyleContext;
import haxe.ds.ReadOnlyArray;
using transform.LiquidTransformer.BoundboxConverters;
class TextTransformer extends TransformerBase {
    var textStyleContext:TextStyleContext;
    var lineHeight:Float;

    function new(w, ar, ts) {
        super(ar);
        textStyleContext = ts;
        lineHeight = textStyleContext.getFont().getLineHeight();
        trace(lineHeight);
    }

    override public function transformValue(c:Axis2D, input:Float):Float {
        var sign = c == 0 ? 1 : -1;
        var offset = c == 0 ? 0 : lineHeight;
        var r = sign *
        (
            (pos[c] + //placeholder position
            ( offset + input ) * textStyleContext.getFontScale()
            ) / aspects.getFactor(c) // aspect ratio correction
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

// todo replace with generalized baseline transformer
class FitOneLineTextTransformer extends TransformerBase {
    var textStyleContext:TextStyleContext;
    var lineHeight:Float;

    function new(w, ar, ts) {
        super(ar);
        textStyleContext = ts;
        lineHeight = textStyleContext.getFont().getLineHeight();
        trace(lineHeight);
    }

    override public function transformValue(c:Axis2D, input:Float):Float {
        var sign = c == 0 ? 1 : -1;
        var offset = c == 0 ? 0 : 2/3;
        var r = sign *
        (
            (offset * size[vertical] + pos[c] + //placeholder position
              input  * size[vertical] * 0.5
            ) / aspects.getFactor(c) // aspect ratio correction
            - 1); // gl offset
        return r;
    }

    public static function withOneLineFit(w:Widget2D, aspectRatio, style) {
        var transformer = new FitOneLineTextTransformer(w, aspectRatio, style);
        for (a in Axis2D.keys) {
            var applier2 = transformer.getAxisApplier(a);
            w.axisStates[a].addSibling(applier2);
        }
        w.entity.addComponent(transformer);
        return w;
    }
}


class ScreenPercentHeightFontHeightCalculator implements FloatPropertyReader {
    var ar:ReadOnlyArray<Float>;
    var base:Float;

    public function new(ar, base = 0.25) {
        this.ar = ar;
        this.base = base;
    }

    public function getValue() {
        return base * ar[vertical];
    }
}


class PixelFontHeightCalculator implements FloatPropertyReader {
    var ar:ReadOnlyArray<Float>;
    var windowSize:Size2D;
    var px:Int;

    public function new(ar, ws, px) {
        this.ar = ar;
        this.windowSize = ws;
        this.px = px;
    }

    public function getValue():Float {
        return 2 * px * ar[vertical] / windowSize.getValue(vertical);
    }
}
