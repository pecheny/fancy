package widgets;
import htext.TextAutoWidth;
import htext.TextTransformer;
import a2d.Stage;
import al.animation.Animation.Animatable;
import ec.CtxWatcher;
import gl.ec.DrawcallDataProvider;
import gl.ec.Drawcalls;
import gl.sets.MSDFSet;
import htext.animation.VUnfoldAnimTextRender;
import htext.SmothnessWriter;
import htext.style.TextStyleContext;
import htext.TextRender;
import widgets.Widgetable;
using htext.TextTransformer;

class Label extends Widgetable {
    var textStyleContext:TextStyleContext;
    var text:String = "";
    var render:TextRender<MSDFSet>;
    @:once var stage:Stage;

    public function new(w, tc) {
        this.textStyleContext = tc;
        super(w);
    }

    public function withText(s) {
        text = s;
        if (render != null)
            render.setText(s);
        return this;
    }

    override function init() {
        var attrs = MSDFSet.instance;
        var l = textStyleContext.createLayouter();
        var dpiWriter = attrs.getWriter(MSDFSet.NAME_DPI);
        TextTransformer.withTextTransform(w, stage.getFactorsRef(), textStyleContext);
        var tt = w.entity.getComponent(TextTransformer);
        var smothWr = new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize());
        var aw = new TextAutoWidth(w, l, tt, textStyleContext);
        render = new TextRender(attrs, l, tt, smothWr);
        render.setText(this.text);
        var drawcallsData = DrawcallDataProvider.get(MSDFSet.instance, w.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(render);
        new CtxWatcher(Drawcalls, w.entity);
    }
}

class AnimatedLabel extends Widgetable implements Animatable {
    var textStyleContext:TextStyleContext;
    var text:String = "";
    var render:VUnfoldAnimTextRender<MSDFSet>;
    @:once var stage:Stage;

    public function new(w, tc) {
        this.textStyleContext = tc;
        super(w);
    }

    public function withText(s) {
        text = s;
        if (render != null)
            render.setText(s);
        return this;
    }

    override function init() {
        var attrs = MSDFSet.instance;
        var l = textStyleContext.createLayouter();
        var dpiWriter = attrs.getWriter(MSDFSet.NAME_DPI);
        TextTransformer.withTextTransform(w, stage.getFactorsRef(), textStyleContext);
        var tt = w.entity.getComponent(TextTransformer);
        var smothWr = new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize());
        var aw = new TextAutoWidth(w, l, tt, textStyleContext);
        render = new VUnfoldAnimTextRender(attrs, l, tt, smothWr);
        render.setText(this.text);
        var drawcallsData = DrawcallDataProvider.get(MSDFSet.instance, w.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(render);
        new CtxWatcher(Drawcalls, w.entity);
    }

    public function setTime(t:Float):Void {
        render.setTime(t);
    }
}



