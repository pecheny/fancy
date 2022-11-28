package scroll;
import al.al2d.Placeholder2D;
import al.al2d.Widget2DContainer;
import al.appliers.ContainerRefresher;
import al.Builder;
import al.layouts.data.LayoutData.FixedSize;
import al.layouts.PortionLayout;
import Axis2D;
import widgets.Widget;
import ec.CtxWatcher;
import widgets.utils.WidgetHitTester;
import input.core.InputSystemsContainer;
import input.core.InputSystem;
import ecbind.InputBinder;
import input.core.Point;
import scroll.ScrollboxInput;


class ScrollboxWidget extends Widget implements VisibleSizeProvider {

    var scrollbars:AVector2D<WidgetScrollbar> ;

    public function new(w:Placeholder2D, content:ScrollableContent, ar) {
        super(w);
        trace(w.entity.getChildren().length);
        var hitester = new WidgetHitTester(w);
        new CtxWatcher(InputBinder, w.entity, true); // send upstream to scrollbox
        var inputPassthrough = new InputSystemsContainer(new Point(), hitester);
        inputPassthrough.verbose = true;
        w.entity.addComponentByType(InputSystem, inputPassthrough);
        var binder = new InputBinder(inputPassthrough);
        content.widget().entity.addComponent(binder);
        wireAxis( ar);
        var scrollbox = new ScrollboxInput(content, this, cast scrollbars, hitester, inputPassthrough);
        w.entity.addComponentByType(InputSystemTarget, scrollbox);
    }

    function wireAxis(ar) {
        var child1 = Builder.widget();
        var child2 = Builder.widget(new FixedSize( 0.03), new FixedSize( 0.03));

        var hscroll = scrollbars[horizontal];
        var vscroll = scrollbars[vertical];

        child1.axisStates[horizontal].addSibling(hscroll.widget().axisStates[horizontal]);
        child2.axisStates[vertical].addSibling(hscroll.widget().axisStates[vertical]);

        child2.axisStates[horizontal].addSibling(vscroll.widget().axisStates[horizontal]);
        child1.axisStates[vertical].addSibling(vscroll.widget().axisStates[vertical]);

//        child1.axisStates[horizontal].addSibling(content.widget().axisStates[horizontal]);
//        child1.axisStates[vertical].addSibling(content.widget().axisStates[vertical]);

//        w.entity.addChild(content.widget().entity);
//        w.entity.addChild(hscroll.widget().entity); // todo bind to one entity instead
//        w.entity.addChild(vscroll.widget().entity);
        makeContainer(w, [child1, child2]);
    }

    function makeContainer(w:Placeholder2D, children:Array<Placeholder2D>) {
        var wc = new Widget2DContainer(w, 2);
        for (a in Axis2D) {
            w.axisStates[a].addSibling(new ContainerRefresher(wc));
        }
        w.entity.addComponent(wc);
        wc.setLayout(horizontal, PortionLayout.instance) ;
        wc.setLayout(vertical, PortionLayout.instance) ;
        for (ch in children) {
            wc.entity.addChild(ch.entity);
            wc.addChild(ch);
        }
        return wc;
    }

    public function getVisibleSize(a:Axis2D):Float {
        return w.axisStates[a].getSize();
    }

}

