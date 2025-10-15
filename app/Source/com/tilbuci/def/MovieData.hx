/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package com.tilbuci.def;

/** HAXE **/
import com.tilbuci.statictools.StringStatic;
import com.tilbuci.ui.PlayerTheme;
import haxe.Json;

/** ACTUATE **/
import motion.easing.Cubic;
import motion.easing.Bounce;
import motion.easing.Linear;
import motion.easing.Sine;
import motion.easing.Quint;
import motion.easing.Quart;
import motion.easing.Quad;
import motion.easing.Expo;
import motion.easing.Elastic;
import motion.Actuate;

/** FEATHERS UI **/
import feathers.style.Theme;

/** TILBUCI **/
import com.tilbuci.def.DefBase;
import com.tilbuci.data.GlobalPlayer;
import com.tilbuci.script.ScriptParser;
import com.tilbuci.font.EmbedFont;
import com.tilbuci.plugin.Plugin;

/**
    Loaded movie information.
**/
class MovieData extends DefBase {
    
    /**
        tilbuci version
    **/
    public var version:Int;

    /**
        movie title
    **/
    public var title:String;

    /**
        movie author
    **/
    public var author:String;

    /**
        movie copyright
    **/
    public var copyright:String;

    /**
        movie copyleft
    **/
    public var copyleft:String;

    /**
        movie description
    **/
    public var description:String;

    /**
        favicon image path
    **/
    public var favicon:String;

    /**
        share image path
    **/
    public var image:String;

    /**
        movie secret access key
    **/
    public var key:String;

    /**
        movie to load on access denied
    **/
    public var fallback:String;

    /**
        require visitor login?
    **/
    public var identify:Bool = false;

    /**
        visitor groups allowed
    **/
    public var vsgroups:Array<String> = [ ];

    /**
        movie initial scene
    **/
    public var start:String;

    /**
        movie initial actions
    **/
    public var acstart:String;

    /**
        movie tags
    **/
    public var tags:Array<String>;

    /**
        movie screen information
    **/
    public var screen:MovieDataScreen;

    /**
        time between keyframes
    **/
    public var time:Float = 1;

    /**
        instance origin
    **/
    public var origin:String = 'center';

    /**
        transition animation
    **/
    public var animation:String = 'linear';

    /**
        embed fonts
    **/
    public var fonts:Array<FontInfo> = [ ];

    /**
        css stylesheet for html text
    **/
    public var style:String = '';

    /**
        movie named actions
    **/
    public var actions:Array<MovieAction> = [ ];

    /**
        ui theme colors
    **/
    public var theme:String = '';

    /**
        movie constant strings
    **/
    public var texts:Map<String, String> = [ ];

    /**
        movie constant numbers
    **/
    public var numbers:Map<String, Float> = [ ];

    /**
        movie constant booleans
    **/
    public var flags:Map<String, Bool> = [ ];

    /**
        plugin movie configurations
    **/
    public var plugins:Map<String, PluginConf> = [ ];

    /**
        highlight color
    **/
    public var highlight:String = '';

    /**
        scene loading icon animation
    **/
    public var loadingic:Array<String> = [ '', '', '' ];

    /**
        encrypt movie files?
    **/
    public var encrypted:Bool = false;

    /**
        highlight color (int value)
    **/
    public var highlightInt:Null<Int> = null;

    /**
        input settings
    **/
    public var inputs:Map<String, String> = [ ];

    /**
        Creator.
    **/
    public function new() {
        super(['version', 'title', 'author', 'copyright', 'copyleft', 'description', 'favicon', 'image', 'key', 'start', 'acstart', 'tags', 'screen', 'time', 'origin', 'animation', 'fonts', 'style', 'theme', 'texts', 'numbers', 'flags', 'plugins']);
        this.screen = new MovieDataScreen();
        this.clear();
    }

    /**
        Clears current movie data.
    **/
    public function clear():Void {
        this.version = 0;
        this.title = '';
        this.author = '';
        this.copyright = '';
        this.copyleft = '';
        this.description = '';
        this.favicon = '';
        this.image = '';
        this.key = '';
        this.fallback = '';
        this.identify = false;
        this.vsgroups = [ ];
        this.start = '';
        this.acstart = '';
        this.tags = [ ];
        this.time = 1;
        this.origin = 'center';
        this.animation = 'linear';
        this.highlight = '';
        this.highlightInt = null;
        this.loadingic = [ '', '', '' ];
        this.encrypted = false;
        this.screen.clear();
        while (this.fonts.length > 0) {
            var ft:FontInfo = this.fonts.shift();
            ft.name = null;
            ft.file = null;
            ft = null;
        }
        while (this.actions.length > 0) {
            var ac:MovieAction = this.actions.shift();
            ac.name = null;
            ac.ac = null;
            ac = null;
        }
        this.style = '';
        this.theme = '';
        for (t in this.texts.keys()) this.texts.remove(t);
        for (t in this.numbers.keys()) this.numbers.remove(t);
        for (t in this.flags.keys()) this.flags.remove(t);
        for (t in this.plugins.keys()) {
            this.plugins.remove(t);
        }
        for (n in GlobalPlayer.plugins.keys()) {
            GlobalPlayer.plugins[n].active = false;
        }
        GlobalPlayer.style.clear();
        for (ac in GlobalPlayer.mvActions.keys()) GlobalPlayer.mvActions.remove(ac);
        Actuate.defaultEase = Linear.easeNone;
        this.inputs = [
            'keyup' => 'up', 
            'keydown' => 'down', 
            'keyleft' => 'left', 
            'keyright' => 'right', 
            'keyspace' => '',
            'keyenter' => 'target',
            'keypup' => 'nout', 
            'keypdown' => 'nin', 
            'keyhome' => 'nothing', 
            'keyend' => 'nothing', 
            'swiperight' => 'right', 
            'swipeleft' => 'left', 
            'swipetop' => 'up', 
            'swipebottom' => 'down', 
            'touchhold' => 'nothing', 
            'mousemiddle' => 'nothing', 
            'mouseright' => 'nothing', 
            'mousewheelup' => 'nothing', 
            'mousewheeldown' => 'nothing', 
        ];
    }

    /**
        Loads a movie information.
        @param  data    movie data to load
        @return all required fields sent on data?
    **/
    public function load(data:Map<String, Dynamic>):Bool {
        if (this.checkFields(data)) {
            // getting movie information
            this.version = data['version'];
            this.title = data['title'];
            this.author = data['author'];
            this.copyright = data['copyright'];
            this.copyleft = data['copyleft'];
            this.description = data['description'];
            this.favicon = data['favicon'];
            this.image = data['image'];
            this.key = data['key'];
            this.start = data['start'];
            this.acstart = data['acstart'];
            this.tags = data['tags'];
            this.screen.big = data['screen'].big;
            this.screen.small = data['screen'].small;
            this.screen.type = data['screen'].type;
            this.screen.bgcolor = Std.parseInt(data['screen'].bgcolor);
            this.time = data['time'];
            this.origin = data['origin'];
            this.animation = data['animation'];
            this.fonts = data['fonts'];
            this.style = data['style'];
            this.actions = data['actions'];
            this.theme = data['theme'];
            // optional fields
            if (data.exists('fallback')) this.fallback = data['fallback'];
                else this.fallback = '';
            if (data.exists('identify')) this.identify = data['identify'];
                else this.identify = false;
            if (data.exists('vsgroups')) this.vsgroups = data['vsgroups'];
                else this.vsgroups = [ ];
            if (this.vsgroups.length > 0) this.identify = true;
            if (data.exists('highlight')) {
                this.highlight = data['highlight'];
                this.highlightInt = Std.parseInt(this.highlight);
            } else {
                this.highlight = '';
                this.highlightInt = null;
            }
            if (data.exists('inputs')) {
                for (t in Reflect.fields(data['inputs'])) {
                    this.inputs[t] = Reflect.field(data['inputs'], t);
                }
            }
            if (data.exists('loadingic')) {
                if (data['loadingic'] == '') {
                    this.loadingic = [ '', '', '' ];
                } else {
                    this.loadingic = StringStatic.jsonParse(data['loadingic']);
                }
            } else {
                this.loadingic = [ '', '', '' ];
            }
            if (data.exists('encrypted')) {
                this.encrypted = data['encrypted'];
            } else {
                this.encrypted = false;
            }
            GlobalPlayer.mdata = this;
            // setting animation transition
            switch (this.animation) {
                case 'bounce.in':
                    Actuate.defaultEase = Bounce.easeIn;
                case 'bounce.out':
                    Actuate.defaultEase = Bounce.easeOut;
                case 'bounce.inout':
                    Actuate.defaultEase = Bounce.easeInOut;
                case 'cubic.in':
                    Actuate.defaultEase = Cubic.easeIn;
                case 'cubic.out':
                    Actuate.defaultEase = Cubic.easeOut;
                case 'cubic.inout':
                    Actuate.defaultEase = Cubic.easeInOut;
                case 'elastic.in':
                    Actuate.defaultEase = Elastic.easeIn;
                case 'elastic.out':
                    Actuate.defaultEase = Elastic.easeOut;
                case 'elastic.inout':
                    Actuate.defaultEase = Elastic.easeInOut;
                case 'expo.in':
                    Actuate.defaultEase = Expo.easeIn;
                case 'expo.out':
                    Actuate.defaultEase = Expo.easeOut;
                case 'expo.inout':
                    Actuate.defaultEase = Expo.easeInOut;
                case 'quad.in':
                    Actuate.defaultEase = Quad.easeIn;
                case 'quad.out':
                    Actuate.defaultEase = Quad.easeOut;
                case 'quad.inout':
                    Actuate.defaultEase = Quad.easeInOut;
                case 'quart.in':
                    Actuate.defaultEase = Quart.easeIn;
                case 'quart.out':
                    Actuate.defaultEase = Quart.easeOut;
                case 'quart.inout':
                    Actuate.defaultEase = Quart.easeInOut;
                case 'quint.in':
                    Actuate.defaultEase = Quint.easeIn;
                case 'quint.out':
                    Actuate.defaultEase = Quint.easeOut;
                case 'quint.inout':
                    Actuate.defaultEase = Quint.easeInOut;
                case 'sine.in':
                    Actuate.defaultEase = Sine.easeIn;
                case 'sine.out':
                    Actuate.defaultEase = Sine.easeOut;
                case 'sine.inout':
                    Actuate.defaultEase = Sine.easeInOut;
                default:
                    this.animation = 'linear';
                    Actuate.defaultEase = Linear.easeNone;
            }
            // loading fonts
            for (ft in this.fonts) {
                new EmbedFont(GlobalPlayer.path + 'media/font/' + ft.file, ft.name, null, false);
            }
            // getting named actions
            for (ac in GlobalPlayer.mvActions.keys()) GlobalPlayer.mvActions.remove(ac);
            for (ac in this.actions) GlobalPlayer.mvActions[ac.name] = ac.ac;
            // global texts
            for (t in this.texts.keys()) this.texts.remove(t);
            for (t in Reflect.fields(data['texts'])) {
                this.texts[t] = Reflect.field(data['texts'], t);
            }
            // global numbers
            for (t in this.numbers.keys()) this.numbers.remove(t);
            for (t in Reflect.fields(data['numbers'])) {
                this.numbers[t] = Reflect.field(data['numbers'], t);
            }
            // global booleans
            for (t in this.flags.keys()) this.flags.remove(t);
            for (t in Reflect.fields(data['flags'])) {
                this.flags[t] = Reflect.field(data['flags'], t);
            }
            // plugins
            for (n in GlobalPlayer.plugins.keys()) {
                GlobalPlayer.plugins[n].active = false;
            }
            for (t in this.plugins.keys()) {
                this.plugins.remove(t);
            }
            for (t in Reflect.fields(data['plugins'])) {
                this.plugins[t] = Reflect.field(data['plugins'], t);
            }
            // apply current movie settings
            this.applySets();
            // returning
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Applies movie settings.
    **/
    public function applySets(clearvars:Bool = false):Void {
        // setting style
        GlobalPlayer.style.clear();
        GlobalPlayer.style.parseCSS(this.style);
        // getting named actions
        for (ac in GlobalPlayer.mvActions.keys()) GlobalPlayer.mvActions.remove(ac);
        for (ac in this.actions) GlobalPlayer.mvActions[ac.name] = ac.ac;
        // setting values
        if (clearvars) GlobalPlayer.parser.clearVars();
        for (k in this.texts.keys()) GlobalPlayer.parser.setString(k, this.texts[k]);
        for (k in this.flags.keys()) GlobalPlayer.parser.setBool(k, this.flags[k]);
        for (k in this.numbers.keys()) {
            GlobalPlayer.parser.setFloat(k, this.numbers[k]);
            GlobalPlayer.parser.setInt(k, Math.round(this.numbers[k]));
        }
        // plugins
        for (n in GlobalPlayer.plugins.keys()) GlobalPlayer.plugins[n].active = false;
        for (t in GlobalPlayer.plugins.keys()) {
            if (this.plugins.exists(t)) {
                GlobalPlayer.plugins[t].active = this.plugins[t].active;
                GlobalPlayer.plugins[t].setConfig(this.plugins[t].config);
            } else {
                GlobalPlayer.plugins[t].active = false;
            }
        }
        // apply movie ui theme?
        var applyTheme:Bool = true;
        if (Reflect.hasField(Main, 'mode')) {
            if (Reflect.field(Main, 'mode') == 'editor') {
                applyTheme = false;
            }
        }
        if (applyTheme) {
            GlobalPlayer.theme = new PlayerTheme(this.theme);
            Theme.setTheme(GlobalPlayer.theme);
        }
        // loadins scene icon
        GlobalPlayer.contraptions.loadLoadingIc();
    }

    /**
        Creates a JSON-encoded string with current movie information.
        @return the JSON-formatted text
    **/
    public function toJson():String {
        return (Json.stringify({
            version: this.version, 
            title: this.title, 
            author: this.author, 
            copyright: this.copyright, 
            copyleft: this.copyleft, 
            start: this.start, 
            acstart: this.acstart, 
            description: this.description, 
            favicon: this.favicon, 
            key: this.key, 
            identify: this.identify, 
            vsgroups: this.vsgroups, 
            image: this.image, 
            tags: this.tags, 
            screen: {
                big: this.screen.big, 
                small: this.screen.small, 
                type: this.screen.type, 
                bgcolor: ('0x' + StringTools.hex(this.screen.bgcolor))
            }, 
            time: this.time, 
            origin: this.origin, 
            animation: this.animation, 
            fonts: this.fonts, 
            highlight: this.highlight, 
            loadingic: this.loadingic, 
            encrypted: this.encrypted, 
            inputs: this.inputs
        }));
    }

    /**
        Releases resources used by the object.
    **/
    override public function kill():Void {
        super.kill();
        this.title = null;
        this.author = null;
        this.copyright = null;
        this.copyleft = null;
        this.description = null;
        this.favicon = null;
        this.image = null;
        this.start = null;
        this.acstart = null;
        while (this.tags.length > 0) this.tags.shift();
        this.tags = null;
        this.screen.kill();
        this.screen = null;
        this.time = 1;
        this.origin = null;
        this.animation = null;
        while (this.fonts.length > 0) {
            var ft:FontInfo = this.fonts.shift();
            ft.name = null;
            ft.file = null;
            ft = null;
        }
        this.fonts = null;
        this.style = null;
        this.theme = null;
        while (this.actions.length > 0) {
            var ac:MovieAction = this.actions.shift();
            ac.name = null;
            ac.ac = null;
            ac = null;
        }
        this.actions = null;
        for (t in this.texts.keys()) this.texts.remove(t);
        this.texts = null;
        for (t in this.numbers.keys()) this.numbers.remove(t);
        this.numbers = null;
        for (t in this.flags.keys()) this.flags.remove(t);
        this.flags = null;
        for (t in this.plugins.keys()) {
            this.plugins.remove(t);
        }
        this.plugins = null;
        this.highlight = null;
        this.highlightInt = null;
        while (this.loadingic.length > 0) this.loadingic.shift();
        this.loadingic = null;
        for (k in this.inputs.keys()) this.inputs.remove(k);
        this.inputs = null;
    }
}

/**
    Movie screen information.
**/
class MovieDataScreen {

    /**
        bigger screem size
    **/
    public var big:Int;

    /**
        smaller screen size
    **/
    public var small:Int;

    /**
        screen display type
    **/
    public var type:String;

    /**
        movie backgournd color
    **/
    public var bgcolor:Int;

    public function new() {
        this.clear();
    }

    /**
        Clears current screen information.
    **/
    public function clear():Void {
        this.big = 0;
        this.small = 0;
        this.type = '';
        this.bgcolor = 0;
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this.type = null;
    }
}

