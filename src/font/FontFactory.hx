package font;
interface FontFactory<T> {
    function create(path:String, ?dfSize:Int):FontInstance<T>;
}
