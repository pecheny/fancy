package htext.animation;
class SeqTimeConverter {
    var lastChar = 5;
    var duration = 1;
    inline static var eps = 0.0001;

    public function new(n) {
        this.lastChar = n;
    }

    public function getLocalTime(at, t:Float):Float {
        var partTime = duration / lastChar;
        var startInParent = at * partTime;
        var endInParent = startInParent + partTime;

        if (t > endInParent - eps)
            return 1;
        if (t < startInParent + eps)
            return 0;
        var durationInParent = (endInParent - startInParent);
        return (t - startInParent) / durationInParent;
    }
}
