/* window.vala
 *
 * Copyright 2025 Butiu Octavian Alexandru
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/org/gnome/Example/window.ui")]
public class Koboreadingstats.Window : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Gtk.ListBox sidebar_listbox;

    public Window (Gtk.Application app) {
        Object (application: app);

        for (int i = 0; i < 100; i++) {
            var label = new Adw.ActionRow();
            label.title = i.to_string();
            var button = new Gtk.Button();
            button.icon_name = "list-add-symbolic";
            button.valign = 3;
            button.name = i.to_string();

            label.add_suffix(button);
            label.activatable_widget = button;
            //label.text = i.to_string();
            sidebar_listbox.append(label);
        }
    }
}
