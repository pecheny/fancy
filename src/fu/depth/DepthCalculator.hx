package fu.depth;

import al.prop.DepthComponent;
import ec.Component;

class DepthCalculator extends Component {
    @:once var depth:DepthComponent;
    @:once var index:ZIndexComponent;
    @:once var range:DepthRangeComponent;

    static var step = 0.0001;

    override function init() {
        super.init();
        index.onChange.listen(onChange);
        range.onChange.listen(onChange);
        onChange();
    }

    function onChange() {
        depth.value = if (index.value < 0) {
            range.maxValue + index.value * step;
        } else {
            range.value + index.value * step;
        }
    }
}
