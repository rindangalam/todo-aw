package com.todoaw.todoaw.widget

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.todoaw.todoaw.R

class QuickAddWidget : BaseWidgetProvider() {
    override val layoutRes = R.layout.widget_quick_add

    override fun render(
        context: Context,
        views: RemoteViews,
        data: SharedPreferences,
        widgetId: Int,
    ) {
        val p = WidgetTheme.palette(data)
        WidgetTheme.applyRoot(views, p, R.id.widget_quick_add_root)
        views.setTextViewText(R.id.widget_quick_add_placeholder, "Tambah tugas baru...")
        views.setTextColor(R.id.widget_quick_add_placeholder, p.muted)

        val intent = Intent(context, QuickInputActivity::class.java).apply {
            action = QuickInputActivity.ACTION_MODE
            putExtra(QuickInputActivity.EXTRA_MODE, QuickInputActivity.MODE_TASK)
        }
        val pi = PendingIntent.getActivity(
            context, 6100 + widgetId, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_quick_add_root, pi)
        views.setOnClickPendingIntent(R.id.widget_quick_add_plus, pi)
    }
}
