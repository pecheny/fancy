package fu.depth;

import ec.PropertyComponent;

class DepthRangeComponent extends PropertyComponent<Float> {
    @:isVar public var maxValue(get, set):Float;
    
    public function new(maxVal) {
        super();
        this.maxValue = maxVal;
    }

    function get_maxValue():Float {
        return maxValue;
    }

    function set_maxValue(maxValue:Float):Float {
        this.maxValue = maxValue;
        onChange.dispatch();
        return maxValue;
    }
}
