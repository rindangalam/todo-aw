package com.todoaw.todoaw.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != WidgetActionsNative.ACTION_TOGGLE_TASK) return
        val uuid = intent.getStringExtra("uuid") ?: return
        // Backup copy in case the click event stream is not yet listening.
        try {
            val data = HomeWidgetPlugin.getData(context)
            data.edit()
                .putString("pending_action", WidgetActionsNative.TOGGLE_TASK)
                .putString("pending_uuid", uuid)
                .apply()
        } catch (_: Exception) {
        }
        // Launch via home_widget so Dart receives todoaw://widget/toggle_task?uuid=...
        // (widgetClicked stream on warm start, initiallyLaunchedFromHomeWidget on cold).
        try {
            val uri = Uri.Builder()
                .scheme("todoaw")
                .authority("widget")
                .appendPath(WidgetActionsNative.TOGGLE_TASK)
                .appendQueryParameter("uuid", uuid)
                .build()
            HomeWidgetLaunchIntent.getActivity(
                context,
                com.todoaw.todoaw.MainActivity::class.java,
                uri,
            ).send()
        } catch (_: Exception) {
        }
    }
}
