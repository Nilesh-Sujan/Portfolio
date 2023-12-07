/*
@license
dhtmlxScheduler v.4.3.1 

This software is covered by GPL license. You also can obtain Commercial or Enterprise license to use it in non-GPL project - please contact sales@dhtmlx.com. Usage without proper license is prohibited.

(c) Dinamenta, UAB.
*/
scheduler.attachEvent("onTemplatesReady", function() {
    this.layers.sort(function(e, t) {
            return e.zIndex - t.zIndex
        }), scheduler._dp_init = function(e) {
            e._methods = ["_set_event_text_style", "", "changeEventId", "deleteEvent"], this.attachEvent("onEventAdded", function(t) {
                !this._loading && this.validId(t) && this.getEvent(t) && this.getEvent(t).layer == e.layer && e.setUpdated(t, !0, "inserted")
            }), this.attachEvent("onBeforeEventDelete", function(t) {
                if (this.getEvent(t) && this.getEvent(t).layer == e.layer) {
                    if (!this.validId(t)) return;

                    var a = e.getState(t);
                    return "inserted" == a || this._new_event ? (e.setUpdated(t, !1), !0) : "deleted" == a ? !1 : "true_deleted" == a ? !0 : (e.setUpdated(t, !0, "deleted"), !1)
                }
                return !0
            }), this.attachEvent("onEventChanged", function(t) {
                !this._loading && this.validId(t) && this.getEvent(t) && this.getEvent(t).layer == e.layer && e.setUpdated(t, !0, "updated")
            }), e._getRowData = function(e, t) {
                var a = this.obj.getEvent(e),
                    i = {};
                for (var n in a) 0 !== n.indexOf("_") && (a[n] && a[n].getUTCFullYear ? i[n] = this.obj.templates.xml_format(a[n]) : i[n] = a[n]);
                return i;

            }, e._clearUpdateFlag = function() {}, e.attachEvent("insertCallback", scheduler._update_callback), e.attachEvent("updateCallback", scheduler._update_callback), e.attachEvent("deleteCallback", function(e, t) {
                this.obj.setUserData(t, this.action_param, "true_deleted"), this.obj.deleteEvent(t)
            })
        },
        function() {
            var e = function(t) {
                if (null === t || "object" != typeof t) return t;
                var a = new t.constructor;
                for (var i in t) a[i] = e(t[i]);
                return a
            };
            scheduler._dataprocessors = [], scheduler._layers_zindex = {};
            for (var t = 0; t < scheduler.layers.length; t++) {
                if (scheduler.config["lightbox_" + scheduler.layers[t].name] = {}, scheduler.config["lightbox_" + scheduler.layers[t].name].sections = e(scheduler.config.lightbox.sections), scheduler._layers_zindex[scheduler.layers[t].name] = scheduler.config.inital_layer_zindex || 5 + 3 * t, scheduler.layers[t].url) {
                    var a = new dataProcessor(scheduler.layers[t].url);
                    a.layer = scheduler.layers[t].name, scheduler._dataprocessors.push(a), scheduler._dataprocessors[t].init(scheduler)
                }
                scheduler.layers[t].isDefault && (scheduler.defaultLayer = scheduler.layers[t].name);

            }
        }(), scheduler.showLayer = function(e) {
            this.toggleLayer(e, !0)
        }, scheduler.hideLayer = function(e) {
            this.toggleLayer(e, !1)
        }, scheduler.toggleLayer = function(e, t) {
            var a = this.getLayer(e);
            "undefined" != typeof t ? a.visible = !!t : a.visible = !a.visible, this.setCurrentView(this._date, this._mode)
        }, scheduler.getLayer = function(e) {
            var t, a;
            "string" == typeof e && (a = e), "object" == typeof e && (a = e.layer);
            for (var i = 0; i < scheduler.layers.length; i++) scheduler.layers[i].name == a && (t = scheduler.layers[i]);
            return t
        }, scheduler.attachEvent("onBeforeLightbox", function(e) {
            var t = this.getEvent(e);
            return this.config.lightbox.sections = this.config["lightbox_" + t.layer].sections, scheduler.resetLightbox(), !0
        }), scheduler.attachEvent("onClick", function(e, t) {
            var a = scheduler.getEvent(e);
            return !scheduler.getLayer(a.layer).noMenu
        }), scheduler.attachEvent("onEventCollision", function(e, t) {
            var a = this.getLayer(e);
            if (!a.checkCollision) return !1;
            for (var i = 0, n = 0; n < t.length; n++) t[n].layer == a.name && t[n].id != e.id && i++;
            return i >= scheduler.config.collision_limit
        }), scheduler.addEvent = function(e, t, a, i, n) {
            var r = e;
            1 != arguments.length && (r = n || {}, r.start_date = e, r.end_date = t, r.text = a, r.id = i, r.layer = this.defaultLayer), r.id = r.id || scheduler.uid(), r.text = r.text || "", "string" == typeof r.start_date && (r.start_date = this.templates.api_date(r.start_date)), "string" == typeof r.end_date && (r.end_date = this.templates.api_date(r.end_date)), r._timed = this.isOneDayEvent(r);
            var l = !this._events[r.id];
            this._events[r.id] = r, this.event_updated(r), this._loading || this.callEvent(l ? "onEventAdded" : "onEventChanged", [r.id, r])
        }, this._evs_layer = {};

    for (var e = 0; e < this.layers.length; e++) this._evs_layer[this.layers[e].name] = [];
    scheduler.addEventNow = function(e, t, a) {
        var i = {};
        "object" == typeof e && (i = e, e = null);
        var n = 6e4 * (this.config.event_duration || this.config.time_step);
        e || (e = Math.round(scheduler._currentDate().valueOf() / n) * n);
        var r = new Date(e);
        if (!t) {
            var l = this.config.first_hour;
            l > r.getHours() && (r.setHours(l), e = r.valueOf()), t = e + n
        }
        i.start_date = i.start_date || r, i.end_date = i.end_date || new Date(t), i.text = i.text || this.locale.labels.new_event, i.id = this._drag_id = this.uid(),
            i.layer = this.defaultLayer, this._drag_mode = "new-size", this._loading = !0, this.addEvent(i), this.callEvent("onEventCreated", [this._drag_id, a]), this._loading = !1, this._drag_event = {}, this._on_mouse_up(a)
    }, scheduler._t_render_view_data = function(e) {
        if (this.config.multi_day && !this._table_view) {
            for (var t = [], a = [], i = 0; i < e.length; i++) e[i]._timed ? t.push(e[i]) : a.push(e[i]);
            this._table_view = !0, this.render_data(a), this._table_view = !1, this.render_data(t)
        } else this.render_data(e)
    }, scheduler.render_view_data = function() {
        if (this._not_render) return void(this._render_wait = !0);
        this._render_wait = !1, this.clear_view(), this._evs_layer = {};
        for (var e = 0; e < this.layers.length; e++) this._evs_layer[this.layers[e].name] = [];
        for (var t = this.get_visible_events(), e = 0; e < t.length; e++) this._evs_layer[t[e].layer] && this._evs_layer[t[e].layer].push(t[e]);
        if ("month" == this._mode) {
            for (var a = [], e = 0; e < this.layers.length; e++) this.layers[e].visible && (a = a.concat(this._evs_layer[this.layers[e].name]));
            this._t_render_view_data(a)
        } else
            for (var e = 0; e < this.layers.length; e++)
                if (this.layers[e].visible) {
                    var i = this._evs_layer[this.layers[e].name];
                    this._t_render_view_data(i)
                }
    }, scheduler._render_v_bar = function(e, t, a, i, n, r, l, d, s) {
        var o = e.id; - 1 == l.indexOf("<div class=") && (l = scheduler.templates["event_header_" + e.layer] ? scheduler.templates["event_header_" + e.layer](e.start_date, e.end_date, e) : l), -1 == d.indexOf("<div class=") && (d = scheduler.templates["event_text_" + e.layer] ? scheduler.templates["event_text_" + e.layer](e.start_date, e.end_date, e) : d);
        var _ = document.createElement("DIV"),
            c = "dhx_cal_event",
            u = scheduler.templates["event_class_" + e.layer] ? scheduler.templates["event_class_" + e.layer](e.start_date, e.end_date, e) : scheduler.templates.event_class(e.start_date, e.end_date, e);

        u && (c = c + " " + u);
        var h = '<div event_id="' + o + '" class="' + c + '" style="position:absolute; top:' + a + "px; left:" + t + "px; width:" + (i - 4) + "px; height:" + n + "px;" + (r || "") + '">';
        return h += '<div class="dhx_header" style=" width:' + (i - 6) + 'px;" >&nbsp;</div>', h += '<div class="dhx_title">' + l + "</div>", h += '<div class="dhx_body" style=" width:' + (i - (this._quirks ? 4 : 14)) + "px; height:" + (n - (this._quirks ? 20 : 30)) + 'px;">' + d + "</div>", h += '<div class="dhx_footer" style=" width:' + (i - 8) + "px;" + (s ? " margin-top:-1px;" : "") + '" ></div></div>',
            _.innerHTML = h, _.style.zIndex = 100, _.firstChild
    }, scheduler.render_event_bar = function(e) {
        var t = this._els.dhx_cal_data[0],
            a = this._colsS[e._sday],
            i = this._colsS[e._eday];
        i == a && (i = this._colsS[e._eday + 1]);
        var n = this.xy.bar_height,
            r = this._colsS.heights[e._sweek] + (this._colsS.height ? this.xy.month_scale_height + 2 : 2) + e._sorder * n,
            l = document.createElement("DIV"),
            d = e._timed ? "dhx_cal_event_clear" : "dhx_cal_event_line",
            s = scheduler.templates["event_class_" + e.layer] ? scheduler.templates["event_class_" + e.layer](e.start_date, e.end_date, e) : scheduler.templates.event_class(e.start_date, e.end_date, e);

        s && (d = d + " " + s);
        var o = '<div event_id="' + e.id + '" class="' + d + '" style="position:absolute; top:' + r + "px; left:" + a + "px; width:" + (i - a - 15) + "px;" + (e._text_style || "") + '">';
        e._timed && (o += scheduler.templates["event_bar_date_" + e.layer] ? scheduler.templates["event_bar_date_" + e.layer](e.start_date, e.end_date, e) : scheduler.templates.event_bar_date(e.start_date, e.end_date, e)), o += scheduler.templates["event_bar_text_" + e.layer] ? scheduler.templates["event_bar_text_" + e.layer](e.start_date, e.end_date, e) : scheduler.templates.event_bar_text(e.start_date, e.end_date, e) + "</div>)",
            o += "</div>", l.innerHTML = o, this._rendered.push(l.firstChild), t.appendChild(l.firstChild)
    }, scheduler.render_event = function(e) {
        var t = scheduler.xy.menu_width;
        if (scheduler.getLayer(e.layer).noMenu && (t = 0), !(e._sday < 0)) {
            var a = scheduler.locate_holder(e._sday);
            if (a) {
                var i = 60 * e.start_date.getHours() + e.start_date.getMinutes(),
                    n = 60 * e.end_date.getHours() + e.end_date.getMinutes() || 60 * scheduler.config.last_hour,
                    r = Math.round((60 * i * 1e3 - 60 * this.config.first_hour * 60 * 1e3) * this.config.hour_size_px / 36e5) % (24 * this.config.hour_size_px) + 1,
                    l = Math.max(scheduler.xy.min_event_height, (n - i) * this.config.hour_size_px / 60) + 1,
                    d = Math.floor((a.clientWidth - t) / e._count),
                    s = e._sorder * d + 1;

                e._inner || (d *= e._count - e._sorder);
                var o = this._render_v_bar(e.id, t + s, r, d, l, e._text_style, scheduler.templates.event_header(e.start_date, e.end_date, e), scheduler.templates.event_text(e.start_date, e.end_date, e));
                if (this._rendered.push(o), a.appendChild(o), s = s + parseInt(a.style.left, 10) + t, r += this._dy_shift, o.style.zIndex = this._layers_zindex[e.layer], this._edit_id == e.id) {
                    o.style.zIndex = parseInt(o.style.zIndex) + 1;
                    var _ = o.style.zIndex;
                    d = Math.max(d - 4, scheduler.xy.editor_width);
                    var o = document.createElement("DIV");

                    o.setAttribute("event_id", e.id), this.set_xy(o, d, l - 20, s, r + 14), o.className = "dhx_cal_editor", o.style.zIndex = _;
                    var c = document.createElement("DIV");
                    this.set_xy(c, d - 6, l - 26), c.style.cssText += ";margin:2px 2px 2px 2px;overflow:hidden;", c.style.zIndex = _, o.appendChild(c), this._els.dhx_cal_data[0].appendChild(o), this._rendered.push(o), c.innerHTML = "<textarea class='dhx_cal_editor'>" + e.text + "</textarea>", this._quirks7 && (c.firstChild.style.height = l - 12 + "px"), this._editor = c.firstChild, this._editor.onkeypress = function(e) {
                        if ((e || event).shiftKey) return !0;
                        var t = (e || event).keyCode;
                        t == scheduler.keys.edit_save && scheduler.editStop(!0), t == scheduler.keys.edit_cancel && scheduler.editStop(!1)
                    }, this._editor.onselectstart = function(e) {
                        return (e || event).cancelBubble = !0, !0
                    }, c.firstChild.focus(), this._els.dhx_cal_data[0].scrollLeft = 0, c.firstChild.select()
                }
                if (this._select_id == e.id) {
                    o.style.zIndex = parseInt(o.style.zIndex) + 1;
                    for (var u = this.config["icons_" + (this._edit_id == e.id ? "edit" : "select")], h = "", p = 0; p < u.length; p++) h += "<div class='dhx_menu_icon " + u[p] + "' title='" + this.locale.labels[u[p]] + "'></div>";

                    var v = this._render_v_bar(e.id, s - t + 1, r, t, 20 * u.length + 26, "", "<div class='dhx_menu_head'></div>", h, !0);
                    v.style.left = s - t + 1, v.style.zIndex = o.style.zIndex, this._els.dhx_cal_data[0].appendChild(v), this._rendered.push(v)
                }
            }
        }
    }, scheduler.filter_agenda = function(e, t) {
        var a = scheduler.getLayer(t.layer);
        return a && a.visible
    }
});
//# sourceMappingURL=../sources/ext/dhtmlxscheduler_layer.js.map