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
        if (GlobalPlayer.movie.mvId == '') {
            this.ui.buttons['btCollectionsRm'].enabled = false;
            this.ui.buttons['btCollectionsRm'].toolTip = Global.ln.get('tooltip-movie-nomovie');
        } else {
            this.ui.buttons['btCollectionsRm'].enabled = true;
            this.ui.buttons['btCollectionsRm'].toolTip = null;
        }
        if (GlobalPlayer.movie.scId == '') {
            this.ui.buttons['btCollections'].enabled = false;
            this.ui.buttons['btCollectionsAdd'].enabled = false;
            this.ui.buttons['btAudio'].enabled = false;
            this.ui.buttons['btHtml'].enabled = false;
            this.ui.buttons['btParagraph'].enabled = false;
            this.ui.buttons['btPicture'].enabled = false;
            this.ui.buttons['btShape'].enabled = false;
            this.ui.buttons['btSpritemap'].enabled = false;
            //this.ui.buttons['btText'].enabled = false;
            this.ui.buttons['btVideo'].enabled = false;
            this.ui.buttons['btEmbed'].enabled = false;
            this.ui.buttons['btCollections'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btCollectionsAdd'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btAudio'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btHtml'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btParagraph'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btPicture'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btShape'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btSpritemap'].toolTip = Global.ln.get('tooltip-movie-noscene');
            //this.ui.buttons['btText'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btVideo'].toolTip = Global.ln.get('tooltip-movie-noscene');
            this.ui.buttons['btEmbed'].toolTip = Global.ln.get('tooltip-movie-noscene');
        } else {
            this.ui.buttons['btCollections'].enabled = true;
            this.ui.buttons['btCollectionsAdd'].enabled = true;
            this.ui.buttons['btAudio'].enabled = true;
            this.ui.buttons['btHtml'].enabled = true;
            this.ui.buttons['btParagraph'].enabled = true;
            this.ui.buttons['btPicture'].enabled = true;
            this.ui.buttons['btShape'].enabled = true;
            this.ui.buttons['btSpritemap'].enabled = true;
            //this.ui.buttons['btText'].enabled = true;
            this.ui.buttons['btVideo'].enabled = true;
            this.ui.buttons['btEmbed'].enabled = true;
            this.ui.buttons['btCollections'].toolTip = null;
            this.ui.buttons['btCollectionsAdd'].toolTip = null;
            this.ui.buttons['btAudio'].toolTip = null;
            this.ui.buttons['btHtml'].toolTip = null;
            this.ui.buttons['btParagraph'].toolTip = null;
            this.ui.buttons['btPicture'].toolTip = null;
            this.ui.buttons['btShape'].toolTip = null;
            this.ui.buttons['btSpritemap'].toolTip = null;
            //this.ui.buttons['btText'].toolTip = null;
            this.ui.buttons['btVideo'].toolTip = null;
            this.ui.buttons['btEmbed'].toolTip = null;
        }
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