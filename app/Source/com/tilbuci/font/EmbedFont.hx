package com.tilbuci.font;

/** OPENFL **/
import openfl.text.Font;
#if (js && html5)
	import js.Browser;
	import js.html.FontFace;
    import js.lib.ArrayBuffer;
    import js.lib.DataView;
#end

/** TILBUCI **/
import com.tilbuci.data.DataLoader;
import com.tilbuci.data.Global;

/**
    Embeds a font file at runtime.
    (many thanks to sanline for HTML5 font loading - https://github.com/scanline)
**/
class EmbedFont {

    /**
        loaded font name
    **/
    public var fname(get, null):String;
    private var _fname:String = '';
    private function get_fname():String { return (this._fname); }

    /**
        method to call after font load
    **/
    private var _ac:Dynamic;

    /**
        add font name to global list after loading?
    **/
    private var _addToGlobal:Bool = true;

    /**
        Constructor.
        @param  path    the path to the font (ttf, otf or woff2 file)
        @param  name    the font family name
        @param  ac  a method to call after font loading (receives two parameters: Bool and EmbedFont)
        @param  addToGlobal add font name to global list after loading?
    **/
    public function new(path:String, name:String, ac:Dynamic = null, addToGlobal:Bool = true) {
        // adjust path
        #if (js && html5)
            path = StringTools.replace(path, '.ttf', '.woff2');
            path = StringTools.replace(path, '.otf', '.woff2');
        #else
            path = StringTools.replace(path, '.woff2', '.ttf');
            path = StringTools.replace(path, '.woff', '.ttf');
        #end
        // load file
        this._addToGlobal = addToGlobal;
        this._fname = name;
        this._ac = ac;
        new DataLoader(true, path, 'GET', null, DataLoader.MODEBINARY, onLoad);
    }

    /**
        File loading ends.
        @param  ok  load successful?
        @param  ld  the loader reference
    **/
    private function onLoad(ok:Bool, ld:DataLoader):Void {
        if (ok) {
            // load the font file
            #if (js && html5)
                // browser
                var buffer:ArrayBuffer = new ArrayBuffer(ld.binary.length);
                var view:DataView = new DataView(buffer, 0, buffer.byteLength);
                for (i in 0...ld.binary.length) view.setUint8(i, ld.binary[i]);
                var face:FontFace = new FontFace(this._fname, buffer);
                Browser.document.fonts.add(face);
                face.load().then(function(_){
                    var future:lime.app.Future<Font> = Font.loadFromName(this._fname);
                    future.onComplete(function(font){
                        // warn listeners about load ok
                        if (this._addToGlobal) Global.fonts.push(this._fname);
                        if (this._ac != null) this._ac(true, this);
                        this._ac = null;
                    });
                });
            #elseif air
                // no support for AIR dynamic font loading
                this._fname = '';
                if (this._ac = null) this._ac(false, this);
                this._ac = null;
            #else
                // binary font load
                var fnt:Font = Font.fromBytes(ld.binary);
                Font.registerFont(fnt);
                this._fname = fnt.fontName;
                // warn listeners about load ok
                if (this._addToGlobal) Global.fonts.push(this._fname);
                if (this._ac != null) this._ac(true, this);
                this._ac = null;
            #end
        } else {
            // error loading the font file
            this._fname = '';
            if (this._ac = null) this._ac(false, this);
            this._ac = null;
        }
    }

}

/**
    Information about an embed font.
**/
typedef FontInfo = {
    var name:String;    // name
    var file:String;    // file
}