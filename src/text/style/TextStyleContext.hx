package text.style;
import text.TextLayouter.Align;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
import font.FontInstance;
import font.IFont;
import text.style.Pivot;
import text.style.Scale;
import text.TextLayouter.CharsLayouterFactory;
import transform.TransformerBase;

class TextStyleContext {
    var layouterFactory(default, null):CharsLayouterFactory;
    var font:FontInstance<IFont>;
    var fontScale:FontScale;
    var pivot:AxisCollection2D<TextPivot>;
    var padding:AxisCollection2D<Padding>;
    var align:Align;

    public function new(lf, f, scale, pivot, padding, align = Left) {
        this.layouterFactory = lf;
        this.font = f;
        this.fontScale = scale;
        this.pivot = pivot;
        this.padding = padding;
        this.align = align;
    }

    public function createLayouter() {
        var l = layouterFactory.create();
        l.setTextAlign(align) ;
        return l;
    }

    public function getDrawcallName() {
        return font.getId();
    }

    public function getFont():IFont {
        return font.font;
    }

    public function getFontScale(tr) {
        return fontScale.getValue(tr);
    }

    public function getPivot(a:Axis2D, transform:TransformerBase) {
        var offset = switch a {
            case horizontal :         switch align {
                case Left : padding[a].getMain();
                case Right : padding[a].getSecondary();
                case Center : 0;
            }
            case vertical : padding[a].getMain();
        }

        return offset + pivot[a].getPivot(a, transform, this);
    }

    public function getContentSize(a:Axis2D, transform:TransformerBase) {
        return transform.size[a] - padding[a].getTotal();
    }

}