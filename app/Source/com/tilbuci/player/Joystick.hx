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
        this._timer = new Timer(75);
        this._timer.run = this.checkInput;
    }

    private function checkInput():Void {
        for (k in this._controls.keys()) {
            if ((this._controls[k].value < -0.5) || (this._controls[k].value > 0.5)) {
                switch (k) {
                    case 'B0':
                        GlobalPlayer.parser.checkJoystick('0');
                    case 'B1':
                        GlobalPlayer.parser.checkJoystick('1');
                    case 'B2':
                        GlobalPlayer.parser.checkJoystick('2');
                    case 'B3':
                        GlobalPlayer.parser.checkJoystick('3');
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
    }

}