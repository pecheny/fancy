package ;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import al.al2d.Widget2DContainer;
import al.appliers.ContainerRefresher;
import al.core.AxisCollection;
import al.core.AxisState;
import al.layouts.data.LayoutData.Position;
import al.layouts.data.LayoutData.Size;
import al.layouts.data.LayoutData.SizeType;
import al.layouts.PortionLayout;
import al.layouts.WholefillLayout;
import al.openfl.StageAspectResizer;
import ec.Entity;
import FuiBuilder;
import openfl.display.Sprite;
import transform.AspectRatioProvider;
import widgets.Label;
using NewBuilder.WB;
class NewBuilder extends FuiAppBase {
    public function new() {
        super();
        var root:Entity = new Entity();
        var ar = fuiBuilder.ar;
//        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt"); // todo
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), fuiBuilder.ar);
        root.addComponentByType(Size2D, fuiBuilder.ar);
        fuiBuilder.configureInput(root);

        var dl =
        '<container>
        <drawcall type="color"/>
        <drawcall type="text" font=""/>
        </container>';
        fuiBuilder.createContainer(root, Xml.parse(dl).firstElement());
        var container:Sprite = root.getComponent(Sprite);
        for (i in 0...container.numChildren) {
            trace(container.getChildAt(i));
        }
        addChild(container);

        var style = fuiBuilder.textStyles.newStyle("")
        .build();
        var rw = WB.h().withChildren([ new Label(WB.widget(), style).withText("Foo:").widget()]);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
    }
}

class WB {
    public static inline function widget(xtype:SizeType = SizeType.portion, xsize = 1., ytype = SizeType.portion, ysize = 1.):Widget2D {
        var entity = new Entity();
        var axisStates = new AxisCollection<Axis2D, AxisState>();
        axisStates[horizontal] = new AxisState(new Position(), new Size(xtype, xsize ));
        axisStates[vertical] = new AxisState(new Position(), new Size(ytype, ysize ));
        var w = new Widget2D(axisStates);
        entity.addComponent(w);
        return w;
    }


    public static function createContainer(w:Widget2D, alignment):Widget2DContainer {
        var wc = new Widget2DContainer(w);
        for (a in Axis2D.keys) {
            w.axisStates[a].addSibling(new ContainerRefresher(wc));
        }
        w.entity.addComponent(wc);
        alignContainer(wc, alignment);
        return wc;
    }

    public static function alignContainer(wc:Widget2DContainer, align:Axis2D):Widget2DContainer {
        for (axis in Axis2D.keys) {
            wc.setLayout(axis,
            if (axis == align)
                PortionLayout.instance
            else
                WholefillLayout.instance
            );
        };
        return wc;
    }

    public static function v(xtype:SizeType = SizeType.portion, xsize = 1., ytype = SizeType.portion, ysize = 1.) {
        return createContainer(widget(xtype, xsize, ytype, ysize), vertical);
    }

    public static function h(xtype:SizeType = SizeType.portion, xsize = 1., ytype = SizeType.portion, ysize = 1.) {
        return createContainer(widget(xtype, xsize, ytype, ysize), horizontal);
    }

    public static function withChildren(c:Widget2DContainer, children:Array<Widget2D>):Widget2D {
        for (ch in children)
            addWidget(c, ch);
        return c.widget();
    }

    public static function addWidget(wc:Widget2DContainer, w:Widget2D) {
        wc.addChild(w);
        wc.entity.addChild(w.entity);
    }

}