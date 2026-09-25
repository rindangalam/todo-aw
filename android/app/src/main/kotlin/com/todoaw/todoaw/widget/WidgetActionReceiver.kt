package com.todoaw.todoaw.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin

class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != WidgetActionsNative.ACTION_TOGGLE_TASK) return
        val uuid = intent.getStringExtra("uuid") ?: return
        try {
            val data = HomeWidgetPlugin.getData(context)
            data.edit()
                .putString("pending_action", WidgetActionsNative.TOGGLE_TASK)
                .putString("pending_uuid", uuid)
                .apply()
        } catch (_: Exception) {
        }
        // Launch app so Dart can consume pending_action/pending_uuid.
        val launch = Intent(context, com.todoaw.todoaw.MainActivity::class.java).apply {
            action = WidgetActionsNative.TOGGLE_TASK
            putExtra("uuid", uuid)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        try {
            context.startActivity(launch)
        } catch (_: Exception) {
        }
    }
}
