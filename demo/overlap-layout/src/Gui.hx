// import bindings.GL;
import fu.graphics.DepthAssigner;
import al.prop.DepthComponent;
import gl.sets.ColorSet;
import openfl.filters.ShaderFilter;
import openfl.display3D.Context3DCompareMode;
import openfl.geom.Matrix3D;
import data.aliases.AttribAliases;
import ec.PropertyComponent;
import ec.Component;
import graphics.ShapesBuffer;
import gl.AttribSet;
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

@:postInit(initDkit)
class Cont extends BaseDkit {
    static var SRC = <cont vl={PortionLayout.instance}>
        <data-container(b().v(pfr, 1).b()) public id="dc" inputFactory={inputFactory}  itemFactory={() -> new RadioButton(b().h(sfr, 0.3).v(sfr, 0.2).b())}  hl={OverlapLayout.instance}/>
    </cont>

    public function inputFactory(ph:Placeholder2D, n:Int) {
        var depth = DepthComponent.getOrCreate(ph.entity);
        depth.value = 0.8 - n / 10;
        // depth.value = n / 100;
    }

    override function initDkit()
        super.initDkit();
}

class RadioButton extends BaseDkit implements DataView<String> {
    static var SRC = <radio-button hl={PortionLayout.instance}>
    <label(b().h(pfr, .7).b()) id="caption"  text={ "text" } style={"fit"} />
    ${quad(__this__.ph, 0xFF000000 + Std.int(Math.random() * 0xffffff))}
</radio-button>;

    public function new(ph:Placeholder2D, ?parent:BaseDkit) {
        super(ph, parent);
        initComponent();
        initDkit();
    }

    public function quad(ph:Placeholder2D, color) {
        fui.lqtr(ph);
        var attrs = ColorSet.instance;
        var shw = new fu.graphics.ShapeWidget(attrs, ph, true);
        shw.addChild(new graphics.shapes.QuadGraphicElement(attrs));
        var colors = new graphics.ShapesColorAssigner(attrs, color, shw.getBuffer());
        var depth = new DepthAssigner(attrs, shw.getBuffer());
        ph.entity.addComponent(colors);
        ph.entity.addComponent(depth);
        shw.manInit();
        return shw;
    }

    public function initData(descr:String) {
        caption.text = descr;
    }
}
