package com.tilbuci.ui.menu;

/** FEATHERS UI **/
import com.tilbuci.data.GlobalPlayer;
import feathers.events.TriggerEvent;

/** TILBUCI **/
import com.tilbuci.ui.menu.DrawerMenu;
import com.tilbuci.data.Global;

class MenuMedia extends DrawerMenu {

    /**
        Constructor.
        @param  ac  the menu action mehtod
    **/
    public function new(ac:Dynamic) {
        super(ac, Global.ln.get('menu-media-title'));
        this.addButton('btCollections', Global.ln.get('menu-media-collections'), onCollections);
        this.addButton('btCollectionsAdd', Global.ln.get('menu-media-collectionsadd'), onCollectionsAdd);
        this.addButton('btCollectionsRm', Global.ln.get('menu-media-collectionsrm'), onCollectionsRm);
        this.addButton('btAudio', Global.ln.get('menu-media-audio'), onAudio);
        this.addButton('btHtml', Global.ln.get('menu-media-html'), onHtml);
        this.addButton('btParagraph', Global.ln.get('menu-media-paragraph'), onParagraph);
        this.addButton('btPicture', Global.ln.get('menu-media-picture'), onPicture);
        this.addButton('btShape', Global.ln.get('menu-media-shape'), onShape);
        this.addButton('btSpritemap', Global.ln.get('menu-media-spritemap'), onSpritemap);
        //this.addButton('btText', Global.ln.get('menu-media-text'), onText);
        this.addButton('btVideo', Global.ln.get('menu-media-video'), onVideo);
        this.addButton('btEmbed', Global.ln.get('menu-media-embed'), onEmbed);
    }

    /**
        The menu was just open.
    **/
    override public function onShow():Void {
        super.onShow();
        this.ui.buttons['btCollections'].enabled = (GlobalPlayer.movie.mvId != '');
        this.ui.buttons['btCollectionsAdd'].enabled = (GlobalPlayer.movie.mvId != '');
        this.ui.buttons['btCollectionsRm'].enabled = (GlobalPlayer.movie.mvId != '');
        this.ui.buttons['btAudio'].enabled = (GlobalPlayer.movie.scId != '');
        this.ui.buttons['btHtml'].enabled = (GlobalPlayer.movie.scId != '');
        this.ui.buttons['btParagraph'].enabled = (GlobalPlayer.movie.scId != '');
        this.ui.buttons['btPicture'].enabled = (GlobalPlayer.movie.scId != '');
        this.ui.buttons['btShape'].enabled = (GlobalPlayer.movie.scId != '');
        this.ui.buttons['btSpritemap'].enabled = (GlobalPlayer.movie.scId != '');
        //this.ui.buttons['btText'].enabled = (GlobalPlayer.movie.scId != '');
        this.ui.buttons['btVideo'].enabled = (GlobalPlayer.movie.scId != '');
        this.ui.buttons['btEmbed'].enabled = (GlobalPlayer.movie.mvId != '');
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
    }

    /**
        Shows unused movie collections.
    **/
    private  function onCollectionsAdd(evt:TriggerEvent):Void {
        this._ac('collectionadd');
    }

    /**
        Shows collections removal window.
    **/
    private  function onCollectionsRm(evt:TriggerEvent):Void {
        this._ac('collectionrm');
    }

    /**
        Shows the scene collections.
    **/
    private  function onCollections(evt:TriggerEvent):Void {
        this._ac('collection');
    }

    /**
        Shows the new picture manager.
    **/
    private  function onPicture(evt:TriggerEvent):Void {
        this._ac('picture');
    }

    /**
        Shows the new shape manager.
    **/
    private  function onShape(evt:TriggerEvent):Void {
        this._ac('shape');
    }

    /**
        Shows the new video manager.
    **/
    private  function onVideo(evt:TriggerEvent):Void {
        this._ac('video');
    }

    /**
        Shows the embed content manager.
    **/
    private  function onEmbed(evt:TriggerEvent):Void {
        this._ac('embed');
    }

    /**
        Shows the new audio manager.
    **/
    private  function onAudio(evt:TriggerEvent):Void {
        this._ac('audio');
    }

    /**
        Shows the new html manager.
    **/
    private  function onHtml(evt:TriggerEvent):Void {
        this._ac('html');
    }

    /**
        Shows the new paragraph manager.
    **/
    private  function onParagraph(evt:TriggerEvent):Void {
        this._ac('paragraph');
    }

    /**
        Shows the new text manager.
    **/
    private  function onText(evt:TriggerEvent):Void {
        this._ac('text');
    }

    /**
        Shows the new spritemap manager.
    **/
    private  function onSpritemap(evt:TriggerEvent):Void {
        this._ac('spritemap');
    }

}