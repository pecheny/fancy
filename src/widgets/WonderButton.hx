package widgets;
import widgets.Label.AnimatedLabel;
import widgets.ButtonBase.ClickViewProcessor;
import widgets.ColouredQuad;
import al.animation.Animation.AnimWidget;
import al.animation.AnimationTreeBuilder;
import data.aliases.AttribAliases;
import gl.AttribSet;
import gl.sets.ColorSet;
import graphics.shapes.Bar.BarAxisSlot;
import graphics.shapes.Bar.BarContainer;
import graphics.shapes.Bar;
import graphics.ShapesBuffer;
import mesh.providers.AttrProviders.SolidColorProvider;
class WonderButton extends ButtonBase {
    var tree:AnimWidget;

    public function new(w, h, text, style) {
        super(w, h);

        var elements = [
            new BarContainer(Portion(new BarAxisSlot ({start:0., end:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)) ),
            new BarContainer(FixedThikness(new BarAxisSlot ({pos:0., thikness:1.}, null)), Portion(new BarAxisSlot ({start:0., end:1.}, null)))
        ];
        var bg = new BarWidget(ColorSet.instance, w, elements);
         new BColors(ColorSet.instance, bg, 1).colorizeQuad(0);
        var colors = new BColors(ColorSet.instance, bg, 0);
        var viewProc:ClickViewProcessor = w.entity.getComponent(ClickViewProcessor);
        if (viewProc!=null) {
            viewProc.addHandler(new InteractiveColors(colors.colorizeQuad).viewHandler);
//            viewProc.addHandler(new InteractiveTransform(w).viewHandler);
        }

        var lbl = new AnimatedLabel(w, style);
        lbl.withText(text);

        tree = new AnimationTreeBuilder().build(
            { layout:"wholefill",
                children:[ {
                    layout:"portion",
                    children:[
                        {size:{value:.4 }},
                        {size:{value:1. }},
                    ]
                } ] }
        );
        tree.bindDeep([0, 0], BarAnimationUtils.directUnfold(elements[1]));
        tree.bindDeep([0, 1], BarAnimationUtils.directUnfold(elements[0]));
        tree.bindDeep([0, 1], lbl.setTime);
    }

    public function setTime(t):Void {
        tree.setTime(t);
    }
}


class BColors<T:AttribSet> {
    var attrs:T;
    var buffer:ShapesBuffer<T>;
    var n:Int;
    var color:Int = -1;

    public function new(attrs, bars:BarWidget<T>, n):Void {
        this.attrs = attrs;
        this.buffer = bars.getBuffer();
        this.n = n;
        buffer.onInit.listen(() -> {
            if (color > -1)
                colorizeQuad(color);
        });
    }

    public function colorizeQuad(color) {
        this.color = color;
        if (!buffer.isInited())
            return;
        attrs.writeColor(buffer.getBuffer(), color, n * 4, 4);
    }
}

class BarsColorAssigner<T:AttribSet> {
    var attrs:T;
    var cp:SolidColorProvider;
    var buffer:ShapesBuffer<T>;
    var colors:Array<Int>;


    public function new(attrs, color, buffer):Void {
        this.attrs = attrs;
        this.colors = color;
        this.buffer = buffer;
        cp = new SolidColorProvider(0, 0, 0);
        this.buffer.onInit.listen(fillBuffer);
    }

    function fillBuffer() {
        if (!buffer.isInited())
            return;
        var writers = attrs.getWriter(AttribAliases.NAME_COLOR_IN);
        var quadsCount = Std.int(buffer.getVertCount() / 4);
        for (q in 0...quadsCount) {
            var color = q < colors.length ? colors[q] : colors[colors.length - 1];
            cp.setColor(color);
            for (v in 0...4)
                for (w in 0...writers.length)
                    writers[w].setValue(buffer.getBuffer(), q * 4 + v, cp.getValue(0, w));
        }
//        MeshUtilss.writeInt8Attribute(attrs, buffer.getBuffer(), AttribAliases.NAME_COLOR_IN, 0, buffer.getVertCount(), cp.getValue);
    }

}
