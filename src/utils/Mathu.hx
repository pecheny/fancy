package utils;
class Mathu {
    public static inline function clamp<T:Float>(val:T, min:T, max:T):T {
        return
            if (val < min)
                min;
            else if(val > max)
                max;
            else val;
    }

    public static inline function min<T:Float>(a:T, b:T):T {
        return cast Math.min(a,b);
    }

    public static inline function max<T:Float>(a:T, b:T):T {
        return cast Math.max(a,b);
    }

    public static inline function lerp/*unclamped*/(pct:Float, lo:Float, ho:Float):Float { return (ho - lo) * pct + lo; }
}
