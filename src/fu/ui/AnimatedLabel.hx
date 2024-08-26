package fu.ui;

import al.animation.Animation.Animatable;
import gl.sets.MSDFSet;
import htext.ITextRender;
import htext.SmothnessWriter;
import htext.TextRender;
import htext.animation.VUnfoldAnimTextRender;
import a2d.transform.TransformerBase;


using htext.TextTransformer;

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
