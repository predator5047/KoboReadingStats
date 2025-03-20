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

[GtkTemplate (ui = "/org/butiu/koboreadingstats/window.ui")]
public class Koboreadingstats.Window : Adw.ApplicationWindow {
    [GtkChild]
    private unowned Gtk.Box sidebar_listbox;
    [GtkChild]
    private unowned Adw.OverlaySplitView split_view;

    struct TimeSpanUtil {
        TimeSpan t;

        public TimeSpanUtil(TimeSpan t) {
            this.t = t;
        }

        public uint64 seconds {
            get { return t / TimeSpan.SECOND % 60; }
        }

        public uint64 minutes {
            get { return t / TimeSpan.MINUTE % 60; }
        }

        public uint64 hours {
            get { return t / TimeSpan.HOUR; }
        }

        public string to_string() {
            string res = "";
            
            if (hours > 0) {
                res += @"$(hours)h";
            }

            if (minutes > 0 || hours > 0) {
                res += @" $(minutes)m";
            }

            res += @" $(seconds)s";


            return res.strip();
        }
    }

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
    }

    [GtkCallback]
    public async void on_select_dir_clicked() {
        var dialog = new Gtk.FileDialog();
        var folder = yield dialog.select_folder(this, null);

        var file = File.new_build_filename(folder.get_path(), ".kobo", "KoboReader.sqlite");
        
        if (file != null) {
            
            stdout.printf("Selected file %s %d\n", file.get_path(), (int)file.query_exists(null));
        }

        var task = new GLib.Task(this, null, setup_ui);
        task.set_data<string>("db_path", file.get_path());

        task.run_in_thread((task, source) => {
            var this_ = source as Koboreadingstats.Window;
            //var p = file.get_path();
            var res = this_.load_db(task.get_data<string>("db_path"));

            task.return_pointer((owned) res, null);
        });

    } 

    public void setup_ui(Object? _, Task task) {
        
        var map = (owned) task.propagate_pointer() as Gee.TreeMap<DateTime, Gee.ArrayList<TimeSpan?>>;
        
        foreach (var item in map) {

            var button = new Gtk.Button() {
                icon_name = "list-add-symbolic",
                label = item.key.format("%d.%m.%Y"),
                css_classes = {"pill"},
            };

            button.clicked.connect(this.handler);
            button.set_data("date",  item.key);
            button.set_data("value", item.value);
            

            sidebar_listbox.append(button);
        }
        sidebar_listbox.get_first_child()?.activate();
        stdout.printf("Done loading db %u\n", map.ref_count);

    }


       
    private Gee.ArrayList<DateTime> dates_from_qvariant(uint8[] buffer) {
        var dates = new Gee.ArrayList<DateTime>();

        const int QMETA_TYPE_UINT = 3, QUINT_OFFSET = 2;
        for (int i = 50; i < buffer.length - 9; i += 9) {
            uint ts = bytes_to_int(buffer[QUINT_OFFSET + i:]);

            if (buffer[i] == QMETA_TYPE_UINT) {

                //stdout.printf("value of type is %d,  %d, delta %d : %u , %s\n", (int) buffer[i] ,i, i - prev, ts, new DateTime.from_unix_local(ts).format_iso8601());
                var date = new DateTime.from_unix_local(ts);
                if (date != null && date.get_year() > 2000 && date.get_year() < 2030)
                    dates.add(date);
            }
        }

        return dates;
    }
   
    

    public Gee.TreeMap<DateTime, Gee.ArrayList<TimeSpan?>> load_db(string db_path = "/home/octavian/Projects/parse-kobo/KoboReader.sqlite") {

        Sqlite.Database db;
        //string db_path = "/run/media/octavian/KOBOeReader/.kobo/KoboReader.sqlite";
        //int err = Sqlite.Database.open("/home/octavian/Projects/parse-kobo/KoboReader.sqlite", out db);
        int err = Sqlite.Database.open(db_path, out db);
        stdout.printf("%d\n", err);
        assert(err == 0);


        string query = "SELECT a.ExtraData, b.ExtraData, a.ContentId FROM Event a, Event b WHERE a.ContentId = b.ContentId AND a.EventType = 1020 AND b.EventType = 1021";
        Sqlite.Statement stmt;
        err = db.prepare_v2(query, -1, out stmt, null);
        assert(err == 0);
        var map = new Gee.TreeMap<DateTime, Gee.ArrayList<TimeSpan?>>((x, y) => y.compare(x));

        while (stmt.step() == Sqlite.ROW) {
            unowned var start_buffer = (uint8[]) stmt.column_blob(0);
            start_buffer.length = stmt.column_bytes(0);

            unowned var end_buffer = (uint8[]) stmt.column_blob(1);
            end_buffer.length = stmt.column_bytes(1);

            var end_dates = dates_from_qvariant(end_buffer);
            
            var start_dates = dates_from_qvariant(start_buffer);
            
            
            end_dates.sort((x, y) => y.compare(x));
            start_dates.sort((x, y) => y.compare(x));


            for (int i = 0; i < start_dates.size && i < end_dates.size; i++) {
                var delta = end_dates[i].difference(start_dates[i]);
               
                var date_part = new DateTime.local(start_dates[i].get_year(), start_dates[i].get_month(), start_dates[i].get_day_of_month(), 0, 0, 0);

                if (!map.has_key(date_part)) {
                    map.set(date_part, new Gee.ArrayList<TimeSpan?>());
                }
                

                var sessions_read = map.get(date_part);
                if (delta >= TimeSpan.SECOND * 40)
                    sessions_read.add(delta);

            }
        }

        return map;
    }


    private void handler(Gtk.Button button) {
        
        var sessions = button.get_data<Gee.ArrayList<TimeSpan?>>("value");

        var total_read = sessions.fold<TimeSpan?>((acc, x) => acc + x, 0);
        
        var day = button.get_data<DateTime>("date");

        string title = @"On $(day.format("%d.%m.%Y")) read for $(TimeSpanUtil(total_read))";

        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.START,            
        };

        foreach (var total in sessions) {
            var label = new Gtk.Label(TimeSpanUtil(total).to_string());
            label.add_css_class("title-1");
            box.append(label);
        }

        split_view.content = new Adw.StatusPage () {
            title = title,
            child = box,
        };
    }
}
