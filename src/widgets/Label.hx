package widgets;
import htext.ITextRender;
import gl.AttribSet;
import transform.TransformerBase;
import htext.TextAutoWidth;
import htext.TextTransformer;
import a2d.Stage;
import al.animation.Animation.Animatable;
import ec.CtxWatcher;
import ecbind.DrawcallDataProvider;
import ecbind.Drawcalls;
import gl.sets.MSDFSet;
import htext.animation.VUnfoldAnimTextRender;
import htext.SmothnessWriter;
import htext.style.TextStyleContext;
import htext.TextRender;
import widgets.Widget;
using htext.TextTransformer;

typedef Label = MSDFLabel;

class MSDFLabel extends LabelBase<MSDFSet> {
    public function new(w, tc) {
        createTextRender = _createTextRender;
        super(w, tc, MSDFSet.instance);
    }

    function _createTextRender(attrs:MSDFSet, l, tt:TransformerBase) {
        var dpiWriter = attrs.getWriter(MSDFSet.NAME_DPI);
        var smothWr = new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize());
        return new TextRender(attrs, l, tt, smothWr);
    }
}

class LabelBase<T:AttribSet> extends Widget {
    var textStyleContext:TextStyleContext;
    var text:String = "";
    var render:ITextRender<T>;
    var attrs:T;
    @:once var stage:Stage;

    public function new(w, tc, attrs:T) {
        this.attrs = attrs;
        this.textStyleContext = tc;
        super(w);
    }

    public function withText(s) {
        text = s;
        if (render != null)
            render.setText(s);
        return this;
    }

    dynamic function createTextRender(attrs:T, l, tt:TransformerBase):ITextRender<T> {
        return new TextRender(attrs, l, tt);
    }

    override function init() {
        var l = textStyleContext.createLayouter();
        TextTransformer.withTextTransform(w, stage.getAspectRatio(), textStyleContext);
        var tt = w.entity.getComponent(TextTransformer);
        var aw = new TextAutoWidth(w, l, tt, textStyleContext);
        render = createTextRender(attrs, l, tt);
        render.setText(this.text);
        var drawcallsData = DrawcallDataProvider.get(attrs, w.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(render);
        new CtxWatcher(Drawcalls, w.entity);
    }
}

class AnimatedLabel extends LabelBase<MSDFSet> implements Animatable {
    public function new(w, tc) {
        createTextRender = _createTextRender;
        super(w, tc, MSDFSet.instance);
    }

    var _render:VUnfoldAnimTextRender<MSDFSet>;

    function _createTextRender(attrs:MSDFSet, l, tt:TransformerBase):ITextRender<MSDFSet> {
        var dpiWriter = attrs.getWriter(MSDFSet.NAME_DPI);
        var smothWr = new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize());
        _render = new VUnfoldAnimTextRender(attrs, l, tt, smothWr);
        return _render;
    }

    public function setTime(t:Float):Void {
        _render.setTime(t);
    }
}



