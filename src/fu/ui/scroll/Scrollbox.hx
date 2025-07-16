package fu.ui.scroll;

import Axis2D;
import a2d.Placeholder2D;
import a2d.Widget2DContainer;
import a2d.Widget;
import al.Builder;
import al.appliers.ContainerRefresher;
import al.core.WidgetContainer.Refreshable;
import al.layouts.PortionLayout;
import al.layouts.data.LayoutData.FixedSize;
import al2d.WidgetHitTester2D;
import ec.CtxWatcher;
import ecbind.InputBinder;
import fu.ui.scroll.ScrollableContent.Scrollable;
import fu.ui.scroll.ScrollboxInput;
import macros.AVConstructor;
import openfl.events.MouseEvent;
import shimp.InputSystem;
import shimp.InputSystemsContainer;
import shimp.Point;

class ScrollboxWidget extends Widget implements VisibleSizeProvider implements Refreshable implements Scrollable {
    var scrollbars:AVector2D<WidgetScrollbar>;
    var content:ScrollableContent;
    var offsets:AVector2D<Float>;
    var scrollbox:ScrollboxInput;

    public function new(w:Placeholder2D, content:ScrollableContent, ar) {
        super(w);
        this.content = content;
        var hitester = new WidgetHitTester2D(w);
        new CtxWatcher(InputBinder, w.entity, true); // send upstream to scrollbox
        var inputPassthrough = new InputSystemsContainer(new Point(), hitester);
        inputPassthrough.verbose = true;
        w.entity.addComponentByType(InputSystem, inputPassthrough);
        var binder = new InputBinder(inputPassthrough);
        content.ph.entity.addComponent(binder);
        wireAxis(ar);
        offsets = AVConstructor.create(0, 0);
        scrollbox = new ScrollboxInput(this, hitester, inputPassthrough);
        w.entity.addComponentByType(InputSystemTarget, scrollbox);
        w.axisStates[vertical].addSibling(new ContainerRefresher(this));
        w.entity.addComponentByType(Scrollable, this);
    }


    public function setOffset(a, val):Float {
        var offset = content.setOffset(a, val);
        offsets[a] = offset;
        var cs = content.getContentSize(a);
        var vs = getVisibleSize(a);
        var hndlSize = if (cs > vs) vs / cs else 0;
        scrollbars[a].setHandlerSize(hndlSize);
        scrollbars[a].setHandlerPos(-offset / (cs - vs));
        return offset;
    }

    function wireAxis(ar) {
        var child1 = Builder.widget();
        var child2 = Builder.widget(new FixedSize(0.03), new FixedSize(0.03));

        var hscroll = scrollbars[horizontal];
        var vscroll = scrollbars[vertical];

        child1.axisStates[horizontal].addSibling(hscroll.ph.axisStates[horizontal]);
        child2.axisStates[vertical].addSibling(hscroll.ph.axisStates[vertical]);

        child2.axisStates[horizontal].addSibling(vscroll.ph.axisStates[horizontal]);
        child1.axisStates[vertical].addSibling(vscroll.ph.axisStates[vertical]);

        //        child1.axisStates[horizontal].addSibling(content.widget().axisStates[horizontal]);
        //        child1.axisStates[vertical].addSibling(content.widget().axisStates[vertical]);

        //        w.entity.addChild(content.widget().entity);
        ph.entity.addChild(hscroll.ph.entity); // todo bind to one entity instead
        ph.entity.addChild(vscroll.ph.entity);
        makeContainer(ph, [child1, child2]);
    }

    function makeContainer(w:Placeholder2D, children:Array<Placeholder2D>) {
        var wc = new Widget2DContainer(w, 2);
        for (a in Axis2D) {
            w.axisStates[a].addSibling(new ContainerRefresher(wc));
        }
        w.entity.addComponent(wc);
        wc.setLayout(horizontal, PortionLayout.instance);
        wc.setLayout(vertical, PortionLayout.instance);
        for (ch in children) {
            wc.entity.addChild(ch.entity);
            wc.addChild(ch);
        }
        return wc;
    }

    public function getVisibleSize(a:Axis2D):Float {
        return ph.axisStates[a].getSize();
    }

    public function refresh() {
        for (a in Axis2D) {
            setOffset(a, getOffset(a));
        }
    }

    public function getOffset(a:Axis2D):Float {
        return offsets[a];
    }
}
