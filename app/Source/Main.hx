/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

 package;

/** OPENFL **/
import haxe.io.Bytes;
import com.tilbuci.data.DataLoader;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import com.tilbuci.event.TilBuciEvent;
import openfl.text.Font;
import openfl.text.TextFormat;
import openfl.text.TextField;
import com.tilbuci.data.GlobalPlayer;
import haxe.Timer;
import openfl.display.LoaderInfo;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.Assets;
import openfl.display.StageScaleMode;

/** FEATHERSUI **/
import feathers.layout.AnchorLayout;
import feathers.style.IDarkModeTheme;
import feathers.style.Theme;
import feathers.controls.Application;
import feathers.controls.Panel;
import feathers.layout.AnchorLayoutData;
import feathers.controls.Label;
import feathers.core.PopUpManager;

/** TILBUCI **/
import com.tilbuci.Player;
import com.tilbuci.Editor;

/** PLUGINS **/
import plugins.DebugPlugin;
import plugins.SharePlugin;
import plugins.ServerCallPlugin;
import plugins.OverlayPlugin;
import plugins.GoogleAnalyticsPlugin;

class Main extends Application
{

	/**
		system mode (player or editor)
	**/
	public static var mode:String;

	/**
		initial movie
	**/
	public static var movie:String;

	/**
		initial scene
	**/
	public static var scene:String;

	/**
		initial user
	**/
	public static var us:String;

	/**
		initial user key
	**/
	public static var uk:String;

	/**
		the TilBuci player
	**/
	private var _player:Player;

	/**
		the TilBuci editor
	**/
	private var _editor:Editor;

	public function new()
	{
		// prepare interface
		var theme = cast(Theme.fallbackTheme, IDarkModeTheme);
		theme.darkMode = true;
		super();
		this.layout = new AnchorLayout();

		// get start parameters
		Main.mode = 'player';
		Main.movie = '';
		Main.scene = '';
		if (Reflect.hasField(this.loaderInfo.parameters, 'mode')) {
			if (Reflect.field(this.loaderInfo.parameters, 'mode') == 'editor') {
				Main.mode = 'editor';
			}
		}
		if (Reflect.hasField(this.loaderInfo.parameters, 'movie')) {
			Main.movie = Reflect.field(this.loaderInfo.parameters, 'movie');
			if (Reflect.hasField(this.loaderInfo.parameters, 'scene')) {
				Main.scene = Reflect.field(this.loaderInfo.parameters, 'scene');
			}
		}

		if (Reflect.hasField(this.loaderInfo.parameters, 'decrypt')) {
			DataLoader.customDecrypt = Reflect.field(this.loaderInfo.parameters, 'decrypt');
		}

		if (Reflect.hasField(this.loaderInfo.parameters, 'us') && Reflect.hasField(this.loaderInfo.parameters, 'uk')) {
			Main.us = Reflect.field(this.loaderInfo.parameters, 'us');
			Main.uk = Reflect.field(this.loaderInfo.parameters, 'uk');
		} else {
			Main.us = Main.uk = '';
		}

		#if !haxeJSON 
			// show halt message
			var popup:Panel = new Panel();
			popup.layout = new AnchorLayout();
			popup.setPadding(10);
			var message = new Label();
			message.text = "TilBuci relies heavily on JSON data processing. To ensure good operation, please build it with the haxeJSON compile flag, like:\ropenfl build html5 -D haxeJSON";
			message.layoutData = AnchorLayoutData.center();
			popup.addChild(message);
			PopUpManager.addPopUp(popup, this);
		#else
			if (this.stage == null) {
				this.addEventListener(Event.ADDED_TO_STAGE, this.onStage);
			} else {
				this.onStage();
			}
		#end
	}

	/**
		The stage is available.
	**/
	private function onStage(evt:Event = null):Void {
		if (this.hasEventListener(Event.ADDED_TO_STAGE)) this.removeEventListener(Event.ADDED_TO_STAGE, this.onStage);
		if (Main.mode == 'editor') {
			this._editor = new Editor('editor.json');
			this._editor.registerPlugin(new DebugPlugin());
			this._editor.registerPlugin(new SharePlugin());
			this._editor.registerPlugin(new GoogleAnalyticsPlugin());
			this._editor.registerPlugin(new ServerCallPlugin());
			this._editor.registerPlugin(new OverlayPlugin());
			this.addChild(this._editor);
		} else {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			Main.mode = 'player';
			this._player = new Player('player.json', Player.MODE_PLAYER, Player.ORIENTATION_LANDSCAPE);
			this._player.registerPlugin(new DebugPlugin());
			this._player.registerPlugin(new SharePlugin());
			this._player.registerPlugin(new GoogleAnalyticsPlugin());
			this._player.registerPlugin(new ServerCallPlugin());
			this._player.registerPlugin(new OverlayPlugin());
			this._player.setSize(this.stage.stageWidth, this.stage.stageHeight);
			this.stage.addChild(this._player);
			this.stage.addEventListener(Event.RESIZE, onStageResize);
		}

		this.debug();
	}

	/**
		Player stage resize.
	**/
	private function onStageResize(evt:Event):Void {
		this._player.setSize(this.stage.stageWidth, this.stage.stageHeight);
	}

	/**
		Debug
	**/
	private function debug():Void {
		
	}
	
}