package;

import Axis2D;
import a2d.ChildrenPool.DataChildrenPool;
import a2d.ContainerStyler;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;
import a2d.Widget2DContainer;
import al.core.AxisState;
import al.core.DataView;
import al.core.TWidget;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData;
import al.openfl.display.FlashDisplayRoot;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.PropStorage;
import fu.graphics.ColouredQuad;
import fu.ui.ButtonBase;
import fu.ui.Properties;
import openfl.display.Sprite;

using a2d.ProxyWidgetTransform;
using a2d.transform.LiquidTransformer;
using al.Builder;

class GridsDemo extends Sprite {
    public function new() {
        super();
        var fui = new FuiBuilder();

        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();
        root.addComponent(new FlashDisplayRoot(this));

        var uikit = new FlatUikitExtended(fui);
        uikit.configure(root);
        uikit.createContainer(root);

        var switcher = root.getComponent(WidgetSwitcher);

        var wdg = Builder.widget();
        fui.makeClickInput(wdg);
        var axisFac = new Axis2DStateFactory(horizontal, fui.stage);
        var wdc = new GridWidgetContainer(wdg.grantInnerTransformPh(), vertical, [axisFac.create(), axisFac.create(), axisFac.create()], [axisFac.create()]);

        var b = new PlaceholderBuilder2D(fui.ar, true);
        b.keepStateAfterBuild = true;
        b.v(sfr, 0.15).h(sfr, 0.7);

        var gui = new dkit.Dkit.DataContainerDkit(wdg);
        gui.itemFactory = () -> new RadioButton(b.b());
        // new RadioGroup<String, RadioButton>(wdc, (n) -> { new RadioButton(b.b()); });
        gui.initData(["foo", "bar", "baz", "buz", "foo", "bar", "baz", "buz"]);
        // gui.initData(["foo", "bar"]);
        // gui.initData(["foo", "bar", "baz"]);
        switcher.switchTo(wdg);
    }
}

class GridWidgetContainer extends Widget2DContainer {
    var refRow:Array<AxisState>;
    var refCol:Array<AxisState>;
    var direction:Axis2D = horizontal;

    public function new(ph, direction, refRow, refCol) {
        super(ph, 2);
        this.direction = direction;
        for (a in Axis2D) {
            ph.axisStates[a].addSibling(new al.appliers.ContainerRefresher(this));
        }
        this.refRow = childrenAxisStates[direction] = refRow;
        this.refCol = childrenAxisStates[direction.other()] = refCol;
        ph.entity.addComponentByType(Widget2DContainer, this);
        setLayout(horizontal, PortionLayout.instance);
        setLayout(vertical, PortionLayout.instance);
    }

    override public function addChild(child:Placeholder2D) {
        if (children.indexOf(child) > -1)
            throw "Already child";
        var ix = children.length % refRow.length;
        var iy = Math.floor(children.length / refRow.length);
        children.push(child);
        refRow[ix].addSibling(child.axisStates[direction]);
        if (refCol.length <= iy)
            refCol.push(new AxisState(new Position(), new FractionSize(1)));
        refCol[iy].addSibling(child.axisStates[direction.other()]);

        if (refreshOnChildrenChanged) {
            refresh();
        }
    }

    override public function removeChild(child:Placeholder2D) {
        var pos = children.indexOf(child);
        if (pos < 0)
            throw "not a child";
        var toAdd = children.slice(pos + 1);
        while (children.length > pos)
            removeLastChild();
        for (ch in toAdd)
            addChild(ch);
    }

    function removeLastChild() {
        var child = children.pop();
        var ix = children.length % refRow.length;
        var iy = Math.floor(children.length / refRow.length);
        refRow[ix].removeSibling(child.axisStates[direction]);
        refCol[iy].removeSibling(child.axisStates[direction.other()]);
        if (refCol.length > Math.ceil(children.length / refRow.length))
            refCol.pop();
    }
}

class RadioButton extends BaseDkit implements DataView<String> {
    static var SRC = <radio-button hl={PortionLayout.instance}>
    <label(b().h(pfr, .7).b()) id="caption"  text={ "text" }  />
    ${fui.quad(__this__.ph, Std.int(Math.random() * 0xffffff))}
</radio-button>;

    public function new(ph:Placeholder2D, ?parent:BaseDkit) {
        super(ph, parent);
        initComponent();
        initDkit();
    }

    public function initData(descr:String) {
        caption.text = descr;
    }
}
