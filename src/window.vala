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
    private unowned Gtk.Box sidebar_listbox;

    uint bytes_to_int(uint8[] b) {
        uint x0 = b[0];
        uint x1 = b[1];
        uint x2 = b[2];
        uint x3 = b[3];
        //stdout.printf("%d %d %d %d\n", x0, x1, x2, x3);
        return (x0 << 24) | (x1 << 16) | (x2 << 8) | (x3 << 0);
    }
    

    public Window (Gtk.Application app) {
        Object (application: app);
        var fs = FileStream.open("/home/octavian/Projects/parse-kobo/1021.data", "r");

        fs.seek(0, FileSeek.END);

        var file_size = fs.tell();

        fs.seek(0, FileSeek.SET);

        var buffer = new uint8[file_size];

        fs.read(buffer, buffer.length);
        
        var t =  new DateTime.from_unix_local(123);
        int prev = 0;
        const int QMETA_TYPE_UINT = 3, QUINT_OFFSET = 2;
        for (int i = 50; i < 640; i += 9) {
            uint ts = bytes_to_int(buffer[QUINT_OFFSET + i:]);

            if (buffer[i] == QMETA_TYPE_UINT) {

                stdout.printf("value of type is %d,  %d, delta %d : %u , %s\n", (int) buffer[i] ,i, i - prev, ts, new DateTime.from_unix_local(ts).format_iso8601());
                prev = i;
            }
        }


        for (int i = 0; i < 100; i++) {
            
            var button = new Gtk.Button();
            button.icon_name = "list-add-symbolic";
            
            button.name = i.to_string();
            button.label = "10.10.2025";
            button.add_css_class ("pill");

            //label.text = i.to_string();
            sidebar_listbox.append(button);
        }
    }
}
