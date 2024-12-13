package com.tilbuci.contraptions;

import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class Contraptions {

    public var menus:Map<String, MenuContraption> = [ ];

    public var menusOverlay:Sprite;

    public function new() {
        
    }

    public function clear():Void {
        for (k in this.menus.keys()) {
            this.menus[k].kill();
            this.menus.remove(k);
        }

        if (this.menusOverlay == null) {
            this.menusOverlay = GlobalPlayer.area.getOverlay('contraptions-menu');
        }
    }

}