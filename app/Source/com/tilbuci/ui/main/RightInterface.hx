package com.tilbuci.ui.main;


import feathers.controls.HScrollBar;
import openfl.events.Event;
import feathers.layout.VerticalLayout;
import feathers.controls.Panel;
import feathers.skins.RectangleSkin;
import feathers.layout.AnchorLayout;
import feathers.controls.ScrollContainer;

/** TILBUCI **/
import com.tilbuci.ui.component.InstancesPanel;
import com.tilbuci.ui.component.DropDownPanel;
import com.tilbuci.ui.component.HistoryPanel;
import com.tilbuci.ui.component.PropertiesPanel;
import com.tilbuci.ui.component.ColorPanel;
import com.tilbuci.ui.component.SoundPanel;
import com.tilbuci.ui.component.TextPanel;
import com.tilbuci.ui.component.FilterPanel;
import com.tilbuci.ui.component.MediaPanel;
import com.tilbuci.ui.component.ActionPanel;

class RightInterface extends ScrollContainer {

    private var _panels:Array<DropDownPanel> = [ ];

    public function new(centerMethod:Dynamic) {
        super();

        var lay:VerticalLayout = new VerticalLayout();
        lay.gap = 2;
        lay.setPadding(0);
        this.layout = lay;

        var skin:RectangleSkin = new RectangleSkin();
        skin.fill = SolidColor(0x666666);
        this.backgroundSkin = skin;
        this.maxWidth = this.minWidth = this.width = 220;

        this._panels.push(new InstancesPanel(200));
        this._panels.push(new MediaPanel(200));
        this._panels.push(new PropertiesPanel(200));
        this._panels.push(new ColorPanel(200));
        this._panels.push(new TextPanel(200));
        this._panels.push(new ActionPanel(200));
        this._panels.push(new SoundPanel(200));
        this._panels.push(new FilterPanel(200));
        this._panels.push(new HistoryPanel(200, centerMethod));

        // instance set callbacks
        this._panels[0].callbacks.push(this._panels[1].updateContent);
        this._panels[0].callbacks.push(this._panels[2].updateContent);
        this._panels[0].callbacks.push(this._panels[3].updateContent);
        this._panels[0].callbacks.push(this._panels[4].updateContent);
        this._panels[0].callbacks.push(this._panels[5].updateContent);
        this._panels[0].callbacks.push(this._panels[6].updateContent);
        this._panels[0].callbacks.push(this._panels[7].updateContent);
        this._panels[0].callbacks.push(this._panels[8].updateContent);
        for (p in this._panels) this.addChild(p);

        this.scrollPolicyX = OFF;

        this.addEventListener(Event.RESIZE, this.onResize);
    }

    public function updateInstances():Void {
        this._panels[0].reloadContent();
        this._panels[1].reloadContent();
        this._panels[2].reloadContent();
        this._panels[3].reloadContent();
        this._panels[4].reloadContent();
        this._panels[5].reloadContent();
        this._panels[6].reloadContent();
        this._panels[7].reloadContent();
        this._panels[8].reloadContent();
    }

    public function setInstance(data:Map<String, Dynamic> = null):Void {
        this._panels[0].updateContent(data);    // instances
        this._panels[1].updateContent(data);    // media
        this._panels[2].updateContent(data);    // properties
        this._panels[3].updateContent(data);    // color
        this._panels[4].updateContent(data);    // text
        this._panels[5].updateContent(data);    // action
        this._panels[6].updateContent(data);    // sound
        this._panels[7].updateContent(data);    // filter
    }

    private function onResize(evt:Event):Void {
        for (p in this._panels) p.setWd(this.width);
    }

}