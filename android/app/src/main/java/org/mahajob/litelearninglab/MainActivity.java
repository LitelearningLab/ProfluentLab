package org.mahajob.litelearninglab;
import android.provider.Settings.Secure;
import android.view.WindowManager.LayoutParams; // for disable screenshot and video recording
import android.content.Context;
import android.media.AudioManager;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "lite";
    private MethodChannel channels;
    static MainActivity instance;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        //GeneratedPluginRegistrant.registerWith(flutterEngine);
        channels = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger() , CHANNEL);

        channels.setMethodCallHandler(this);
    }

    //------------ TO Enable/disable ScreenShot/ScreenRecord 

     @Override
     protected void onCreate(Bundle savedInstanceState) {
         super.onCreate(savedInstanceState);
         instance = this;
       //  getWindow().addFlags(LayoutParams.FLAG_SECURE); // for disable screenshot and video recording
     }

    //-------------------------------------------------------

    public static MainActivity getInstance() {
        return instance;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call , @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "status":
                AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

                if (audioManager.isWiredHeadsetOn()) result.success(true);
                else result.success(false);
                break;
            case "getUID":
                String android_id = Secure.getString(getContext().getContentResolver(),
                        Secure.ANDROID_ID);
               result.success(android_id);
                break;



            default:
                result.notImplemented();
                break;
        }
    }

}
