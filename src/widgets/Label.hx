package widgets;
import algl.TransformatorAxisApplier;
import Axis2D;
import al.al2d.Widget2D;
import al.core.AxisApplier;
import widgets.Widgetable;
import ec.CtxWatcher;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.sets.MSDFSet;
import htext.style.TextStyleContext;
import htext.TextLayouter;
import htext.TextRender.SmothnessWriter;
import htext.TextRender;
import transform.AspectRatioProvider;
import transform.TransformerBase;
using widgets.Label.TextTransformer;

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
class TextTransformer extends TransformerBase {
    var textStyleContext:TextStyleContext;

    function new(w, ar, ts) {
        super(ar);
        textStyleContext = ts;
    }

    override public function transformValue(c:Axis2D, input:Float):Float {
        var sign = c == 0 ? 1 : -1;
        var r = sign *
        (
            (textStyleContext.getPivot(c, this) +
            input * textStyleContext.getFontScale(this))
            / aspects[c] // aspect ratio correction
            - 1); // gl offset
        return r;
    }

    public static function withTextTransform(w:Widget2D, aspectRatio, style) {
        var transformer = new TextTransformer(w, aspectRatio, style);
        for (a in Axis2D) {
            var applier2 = new TransformatorAxisApplier(transformer, a);
            w.axisStates[a].addSibling(applier2);
        }
        w.entity.addComponent(transformer);
        return w;
    }
}
