


[GtkTemplate (ui = "/org/butiu/koboreadingstats/sessions-page.ui")]
public class Koboreadingstats.SessionsPage : Adw.NavigationPage {


    [GtkChild]
    public unowned Gtk.Box content_box;

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

    public string day_string { get; private set; }
    public string title_string {get; private set; }
    

    public SessionsPage(DateTime day, Gee.ArrayList<TimeSpan?> sessions) {
        var total_read = sessions.fold<TimeSpan?>((acc, x) => acc + x, 0);

        
        day_string = day.format("%d.%m.%Y");

        foreach (var total in sessions) {

            var label = new Gtk.Label(TimeSpanUtil(total).to_string());
            label.add_css_class("title-1");
            content_box.append(label);

        }

        title_string = @"On $(day.format("%d.%m.%Y")) read for $(TimeSpanUtil(total_read))";

    }


    construct {
        title_string = "No reading data";


    }


}