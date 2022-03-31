package text.style;
import al.al2d.Axis2D;
import FuiBuilder.Size2D;
import haxe.ds.ReadOnlyArray;
import transform.TransformerBase;

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
