/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
package com.tilbuci.showtime;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import org.json.JSONObject;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

public class BootReceiver extends BroadcastReceiver {
    // Intercept the boot sequence and start the app if autoStart is configured
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            boolean autoStart = false;
            try {
                File configFile = new File(context.getFilesDir(), "config.json");
                if (configFile.exists()) {
                    InputStream is = new FileInputStream(configFile);
                    byte[] buf = new byte[is.available()];
                    is.read(buf);
                    is.close();
                    JSONObject config = new JSONObject(new String(buf, "UTF-8"));
                    autoStart = config.optBoolean("autoStart", false);
                }
            } catch (Exception e) {}

            if (autoStart) {
                Intent mainIntent = new Intent(context, MainActivity.class);
                mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(mainIntent);
            }
        }
    }
}