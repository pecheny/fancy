package bindings;
typedef ArrayViewBase = #if js js.lib.Uint8Array #else lime.utils.ArrayBufferView #end
