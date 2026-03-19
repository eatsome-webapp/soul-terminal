package com.termux.app.terminal;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.termux.R;

import java.util.ArrayList;
import java.util.List;

public class CommandPaletteAdapter extends BaseAdapter {

    public static class PaletteItem {
        public final String label;
        public final String subtitle;
        public final Runnable action;

        public PaletteItem(String label, String subtitle, Runnable action) {
            this.label = label;
            this.subtitle = subtitle;
            this.action = action;
        }
    }

    public interface OnItemClickListener {
        void onItemClick(PaletteItem item);
    }

    private final List<PaletteItem> mAllItems;
    private final List<PaletteItem> mFilteredItems;
    private OnItemClickListener mClickListener;

    public CommandPaletteAdapter(List<PaletteItem> items) {
        mAllItems = new ArrayList<>(items);
        mFilteredItems = new ArrayList<>(items);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        mClickListener = listener;
    }

    public void filter(String query) {
        mFilteredItems.clear();
        if (query == null || query.isEmpty()) {
            mFilteredItems.addAll(mAllItems);
        } else {
            String lowerQuery = query.toLowerCase();
            for (PaletteItem item : mAllItems) {
                if (item.label.toLowerCase().contains(lowerQuery) ||
                    (item.subtitle != null && item.subtitle.toLowerCase().contains(lowerQuery))) {
                    mFilteredItems.add(item);
                }
            }
        }
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return mFilteredItems.size();
    }

    @Override
    public PaletteItem getItem(int position) {
        return mFilteredItems.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.command_palette_item, parent, false);
        }

        PaletteItem item = mFilteredItems.get(position);
        TextView label = convertView.findViewById(R.id.palette_item_label);
        TextView subtitle = convertView.findViewById(R.id.palette_item_subtitle);

        label.setText(item.label);
        if (item.subtitle != null && !item.subtitle.isEmpty()) {
            subtitle.setText(item.subtitle);
            subtitle.setVisibility(View.VISIBLE);
        } else {
            subtitle.setVisibility(View.GONE);
        }

        return convertView;
    }
}
