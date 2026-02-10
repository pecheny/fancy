package;

import al.layouts.OverlapLayout;
import backends.openfl.OpenflBackend.StageImpl;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;
import a2d.TableWidgetContainer;
import al.core.DataView;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import al.openfl.display.FlashDisplayRoot;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import openfl.display.Sprite;

using a2d.ProxyWidgetTransform;
using a2d.transform.LiquidTransformer;
using al.Builder;

class Demo extends Sprite {
    public function new() {
        super();
        var stage = new StageImpl(1);
        var fui = new FuiBuilder(stage);

        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();

        fui.uikit.configure(root);
        fui.uikit.createContainer(root);
        fui.configureDisplayRoot(root, this);
        var switcher = root.getComponent(WidgetSwitcher);

        var wdg = Builder.widget();

        var gui = new Cont(wdg);
        gui.dc.initData(["foo", "bar", "baz", "buz", "foo", "bar", "baz", "buz"]);
        switcher.switchTo(wdg);
    }
}

@:postInit(initDkit)
class Cont extends BaseDkit {
    static var SRC = <cont vl={PortionLayout.instance}>
        <data-container(b().v(pfr, 1).b()) public id="dc"  itemFactory={() -> new RadioButton(b().h(sfr, 0.2).v(sfr, 0.2).b())}  hl={OverlapLayout.instance}/>
    </cont>

    override function initDkit()
        super.initDkit();
}

class RadioButton extends BaseDkit implements DataView<String> {
    static var SRC = <radio-button hl={PortionLayout.instance}>
    <label(b().h(pfr, .7).b()) id="caption"  text={ "text" }  />
    ${fui.quad(__this__.ph, 0x20000000 + Std.int(Math.random() * 0xffffff))}
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
