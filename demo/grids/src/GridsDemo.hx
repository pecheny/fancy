package;

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

class GridsDemo extends Sprite {
    public function new() {
        super();
        var stage = new StageImpl(1);
        var fui = new FuiBuilder(stage);

        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();
        root.addComponent(new FlashDisplayRoot(this));

        fui.uikit.configure(root);
        fui.uikit.createContainer(root);

        var switcher = root.getComponent(WidgetSwitcher);

        var wdg = Builder.widget();
        fui.makeClickInput(wdg);
        var axisFac = new Axis2DStateFactory(horizontal, fui.stage);
        var wdc = new TableWidgetContainer(wdg.grantInnerTransformPh(), vertical, [axisFac.create(), axisFac.create(), axisFac.create()], axisFac.create);

        var b = new PlaceholderBuilder2D(fui.stage, true);
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
