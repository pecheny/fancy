package ;
import Axis.ROAxisCollection2D;
import algl.Builder.PlaceholderBuilderGl;
import al.Builder as WB;
import al.openfl.StageAspectResizer;
import ec.Entity;
import FuiBuilder;
import openfl.display.Sprite;
import transform.AspectRatioProvider;
import widgets.Label;
import algl.WidgetSizeTypeGl;
using al.Builder ;
class NewBuilder extends FuiAppBase {
    public function new() {
        super();
        var root:Entity = new Entity();
        var ar = fuiBuilder.ar;
//        fuiBuilder.addBmFont("", "Assets/heaps-fonts/monts.fnt"); // todo
        fuiBuilder.addBmFont("", "Assets/heaps-fonts/robo.fnt"); // todo
        root.addComponentByName(Entity.getComponentId(AspectRatioProvider), fuiBuilder.ar);
//        root.addComponentByType(Size2D, fuiBuilder.ar);
        root.addComponentByName(Entity.getComponentId(ROAxisCollection2D) + "_windowSize", fuiBuilder.ar.getWindowSize());
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

        var pb = new PlaceholderBuilderGl(ar);
        var rw = WB.h().withChildren([ new Label(pb.v(sfr, 0.5).h(px, 120).b(), style).withText("Foo:").widget()]);
        root.addChild(rw.entity);
        new StageAspectResizer(rw, 2);
    }
}

