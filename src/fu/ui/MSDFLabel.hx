package fu.ui;

import gl.sets.MSDFSet;
import htext.SmothnessWriter;
import htext.TextRender;
import transform.TransformerBase;

using htext.TextTransformer;

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

