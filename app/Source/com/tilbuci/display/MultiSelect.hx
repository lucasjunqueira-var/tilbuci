/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.display;

import com.tilbuci.data.GlobalPlayer;
import openfl.geom.Point;
import openfl.display.Sprite;

class MultiSelect extends Sprite {

    public var instances:Array<String> = [ ];

    public var position:Point = new Point();

    public var size:Point = new Point();


    public function new() {
        super();
        this.mouseEnabled = false;
        this.mouseChildren = false;
    }

    public function isAvailable():Bool {
        return (this.instances.length > 1);
    }

    public function clear():Void {
        this.graphics.clear();
        while (this.instances.length > 0) this.instances.shift();
        this.position.x = this.position.y = 0;
        this.size.x = this.size.y = 0;
    }

    public function add(inst:String):Void {
        var im:InstanceImage = GlobalPlayer.area.pickInstance(inst);
        if (im != null) {
            this.graphics.lineStyle(2, 0x000000, 0.7);
            this.graphics.beginFill(0xFFFFFF, 0.2);
            this.graphics.drawRect(im.x, im.y, im.width, im.height);
            this.graphics.endFill();
            this.instances.push(inst);
        }
    }

}