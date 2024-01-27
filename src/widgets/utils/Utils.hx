package widgets.utils;
import algl.TransformatorAxisApplier;
import transform.LiquidTransformer;
import al.al2d.Placeholder2D;
class Utils {
    public static function withLiquidTransform(w:Placeholder2D, aspectRatio) {
        if (w.entity.hasComponent(LiquidTransformer))
            return w;
        var transformer = new LiquidTransformer(aspectRatio);
        for (a in Axis2D) {
            var applier2 = new TransformatorAxisApplier(transformer, a);
            w.axisStates[a].addSibling(applier2);
        }
        w.entity.addComponent(transformer);
        return w;
    }
}

