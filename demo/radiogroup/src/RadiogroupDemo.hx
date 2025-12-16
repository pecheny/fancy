package;

import backends.openfl.OpenflBackend.StageImpl;
import shimp.ClicksInputSystem.ClickViewProcessor;
import ec.Entity;
import al.openfl.display.FlashDisplayRoot;
import al.ec.WidgetSwitcher;
import dkit.Dkit.BaseDkit;
import openfl.display.Sprite;
import a2d.ChildrenPool.DataChildrenPool;
import a2d.ContainerStyler;
import a2d.Placeholder2D;
import a2d.PlaceholderBuilder2D;
import al.core.DataView;
import al.core.TWidget;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.layouts.data.LayoutData;
import fu.PropStorage;
import fu.graphics.ColouredQuad;
import fu.ui.ButtonBase;
import fu.ui.Properties;

using a2d.transform.LiquidTransformer;
using al.Builder;

class RadiogroupDemo extends Sprite {
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
        fui.makeClickInput(wdg);
        var wdc = Builder.createContainer(wdg, vertical, Center);

        // createStyles();
        var b = new PlaceholderBuilder2D(fui.ar, true);
        b.keepStateAfterBuild = true;
        b.v(sfr, 0.15).h(sfr, 0.7);

        var gui = new RadioGroup<String, RadioButton>(wdc, (n) -> {
            new RadioButton(b.b());
        });
        gui.initData(["foo", "bar", "baz"]);
        switcher.switchTo(wdg);
    }


    // function createStyles() {
    //     var default_text_style = "small-text";

    //     var pcStyle = fui.textStyles.newStyle(default_text_style)
    //         .withSize(sfr, .07)
    //         .withPadding(horizontal, sfr, 0.1)
    //         .withAlign(vertical, Center)
    //         .build();

    //     var props = new DummyProps<String>();
    //     props.set(Dkit.TEXT_STYLE, default_text_style);
    //     e.addComponentByType(PropStorage, props);

    //     var distributer = new al.layouts.Padding(new FractionSize(.25), new PortionLayout(Center, new FixedSize(0.1)));
    //     var contLayouts = new ContainerStyler();
    //     contLayouts.reg(GuiStyles.L_HOR_CARDS, distributer, WholefillLayout.instance);
    //     e.addComponent(contLayouts);
    // }
}

class RadioGroup<TData, TWidget:IWidget<Axis2D> & DataView<TData>> extends DataChildrenPool<TData, TWidget> {
    var toggles:Array<CheckedProp> = [];
    var activeId = 0;
    var fac:Int->TWidget;

    public function new(ph, fac) {
        this.fac = fac;
        super(ph, _factory);
    }

    function _factory(n) {
        var wdg = fac(n);
        toggles.push(CheckedProp.getOrCreate(wdg.entity));
        new ButtonBase(wdg.ph, setActiveId.bind(n));
        return wdg;
    }

    public function setActiveId(id:Int) {
        if (toggles.length >= activeId)
            toggles[activeId].value = false;
        activeId = id;
        toggles[activeId].value = true;
    }

    override function initData(descr:Array<TData>) {
        super.initData(descr);
        setActiveId(0);
    }
}

class RadioButton extends BaseDkit implements DataView<String> {
    static var SRC = <radio-button hl={PortionLayout.instance}>
    <label(b().h(pfr, .2).b()) id="status"  text={ "[ ]" }  />
    <label(b().h(pfr, .7).b()) id="caption"  text={ "text" }  />
</radio-button>;

    @:once var vswitcher:ClickViewProcessor;

    var toggle:CheckedProp;
    var clr:ColorToggle;

    public function new(ph:Placeholder2D, ?parent:BaseDkit) {
        super(ph, parent);
        initComponent();
        initDkit();
    }

    override function init() {
        super.init();
        ColouredQuad.flatClolorToggleQuad(ph);
        clr = ph.entity.getComponent(ColorToggle);
        toggle = CheckedProp.getOrCreate(ph.entity);
        toggle.onChange.listen(invalidate);
        invalidate();
    }

    function invalidate() {
        clr.setActive(toggle.value);
        status.text = toggle.value ? "[X]" : "[--]";
    }

    public function initData(descr:String) {
        caption.text = descr;
    }
}
