package;

import backends.openfl.OpenflBackend.StageImpl;
import gl.aspects.TransformAspect;
import backends.openfl.DrawcallUtils;
import al.core.AllAxisApplier.AnyAxisApplier;
import gl.aspects.ProjectionMatrixAspect;
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

class TransformDemo extends Sprite {
    var fui:FuiBuilder;

    public function new() {
        super();
        var stage = new StageImpl(1);
        var uikit = new TransformFlatUikit(stage);
        fui = new FuiBuilder(stage, uikit);

        BaseDkit.inject(fui);
        var root:Entity = fui.createDefaultRoot();
        root.addComponent(new FlashDisplayRoot(this));
        uikit.configure(root);
        uikit.createContainer(root);

        root.getComponent(TransformAspect).matrix.appendScale(0.5, 0.5, 0.5);

        var wdg = Builder.widget();
        fui.makeClickInput(wdg);
        var gui = new Gui(wdg);

        // fui.pipeline.createContainer( gui.card.entity, uikit.drawcallsLayout);

        var switcher = root.getComponent(WidgetSwitcher);
        switcher.switchTo(wdg);
    }

    // function createRenderLayer(ph:Placeholder2D) {
    //     // fui.pipeline.addPass("color", new GameRenderPass());
    //     var projAspect = new ProjectionMatrixAspect();
    //     ph.entity.addComponent(projAspect);
    //     for (a in Axis2D)
    //         ph.axisStates[a].addSibling(new AnyAxisApplier(projAspect, a));
    //     fui.pipeline.addAspect(projAspect);
    //     // fui.();
    //     // backends.openfl.DrawcallUtils.createContainer(fui.pipeline, ph.entity, Xml.parse(dl).firstElement());
    // }
}

class Gui extends BaseDkit {
    static var SRC = <gui vl={PortionLayout.instance}>
    <base(b().b()) />
    <base(b().b()) public id="card"> 
        ${fui.quad(__this__.ph, 0xff0000)}
    </base>
    <base(b().b()) />
 </gui>
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
