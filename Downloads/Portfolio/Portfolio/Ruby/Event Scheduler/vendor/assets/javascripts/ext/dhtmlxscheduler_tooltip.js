/*
@license
dhtmlxScheduler v.4.3.1 

This software is covered by GPL license. You also can obtain Commercial or Enterprise license to use it in non-GPL project - please contact sales@dhtmlx.com. Usage without proper license is prohibited.

(c) Dinamenta, UAB.
*/
window.dhtmlXTooltip = scheduler.dhtmlXTooltip = window.dhtmlxTooltip = {}, dhtmlXTooltip.config = {
    className: "dhtmlXTooltip tooltip",
    timeout_to_display: 50,
    timeout_to_hide: 50,
    delta_x: 15,
    delta_y: -20
}, dhtmlXTooltip.tooltip = document.createElement("div"), dhtmlXTooltip.tooltip.className = dhtmlXTooltip.config.className, dhtmlXTooltip.show = function(e, t) {
    if (!scheduler.config.touch || scheduler.config.touch_tooltip) {
        var a = dhtmlXTooltip,
            r = this.tooltip,
            n = r.style;
        a.tooltip.className = a.config.className;
        var i = this.position(e),
            l = e.target || e.srcElement;

        if (!this.isTooltip(l)) {
            var d = i.x + (a.config.delta_x || 0),
                s = i.y - (a.config.delta_y || 0);
            n.visibility = "hidden", n.removeAttribute ? (n.removeAttribute("right"), n.removeAttribute("bottom")) : (n.removeProperty("right"), n.removeProperty("bottom")), n.left = "0", n.top = "0", this.tooltip.innerHTML = t, document.body.appendChild(this.tooltip);
            var o = this.tooltip.offsetWidth,
                _ = this.tooltip.offsetHeight;
            document.body.offsetWidth - d - o < 0 ? (n.removeAttribute ? n.removeAttribute("left") : n.removeProperty("left"), n.right = document.body.offsetWidth - d + 2 * (a.config.delta_x || 0) + "px") : 0 > d ? n.left = i.x + Math.abs(a.config.delta_x || 0) + "px" : n.left = d + "px",
                document.body.offsetHeight - s - _ < 0 ? (n.removeAttribute ? n.removeAttribute("top") : n.removeProperty("top"), n.bottom = document.body.offsetHeight - s - 2 * (a.config.delta_y || 0) + "px") : 0 > s ? n.top = i.y + Math.abs(a.config.delta_y || 0) + "px" : n.top = s + "px", n.visibility = "visible", this.tooltip.onmouseleave = function(e) {
                    e = e || window.event;
                    for (var t = scheduler.dhtmlXTooltip, a = e.relatedTarget; a != scheduler._obj && a;) a = a.parentNode;
                    a != scheduler._obj && t.delay(t.hide, t, [], t.config.timeout_to_hide)
                }, scheduler.callEvent("onTooltipDisplayed", [this.tooltip, this.tooltip.event_id]);

        }
    }
}, dhtmlXTooltip._clearTimeout = function() {
    this.tooltip._timeout_id && window.clearTimeout(this.tooltip._timeout_id)
}, dhtmlXTooltip.hide = function() {
    if (this.tooltip.parentNode) {
        var e = this.tooltip.event_id;
        this.tooltip.event_id = null, this.tooltip.onmouseleave = null, this.tooltip.parentNode.removeChild(this.tooltip), scheduler.callEvent("onAfterTooltip", [e])
    }
    this._clearTimeout()
}, dhtmlXTooltip.delay = function(e, t, a, r) {
    this._clearTimeout(), this.tooltip._timeout_id = setTimeout(function() {
        var r = e.apply(t, a);
        return e = t = a = null,
            r
    }, r || this.config.timeout_to_display)
}, dhtmlXTooltip.isTooltip = function(e) {
    var t = !1;
    for ("dhtmlXTooltip" == e.className.split(" ")[0]; e && !t;) t = e.className == this.tooltip.className, e = e.parentNode;
    return t
}, dhtmlXTooltip.position = function(e) {
    if (e = e || window.event, e.pageX || e.pageY) return {
        x: e.pageX,
        y: e.pageY
    };
    var t = window._isIE && "BackCompat" != document.compatMode ? document.documentElement : document.body;
    return {
        x: e.clientX + t.scrollLeft - t.clientLeft,
        y: e.clientY + t.scrollTop - t.clientTop
    }
}, scheduler.attachEvent("onMouseMove", function(e, t) {
    var a = window.event || t,
        r = a.target || a.srcElement,
        n = dhtmlXTooltip,
        i = n.isTooltip(r),
        l = n.isTooltipTarget && n.isTooltipTarget(r);
    if (e || i || l) {
        var d;
        if (e || n.tooltip.event_id) {
            var s = scheduler.getEvent(e) || scheduler.getEvent(n.tooltip.event_id);
            if (!s) return;
            if (n.tooltip.event_id = s.id, d = scheduler.templates.tooltip_text(s.start_date, s.end_date, s), !d) return n.hide()
        }
        l && (d = "");
        var o;
        if (_isIE) {
            o = {
                pageX: void 0,
                pageY: void 0,
                clientX: void 0,
                clientY: void 0,
                target: void 0,
                srcElement: void 0
            };
            for (var _ in o) o[_] = a[_]
        }
        if (!scheduler.callEvent("onBeforeTooltip", [e]) || !d) return;

        n.delay(n.show, n, [o || a, d])
    } else n.delay(n.hide, n, [], n.config.timeout_to_hide)
}), scheduler.attachEvent("onBeforeDrag", function() {
    return dhtmlXTooltip.hide(), !0
}), scheduler.attachEvent("onEventDeleted", function() {
    return dhtmlXTooltip.hide(), !0
}), scheduler.templates.tooltip_date_format = scheduler.date.date_to_str("%Y-%m-%d %H:%i"), scheduler.templates.tooltip_text = function(e, t, a) {
    return "<b>Event:</b> " + a.text + "<br/><b>Start date:</b> " + scheduler.templates.tooltip_date_format(e) + "<br/><b>End date:</b> " + scheduler.templates.tooltip_date_format(t);

};
//# sourceMappingURL=../sources/ext/dhtmlxscheduler_tooltip.js.map