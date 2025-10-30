/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package com.tilbuci.player;

// OPENFL
import com.tilbuci.data.GlobalPlayer;
import haxe.Timer;
import openfl.ui.GameInputControl;
import openfl.ui.GameInputDevice;
import openfl.ui.GameInput;
import openfl.events.GameInputEvent;

/**
    Game controller support.
**/
class Joystick {

    private var _gameInput:GameInput;
    private var _device:GameInputDevice;
    private var _controls:Map<String, GameInputControl> = [ ];

    private var _timer:Timer;

    private var _counter:Int = 0;
    private var _buttonclick:Array<Bool> = [ true, true, true, true ];

    private var _counterd:Int = 0;
    private var _directionclick:Array<Bool> = [ true, true, true, true ];

    public function new() {
        this._gameInput = new GameInput();
        this._gameInput.addEventListener(GameInputEvent.DEVICE_ADDED, onDeviceAdded);
        this._gameInput.addEventListener(GameInputEvent.DEVICE_REMOVED, onDeviceRemoved);
    }

    private function onDeviceRemoved(e:GameInputEvent):Void {
        if (this._timer != null) {
            try {
                this._timer.stop();
            } catch (e) { }
        }
        this._timer = null;
    }

    private function onDeviceAdded(e:GameInputEvent):Void {
        this._device = e.device;
        this._device.enabled = true;

        for (k in this._controls.keys()) this._controls.remove(k);
        
        for (i in 0...this._device.numControls) {
            var control = this._device.getControlAt(i);
            switch (control.id) {
                case 'BUTTON_0': this._controls['B0'] = control;
                case 'BUTTON_1': this._controls['B1'] = control;
                case 'BUTTON_2': this._controls['B2'] = control;
                case 'BUTTON_3': this._controls['B3'] = control;
                case 'DPAD_UP': this._controls['DU'] = control;
                case 'DPAD_DOWN': this._controls['DD'] = control;
                case 'DPAD_LEFT': this._controls['DL'] = control;
                case 'DPAD_RIGHT': this._controls['DR'] = control;
                case 'AXIS_0': this._controls['HL'] = control;
                case 'AXIS_1': this._controls['VL'] = control;
                case 'AXIS_2': this._controls['HR'] = control;
                case 'AXIS_3': this._controls['VR'] = control;
            }
            this._controls[control.id] = control;
        }

        if (this._timer != null) {
            try {
                this._timer.stop();
            } catch (e) { }
        }

        this._counter = 0;
        this._buttonclick = [ true, true, true, true ];
        this._counterd = 0;
        this._directionclick = [ true, true, true, true ];

        this._timer = new Timer(32);
        this._timer.run = this.checkInput;
    }

    private function checkInput():Void {
        if (GlobalPlayer.usingTarget > 0) {
            for (k in this._controls.keys()) {
                if ((this._controls[k].value < -0.5) || (this._controls[k].value > 0.5)) {
                    switch (k) {
                        case 'B0':
                            if (this._buttonclick[0]) {
                                GlobalPlayer.parser.checkJoystick('0');
                                this._buttonclick[0] = false;
                                this._counter = 0;
                            }
                        case 'B1':
                            if (this._buttonclick[1]) {
                                GlobalPlayer.parser.checkJoystick('1');
                                this._buttonclick[1] = false;
                                this._counter = 0;
                            }
                        case 'B2':
                            if (this._buttonclick[2]) {
                                GlobalPlayer.parser.checkJoystick('2');
                                this._buttonclick[2] = false;
                                this._counter = 0;
                            }
                        case 'B3':
                            if (this._buttonclick[3]) {
                                GlobalPlayer.parser.checkJoystick('3');
                                this._buttonclick[3] = false;
                                this._counter = 0;
                            }
                        case 'DU':
                            GlobalPlayer.parser.checkJoystick('u');
                        case 'DD':
                            GlobalPlayer.parser.checkJoystick('d');
                        case 'DL':
                            GlobalPlayer.parser.checkJoystick('l');
                        case 'DR':
                            GlobalPlayer.parser.checkJoystick('r');
                        case 'HL':
                            if (this._controls[k].value < 0) {
                                GlobalPlayer.parser.checkJoystick('l');
                            } else {
                                GlobalPlayer.parser.checkJoystick('r');
                            }
                        case 'VL':
                            if (this._controls[k].value < 0) {
                                GlobalPlayer.parser.checkJoystick('u');
                            } else {
                                GlobalPlayer.parser.checkJoystick('d');
                            }
                        case 'HR':
                            if (this._controls[k].value < 0) {
                                GlobalPlayer.parser.checkJoystick('l');
                            } else {
                                GlobalPlayer.parser.checkJoystick('r');
                            }
                        case 'VR':
                            if (this._controls[k].value < 0) {
                                GlobalPlayer.parser.checkJoystick('u');
                            } else {
                                GlobalPlayer.parser.checkJoystick('d');
                            }
                    }
                }
            }
        } else {
            for (k in this._controls.keys()) {
                if ((this._controls[k].value < -0.5) || (this._controls[k].value > 0.5)) {
                    switch (k) {
                        case 'B0':
                            if (this._buttonclick[0]) {
                                GlobalPlayer.parser.checkJoystick('0');
                                this._buttonclick[0] = false;
                                this._counter = 0;
                            }
                        case 'B1':
                            if (this._buttonclick[1]) {
                                GlobalPlayer.parser.checkJoystick('1');
                                this._buttonclick[1] = false;
                                this._counter = 0;
                            }
                        case 'B2':
                            if (this._buttonclick[2]) {
                                GlobalPlayer.parser.checkJoystick('2');
                                this._buttonclick[2] = false;
                                this._counter = 0;
                            }
                        case 'B3':
                            if (this._buttonclick[3]) {
                                GlobalPlayer.parser.checkJoystick('3');
                                this._buttonclick[3] = false;
                                this._counter = 0;
                            }
                        case 'DU':
                            if (this._directionclick[0]) {
                                GlobalPlayer.parser.checkJoystick('u');
                                this._directionclick[0] = false;
                                this._counterd = 0;
                            }
                        case 'DD':
                            if (this._directionclick[2]) {
                                GlobalPlayer.parser.checkJoystick('d');
                                this._directionclick[2] = false;
                                this._counterd = 0;
                            }
                        case 'DL':
                            if (this._directionclick[3]) {
                                GlobalPlayer.parser.checkJoystick('l');
                                this._directionclick[3] = false;
                                this._counterd = 0;
                            }
                        case 'DR':
                            if (this._directionclick[1]) {
                                GlobalPlayer.parser.checkJoystick('r');
                                this._directionclick[1] = false;
                                this._counterd = 0;
                            }
                        case 'HL':
                            if (this._controls[k].value < 0) {
                                if (this._directionclick[3]) {
                                    GlobalPlayer.parser.checkJoystick('l');
                                    this._directionclick[3] = false;
                                    this._counterd = 0;
                                }
                            } else {
                                if (this._directionclick[1]) {
                                    GlobalPlayer.parser.checkJoystick('r');
                                    this._directionclick[1] = false;
                                    this._counterd = 0;
                                }
                            }
                        case 'VL':
                            if (this._controls[k].value < 0) {
                                if (this._directionclick[0]) {
                                    GlobalPlayer.parser.checkJoystick('u');
                                    this._directionclick[0] = false;
                                    this._counterd = 0;
                                }
                            } else {
                                if (this._directionclick[2]) {
                                    GlobalPlayer.parser.checkJoystick('d');
                                    this._directionclick[2] = false;
                                    this._counterd = 0;
                                }
                            }
                        case 'HR':
                            if (this._controls[k].value < 0) {
                                if (this._directionclick[3]) {
                                    GlobalPlayer.parser.checkJoystick('l');
                                    this._directionclick[3] = false;
                                    this._counterd = 0;
                                }
                            } else {
                                if (this._directionclick[1]) {
                                    GlobalPlayer.parser.checkJoystick('r');
                                    this._directionclick[1] = false;
                                    this._counterd = 0;
                                }
                            }
                        case 'VR':
                            if (this._controls[k].value < 0) {
                                if (this._directionclick[0]) {
                                    GlobalPlayer.parser.checkJoystick('u');
                                    this._directionclick[0] = false;
                                    this._counterd = 0;
                                }
                            } else {
                                if (this._directionclick[2]) {
                                    GlobalPlayer.parser.checkJoystick('d');
                                    this._directionclick[2] = false;
                                    this._counterd = 0;
                                }
                            }
                    }
                }
            }
        }

        this._counter++;
        if (this._counter >= 10) {
            this._buttonclick = [ true, true, true, true ];
            this._counter = 0;
        }

        this._counterd++;
        if (this._counterd >= 10) {
            this._directionclick = [ true, true, true, true ];
            this._counterd = 0;
        }
    }

}