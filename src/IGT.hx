package ;


import al.al2d.Axis2D;
import al.core.AxisApplier;
interface IGraphicsTransform {
    public function applyTransform(a:Axis2D, tr:Float -> Float):Void;
}

interface IGraphicsTransformApplier {
    public function addChild<T:IGraphicsTransform>(tr:T):T;

    public function getAxisApplier(a:Axis2D):AxisApplier;
}
