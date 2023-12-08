/*
@license
dhtmlxScheduler v.4.3.1 

This software is covered by GPL license. You also can obtain Commercial or Enterprise license to use it in non-GPL project - please contact sales@dhtmlx.com. Usage without proper license is prohibited.

(c) Dinamenta, UAB.
*/
! function() {
    function e(e) {
        return e.replace(f, "\n").replace(b, "")
    }

    function t(e, t) {
        e = parseFloat(e), t = parseFloat(t), isNaN(t) || (e -= t);
        var a = r(e);
        return e = e - a.width + a.cols * m, isNaN(e) ? "auto" : 100 * e / m
    }

    function a(e, t, a) {
        e = parseFloat(e), t = parseFloat(t), !isNaN(t) && a && (e -= t);
        var n = r(e);
        return e = e - n.width + n.cols * m, isNaN(e) ? "auto" : 100 * e / (m - (isNaN(t) ? 0 : t))
    }

    function r(e) {
        for (var t = 0, a = scheduler._els.dhx_cal_header[0].childNodes, r = a[1] ? a[1].childNodes : a[0].childNodes, n = 0; n < r.length; n++) {
            var i = r[n].style ? r[n] : r[n].parentNode,
                d = parseFloat(i.style.width);

            if (!(e > d)) break;
            e -= d + 1, t += d + 1
        }
        return {
            width: t,
            cols: n
        }
    }

    function n(e) {
        return e = parseFloat(e), isNaN(e) ? "auto" : 100 * e / g
    }

    function i(e, t) {
        return (window.getComputedStyle ? window.getComputedStyle(e, null)[t] : e.currentStyle ? e.currentStyle[t] : null) || ""
    }

    function d(e, t) {
        for (var a = parseInt(e.style.left, 10), r = 0; r < scheduler._cols.length; r++)
            if (a -= scheduler._cols[r], 0 > a) return r;
        return t
    }

    function l(e, t) {
        for (var a = parseInt(e.style.top, 10), r = 0; r < scheduler._colsS.heights.length; r++)
            if (scheduler._colsS.heights[r] > a) return r;

        return t
    }

    function s(e) {
        return e ? "<" + e + ">" : ""
    }

    function o(e) {
        return e ? "</" + e + ">" : ""
    }

    function _(e, t, a, r) {
        var n = "<" + e + " profile='" + t + "'";
        return a && (n += " header='" + a + "'"), r && (n += " footer='" + r + "'"), n += ">"
    }

    function c() {
        var t = "",
            a = scheduler._mode;
        if (scheduler.matrix && scheduler.matrix[scheduler._mode] && (a = "cell" == scheduler.matrix[scheduler._mode].render ? "matrix" : "timeline"), t += "<scale mode='" + a + "' today='" + scheduler._els.dhx_cal_date[0].innerHTML + "'>", "week_agenda" == scheduler._mode)
            for (var r = scheduler._els.dhx_cal_data[0].getElementsByTagName("DIV"), n = 0; n < r.length; n++) "dhx_wa_scale_bar" == r[n].className && (t += "<column>" + e(r[n].innerHTML) + "</column>");
        else if ("agenda" == scheduler._mode || "map" == scheduler._mode) {
            var r = scheduler._els.dhx_cal_header[0].childNodes[0].childNodes;
            t += "<column>" + e(r[0].innerHTML) + "</column><column>" + e(r[1].innerHTML) + "</column>"
        } else if ("year" == scheduler._mode)
            for (var r = scheduler._els.dhx_cal_data[0].childNodes, n = 0; n < r.length; n++) t += "<month label='" + e(r[n].childNodes[0].innerHTML) + "'>", t += h(r[n].childNodes[1].childNodes), t += u(r[n].childNodes[2]), t += "</month>";
        else {
            t += "<x>";
            var r = scheduler._els.dhx_cal_header[0].childNodes;

            t += h(r), t += "</x>";
            var i = scheduler._els.dhx_cal_data[0];
            if (scheduler.matrix && scheduler.matrix[scheduler._mode]) {
                t += "<y>";
                for (var n = 0; n < i.firstChild.rows.length; n++) {
                    var d = i.firstChild.rows[n];
                    t += "<row><![CDATA[" + e(d.cells[0].innerHTML) + "]]></row>"
                }
                t += "</y>", g = i.firstChild.rows[0].cells[0].offsetHeight
            } else if ("TABLE" == i.firstChild.tagName) t += u(i);
            else {
                for (i = i.childNodes[i.childNodes.length - 1]; - 1 == i.className.indexOf("dhx_scale_holder");) i = i.previousSibling;
                i = i.childNodes, t += "<y>";
                for (var n = 0; n < i.length; n++) t += "\n<row><![CDATA[" + e(i[n].innerHTML) + "]]></row>";

                t += "</y>", g = i[0].offsetHeight
            }
        }
        return t += "</scale>"
    }

    function u(t) {
        for (var a = "", r = t.firstChild.rows, n = 0; n < r.length; n++) {
            for (var i = [], d = 0; d < r[n].cells.length; d++) i.push(r[n].cells[d].firstChild.innerHTML);
            a += "\n<row height='" + t.firstChild.rows[n].cells[0].offsetHeight + "'><![CDATA[" + e(i.join("|")) + "]]></row>", g = t.firstChild.rows[0].cells[0].offsetHeight
        }
        return a
    }

    function h(t) {
        var a, r = "";
        scheduler.matrix && scheduler.matrix[scheduler._mode] && (scheduler.matrix[scheduler._mode].second_scale && (a = t[1].childNodes),
            t = t[0].childNodes);
        for (var n = 0; n < t.length; n++) r += "\n<column><![CDATA[" + e(t[n].innerHTML) + "]]></column>";
        if (m = t[0].offsetWidth, a)
            for (var i = 0, d = t[0].offsetWidth, l = 1, n = 0; n < a.length; n++) r += "\n<column second_scale='" + l + "'><![CDATA[" + e(a[n].innerHTML) + "]]></column>", i += a[n].offsetWidth, i >= d && (d += t[l] ? t[l].offsetWidth : 0, l++), m = a[0].offsetWidth;
        return r
    }

    function p(r) {
        var s = "",
            o = scheduler._rendered,
            _ = scheduler.matrix && scheduler.matrix[scheduler._mode];
        if ("agenda" == scheduler._mode || "map" == scheduler._mode)
            for (var c = 0; c < o.length; c++) s += "<event><head><![CDATA[" + e(o[c].childNodes[0].innerHTML) + "]]></head><body><![CDATA[" + e(o[c].childNodes[2].innerHTML) + "]]></body></event>";
        else if ("week_agenda" == scheduler._mode)
            for (var c = 0; c < o.length; c++) s += "<event day='" + o[c].parentNode.getAttribute("day") + "'><body>" + e(o[c].innerHTML) + "</body></event>";
        else if ("year" == scheduler._mode)
            for (var o = scheduler.get_visible_events(), c = 0; c < o.length; c++) {
                var u = o[c].start_date;
                for (u.valueOf() < scheduler._min_date.valueOf() && (u = scheduler._min_date); u < o[c].end_date;) {
                    var h = u.getMonth() + 12 * (u.getFullYear() - scheduler._min_date.getFullYear()) - scheduler.week_starts._month,
                        p = scheduler.week_starts[h] + u.getDate() - 1,
                        v = r ? i(scheduler._get_year_cell(u), "color") : "",
                        m = r ? i(scheduler._get_year_cell(u), "backgroundColor") : "";

                    if (s += "<event day='" + p % 7 + "' week='" + Math.floor(p / 7) + "' month='" + h + "' backgroundColor='" + m + "' color='" + v + "'></event>", u = scheduler.date.add(u, 1, "day"), u.valueOf() >= scheduler._max_date.valueOf()) break
                }
            } else if (_ && "cell" == _.render)
                for (var o = scheduler._els.dhx_cal_data[0].getElementsByTagName("TD"), c = 0; c < o.length; c++) {
                    var v = r ? i(o[c], "color") : "",
                        m = r ? i(o[c], "backgroundColor") : "";
                    s += "\n<event><body backgroundColor='" + m + "' color='" + v + "'><![CDATA[" + e(o[c].innerHTML) + "]]></body></event>"
                } else
                    for (var c = 0; c < o.length; c++) {
                        var b, f;
                        if (scheduler.matrix && scheduler.matrix[scheduler._mode]) b = t(o[c].style.left), f = t(o[c].offsetWidth) - 1;
                        else {
                            var y = scheduler.config.use_select_menu_space ? 0 : 26;
                            b = a(o[c].style.left, y, !0), f = a(o[c].style.width, y) - 1
                        }
                        if (!isNaN(1 * f)) {
                            var x = n(o[c].style.top),
                                k = n(o[c].style.height),
                                w = o[c].className.split(" ")[0].replace("dhx_cal_", "");
                            if ("dhx_tooltip_line" !== w) {
                                var D = scheduler.getEvent(o[c].getAttribute("event_id"));
                                if (D) {
                                    var p = D._sday,
                                        E = D._sweek,
                                        M = D._length || 0;
                                    if ("month" == scheduler._mode) k = parseInt(o[c].offsetHeight, 10),
                                        x = parseInt(o[c].style.top, 10) - scheduler.xy.month_head_height, p = d(o[c], p), E = l(o[c], E);
                                    else if (scheduler.matrix && scheduler.matrix[scheduler._mode]) {
                                        p = 0;
                                        var S = o[c].parentNode.parentNode.parentNode;
                                        E = S.rowIndex;
                                        var N = g;
                                        g = o[c].parentNode.offsetHeight, x = n(o[c].style.top), x -= .2 * x, g = N
                                    } else {
                                        if (o[c].parentNode == scheduler._els.dhx_cal_data[0]) continue;
                                        var O = scheduler._els.dhx_cal_data[0].childNodes[0],
                                            T = parseFloat(-1 != O.className.indexOf("dhx_scale_holder") ? O.style.left : 0);
                                        b += t(o[c].parentNode.style.left, T);

                                    }
                                    if (s += "\n<event week='" + E + "' day='" + p + "' type='" + w + "' x='" + b + "' y='" + x + "' width='" + f + "' height='" + k + "' len='" + M + "'>", "event" == w) {
                                        s += "<header><![CDATA[" + e(o[c].childNodes[1].innerHTML) + "]]></header>";
                                        var v = r ? i(o[c].childNodes[2], "color") : "",
                                            m = r ? i(o[c].childNodes[2], "backgroundColor") : "";
                                        s += "<body backgroundColor='" + m + "' color='" + v + "'><![CDATA[" + e(o[c].childNodes[2].innerHTML) + "]]></body>"
                                    } else {
                                        var v = r ? i(o[c], "color") : "",
                                            m = r ? i(o[c], "backgroundColor") : "";
                                        s += "<body backgroundColor='" + m + "' color='" + v + "'><![CDATA[" + e(o[c].innerHTML) + "]]></body>";

                                    }
                                    s += "</event>"
                                }
                            }
                        }
                    }
        return s
    }

    function v(e, t, a, r, n, i, d) {
        var l = !1;
        "fullcolor" == n && (l = !0, n = "color"), n = n || "color";
        var u = scheduler.uid(),
            h = document.createElement("div");
        h.style.display = "none", document.body.appendChild(h), h.innerHTML = '<form id="' + u + '" method="post" target="_blank" action="' + r + '" accept-charset="utf-8" enctype="application/x-www-form-urlencoded"><input type="hidden" name="mycoolxmlbody"/> </form>';
        var v = "";
        if (e) {
            var m = scheduler._date,
                g = scheduler._mode;
            t = scheduler.date[a + "_start"](t), t = scheduler.date["get_" + a + "_end"] ? scheduler.date["get_" + a + "_end"](t) : scheduler.date.add(t, 1, a),
                v = _("pages", n, i, d);
            for (var b = new Date(e); + t > +b; b = scheduler.date.add(b, 1, a)) scheduler.setCurrentView(b, a), v += s("page") + c().replace("–", "-") + p(l) + o("page");
            v += o("pages"), scheduler.setCurrentView(m, g)
        } else v = _("data", n, i, d) + c().replace("–", "-") + p(l) + o("data");
        document.getElementById(u).firstChild.value = encodeURIComponent(v), document.getElementById(u).submit(), h.parentNode.removeChild(h)
    }
    var m, g, b = new RegExp("<[^>]*>", "g"),
        f = new RegExp("<br[^>]*>", "g");
    scheduler.toPDF = function(e, t, a, r) {
        return v.apply(this, [null, null, null, e, t, a, r]);

    }, scheduler.toPDFRange = function(e, t, a, r, n, i, d) {
        return "string" == typeof e && (e = scheduler.templates.api_date(e), t = scheduler.templates.api_date(t)), v.apply(this, arguments)
    }
}();
//# sourceMappingURL=../sources/ext/dhtmlxscheduler_pdf.js.map