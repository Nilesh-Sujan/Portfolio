/*
@license
dhtmlxScheduler v.4.3.1 

This software is covered by GPL license. You also can obtain Commercial or Enterprise license to use it in non-GPL project - please contact sales@dhtmlx.com. Usage without proper license is prohibited.

(c) Dinamenta, UAB.
*/
scheduler.xy.map_date_width = 188, scheduler.xy.map_description_width = 400, scheduler.config.map_resolve_event_location = !0, scheduler.config.map_resolve_user_location = !0, scheduler.config.map_initial_position = new google.maps.LatLng(48.724, 8.215), scheduler.config.map_error_position = new google.maps.LatLng(15, 15), scheduler.config.map_infowindow_max_width = 300, scheduler.config.map_type = google.maps.MapTypeId.ROADMAP, scheduler.config.map_zoom_after_resolve = 15, scheduler.locale.labels.marker_geo_success = "It seems you are here.",
    scheduler.locale.labels.marker_geo_fail = "Sorry, could not get your current position using geolocation.", scheduler.templates.marker_date = scheduler.date.date_to_str("%Y-%m-%d %H:%i"), scheduler.templates.marker_text = function(e, t, a) {
        return "<div><b>" + a.text + "</b><br/><br/>" + (a.event_location || "") + "<br/><br/>" + scheduler.templates.marker_date(e) + " - " + scheduler.templates.marker_date(t) + "</div>"
    }, scheduler.dblclick_dhx_map_area = function() {
        !this.config.readonly && this.config.dblclick_create && this.addEventNow({
            start_date: scheduler._date,
            end_date: scheduler.date.add(scheduler._date, scheduler.config.time_step, "minute")
        })
    }, scheduler.templates.map_time = function(e, t, a) {
        return a._timed ? this.day_date(a.start_date, a.end_date, a) + " " + this.event_date(e) : scheduler.templates.day_date(e) + " &ndash; " + scheduler.templates.day_date(t)
    }, scheduler.templates.map_text = function(e, t, a) {
        return a.text
    }, scheduler.date.map_start = function(e) {
        return e
    }, scheduler.date.add_map = function(e, t, a) {
        return new Date(e.valueOf())
    }, scheduler.templates.map_date = function(e, t, a) {
        return ""
    }, scheduler._latLngUpdate = !1, scheduler.attachEvent("onSchedulerReady", function() {
        function e(e) {
            if (e) {
                var t = scheduler.locale.labels;
                scheduler._els.dhx_cal_header[0].innerHTML = "<div class='dhx_map_line' style='width: " + (scheduler.xy.map_date_width + scheduler.xy.map_description_width + 2) + "px;' ><div class='headline_date' style='width: " + scheduler.xy.map_date_width + "px;'>" + t.date + "</div><div class='headline_description' style='width: " + scheduler.xy.map_description_width + "px;'>" + t.description + "</div></div>",
                    scheduler._table_view = !0, scheduler.set_sizes()
            }
        }

        function t() {
            scheduler._selected_event_id = null, scheduler.map._infowindow.close();
            var e = scheduler.map._markers;
            for (var t in e) e.hasOwnProperty(t) && (e[t].setMap(null), delete scheduler.map._markers[t], scheduler.map._infowindows_content[t] && delete scheduler.map._infowindows_content[t])
        }

        function a() {
            var e = scheduler.get_visible_events();
            e.sort(function(e, t) {
                return e.start_date.valueOf() == t.start_date.valueOf() ? e.id > t.id ? 1 : -1 : e.start_date > t.start_date ? 1 : -1;

            });
            for (var t = "<div class='dhx_map_area'>", a = 0; a < e.length; a++) {
                var r = e[a],
                    n = r.id == scheduler._selected_event_id ? "dhx_map_line highlight" : "dhx_map_line",
                    i = r.color ? "background:" + r.color + ";" : "",
                    l = r.textColor ? "color:" + r.textColor + ";" : "";
                t += "<div class='" + n + "' event_id='" + r.id + "' style='" + i + l + (r._text_style || "") + " width: " + (scheduler.xy.map_date_width + scheduler.xy.map_description_width + 2) + "px;'><div style='width: " + scheduler.xy.map_date_width + "px;' >" + scheduler.templates.map_time(r.start_date, r.end_date, r) + "</div>",
                    t += "<div class='dhx_event_icon icon_details'>&nbsp</div>", t += "<div class='line_description' style='width:" + (scheduler.xy.map_description_width - 25) + "px;'>" + scheduler.templates.map_text(r.start_date, r.end_date, r) + "</div></div>"
            }
            t += "<div class='dhx_v_border' style='left: " + (scheduler.xy.map_date_width - 2) + "px;'></div><div class='dhx_v_border_description'></div></div>", scheduler._els.dhx_cal_data[0].scrollTop = 0, scheduler._els.dhx_cal_data[0].innerHTML = t, scheduler._els.dhx_cal_data[0].style.width = scheduler.xy.map_date_width + scheduler.xy.map_description_width + 1 + "px";

            var d = scheduler._els.dhx_cal_data[0].firstChild.childNodes;
            scheduler._els.dhx_cal_date[0].innerHTML = scheduler.templates[scheduler._mode + "_date"](scheduler._min_date, scheduler._max_date, scheduler._mode), scheduler._rendered = [];
            for (var a = 0; a < d.length - 2; a++) scheduler._rendered[a] = d[a]
        }

        function r(e) {
            var t = document.getElementById(e),
                a = scheduler._y - scheduler.xy.nav_height;
            0 > a && (a = 0);
            var r = scheduler._x - scheduler.xy.map_date_width - scheduler.xy.map_description_width - 1;
            0 > r && (r = 0), t.style.height = a + "px", t.style.width = r + "px",
                t.style.marginLeft = scheduler.xy.map_date_width + scheduler.xy.map_description_width + 1 + "px", t.style.marginTop = scheduler.xy.nav_height + 2 + "px"
        }
        scheduler._isMapPositionSet = !1;
        var n = document.createElement("div");
        n.className = "dhx_map", n.id = "dhx_gmap", n.style.dispay = "none";
        var i = scheduler._obj;
        i.appendChild(n), scheduler._els.dhx_gmap = [], scheduler._els.dhx_gmap.push(n), r("dhx_gmap");
        var l = {
                zoom: scheduler.config.map_inital_zoom || 10,
                center: scheduler.config.map_initial_position,
                mapTypeId: scheduler.config.map_type || google.maps.MapTypeId.ROADMAP
            },
            d = new google.maps.Map(document.getElementById("dhx_gmap"), l);
        d.disableDefaultUI = !1, d.disableDoubleClickZoom = !scheduler.config.readonly, google.maps.event.addListener(d, "dblclick", function(e) {
            if (!scheduler.config.readonly && scheduler.config.dblclick_create) {
                var t = e.latLng;
                geocoder.geocode({
                    latLng: t
                }, function(e, a) {
                    a == google.maps.GeocoderStatus.OK && (t = e[0].geometry.location, scheduler.addEventNow({
                        lat: t.lat(),
                        lng: t.lng(),
                        event_location: e[0].formatted_address,
                        start_date: scheduler._date,
                        end_date: scheduler.date.add(scheduler._date, scheduler.config.time_step, "minute")
                    }))
                })
            }
        });
        var s = {
            content: ""
        };
        scheduler.config.map_infowindow_max_width && (s.maxWidth = scheduler.config.map_infowindow_max_width), scheduler.map = {
            _points: [],
            _markers: [],
            _infowindow: new google.maps.InfoWindow(s),
            _infowindows_content: [],
            _initialization_count: -1,
            _obj: d
        }, geocoder = new google.maps.Geocoder, scheduler.config.map_resolve_user_location && navigator.geolocation && (scheduler._isMapPositionSet || navigator.geolocation.getCurrentPosition(function(e) {
            var t = new google.maps.LatLng(e.coords.latitude, e.coords.longitude);

            d.setCenter(t), d.setZoom(scheduler.config.map_zoom_after_resolve || 10), scheduler.map._infowindow.setContent(scheduler.locale.labels.marker_geo_success), scheduler.map._infowindow.position = d.getCenter(), scheduler.map._infowindow.open(d), scheduler._isMapPositionSet = !0
        }, function() {
            scheduler.map._infowindow.setContent(scheduler.locale.labels.marker_geo_fail), scheduler.map._infowindow.setPosition(d.getCenter()), scheduler.map._infowindow.open(d), scheduler._isMapPositionSet = !0
        })), google.maps.event.addListener(d, "resize", function(e) {
            n.style.zIndex = "5", d.setZoom(d.getZoom())
        }), google.maps.event.addListener(d, "tilesloaded", function(e) {
            n.style.zIndex = "5"
        }), n.style.display = "none", scheduler.attachEvent("onSchedulerResize", function() {
            return "map" == this._mode ? (this.map_view(!0), !1) : !0
        });
        var o = scheduler.render_data;
        scheduler.render_data = function(e, t) {
            if ("map" != this._mode) return o.apply(this, arguments);
            a();
            for (var r = scheduler.get_visible_events(), n = 0; n < r.length; n++) scheduler.map._markers[r[n].id] || c(r[n], !1, !1)
        }, scheduler.map_view = function(n) {
            scheduler.map._initialization_count++;
            var i, l = scheduler._els.dhx_gmap[0];
            if (scheduler._els.dhx_cal_data[0].style.width = scheduler.xy.map_date_width + scheduler.xy.map_description_width + 1 + "px", scheduler._min_date = scheduler.config.map_start || scheduler._currentDate(), scheduler._max_date = scheduler.config.map_end || scheduler.date.add(scheduler._currentDate(), 1, "year"), scheduler._table_view = !0, e(n), n) {
                t(), a(), l.style.display = "block", r("dhx_gmap"), i = scheduler.map._obj.getCenter();
                for (var d = scheduler.get_visible_events(), s = 0; s < d.length; s++) scheduler.map._markers[d[s].id] || c(d[s]);

            } else l.style.display = "none";
            google.maps.event.trigger(scheduler.map._obj, "resize"), 0 === scheduler.map._initialization_count && i && scheduler.map._obj.setCenter(i), scheduler._selected_event_id && _(scheduler._selected_event_id)
        };
        var _ = function(e) {
                scheduler.map._obj.setCenter(scheduler.map._points[e]), scheduler.callEvent("onClick", [e])
            },
            c = function(e, t, a) {
                var r = scheduler.config.map_error_position;
                e.lat && e.lng && (r = new google.maps.LatLng(e.lat, e.lng));
                var n = scheduler.templates.marker_text(e.start_date, e.end_date, e);

                scheduler._new_event || (scheduler.map._infowindows_content[e.id] = n, scheduler.map._markers[e.id] && scheduler.map._markers[e.id].setMap(null), scheduler.map._markers[e.id] = new google.maps.Marker({
                    position: r,
                    map: scheduler.map._obj
                }), google.maps.event.addListener(scheduler.map._markers[e.id], "click", function() {
                    scheduler.map._infowindow.setContent(scheduler.map._infowindows_content[e.id]), scheduler.map._infowindow.open(scheduler.map._obj, scheduler.map._markers[e.id]), scheduler._selected_event_id = e.id, scheduler.render_data();

                }), scheduler.map._points[e.id] = r, t && scheduler.map._obj.setCenter(scheduler.map._points[e.id]), a && scheduler.callEvent("onClick", [e.id]))
            };
        scheduler.attachEvent("onClick", function(e, t) {
            if ("map" == this._mode) {
                scheduler._selected_event_id = e;
                for (var a = 0; a < scheduler._rendered.length; a++) scheduler._rendered[a].className = "dhx_map_line", scheduler._rendered[a].getAttribute("event_id") == e && (scheduler._rendered[a].className += " highlight");
                scheduler.map._points[e] && scheduler.map._markers[e] && (scheduler.map._obj.setCenter(scheduler.map._points[e]),
                    google.maps.event.trigger(scheduler.map._markers[e], "click"))
            }
            return !0
        });
        var u = function(e) {
                e.event_location && geocoder ? geocoder.geocode({
                    address: e.event_location,
                    language: scheduler.uid().toString()
                }, function(t, a) {
                    var r = {};
                    a != google.maps.GeocoderStatus.OK ? (r = scheduler.callEvent("onLocationError", [e.id]), r && r !== !0 || (r = scheduler.config.map_error_position)) : r = t[0].geometry.location, e.lat = r.lat(), e.lng = r.lng(), scheduler._selected_event_id = e.id, scheduler._latLngUpdate = !0, scheduler.callEvent("onEventChanged", [e.id, e]),
                        c(e, !0, !0)
                }) : c(e, !0, !0)
            },
            h = function(e) {
                e.event_location && geocoder && geocoder.geocode({
                    address: e.event_location,
                    language: scheduler.uid().toString()
                }, function(t, a) {
                    var r = {};
                    a != google.maps.GeocoderStatus.OK ? (r = scheduler.callEvent("onLocationError", [e.id]), r && r !== !0 || (r = scheduler.config.map_error_position)) : r = t[0].geometry.location, e.lat = r.lat(), e.lng = r.lng(), scheduler._latLngUpdate = !0, scheduler.callEvent("onEventChanged", [e.id, e])
                })
            },
            p = function(e, t, a, r) {
                setTimeout(function() {
                    var r = e.apply(t, a);
                    return e = t = a = null,
                        r
                }, r || 1)
            };
        scheduler.attachEvent("onEventChanged", function(e, t) {
            if (this._latLngUpdate) this._latLngUpdate = !1;
            else {
                var a = scheduler.getEvent(e);
                a.start_date < scheduler._min_date && a.end_date > scheduler._min_date || a.start_date < scheduler._max_date && a.end_date > scheduler._max_date || a.start_date.valueOf() >= scheduler._min_date && a.end_date.valueOf() <= scheduler._max_date ? (scheduler.map._markers[e] && scheduler.map._markers[e].setMap(null), u(a)) : (scheduler._selected_event_id = null, scheduler.map._infowindow.close(),
                    scheduler.map._markers[e] && scheduler.map._markers[e].setMap(null))
            }
            return !0
        }), scheduler.attachEvent("onEventIdChange", function(e, t) {
            var a = scheduler.getEvent(t);
            return (a.start_date < scheduler._min_date && a.end_date > scheduler._min_date || a.start_date < scheduler._max_date && a.end_date > scheduler._max_date || a.start_date.valueOf() >= scheduler._min_date && a.end_date.valueOf() <= scheduler._max_date) && (scheduler.map._markers[e] && (scheduler.map._markers[e].setMap(null), delete scheduler.map._markers[e]), scheduler.map._infowindows_content[e] && delete scheduler.map._infowindows_content[e],
                u(a)), !0
        }), scheduler.attachEvent("onEventAdded", function(e, t) {
            return scheduler._dataprocessor || (t.start_date < scheduler._min_date && t.end_date > scheduler._min_date || t.start_date < scheduler._max_date && t.end_date > scheduler._max_date || t.start_date.valueOf() >= scheduler._min_date && t.end_date.valueOf() <= scheduler._max_date) && (scheduler.map._markers[e] && scheduler.map._markers[e].setMap(null), u(t)), !0
        }), scheduler.attachEvent("onBeforeEventDelete", function(e, t) {
            return scheduler.map._markers[e] && scheduler.map._markers[e].setMap(null),
                scheduler._selected_event_id = null, scheduler.map._infowindow.close(), !0
        }), scheduler._event_resolve_delay = 1500, scheduler.attachEvent("onEventLoading", function(e) {
            return scheduler.config.map_resolve_event_location && e.event_location && !e.lat && !e.lng && (scheduler._event_resolve_delay += 1500, p(h, this, [e], scheduler._event_resolve_delay)), !0
        }), scheduler.attachEvent("onEventCancel", function(e, t) {
            return t && (scheduler.map._markers[e] && scheduler.map._markers[e].setMap(null), scheduler.map._infowindow.close()), !0;

        })
    });
//# sourceMappingURL=../sources/ext/dhtmlxscheduler_map_view.js.map