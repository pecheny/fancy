package fu.ui;

import a2d.transform.TransformerBase;
import al.prop.DepthComponent;
import data.aliases.AttribAliases;
import gl.sets.CMSDFSet;
import htext.AttributeFiller.AttFillContainer;
import htext.TextDepthFiller;
import htext.TextLayouter;
import htext.TextRender;

class DepthCMSDFLabel extends CMSDFLabel {
    @:once var depth:DepthComponent;

    override function createTextRender(attrs:CMSDFSet, l:TextLayouter, tt:TransformerBase):TextRender<CMSDFSet> {
        var rend = super.createTextRender(attrs, l, tt);
        var wrs = entity.getComponent(AttFillContainer);
        var dwr = new TextDepthFiller(attrs.getWriter(AttribAliases.NAME_DEPTH)[0], glyphs);
        function writeDepth() {
            dwr.value = depth.value;
            rend.setDirty(transform);
        }
        depth.onChange.listen(writeDepth);
        wrs.addChild(dwr);
        writeDepth();
        return rend;
    }
}
