package htext;

import al.prop.ScaleComponent;
import ec.Component;

class TextAutoScale extends Component {
    @:once var scale:ScaleComponent;
    var tr:TextTransformer;
    var consumer:htext.ITextRender.ITextConsumer;

    public function new(e, tr, cons) {
        this.tr = tr;
        this.consumer = cons;
        super(e);
    }

    override function init() {
        super.init();
        scale.onChange.listen(onChange);
        onChange();
    }

    function onChange() {
        tr.scale = scale.value;
        consumer.setDirty();
    }
}
