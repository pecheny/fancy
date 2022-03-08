package bindings;
typedef ArrayBufferView =
#if nme
    nme.utils.ArrayBufferView;
#elseif lime
    lime.utils.ArrayBufferView
#else
    Dynamic
#end
    
