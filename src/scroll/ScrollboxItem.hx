package scroll;
import al.al2d.Axis2D;
import al.al2d.Widget2D.AxisCollection2D;
import al.al2d.Widget2D;
import al.Builder;
import scroll.Scrollbox.ScrollboxWidget;

class ScrollboxItem extends ScrollboxWidget {

    public function new(w:Widget2D, content:ScrollableContent, ar) {


        var vscroll = new FlatScrollbar(Builder.widget(), ar, vertical);
        var hscroll = new FlatScrollbar(Builder.widget(), ar, horizontal);
        scrollbars = new AxisCollection2D();
        scrollbars[horizontal] = hscroll;
        scrollbars[vertical] = vscroll;
        super(w, content, ar);
//        bg(w.entity, ar);
    }
}