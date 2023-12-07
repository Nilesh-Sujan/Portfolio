/*
@license
dhtmlxScheduler v.4.3.1 

This software is covered by GPL license. You also can obtain Commercial or Enterprise license to use it in non-GPL project - please contact sales@dhtmlx.com. Usage without proper license is prohibited.

(c) Dinamenta, UAB.
*/
scheduler.config.year_x = 4, scheduler.config.year_y = 3, scheduler.xy.year_top = 0, scheduler.templates.year_date = function(e) {
    return scheduler.date.date_to_str(scheduler.locale.labels.year_tab + " %Y")(e)
}, scheduler.templates.year_month = scheduler.date.date_to_str("%F"), scheduler.templates.year_scale_date = scheduler.date.date_to_str("%D"), scheduler.templates.year_tooltip = function(e, t, a) {
    return a.text
},
function() {
    var e = function() {
        return "year" == scheduler._mode
    };
    scheduler.dblclick_dhx_month_head = function(t) {
        if (e()) {
            var a = t.target || t.srcElement;
            if (-1 != a.parentNode.className.indexOf("dhx_before") || -1 != a.parentNode.className.indexOf("dhx_after")) return !1;
            var r = this.templates.xml_date(a.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.getAttribute("date"));
            r.setDate(parseInt(a.innerHTML, 10));
            var n = this.date.add(r, 1, "day");
            !this.config.readonly && this.config.dblclick_create && this.addEventNow(r.valueOf(), n.valueOf(), t)
        }
    };
    var t = scheduler.changeEventId;
    scheduler.changeEventId = function() {
        t.apply(this, arguments),
            e() && this.year_view(!0)
    };
    var a = scheduler.render_data,
        r = scheduler.date.date_to_str("%Y/%m/%d"),
        n = scheduler.date.str_to_date("%Y/%m/%d");
    scheduler.render_data = function(t) {
        if (!e()) return a.apply(this, arguments);
        for (var r = 0; r < t.length; r++) this._year_render_event(t[r])
    };
    var d = scheduler.clear_view;
    scheduler.clear_view = function() {
        if (!e()) return d.apply(this, arguments);
        var t = scheduler._year_marked_cells,
            a = null;
        for (var r in t) t.hasOwnProperty(r) && (a = t[r], a.className = "dhx_month_head", a.setAttribute("date", ""));

        scheduler._year_marked_cells = {}
    }, scheduler._hideToolTip = function() {
        this._tooltip && (this._tooltip.style.display = "none", this._tooltip.date = new Date(9999, 1, 1))
    }, scheduler._showToolTip = function(e, t, a, r) {
        if (this._tooltip) {
            if (this._tooltip.date.valueOf() == e.valueOf()) return;
            this._tooltip.innerHTML = ""
        } else {
            var n = this._tooltip = document.createElement("DIV");
            n.className = "dhx_year_tooltip", document.body.appendChild(n), n.onclick = scheduler._click.dhx_cal_data
        }
        for (var d = this.getEvents(e, this.date.add(e, 1, "day")), l = "", i = 0; i < d.length; i++) {
            var s = d[i];
            if (this.filter_event(s.id, s)) {
                var o = s.color ? "background:" + s.color + ";" : "",
                    _ = s.textColor ? "color:" + s.textColor + ";" : "";
                l += "<div class='dhx_tooltip_line' style='" + o + _ + "' event_id='" + d[i].id + "'>", l += "<div class='dhx_tooltip_date' style='" + o + _ + "'>" + (d[i]._timed ? this.templates.event_date(d[i].start_date) : "") + "</div>", l += "<div class='dhx_event_icon icon_details'>&nbsp;</div>", l += this.templates.year_tooltip(d[i].start_date, d[i].end_date, d[i]) + "</div>"
            }
        }
        this._tooltip.style.display = "", this._tooltip.style.top = "0px",
            document.body.offsetWidth - t.left - this._tooltip.offsetWidth < 0 ? this._tooltip.style.left = t.left - this._tooltip.offsetWidth + "px" : this._tooltip.style.left = t.left + r.offsetWidth + "px", this._tooltip.date = e, this._tooltip.innerHTML = l, document.body.offsetHeight - t.top - this._tooltip.offsetHeight < 0 ? this._tooltip.style.top = t.top - this._tooltip.offsetHeight + r.offsetHeight + "px" : this._tooltip.style.top = t.top + "px"
    }, scheduler._year_view_tooltip_handler = function(t) {
        if (e()) {
            var t = t || event,
                a = t.target || t.srcElement;
            "a" == a.tagName.toLowerCase() && (a = a.parentNode),
                -1 != (a.className || "").indexOf("dhx_year_event") ? scheduler._showToolTip(n(a.getAttribute("date")), getOffset(a), t, a) : scheduler._hideToolTip()
        }
    }, scheduler._init_year_tooltip = function() {
        scheduler._detachDomEvent(scheduler._els.dhx_cal_data[0], "mouseover", scheduler._year_view_tooltip_handler), dhtmlxEvent(scheduler._els.dhx_cal_data[0], "mouseover", scheduler._year_view_tooltip_handler)
    }, scheduler.attachEvent("onSchedulerResize", function() {
        return e() ? (this.year_view(!0), !1) : !0
    }), scheduler._get_year_cell = function(e) {
        var t = e.getMonth() + 12 * (e.getFullYear() - this._min_date.getFullYear()) - this.week_starts._month,
            a = this._els.dhx_cal_data[0].childNodes[t],
            e = this.week_starts[t] + e.getDate() - 1;
        return a.childNodes[2].firstChild.rows[Math.floor(e / 7)].cells[e % 7].firstChild
    }, scheduler._year_marked_cells = {}, scheduler._mark_year_date = function(e, t) {
        var a = r(e),
            n = this._get_year_cell(e),
            d = this.templates.event_class(t.start_date, t.end_date, t);
        scheduler._year_marked_cells[a] || (n.className = "dhx_month_head dhx_year_event", n.setAttribute("date", a),
            scheduler._year_marked_cells[a] = n), n.className += d ? " " + d : ""
    }, scheduler._unmark_year_date = function(e) {
        this._get_year_cell(e).className = "dhx_month_head"
    }, scheduler._year_render_event = function(e) {
        var t = e.start_date;
        for (t = t.valueOf() < this._min_date.valueOf() ? this._min_date : this.date.date_part(new Date(t)); t < e.end_date;)
            if (this._mark_year_date(t, e), t = this.date.add(t, 1, "day"), t.valueOf() >= this._max_date.valueOf()) return
    }, scheduler.year_view = function(e) {
        var t;
        if (e && (t = scheduler.xy.scale_height, scheduler.xy.scale_height = -1),
            scheduler._els.dhx_cal_header[0].style.display = e ? "none" : "", scheduler.set_sizes(), e && (scheduler.xy.scale_height = t), scheduler._table_view = e, !this._load_mode || !this._load())
            if (e) {
                if (scheduler._init_year_tooltip(), scheduler._reset_year_scale(), scheduler._load_mode && scheduler._load()) return void(scheduler._render_wait = !0);
                scheduler.render_view_data()
            } else scheduler._hideToolTip()
    }, scheduler._reset_year_scale = function() {
        this._cols = [], this._colsS = {};
        var e = [],
            t = this._els.dhx_cal_data[0],
            a = this.config;
        t.scrollTop = 0,
            t.innerHTML = "";
        var r = Math.floor(parseInt(t.style.width) / a.year_x),
            n = Math.floor((parseInt(t.style.height) - scheduler.xy.year_top) / a.year_y);
        190 > n && (n = 190, r = Math.floor((parseInt(t.style.width) - scheduler.xy.scroll_width) / a.year_x));
        for (var d = r - 11, l = 0, i = document.createElement("div"), s = this.date.week_start(scheduler._currentDate()), o = 0; 7 > o; o++) this._cols[o] = Math.floor(d / (7 - o)), this._render_x_header(o, l, s, i), s = this.date.add(s, 1, "day"), d -= this._cols[o], l += this._cols[o];
        i.lastChild.className += " dhx_scale_bar_last";

        for (var _ = this.date[this._mode + "_start"](this.date.copy(this._date)), c = _, h = null, o = 0; o < a.year_y; o++)
            for (var u = 0; u < a.year_x; u++) {
                h = document.createElement("DIV"), h.style.cssText = "position:absolute;", h.setAttribute("date", this.templates.xml_format(_)), h.innerHTML = "<div class='dhx_year_month'></div><div class='dhx_year_week'>" + i.innerHTML + "</div><div class='dhx_year_body'></div>", h.childNodes[0].innerHTML = this.templates.year_month(_);
                for (var p = this.date.week_start(_), v = this._reset_month_scale(h.childNodes[2], _, p), m = h.childNodes[2].firstChild.rows, g = m.length; 6 > g; g++) {
                    m[0].parentNode.appendChild(m[0].cloneNode(!0));
                    for (var f = 0, y = m[g].childNodes.length; y > f; f++) m[g].childNodes[f].className = "dhx_after", m[g].childNodes[f].firstChild.innerHTML = scheduler.templates.month_day(v), v = scheduler.date.add(v, 1, "day")
                }
                t.appendChild(h), h.childNodes[1].style.height = h.childNodes[1].childNodes[0].offsetHeight + "px";
                var b = Math.round((n - 190) / 2);
                h.style.marginTop = b + "px", this.set_xy(h, r - 10, n - b - 10, r * u + 5, n * o + 5 + scheduler.xy.year_top), e[o * a.year_x + u] = (_.getDay() - (this.config.start_on_monday ? 1 : 0) + 7) % 7,
                    _ = this.date.add(_, 1, "month")
            }
        this._els.dhx_cal_date[0].innerHTML = this.templates[this._mode + "_date"](c, _, this._mode), this.week_starts = e, e._month = c.getMonth(), this._min_date = c, this._max_date = _
    };
    var l = scheduler.getActionData;
    scheduler.getActionData = function(t) {
        if (!e()) return l.apply(scheduler, arguments);
        var a = t ? t.target : event.srcElement,
            r = scheduler._get_year_month_date(a),
            n = scheduler._get_year_month_cell(a),
            d = scheduler._get_year_day_indexes(n);
        return d && r ? (r = scheduler.date.add(r, d.week, "week"), r = scheduler.date.add(r, d.day, "day")) : r = null, {
            date: r,
            section: null
        }
    }, scheduler._get_year_day_indexes = function(e) {
        var t = scheduler._get_year_el_node(e, this._locate_year_month_table);
        if (!t) return null;
        for (var a = 0, r = 0, a = 0, n = t.rows.length; n > a; a++) {
            for (var d = t.rows[a].getElementsByTagName("td"), r = 0, l = d.length; l > r && d[r] != e; r++);
            if (l > r) break
        }
        return n > a ? {
            day: r,
            week: a
        } : null
    }, scheduler._get_year_month_date = function(e) {
        var e = scheduler._get_year_el_node(e, scheduler._locate_year_month_root);
        if (!e) return null;
        var t = e.getAttribute("date");
        return t ? scheduler.date.week_start(scheduler.templates.xml_date(t)) : null;

    }, scheduler._locate_year_month_day = function(e) {
        return e.className && -1 != e.className.indexOf("dhx_year_event") && e.hasAttribute && e.hasAttribute("date")
    };
    var i = scheduler._locate_event;
    scheduler._locate_event = function(e) {
        var t = i.apply(scheduler, arguments);
        if (!t) {
            var a = scheduler._get_year_el_node(e, scheduler._locate_year_month_day);
            if (!a || !a.hasAttribute("date")) return null;
            var r = scheduler.templates.xml_date(a.getAttribute("date")),
                n = scheduler.getEvents(r, scheduler.date.add(r, 1, "day"));
            if (!n.length) return null;

            t = n[0].id
        }
        return t
    }, scheduler._locate_year_month_cell = function(e) {
        return "td" == e.nodeName.toLowerCase()
    }, scheduler._locate_year_month_table = function(e) {
        return "table" == e.nodeName.toLowerCase()
    }, scheduler._locate_year_month_root = function(e) {
        return e.hasAttribute && e.hasAttribute("date")
    }, scheduler._get_year_month_cell = function(e) {
        return this._get_year_el_node(e, this._locate_year_month_cell)
    }, scheduler._get_year_month_table = function(e) {
        return this._get_year_el_node(e, this._locate_year_month_table)
    }, scheduler._get_year_month_root = function(e) {
        return this._get_year_el_node(this._get_year_month_table(e), this._locate_year_month_root)
    }, scheduler._get_year_el_node = function(e, t) {
        for (; e && !t(e);) e = e.parentNode;
        return e
    }
}();
//# sourceMappingURL=../sources/ext/dhtmlxscheduler_year_view.js.map