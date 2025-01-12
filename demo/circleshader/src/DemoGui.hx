package;
import Axis2D;
import a2d.Placeholder2D;
import a2d.transform.WidgetToScreenRatio;
import al.ec.WidgetSwitcher;
import al.layouts.PortionLayout;
import data.IndexCollection;
import data.aliases.AttribAliases;
import dkit.Dkit.BaseDkit;
import ec.Entity;
import fu.Signal;
import fu.graphics.ShapeWidget;
import fu.graphics.Slider;
import gl.AttribSet;
import gl.ValueWriter;
import gl.sets.CircleSet;
import graphics.ShapesColorAssigner;
import graphics.shapes.Shape;
import haxe.ds.ReadOnlyArray;
import haxe.io.Bytes;
import macros.AVConstructor;
import openfl.display.Sprite;

using a2d.transform.LiquidTransformer;
using al.Builder;

class DemoGui extends BaseDkit {
    public var r1Changed:Signal<Float->Void> = new Signal();
    public var r2Changed:Signal<Float->Void> = new Signal();

    static var SRC = <demo-gui hl={PortionLayout.instance}>
        <base(b().h(pfr, 0.25).b()) vl={PortionLayout.instance}>
            <label(b().h(pfr, 1).v(sfr, 0.1).l().b()) text={ "r1, inner radius" }  />
            <base(b().v(sfr,0.05).l().b())>
                ${new Slider(__this__.ph, horizontal, v -> r1Changed.dispatch(v)).withProgress(0.3)}
            </base>
            <label(b().h(pfr, 1).v(sfr, 0.1).l().b())  text={ "r2, outer radius" }  />
            <base(b().v(sfr,0.05).l().b())>
                ${new Slider(__this__.ph, horizontal, v -> r2Changed.dispatch(v)).withProgress(0.9)}
            </base>

        </base>
        <base(b().h(pfr, 1).b()) vl={PortionLayout.instance}>
            <base(b().h(pfr, 1).v(sfr,0.5).l().b()) public id="canvas"></base>
            <base(b().h(pfr, 1).v(sfr,0.5).l().b()) ></base>
        </base>
    </demo-gui>
}
