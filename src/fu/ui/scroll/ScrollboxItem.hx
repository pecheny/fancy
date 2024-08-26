package fu.ui.scroll;
import macros.AVConstructor;
import Axis2D;
import al.al2d.Placeholder2D;
import al.Builder;
import fu.ui.scroll.Scrollbox.ScrollboxWidget;

using transform.LiquidTransformer;
class ScrollboxItem extends ScrollboxWidget {


    public function new(w:Placeholder2D, content:ScrollableContent, ar) {


        var vscroll = new FlatScrollbar(Builder.widget().withLiquidTransform(ar), ar, vertical);
        var hscroll = new FlatScrollbar(Builder.widget().withLiquidTransform(ar), ar, horizontal);
        scrollbars = AVConstructor.create(hscroll, vscroll);
        super(w, content, ar);
//        bg(w.entity, ar);
    }
}