package fu.ui;

import a2d.transform.TransformerBase;
import al.animation.Animation.Animatable;
import gl.AttribSet;
import gl.sets.CMSDFSet;
import haxe.io.Bytes;
import htext.AttributeFiller;
import htext.ITextRender;
import htext.SmothnessWriter;
import htext.TextLayouter;
import htext.animation.VUnfoldAnimTextRender;

using htext.TextTransformer;

class AnimatedLabel extends LabelBase<CMSDFSet> implements Animatable {
    public function new(w, tc) {
        super(w, tc, CMSDFSet.instance);
    }

    var _render:VUnfoldAnimTextRender<CMSDFSet>;

    override function createTextRender(attrs:CMSDFSet, l:TextLayouter, tt:TransformerBase):ITextRender<CMSDFSet> {
        var dpiWriter = attrs.getWriter(CMSDFSet.NAME_DPI);
        var wrs = new AttFillContainer();
        wrs.addChild(new SmothnessWriter(dpiWriter[0], l, textStyleContext, tt, stage.getWindowSize()));
        var cw = new TextColorFiller(CMSDFSet.instance, l);
        cw.color = 0xffffff;
        wrs.addChild(cw);
        _render = new VUnfoldAnimTextRender(attrs, l, tt, wrs);
        return _render;
    }

    public function setTime(t:Float):Void {
        _render.setTime(t);
    }
}

class TextColorFiller<T:AttribSet> implements AttributeFiller {
    var attr:T;

    public var color:Int = 0xffffff;

    var layouter:TextLayouter;

    public function new(attrs:T, l) {
        this.attr = attrs;
        this.layouter = l;
    }

    public function write(target:Bytes, start) {
        attr.writeColor(target, color, start, 4 * layouter.getTiles().length);
    }
}
