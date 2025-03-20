package fu.ui;

import Axis2D;
import htext.TextLayouter;
import htext.Align;
import a2d.Stage;
import ec.CtxWatcher;
import ecbind.RenderableBinder;
import ecbind.RenderablesComponent;
import gl.AttribSet;
import htext.ITextRender;
import htext.TextAutoWidth;
import htext.TextRender;
import htext.style.TextStyleContext;
import a2d.transform.TransformerBase;
import a2d.Widget;

using htext.TextTransformer;

class LabelBase<T:AttribSet> extends Widget {
    var textStyleContext:TextStyleContext;
    var text:String = "";
    var render:ITextRender<T>;
    var attrs:T;
    var layouter:TextLayouter;
    var transformer:TextTransformer;

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

    public function setAlign(?align:Align) {
        transformer.align[horizontal] = align; // if null - the value from ctx used
        if (align == null)
            align = @:privateAccess textStyleContext.align[horizontal];
        layouter.setTextAlign(align);
    }

    override function init() {
        layouter = textStyleContext.createLayouter();
        TextTransformer.withTextTransform(ph, stage.getAspectRatio(), textStyleContext);
        transformer = ph.entity.getComponent(TextTransformer);
        var aw = new TextAutoWidth(ph, layouter, transformer, textStyleContext);
        render = createTextRender(attrs, layouter, transformer);
        var as = new htext.TextAutoScale(ph.entity, transformer, render, aw);
        render.setText(this.text);
        var drawcallsData = RenderablesComponent.get(attrs, ph.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(render);
        new CtxWatcher(RenderableBinder, ph.entity);
    }
}
