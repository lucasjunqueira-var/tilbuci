package com.tilbuci.contraptions;

import com.tilbuci.statictools.StringStatic;
import com.tilbuci.data.GlobalPlayer;
import openfl.display.Sprite;

class Contraptions {

    public var menus:Map<String, MenuContraption> = [ ];

    private var _menusOverlay:Sprite;

    private var _menuAction:Dynamic;

    private var _menuVariable:String;

    public function new() {
        
    }

    public function clear():Void {
        for (k in this.menus.keys()) {
            this.menus[k].kill();
            this.menus.remove(k);
        }
        if (this._menusOverlay == null) {
            this._menusOverlay = GlobalPlayer.area.getOverlay('contraptions-menu');
        }
        this._menusOverlay.graphics.clear();
    }

    public function getData():String {
        var data:Map<String, Array<Dynamic>> = [ ];
        data['menus'] = new Array<Dynamic>();
        for (mn in this.menus) {
            data['menus'].push(mn.toObject());
        }
        return(StringStatic.jsonStringify(data));
    }

    public function menuShow(name:String, options:Array<String>, variable:String, actions:Dynamic, pos:String, px:Int, py:Int):Bool {
        if (this.menus.exists(name)) {
            var mn:MenuContraption = this.menus[name];
            if (mn.ok) {
                this._menusOverlay.graphics.clear();
                if (mn.bgalpha > 0) {
                    this._menusOverlay.graphics.beginFill(Std.parseInt(StringTools.replace('#', '0x', mn.bgcolor)), mn.bgalpha);
                    this._menusOverlay.graphics.drawRect(0, 0, GlobalPlayer.area.aWidth, GlobalPlayer.area.aHeight);
                    this._menusOverlay.graphics.endFill();
                }
                this._menusOverlay.addChild(mn.create(options, this.onMenuSelect));
                switch (pos) {
                    case 'top':
                        mn.x = ((GlobalPlayer.area.aWidth - mn.width) / 2);
                        mn.y = py;
                    case 'topleft':
                        mn.x = px;
                        mn.y = py;
                    case 'topright':
                        mn.x = GlobalPlayer.area.aWidth - mn.width - px;
                        mn.y = py;
                    case 'centerleft':
                        mn.x = px;
                        mn.y = ((GlobalPlayer.area.aHeight - mn.height) / 2);
                    case 'centerright':
                        mn.x = GlobalPlayer.area.aWidth - mn.width - px;
                        mn.y = ((GlobalPlayer.area.aHeight - mn.height) / 2);
                    case 'bottom':
                        mn.x = ((GlobalPlayer.area.aWidth - mn.width) / 2);
                        mn.y = GlobalPlayer.area.aHeight - mn.height - py;
                    case 'bottomleft':
                        mn.x = px;
                        mn.y = GlobalPlayer.area.aHeight - mn.height - py;
                    case 'bottomright':
                        mn.x = GlobalPlayer.area.aWidth - mn.width - px;
                        mn.y = GlobalPlayer.area.aHeight - mn.height - py;
                    case 'absolute':
                        mn.x = px;
                        mn.y = py;
                    default: // center
                        mn.x = (GlobalPlayer.area.aWidth - mn.width) / 2;
                        mn.y = (GlobalPlayer.area.aHeight - mn.height) / 2;
                }
                this._menuAction = actions;
                this._menuVariable = variable;
                return (true);
            } else {
                return (false);
            }
        } else {
            return (false);
        }
    }

    public function menuHide():Void {
        for (mn in this.menus) mn.remove();
        this._menusOverlay.graphics.clear();
    }

    private function onMenuSelect(val:String):Void {
        this.menuHide();
        GlobalPlayer.parser.setInt(this._menuVariable, val);
        if (this._menuAction != null) GlobalPlayer.parser.run(this._menuAction, true);
        this._menuAction = null;
    }

}