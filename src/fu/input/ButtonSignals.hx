package fu.input;

import fu.Signal;

#if ginp
typedef ButtonSignals<T:Axis<T>> = ginp.ButtonSignals<T>;
#else
interface ButtonSignals<T:Axis<T>> {
    public var onPress(default, null):Signal<T->Void>;
    public var onRelease(default, null):Signal<T->Void>;
}
#end
