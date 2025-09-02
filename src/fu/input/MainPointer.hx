package fu.input;

import shimp.IPos;

interface MainPointer<T:IPos<T>> {
    public function getPos():T;
}
