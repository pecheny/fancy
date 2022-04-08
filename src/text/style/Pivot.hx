package text.style;
import al.al2d.Axis2D;
import transform.TransformerBase;

interface TextPivot {
    public function getPivot(a:Axis2D, transform:TransformerBase, style:TextStyleContext):Float;
}

class ForwardPivot implements TextPivot {
    public function new() { }

    public function getPivot(a:Axis2D, transform:TransformerBase, style:TextStyleContext):Float {
        var offset = 0.;
        if (a == vertical)
            offset += ( style.getFont().getBaseline() );
        return transform.pos[a] + offset * style.getFontScale(transform);
    }
}

class BackwardPivot implements TextPivot {
    public function new() { }

    public function getPivot(a:Axis2D, transform:TransformerBase, style:TextStyleContext):Float {
        return transform.pos[a] + transform.size[a];
    }
}

class MiddlePivot implements TextPivot {
    public function new() {}

    public function getPivot(a:Axis2D, transform:TransformerBase, style:TextStyleContext):Float {
        var offset = 0.;
        if (a == vertical)
            offset = (style.getFontScale(transform) * style.getFont().getBaseline()) / 2;
        return transform.pos[a] + transform.size[a] / 2 + offset;
    }
}
