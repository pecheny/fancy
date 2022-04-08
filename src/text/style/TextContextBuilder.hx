package text.style;
import text.h2d.H2dTextLayouter.H2dCharsLayouterFactory;
import text.TextLayouter.Align;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
import font.bmf.BMFont.BMFontFactory;
import font.FontStorage;
import FuiBuilder.StageAspectKeeper;
import text.h2d.H2dTextLayouter.H2dRichCharsLayouterFactory;
import text.style.Padding;
import text.style.Pivot;
import text.style.Scale;
import text.TextLayouter.CharsLayouterFactory;

interface TextContextStorage {
    function getStyle(name:String):TextStyleContext;
}

class TextContextBuilder implements TextContextStorage {
    var ar:StageAspectKeeper;
    var fonts(default, null) = new FontStorage(new BMFontFactory());
    var layouterFactory(default, null):CharsLayouterFactory;
    var fontScale:FontScale;
    var pivot:AxisCollection2D<TextPivot> = new AxisCollection2D();
    var padding:AxisCollection2D<Padding> = new AxisCollection2D();
    var fontName = "";
    var align:Align;

    public function new(fonts:FontStorage, ar) {
        this.fonts = fonts;
        this.ar = ar;
        this.layouterFactory = new H2dRichCharsLayouterFactory(fonts);
        this.fontScale = new FitFontScale(0.75);
        pivot[horizontal] = new ForwardPivot();
        pivot[vertical] = new MiddlePivot();

        padding[horizontal] = new SamePadding(.0);
        padding[vertical] = new SamePadding(.0);
    }

    public function withPivot(a:Axis2D, tp:TextPivot) {
        pivot[a] = tp;
        return this;
    }

    public function withAlign(a:Align) {
        this.align = a;
        pivot[horizontal] =
        switch a {
            case Left: new ForwardPivot();
            case Right: new BackwardPivot();
            case Center: new MiddlePivot();
        }
        return this;
    }

    public function withScale(fs:FontScale) {
        this.fontScale = fs;
        return this;
    }

    public function withFont(name) {
        fontName = name;
        return this;
    }

    public function withSizeInPixels(px:Int) {
        fontScale = new PixelFontHeightCalculator(ar.getFactorsRef(), ar, px);
        return this;
    }

    public function withPercentFontScale(p) {
        fontScale = new ScreenPercentHeightFontHeightCalculator(ar.getFactorsRef(), p);
        return this;
    }

    public function withFitFontScale(p) {
        fontScale = new FitFontScale(p);
        return this;
    }


    // ===== storage ====

    var name = "";
    var styles = new Map<String, TextStyleContext>();

    public function newStyle(name) {
        this.name = name;
        return this;
    }

    public function build() {
        var tc = new TextStyleContext(layouterFactory, fonts.getFont(fontName), fontScale, pivot.copy(), padding.copy(), align);
        if (name != "") {
            styles[name] = tc;
            name = "";
        }
        return tc;
    }

    public function getStyle(name) {
        return styles[name];
    }

}