package com.tilbuci.contraptions;

/** OPENFL **/
import openfl.display.Sprite;

class MenuContraption extends Sprite {

    public var id:String;

    public var font:String = 'sans';

    public var fontcolor:String = '0xffffff';

    public var background:String = '';

    public var buton:String = '';

    public var selected:String = '';

    public function new() {
        super();
    }

    public function load(data:Dynamic):Bool {
        if (Reflect.hasField(data, 'id')) {
            this.id = Reflect.field(data, 'id');
            if (Reflect.hasField(data, 'font')) this.font = Reflect.field(data, 'font');
                else this.font = 'sans';
            if (Reflect.hasField(data, 'fontcolor')) this.fontcolor = Reflect.field(data, 'fontcolor');
                else this.fontcolor = '0xffffff';
            if (Reflect.hasField(data, 'background')) this.background = Reflect.field(data, 'background');
                else this.background = '';
            if (Reflect.hasField(data, 'buton')) this.buton = Reflect.field(data, 'buton');
                else this.buton = '';
            if (Reflect.hasField(data, 'selected')) this.selected = Reflect.field(data, 'selected');
                else this.selected = '';
            return (true);
        } else {
            return (false);
        }
    }

    public function kill():Void {
        this.removeChildren();
        this.id = this.font = this.fontcolor = this.background = this.buton = this.selected = null;
    }
}