package fu.ui;

import htext.AutoSize;
import gl.sets.CMSDFSet;
import a2d.transform.LiquidTransformer;
import a2d.Widget2DContainer;
import al.appliers.ContainerRefresher;
import al.core.WidgetContainer.Refreshable;
import a2d.Placeholder2D;
import al.layouts.data.LayoutData.FixedSize;
import al.core.ResizableWidget;
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
import ec.Signal;

using htext.TextTransformer;

class LabelBase<T:AttribSet> extends Widget implements ResizableWidget2D implements Refreshable {
    var textStyleContext:TextStyleContext;
    var text:String = "";
    var render:ITextRender<T>;
    var attrs:T;
    var layouter:TextLayouter;
    var transformer:TextTransformer;
    var vsize:FixedSize;
    var mode:AutoSize;

    @:once var stage:Stage;

    public var contentSizeChanged(default, null):Signal<Axis2D->Void> = new Signal();

    public function getContentSize(a:Axis2D):Float {
        if (layouter == null)
            return 0;
        return layouter.getContentSize(a) * getFontScale();
    }

    public function getFontScale() {
        return textStyleContext.getFontScale(transformer);
    }

    public function new(ph:Placeholder2D, tc, attrs:T) {
        this.attrs = attrs;
        this.textStyleContext = tc;
        // wrong, nullref before super(ph)
        // if (textStyleContext.autoSize)
        //     enableAutoSize();
        super(ph);
    }


    public function setAutoSizeMode(mode:AutoSize) {
        switch mode {
            case none:
            case word_wrap:
                ph.axisStates[horizontal].addSibling(new ContainerRefresher(this));
            case word_wrap_auto_height:
                vsize = new FixedSize(0);
                @:privateAccess ph.axisStates[vertical].size = vsize;
                ph.axisStates[horizontal].addSibling(new ContainerRefresher(this));
        }
        this.mode = mode;
    }

    public function withText(s) {
        text = s;
        if (render == null)
            return this;
        render.setText(s);
        updateSize();
        return this;
    }

    function createTextRender(attrs:T, l:TextLayouter, tt:TransformerBase):ITextRender<T> {
        return new TextRender(attrs, l, tt, null);
    }

    public function setAlign(?align:Align) {
        transformer.align[horizontal] = align; // if null - the value from ctx used
        if (align == null)
            align = @:privateAccess textStyleContext.align[horizontal];
        layouter.setTextAlign(align);
    }

    function createLayouter() {
        return textStyleContext.createLayouter();
    }

    public function refresh() {
        updateSize();
    }

    function updateWordWrap() {
        var ctx = textStyleContext;
        var tr = transformer;
        layouter.setText(text);
        var val = ctx.getContentSize(horizontal, tr) / (ctx.getFontScale(tr));
        layouter.setWidthConstraint(val / tr.scale);
    }
    
    public function setDirty(level:Dirty = full) {
        render.setDirty(level); // ??
    }

    function updateSize() {
        if (!_inited)
            return;
        if (mode == none)
            return;
        updateWordWrap();
        if (mode == word_wrap)
            return;
        render.setDirty(full); // ??
        updateVertSize();
    }

    function updateVertSize() {
        var old = @:privateAccess vsize.value;
        var newv = layouter.getContentSize(vertical) * getFontScale();
        @:privateAccess vsize.value = newv;
        if (old != newv)
            contentSizeChanged.dispatch(vertical);
    }

    override function init() {
        layouter = createLayouter();
        TextTransformer.withTextTransform(ph, stage.getAspectRatio(), textStyleContext);
        transformer = ph.entity.getComponent(TextTransformer);
        LiquidTransformer.withLiquidTransform(ph, stage.getAspectRatio());

        var ltransformer = ph.entity.getComponent(LiquidTransformer);
        render = createTextRender(attrs, layouter, ltransformer);
        var crender:TextRender<CMSDFSet> = cast render;
        @:privateAccess crender.textTr = transformer;

        var as = new htext.TextAutoScale(ph.entity, transformer, render);
        render.setText(this.text);
        updateSize();
        var drawcallsData = RenderablesComponent.get(attrs, ph.entity, textStyleContext.getDrawcallName());
        drawcallsData.views.push(render);
        new CtxWatcher(RenderableBinder, ph.entity);
    }
}
