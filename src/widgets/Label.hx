package widgets;
import Axis.ROAxisCollection2D;
import al.al2d.Axis2D;
import al.al2d.Widget2D;
import al.core.AxisApplier;
import crosstarget.Widgetable;
import ec.CtxWatcher;
import FuiBuilder.Size2D;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.sets.MSDFSet;
import htext.style.TextStyleContext;
import htext.TextLayouter;
import htext.TextRender.SmothnessWriter;
import htext.TextRender;
import htext.transform.TextTransformer;
import transform.AspectRatioProvider;
import transform.TransformerBase;

class Label extends Widgetable {
    var textStyleContext:TextStyleContext;
    var text:String = "";
    var render:TextRender<MSDFSet>;
    @:once var aspectRatioProvider:AspectRatioProvider;
    @:once("windowSize") var windowSize:ROAxisCollection2D<Int>;

    public function new(w, tc) {
        this.textStyleContext = tc;
        super(w);
    }

    public function withText(s) {
        text = s;
        if (render!=null)
            render.setText(s);
        return this;
    }

    override function init() {
        var attrs = MSDFSet.instance;
        var l = textStyleContext.createLayouter();
        var dpiWriter = attrs.getWriter(MSDFSet.NAME_DPI);
        TextTransformer.withTextTransform(w, aspectRatioProvider.getFactorsRef(), textStyleContext);
        var tt = w.entity.getComponent(TextTransformer);
        var smothWr = new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, windowSize);
        var aw = new TextAutoWidth(w, l, tt, textStyleContext);
        render = new TextRender(attrs, l, tt, smothWr);
        render.setText(this.text);
        var drawcallsData = DrawcallDataProvider.get(MSDFSet.instance, w.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(render);
        new CtxWatcher(Drawcalls, w.entity);
    }
}

class TextAutoWidth implements AxisApplier {
    var textLayouter:TextLayouter;
    var tr:TransformerBase;
    var ctx:TextStyleContext;

    public function new(w:Widget2D, l:TextLayouter, tr, ctx) {
        this.textLayouter = l;
        this.tr = tr;
        this.ctx = ctx;
        w.axisStates[horizontal].addSibling(this);
    }

    public function apply(pos:Float, size:Float):Void {
        update();
    }

    function update() {
        var val = ctx.getContentSize(horizontal, tr) / ctx.getFontScale(tr);//tr.size[horizontal] / ctx.getFontScale(tr);
        textLayouter.setWidthConstraint(val);
    }

}