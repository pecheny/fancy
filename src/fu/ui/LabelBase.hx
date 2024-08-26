package fu.ui;


import a2d.Stage;
import ec.CtxWatcher;
import ecbind.RenderableBinder;
import ecbind.RenderablesComponent;
import gl.AttribSet;
import htext.ITextRender;
import htext.TextAutoWidth;
import htext.TextRender;
import htext.style.TextStyleContext;
import transform.TransformerBase;
import al.al2d.Widget;

using htext.TextTransformer;
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
        TextTransformer.withTextTransform(ph, stage.getAspectRatio(), textStyleContext);
        var tt = ph.entity.getComponent(TextTransformer);
        var aw = new TextAutoWidth(ph, l, tt, textStyleContext);
        render = createTextRender(attrs, l, tt);
        var as = new htext.TextAutoScale(ph.entity, tt, render, aw);
        render.setText(this.text);
        var drawcallsData = RenderablesComponent.get(attrs, ph.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(render);
        new CtxWatcher(RenderableBinder, ph.entity);
    }
}