package com.tilbuci.ui.component;

import com.tilbuci.data.GlobalPlayer;
import feathers.layout.AnchorLayoutData;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import com.tilbuci.data.Global;
import openfl.events.Event;

class InstancesPanel extends DropDownPanel {

    public function new(wd:Float) {
        super(Global.ln.get('rightbar-instances'), wd);

        var list:ListView = new ListView();
        list.variant = ListView.VARIANT_BORDERLESS;
        list.layoutData = AnchorLayoutData.fill();
        list.itemToText = (item:Dynamic) -> {
			return item.text;
		};
        list.addEventListener(Event.CHANGE, onChange);

        this._content = list;
        this._content.width = wd - 20;
    }

    override public function reloadContent(data:Map<String, Dynamic> = null):Void {
        var items = [ ];
        for (k in GlobalPlayer.movie.scene.keyframes[GlobalPlayer.area.currentKf].keys()) {
            items.push({ text: k, value: k });
        }
        var list = cast(this._content, ListView);
        list.dataProvider = new ArrayCollection(items);
    }

    override public function updateContent(data:Map<String, Dynamic> = null):Void {
        var list = cast(this._content, ListView);
        if (list.dataProvider != null) {
            for (n in 0...list.dataProvider.length) {
                if (list.dataProvider.get(n) != null) {
                    if (list.dataProvider.get(n).value == data['nm']) {
                        list.selectedIndex = n;
                    }
                }
            }
        }
    }

    public function instanceRename(oldn:String, newn:String):Void {
        var list = cast(this._content, ListView);
        if (list.dataProvider != null) {
            for (n in 0...list.dataProvider.length) {
                if (list.dataProvider.get(n) != null) {
                    if (list.dataProvider.get(n).value == oldn) {
                        list.dataProvider.get(n).text = newn;
                        list.dataProvider.get(n).value = newn;
                        list.selectedIndex = n;
                        list.dataProvider.updateAt(list.selectedIndex);
                    }
                }
            }
        }
    }

    private function onChange(evt:Event):Void {
        var list = cast(this._content, ListView);
        if (list.selectedItem != null) {
            GlobalPlayer.area.imgSelect(list.selectedItem.value);
            for (cb in this.callbacks) cb([ 'nm' => list.selectedItem.value ]);
        }
    }

}