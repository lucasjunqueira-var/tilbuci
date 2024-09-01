package com.tilbuci.ui.base;

/** OPENFL **/
import openfl.events.Event;
import openfl.events.MouseEvent;
import feathers.controls.AssetLoader;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.utils.DisplayObjectRecycler;
import feathers.skins.RectangleSkin;
import feathers.controls.Panel;
import feathers.controls.ToggleSwitch;
import feathers.layout.HorizontalLayout;
import openfl.display.Bitmap;
import feathers.layout.AnchorLayoutData;
import feathers.data.ArrayCollection;
import openfl.display.Stage;

/** FEATHERS UI **/
import feathers.core.FeathersControl;
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.controls.TextArea;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.core.MeasureSprite;
import feathers.events.TriggerEvent;
import feathers.core.PopUpManager;
import feathers.controls.PopUpListView;
import feathers.controls.ListView;
import feathers.layout.HorizontalAlign;
import feathers.controls.NumericStepper;
import feathers.data.ListViewItemState;

/** TILBUCI **/
import com.tilbuci.ui.base.BackgroundSkin;
import com.tilbuci.ui.base.ConfirmWindow;
import com.tilbuci.ui.base.InterfaceContainer;
import com.tilbuci.ui.base.InterfaceColumns;
import com.tilbuci.data.Global;
import com.tilbuci.ui.component.IDButton;

class InterfaceFactory {

    /**
        default layout for window forms
    **/
    private var _vLayout:VerticalLayout;

    /**
        default layout for horizontal display
    **/
    private var _hLayout:HorizontalLayout;

    /**
        default layout padding
    **/
    private var _padding:Int = 10;

    /**
        registered columns
    **/
    public var columns:Map<String, InterfaceColumns> = [ ];

    /**
        registered containers
    **/
    public var containers:Map<String, InterfaceContainer> = [ ];

    /**
        horizontal containers
    **/
    public var hcontainers:Map<String, HInterfaceContainer> = [ ];

    /**
        last created container
    **/
    public var lastCont:InterfaceContainer;

    /**
        registered labels
    **/
    public var labels:Map<String, Label> = [ ];

    /**
        registered text inputs
    **/
    public var inputs:Map<String, TextInput> = [ ];

    /**
        last created text input
    **/
    public var lastInput:TextInput;

    /**
        registered text areas
    **/
    public var tareas:Map<String,TextArea> = [ ];

    /**
        registered numeri stepper inputs
    **/
    public var numerics:Map<String, NumericStepper> = [ ];

    /**
        registered spacers
    **/
    public var spacers:Map<String, MeasureSprite> = [ ];

    /**
        registered buttons
    **/
    public var buttons:Map<String, IDButton> = [ ];

    /**
        registered toggle swtiches
    **/
    public var toggles:Map<String, ToggleSwitch> = [ ];

    /**
        registered button actions
    **/
    private var _btActions:Map<String, Dynamic> = [ ];

    /**
        registered select inputs
    **/
    public var selects:Map<String, PopUpListView> = [ ];

    /**
        registered lists
    **/
    public var lists:Map<String, ListView> = [ ];

    /**
        Creator.
        @param  padding the padding to use 
    **/
    public function new(padding:Int = 10) {
        this._padding = padding;
        this._vLayout = new VerticalLayout();
        this._vLayout.setPadding(this._padding);
        this._vLayout.gap = this._padding / 2;
        this._vLayout.verticalAlign = TOP;
        this._vLayout.horizontalAlign = LEFT;
        this._hLayout = new HorizontalLayout();
        this._hLayout.setPadding(this._padding);
        this._hLayout.gap = this._padding / 2;
        this._hLayout.verticalAlign = TOP;
        this._hLayout.horizontalAlign = LEFT;
    }

    /**
        Creates a multi-column layout.
        @param  id  the columns id
        @param  left    the left column interface
        @param  right   the right column interface
        @param  bottom  bottom interface (null for none)
        @param  ht  height of the columns area (if bottom is set, 0 for standard)
        @return the columns interface
    **/
    public function createColumnHolder(id:String, left:InterfaceContainer, right:InterfaceContainer, bottom:InterfaceContainer = null, ht:Float = 0):InterfaceColumns {
        var cols:InterfaceColumns = new InterfaceColumns(left, right, bottom, ht);
        this.columns[id] = cols;
        return (cols);
    }

    /**
        Creates a container element.
        @param  in  container id
        @param  padding container padding (-1 for default)
        @return the container
    **/
    public function createContainer(id:String, padding:Int = -1):InterfaceContainer {
        var cont:InterfaceContainer = new InterfaceContainer();
        cont.backgroundSkin = new BackgroundSkin();
        if (padding < 0) {
            cont.layout = this._vLayout;
        } else {
            var vLayout:VerticalLayout = new VerticalLayout();
            vLayout.setPadding(padding);
            vLayout.gap = padding / 2;
            vLayout.verticalAlign = TOP;
            vLayout.horizontalAlign = LEFT;
            cont.layout = vLayout;
        }
        this.containers[id] = cont;
        this.lastCont = cont;
        return (cont);
    }

    /**
        Creates a container with elements horizontally distributed.
        @param  in  container id
        @param  bgcolor background color (-1 to avoid setting)
        @return the container
    **/
    public function createHContainer(id:String, bgcolor:Int = -1):HInterfaceContainer {
        var cont:HInterfaceContainer = new HInterfaceContainer();
        if (bgcolor >= 0) {
            var skin:RectangleSkin = new RectangleSkin();
            skin.fill = SolidColor(bgcolor);
            cont.backgroundSkin = skin;
        } else {
            cont.backgroundSkin = new BackgroundSkin();
        }
        this.hcontainers[id] = cont;
        return (cont);
    }

    /**
        Creates a panel to add horizontally distributed elements.
        @param  align   elements alignment (left, right or center)
        @param  color   the background color
        @param  padding the pannel padding/gap
        @return the craeted panel
    **/
    public function createHArea(align:String = 'left', color:Int = 0x999999, pading:Int = 10):Panel {
        var pn:Panel = new Panel();
        var lay:HorizontalLayout = new HorizontalLayout();
        lay.gap = pading;
        lay.setPadding(pading);
        switch (align) {
            case 'left': lay.horizontalAlign = LEFT;
            case 'right': lay.horizontalAlign = RIGHT;
            default: lay.horizontalAlign = CENTER;
        }
        pn.layout = lay;
        var skin:RectangleSkin = new RectangleSkin();
        skin.fill = SolidColor(color);
        pn.backgroundSkin = skin;
        return (pn);
    }

    /**
        Creates a warning popup.
        @param  tit popup title
        @param  txt popup text 
        @param  wd  popup width
        @param  ht  popup height
        @param  st  a reference to the display stage (null to doesn't add automatically)
        @param  ac  an action to call on ok button click (null for none, must receive a single bool argument)
        @param  bttxt   ok button text
        @return a reference to the popup ConfirmWindow
    **/
    public function createWarning(tit:String, txt:String, wd:Int, ht:Int, st:Stage = null, ac:Dynamic = null, bttxt:String = 'Ok'):ConfirmWindow {
        var cw:ConfirmWindow = new ConfirmWindow(tit, txt, wd, ht, bttxt, ac, 'warn');
        if (st != null) PopUpManager.addPopUp(cw, st);
        return (cw);
    }

    /**
        Creates a confirm popup.
        @param  tit popup title
        @param  txt popup text 
        @param  wd  popup width
        @param  ht  popup height
        @param  ac  an action to call on ok button click (must receive a single bool argument)
        @param  oktxt   ok button text
        @param  canceltxt   cancel button text
        @param  st  a reference to the display stage (nutt to doesn't add automatically)
        @return a reference to the popup ConfirmWindow
    **/
    public function createConfirm(tit:String, txt:String, wd:Int, ht:Int, ac:Dynamic, oktxt:String, canceltxt:String, st:Stage = null):ConfirmWindow {
        var cw:ConfirmWindow = new ConfirmWindow(tit, txt, wd, ht, oktxt, ac, 'confirm', canceltxt);
        if (st != null) PopUpManager.addPopUp(cw, st);
        return (cw);
    }

    /**
        Creates a label element.
        @param  id  label id
        @param  txt the label text
        @param  variant the label style variant
        @param  holder  the element parent (null for none)
        @return the label element
    **/
    public function createLabel(id:String, txt:String, variant:String = '', holder:FeathersControl = null):Label {
        var lb:Label = new Label();
        if (variant != '') lb.variant = variant;
        lb.text = txt;
        if (holder != null) holder.addChild(lb);
        this.labels[id] = lb;
        return (lb);
    }

    /**
        Creates a label element for a larger description.
        @param  id  label id
        @param  txt the description text formatted in HTML
        @param  holder  the element parent (null for none)
        @return the label element
    **/
    public function createDescription(id:String, txt:String, variant:String = '', holder:FeathersControl = null):Label {
        var lb:Label = new Label();
        lb.wordWrap = true;
        lb.htmlText = txt;
        if (holder != null) holder.addChild(lb);
        this.labels[id] = lb;
        return (lb);
    }

    /**
        Creates a text input element.
        @param  id  the input id
        @param  txt the initial text
        @param  variant the text input style variant
        @param  holder  the element parent (null for none)
        @return the text input element
    **/
    public function createTInput(id:String, txt:String = '', variant:String = '', holder:FeathersControl = null):TextInput {
        var tx:TextInput = new TextInput();
        tx.text = txt;
        if (variant != '') tx.variant = variant;
        if (holder != null) holder.addChild(tx);
        this.inputs[id] = tx;
        this.lastInput = tx;
        return (tx);
    }

    /**
        Creates a numeric stepper.
        @param  id  the textarea id
        @param  min stepper minimum value
        @param  max stepper maximum value
        @param  step    stepper increase value
        @param  val stepper current value
        @param  holder  the element parent (null for none)
        @return the numeric stepper
    **/
    public function createNumeric(id:String, min:Float = 0, max:Float = 100, step:Float = 1, val:Float = 0,  holder:FeathersControl = null):NumericStepper {
        var st:NumericStepper = new NumericStepper();
        st.minimum = min;
        st.maximum = max;
        st.step = step;
        st.value = val;
        this.numerics[id] = st;
        if (holder != null) holder.addChild(st);
        return (st);
    }

    /**
        Creates a toggle switch.
        @param  id  the textarea id
        @param  val switch current value
        @param  holder  the element parent (null for none)
        @return the toggle switch
    **/
    public function createToggle(id:String, val:Bool = false,  holder:FeathersControl = null):ToggleSwitch {
        var tg:ToggleSwitch = new ToggleSwitch();
        tg.selected = val;
        this.toggles[id] = tg;
        if (holder != null) holder.addChild(tg);
        return (tg);
    }

    /**
        Creates a text area element.
        @param  id  the textarea id
        @param  txt the initial text
        @param  enabled input enabled?
        @param  variant the text area style variant
        @param  holder  the element parent (null for none)
        @return the text area element
    **/
    public function createTArea(id:String, txt:String = '', enabled:Bool = true, variant:String = '', holder:FeathersControl = null):TextArea {
        var tx:TextArea = new TextArea();
        tx.text = txt;
        tx.enabled = enabled;
        if (variant != '') tx.variant = variant;
        if (holder != null) holder.addChild(tx);
        tx.height = 75;
        this.tareas[id] = tx;
        return (tx);
    }

    /**
        Adds a button to the menu.
        @param  id  the button id
        @param  txt the button label
        @param  ac  the click funcion
        @param  holder  the element parent (null for none)
        @return the created button reference
    **/
    public function createButton(id:String, txt:String, ac:Dynamic, holder:FeathersControl = null):IDButton {
        var bt:IDButton = new IDButton(id, ac);
        bt.text = txt;
        bt.horizontalAlign = HorizontalAlign.CENTER;
        if (holder != null) holder.addChild(bt);
        this.buttons[id] = bt;
        this._btActions[id] = ac;
        return (bt);
    }

    /**
        Adds a button to the menu.
        @param  id  the button id
        @param  ac  the click funcion
        @param  icon    the button icon
        @param  txt the button label (null for none)
        @param  holder  the element parent (null for none)
        @return the created button reference
    **/
    public function createIconButton(id:String, ac:Dynamic, icon:Bitmap, txt:String = null, holder:FeathersControl = null):IDButton {
        var bt:IDButton = new IDButton(id, ac);
        icon.smoothing = true;
        icon.width = icon.height = 20;
        bt.icon = icon;
        if (txt != null) bt.text = txt;
        bt.horizontalAlign = HorizontalAlign.CENTER;
        if (holder != null) holder.addChild(bt);
        this.buttons[id] = bt;
        this._btActions[id] = ac;
        return (bt);
    }

    /**
        Disables a button click.
        @param  id  the button id
        @param  txt new button text (null to keep current)
        @return is the button available?
    **/
    public function disableButton(id:String, txt:String = null):Bool {
        if (this.buttons.exists(id)) {
            this.buttons[id].enabled = false;
            if (txt != null) this.buttons[id].text = txt;
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Enables a button click.
        @param  id  the button id
        @param  txt new button text (null to keep current)
        @return is the button available?
    **/
    public function enableButton(id:String, txt:String = null):Bool {
        if (this.buttons.exists(id)) {
            this.buttons[id].enabled = true;
            if (txt != null) this.buttons[id].text = txt;
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Creates a spacer element for forma.
        @param  id  the spacer id
        @param  ht  the spacer height
        @param  line    draw a line in the middle of the space?
        @param  holder  the element parent (null for none)
        @return the spacer element (sprite)
    **/
    public function createSpacer(id:String, ht:Int = 10, line:Bool = false, holder:FeathersControl = null):MeasureSprite {
        var sp:MeasureSprite = new MeasureSprite();
        sp.width = 10;
        sp.height = ht;
        if (line) {
            var posline:Int = Math.ceil(ht/2);
            sp.graphics.beginFill(0xa7a7a7);
            sp.graphics.drawRect(0, posline, sp.width, 1);
            sp.graphics.endFill();
        }
        this.spacers[id] = sp;
        if (holder != null) holder.addChild(sp);
        return (sp);
    }

    /**
        Creates a select element.
        @param  id  the select id
        @param  values  the values (array of {text, value} elements)
        @param  selected    the initially selected element (null for the first one)
        @param  holder  the element parent (null for none)
        @return the select element (PopUpListView)
    **/
    public function createSelect(id:String, values:Array<Dynamic>, selected:Dynamic = null, holder:FeathersControl = null):PopUpListView {
        var sl:PopUpListView= new PopUpListView();
        sl.dataProvider = new ArrayCollection(values);
        sl.itemToText = (item:Dynamic) -> {
            return (item.text);
        };
        this.selects[id] = sl;
        if (selected != null) this.setSelectValue(id, selected);
        if (holder != null) holder.addChild(sl);
        return (sl);
    }

    /**
        Sets the values of a select input.
        @param  id  the select id
        @param  to  the new select options
        @param  val initial value to select (optional)
        @return was the value found and selected?
    **/
    public function setSelectOptions(id:String, to:Array<Dynamic>, val:Dynamic = null):Bool {
        if (this.selects.exists(id)) {
            this.selects[id].dataProvider = new ArrayCollection(to);
            if (val != null) {
                return (this.setSelectValue(id, val));
            } else {
                return (true);
            }
        } else {
            return (false);
        }
    }

    /**
        Sets the current value of a select input.
        @param  id  the select id
        @param  val the value to select
        @return was the value found and selected?
    **/
    public function setSelectValue(id:String, val:Dynamic):Bool {
        if (this.selects.exists(id)) {
            var found:Bool = false;
            for (n in 0...this.selects[id].dataProvider.length) {
                if (this.selects[id].dataProvider.get(n).value == val) {
                    this.selects[id].selectedIndex = n;
                    found = true;
                }
            }
            return (found);
        } else {
            return (false);
        }
    }

    /**
        Sets a change listener to a select.
        @param  id  the select ID
        @param  ac  the action to call
        @param  acOpen  an action to run when the select is cliecked (before change, optional)
        @return was the list found?
    **/
    public function selectChange(id:String, ac:Dynamic, acOpen:Dynamic = null):Bool {
        if (this.selects.exists(id)) {
            this.selects[id].addEventListener(Event.CHANGE, ac);
            if (acOpen != null) this.selects[id].addEventListener(Event.OPEN, acOpen);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Creates a list element.
        @param  id  the select id
        @param  values  the values (array of {text, value} elements)
        @param  ht  list height
        @param  selected    the initially selected element (null for the first one)
        @param  holder  the element parent (null for none)
        @return the select element (ListView)
    **/
    public function createList(id:String, values:Array<Dynamic>, ht:Int = 100, selected:Dynamic = null, holder:FeathersControl = null):ListView {
        var sl:ListView= new ListView();
        sl.dataProvider = new ArrayCollection(values);
        sl.itemToText = (item:Dynamic) -> {
            return (item.text);
        };
        sl.height = ht;
        this.lists[id] = sl;
        if (selected != null) this.setListSelectValue(id, selected);
        if (holder != null) holder.addChild(sl);
        return (sl);
    }

    /**
        Sets the list display mode to icon.
        @param  id  the list ID
        @return was the list found?
    **/
    public function setListToIcon(id:String):Bool {
        if (this.lists.exists(id)) {
            var recycler = DisplayObjectRecycler.withFunction(() -> {
                var itemRenderer = new ItemRenderer();
                itemRenderer.icon = new AssetLoader();
                return (itemRenderer);
            });
            this.lists[id].itemRendererRecycler = recycler;
            recycler.update = (itemRenderer:ItemRenderer, state:ListViewItemState) -> {
                itemRenderer.text = state.text;
                itemRenderer.secondaryText = state.data.user;
                var loader = cast(itemRenderer.icon, AssetLoader);
                loader.source = state.data.asset;
            };
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Sets a double click listener to a list.
        @param  id  the list ID
        @param  ac  the action to call
        @return was the list found?
    **/
    public function listDbClick(id:String, ac:Dynamic):Bool {
        if (this.lists.exists(id)) {
            this.lists[id].addEventListener(MouseEvent.DOUBLE_CLICK, ac);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Sets a change listener to a list.
        @param  id  the list ID
        @param  ac  the action to call
        @return was the list found?
    **/
    public function listChange(id:String, ac:Dynamic):Bool {
        if (this.lists.exists(id)) {
            this.lists[id].addEventListener(Event.CHANGE, ac);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Changes the values of a list.
        @param  id  the list ID
        @param  values  the new values
        @return was the list found?
    **/
    public function setListValues(id:String, values:Array<Dynamic>):Bool {
        if (this.lists.exists(id)) {
            this.lists[id].dataProvider = new ArrayCollection(values);
            return (true);
        } else {
            return (false);
        }
    }

    /**
        Sets the current value of a list.
        @param  id  the select id
        @param  val the value to select
        @return was the value found and selected?
    **/
    public function setListSelectValue(id:String, val:Dynamic):Bool {
        if (this.lists.exists(id)) {
            var found:Bool = false;
            for (n in 0...this.lists[id].dataProvider.length) {
                if (this.lists[id].dataProvider.get(n).value == val) {
                    this.lists[id].selectedIndex = n;
                    found = true;
                }
            }
            return (found);
        } else {
            if (val == null) {
                this.lists[id].selectedItem = null;
                return (true);
            } else {
                return (false);
            }
        }
    }

    /**
        Sets the current value of a list.
        @param  id  the select id
        @param  val the values to select
    **/
    public function setListMultiValue(id:String, val:Array<Dynamic>):Void {
        if (this.lists.exists(id)) {
            var indices:Array<Int> = [ ];
            for (it in val) {
                for (n in 0...this.lists[id].dataProvider.length) {
                    if (this.lists[id].dataProvider.get(n).value == it) {
                        indices.push(n);
                    }
                }
            }
            this.lists[id].selectedIndices = indices;
        }
    }

    /**
        Creates a forma and populates it.
        @param  id  the form id
        @param  conf    ui elements configuration
        @param  bgcolor color for background fill (-1 to avoid setting)
        @param  wd  default component width (-1 to avoid setting)
        @param  padding container padding (-1 for default)
        @return a reference to the created form
    **/
    public function forge(id:String, conf:Array<Dynamic>, bgcolor:Int = -1, wd:Float = -1, padding:Int = -1):InterfaceContainer {
        // creating container
        var cont:InterfaceContainer = this.createContainer(id, padding);
        if (bgcolor >= 0) {
            var skin:RectangleSkin = new RectangleSkin();
            skin.fill = SolidColor(bgcolor);
            cont.backgroundSkin = skin;
        }
        // create interface from configuration array
        for (n in 0...conf.length) {
            switch (conf[n].tp) {
                case 'Label':
                    this.createLabel(conf[n].id, conf[n].tx, conf[n].vr, this.lastCont);
                    if (Reflect.hasField(conf[n], 'wrap')) this.labels[conf[n].id].wordWrap = conf[n].wrap;
                    if (wd >= 0) this.labels[conf[n].id].width = wd;
                case 'TInput':
                    this.createTInput(conf[n].id, conf[n].tx, conf[n].vr, this.lastCont);
                    if (wd >= 0) this.inputs[conf[n].id].width = wd;
                    if (Reflect.hasField(conf[n], 'ch')) {
                        this.inputs[conf[n].id].addEventListener(Event.CHANGE, conf[n].ch);
                    }
                case 'Numeric':
                    this.createNumeric(conf[n].id, conf[n].mn, conf[n].mx, conf[n].st, conf[n].vl, this.lastCont);
                    if (wd >= 0) this.numerics[conf[n].id].width = wd;
                    if (Reflect.hasField(conf[n], 'ch')) {
                        this.numerics[conf[n].id].addEventListener(Event.CHANGE, conf[n].ch);
                    }
                case 'TArea':
                    this.createTArea(conf[n].id, conf[n].tx, conf[n].en, conf[n].vr, this.lastCont);
                    if (Reflect.hasField(conf[n], 'ht')) this.tareas[conf[n].id].height = conf[n].ht;
                    if (wd >= 0) this.tareas[conf[n].id].width = wd;
                case 'Button':
                    this.createButton(conf[n].id, conf[n].tx, conf[n].ac, this.lastCont);
                    if (wd >= 0) this.buttons[conf[n].id].width = wd;
                    if (Reflect.hasField(conf[n], 'cl')) {
                        this.buttons[conf[n].id].addEventListener(TriggerEvent.TRIGGER, conf[n].cl);
                    }
                case 'Spacer':
                    this.createSpacer(conf[n].id, conf[n].ht, conf[n].ln, this.lastCont);
                    if (wd >= 0) this.spacers[conf[n].id].width = wd;
                case 'Select':
                    this.createSelect(conf[n].id, conf[n].vl, conf[n].sl, this.lastCont);
                    if (wd >= 0) this.selects[conf[n].id].width = wd;
                    if (Reflect.hasField(conf[n], 'ch')) {
                        this.selects[conf[n].id].addEventListener(Event.CHANGE, conf[n].ch);
                    }
                case 'Description':
                    this.createDescription(conf[n].id, conf[n].tx, conf[n].vr, this.lastCont);
                    if (wd >= 0) this.labels[conf[n].id].width = wd;
                case 'List':
                    this.createList(conf[n].id, conf[n].vl, conf[n].ht, conf[n].sl, this.lastCont);
                    if (wd >= 0) this.lists[conf[n].id].width = wd;
                    if (Reflect.hasField(conf[n], 'ch')) {
                        this.lists[conf[n].id].addEventListener(Event.CHANGE, conf[n].ch);
                    }
                case 'Toggle':
                    this.createToggle(conf[n].id, conf[n].vl, this.lastCont);
                    //if (wd >= 0) this.toggles[conf[n].id].width = wd;
                    if (Reflect.hasField(conf[n], 'ch')) {
                        this.toggles[conf[n].id].addEventListener(Event.CHANGE, conf[n].ch);
                    }
                case 'Custom':
                    this.lastCont.addChild(conf[n].cont);
                    if (Reflect.hasField(conf[n], 'wd')) {
                        conf[n].cont.width = conf[n].wd;
                    }
            }
        }
        // returning reference
        if (wd > 0) cont.width = wd;
        return (cont);
    }

    /**
        Releases resources used by the object.
    **/
    public function kill():Void {
        this._vLayout = null;
        for (key in this.columns.keys()) {
            this.columns[key].removeChildren();
            this.columns.remove(key);
        }
        this.columns = null;
        for (key in this.containers.keys()) {
            this.containers[key].removeChildren();
            this.containers.remove(key);
        }
        this.containers = null;
        this.lastCont = null;
        for (key in this.inputs.keys()) {
            this.inputs.remove(key);
        }
        this.inputs = null;
        for (key in this.numerics.keys()) {
            this.numerics.remove(key);
        }
        this.numerics = null;
        this.lastInput = null;
        for (key in this.tareas.keys()) {
            this.tareas.remove(key);
        }
        this.tareas = null;
        for (key in this.labels.keys()) {
            this.labels.remove(key);
        }
        this.labels = null;
        for (key in this.spacers.keys()) {
            this.spacers[key].graphics.clear();
            this.spacers.remove(key);
        }
        this.spacers = null;
        for (key in this.buttons.keys()) {
            this.buttons[key].removeEventListener(TriggerEvent.TRIGGER, this._btActions[key]);
            this.buttons.remove(key);
            this._btActions.remove(key);
        }
        this.buttons = null;
        for (key in this.selects.keys()) {
            this.selects.remove(key);
        }
        this.selects = null;
        for (key in this.lists.keys()) {
            this.lists.remove(key);
        }
        this.lists = null;
        for (key in this.toggles.keys()) {
            this.toggles.remove(key);
        }
        this.toggles = null;
        this._btActions = null;
    }

    /**
        Resizes the registered elements.
    **/
    public function redraw():Void {
        for (item in this.inputs) if ((item.parent != null) && (item.parent.parent != null)) item.width = item.parent.parent.width - (4 * this._padding);
        for (item in this.numerics) if ((item.parent != null) && (item.parent.parent != null)) item.width = item.parent.parent.width - (4 * this._padding);
        for (item in this.tareas) if ((item.parent != null) && (item.parent.parent != null)) item.width = item.parent.parent.width - (4 * this._padding);
        for (item in this.labels) if ((item.parent != null) && (item.parent.parent != null)) item.width = item.parent.parent.width - (4 * this._padding);
        for (item in this.selects) if ((item.parent != null) && (item.parent.parent != null)) item.width = item.parent.parent.width - (4 * this._padding);
        for (item in this.lists) if ((item.parent != null) && (item.parent.parent != null)) item.width = item.parent.parent.width - (4 * this._padding);
        for (item in this.buttons) if ((item.parent != null) && (item.parent.parent != null)) item.width = item.parent.parent.width - (4 * this._padding);
        for (item in this.spacers) if ((item.parent != null) && (item.parent.parent != null)) item.scaleX = (item.parent.parent.width - (4 * this._padding)) / 10;
    }
}