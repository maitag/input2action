package input2actions;

/**
 * by Sylvio Sell - Rostock 2019
*/

@:forward @:transitive abstract NestedArrayItem<T>(Array<T>) from Array<T> to Array<T> {
    public function new() {
        this = new Array<T>();
    }
    @:from public static function fromOther<T>(a:T):NestedArrayItem<T> {
        return [a];
    }
    @:from public static function fromArrayNestedArrayItem<T>(av:Array<NestedArrayItem<T>>):NestedArrayItem<T> {
        var item = new NestedArrayItem<T>();
        for (v in av) {
            for (i in v) 
                item.push(i);
        }
        return item;
    }
    @:from public static function fromArray<T>(a:Array<T>):NestedArrayItem<T> {
        var item = new NestedArrayItem<T>();
        for (v in a) {
            item.push(v);
        }
        return item;
    }
}

@:forward abstract NestedArray<T>(Array<NestedArrayItem<T>>) from Array<NestedArrayItem<T>> to Array<NestedArrayItem<T>> {
    public function new() {
        this = new Array<NestedArrayItem<T>>();
    }
    @:to public function toArray<T>():Array<T> {
        var a = new Array<T>();
        for (item in this) for (v in item) a.push(cast v);
        return a;
    }
}