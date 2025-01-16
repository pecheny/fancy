package fu.ui;

import htext.AttributeFiller.AttFillContainer;
import htext.TextColorFiller;
import al.animation.Animation.Animatable;
import gl.sets.CMSDFSet;
import htext.ITextRender;
import htext.SmothnessWriter;
import htext.TextRender;
import htext.animation.VUnfoldAnimTextRender;
import a2d.transform.TransformerBase;


using htext.TextTransformer;

class AnimatedLabel extends LabelBase<CMSDFSet> implements Animatable {
	public function new(w, tc) {
		createTextRender = _createTextRender;
		super(w, tc, CMSDFSet.instance);
	}

	var _render:VUnfoldAnimTextRender<CMSDFSet>;

	function _createTextRender(attrs:CMSDFSet, l, tt:TransformerBase):ITextRender<CMSDFSet> {
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

