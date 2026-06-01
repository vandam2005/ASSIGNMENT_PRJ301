<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:layout title="Chat Support">
    <jsp:include page="../common/StaffNavbar.jsp" />

    <div class="container-fluid pb-4" style="max-width:1100px">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="text-white border-start border-4 border-warning ps-3 mb-0">
                <i class="bi bi-chat-dots-fill text-orange me-2"></i>Chat Ho Tro Khach Hang
            </h4>
        </div>

        <div class="row g-3" style="height:calc(100vh - 200px); min-height:480px;">

            <%-- ====== CỘT TRÁI: DANH SÁCH GUEST ====== --%>
            <div class="col-md-4 col-lg-3 d-flex flex-column">
                <div class="card h-100 border-secondary" style="background:#1a1a1a; overflow:hidden; display:flex; flex-direction:column;">
                    <div class="card-header border-secondary py-2 px-3" style="background:#252525; flex-shrink:0;">
                        <div class="d-flex align-items-center gap-2">
                            <i class="bi bi-people-fill text-orange"></i>
                            <span class="text-white fw-semibold" style="font-size:13px;">Khach dang chat</span>
                            <span class="badge bg-orange ms-auto" id="total-badge" style="background:var(--primary)!important;">0</span>
                        </div>
                    </div>
                    <div class="p-2" style="flex-shrink:0;">
                        <input type="text" id="guest-search" class="form-control form-control-sm" placeholder="Tim kiem guest..."
                            style="background:#2c2c2c;border-color:#444;color:#e0e0e0;font-size:12px;">
                    </div>
                    <div id="guest-list" style="overflow-y:auto; flex:1; scrollbar-width:thin; scrollbar-color:#333 transparent;">
                        <div class="text-center text-muted py-5" id="guest-empty">
                            <i class="bi bi-inbox display-6 d-block mb-2"></i>
                            <small>Chua co khach nao nhan tin</small>
                        </div>
                    </div>
                </div>
            </div>

            <%-- ====== CỘT PHẢI: CHAT PANEL ====== --%>
            <div class="col-md-8 col-lg-9 d-flex flex-column">
                <div class="card h-100 border-secondary" style="background:#1a1a1a; overflow:hidden; display:flex; flex-direction:column;">

                    <%-- Header chat --%>
                    <div id="chat-panel-header" class="card-header border-secondary py-2 px-3 d-flex align-items-center gap-3" style="background:#252525; flex-shrink:0;">
                        <div class="d-flex align-items-center gap-2 flex-grow-1">
                            <div id="active-av" style="width:34px;height:34px;border-radius:50%;background:#333;display:flex;align-items:center;justify-content:center;font-size:16px;">&#128100;</div>
                            <div>
                                <div id="active-name" class="text-white fw-semibold" style="font-size:14px;">Chon mot cuoc tro chuyen</div>
                                <div id="active-status" class="text-muted" style="font-size:11px;">---</div>
                            </div>
                        </div>
                    </div>

                    <%-- Messages --%>
                    <div id="staff-msgs" style="flex:1;overflow-y:auto;padding:16px;display:flex;flex-direction:column;gap:10px;scrollbar-width:thin;scrollbar-color:#333 transparent;">
                        <div id="staff-msgs-placeholder" class="text-center text-muted my-auto">
                            <i class="bi bi-chat-square-dots display-4 d-block mb-3 opacity-25"></i>
                            <p class="small">Chon mot guest de bat dau chat</p>
                        </div>
                    </div>

                    <%-- Input --%>
                    <div id="staff-input-wrap" class="p-3 border-top border-secondary d-flex gap-2 align-items-end" style="flex-shrink:0; background:#1a1a1a;">
                        <textarea id="staff-input" class="form-control" rows="1" placeholder="Nhap tin nhan tra loi..."
                            style="background:#252525;border-color:#3a3a3a;color:#e0e0e0;border-radius:18px;resize:none;max-height:100px;font-size:13.5px;"
                            disabled></textarea>
                        <button id="staff-send" class="btn btn-resto" style="border-radius:50%;width:40px;height:40px;padding:0;display:flex;align-items:center;justify-content:center;flex-shrink:0;" disabled>
                            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="white" viewBox="0 0 16 16">
                                <path d="M15.854.146a.5.5 0 0 1 .11.54l-5.819 14.547a.75.75 0 0 1-1.329.124l-3.178-4.995L.643 7.184a.75.75 0 0 1 .124-1.33L15.314.037a.5.5 0 0 1 .54.11Z"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
        </div><%-- end row --%>
    </div>

<style>
.guest-item{
    padding:10px 12px; cursor:pointer; border-bottom:1px solid #252525;
    display:flex; align-items:center; gap:10px; transition:background .15s;
}
.guest-item:hover{ background:#222; }
.guest-item.active{ background:#2a1a0e; border-left:3px solid var(--primary); }
.guest-av{width:36px;height:36px;border-radius:50%;background:#333;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0;}
.guest-info{flex:1;min-width:0;}
.guest-name{color:#e0e0e0;font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.guest-preview{color:#666;font-size:11px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.guest-unread{background:var(--primary);color:#fff;font-size:10px;font-weight:700;min-width:18px;height:18px;border-radius:9px;padding:0 4px;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
/* Staff chat bubbles */
.smsg{display:flex;gap:8px;align-items:flex-end;}
.smsg.staff-me{flex-direction:row-reverse;}
.smsg .sav{width:28px;height:28px;border-radius:50%;background:#2e2e2e;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;}
.sbub{max-width:76%;padding:9px 13px;border-radius:14px;font-size:13.5px;line-height:1.45;word-break:break-word;}
.smsg.guest-msg .sbub{background:#2c2c2c;color:#e0e0e0;border-bottom-left-radius:4px;}
.smsg.staff-me .sbub{background:var(--primary);color:#fff;border-bottom-right-radius:4px;}
.smsg.sys-msg .sbub{background:#1e3a1e;color:#86efac;font-size:12px;font-style:italic;border-radius:8px;text-align:center;margin:0 auto;max-width:90%;}
.stime{font-size:10px;color:#555;margin-top:2px;}
</style>

<script>
(function(){
    var ctx = '${pageContext.request.contextPath}';
    var staffName = '${sessionScope.account.username}';

    // WS "all" - lang nghe thong bao toan cuc
    var wsAll, wsCurrent;
    var activeGuestId = null;

    // ---- Guest list state ----
    var guestMap = {};  // guestId -> {name, preview, unread, online}

    // ---- DOM ----
    var guestListEl  = document.getElementById('guest-list');
    var guestEmptyEl = document.getElementById('guest-empty');
    var totalBadge   = document.getElementById('total-badge');
    var staffMsgs    = document.getElementById('staff-msgs');
    var staffInput   = document.getElementById('staff-input');
    var staffSend    = document.getElementById('staff-send');
    var activeNameEl = document.getElementById('active-name');
    var activeStatusEl = document.getElementById('active-status');
    var staffMsgsPlaceholder = document.getElementById('staff-msgs-placeholder');
    var guestSearch  = document.getElementById('guest-search');

    // ---- Connect WS "all" ----
    function connectAll(){
        var p = location.protocol==='https:'?'wss':'ws';
        wsAll = new WebSocket(p+'://'+location.host+ctx+'/ChatWS/staff/all');
        wsAll.onmessage = function(e){
            var d = JSON.parse(e.data);

            // Load danh sach guest cu tu DB khi staff vua vao trang
            if(d.type==='init_guest'){
                var gid = d.guestId;
                if(!guestMap[gid]){
                    guestMap[gid] = {name: d.guestName, preview: d.preview, unread: d.unread||0};
                }
                renderGuestList();

            // Tin nhan moi tu guest
            } else if(d.type==='notif'){
                var gid = d.guestId;
                if(!guestMap[gid]){
                    guestMap[gid] = {name: d.guestName, preview: d.preview, unread: 0};
                }
                guestMap[gid].preview = d.preview;
                if(gid !== activeGuestId){
                    guestMap[gid].unread = (guestMap[gid].unread||0) + 1;
                }
                renderGuestList();
            }
        };
        wsAll.onclose = function(){ setTimeout(connectAll, 3000); };
    }

    // ---- Connect WS specific guest ----
    function openGuestChat(guestId, guestName){
        if(activeGuestId === guestId) return;
        activeGuestId = guestId;

        // Reset unread
        if(guestMap[guestId]) guestMap[guestId].unread = 0;
        renderGuestList();

        // Update header
        activeNameEl.textContent = guestName;
        activeStatusEl.textContent = 'Dang tai lich su chat...';

        // Clear messages
        staffMsgs.innerHTML = '';
        if(staffMsgsPlaceholder){ staffMsgsPlaceholder.remove(); }
        staffInput.disabled = false;
        staffSend.disabled = false;

        // Close old WS
        if(wsCurrent && wsCurrent.readyState < 2) wsCurrent.close();

        var p = location.protocol==='https:'?'wss':'ws';
        wsCurrent = new WebSocket(p+'://'+location.host+ctx+'/ChatWS/staff/'+guestId);

        wsCurrent.onopen = function(){
            activeStatusEl.textContent = 'Ket noi thanh cong';
        };
        wsCurrent.onclose = function(){
            if(activeGuestId === guestId){
                activeStatusEl.textContent = 'Mat ket noi';
                staffInput.disabled = true;
                staffSend.disabled = true;
            }
        };
        wsCurrent.onmessage = function(e){
            var d = JSON.parse(e.data);
            if(d.type==='history'){
                staffMsgs.innerHTML='';
                d.messages.forEach(function(m){
                    appendMsg(m.role==='staff'?'staff-me':'guest-msg', m.content, m.time);
                });
                scrollBottom();
            } else if(d.type==='message'){
                appendMsg(d.role==='staff'?'staff-me':'guest-msg', d.content, d.time);
                scrollBottom();
            } else if(d.type==='system'){
                appendSys(d.content); scrollBottom();
            }
        };
    }

    // ---- Send ----
    function doSend(){
        var t = staffInput.value.trim();
        if(!t || !wsCurrent || wsCurrent.readyState!==1) return;
        wsCurrent.send(t);
        staffInput.value='';
        staffInput.style.height='auto';
    }
    staffSend.addEventListener('click', doSend);
    staffInput.addEventListener('keydown', function(e){
        if(e.key==='Enter' && !e.shiftKey){ e.preventDefault(); doSend(); }
    });
    staffInput.addEventListener('input', function(){
        this.style.height='auto';
        this.style.height=Math.min(this.scrollHeight,100)+'px';
    });

    // ---- Render guest list ----
    function renderGuestList(){
        var keys = Object.keys(guestMap);
        totalBadge.textContent = keys.length;
        guestEmptyEl.style.display = keys.length ? 'none' : '';

        var search = guestSearch.value.toLowerCase();
        var html = '';
        keys.forEach(function(gid){
            var g = guestMap[gid];
            if(search && g.name.toLowerCase().indexOf(search) < 0) return;
            var isActive = parseInt(gid) === activeGuestId;
            html += '<div class="guest-item'+(isActive?' active':'')+'" data-gid="'+gid+'" data-name="'+esc(g.name)+'">'
                  + '<div class="guest-av">&#128100;</div>'
                  + '<div class="guest-info">'
                  + '<div class="guest-name">'+esc(g.name)+'</div>'
                  + '<div class="guest-preview">'+(g.preview ? esc(g.preview) : 'Nhan de mo chat')+'</div>'
                  + '</div>'
                  + (g.unread > 0 ? '<div class="guest-unread">'+g.unread+'</div>' : '')
                  + '</div>';
        });
        guestListEl.innerHTML = html + '<div id="guest-empty" style="display:'+(keys.length?'none':'')+';" class="text-center text-muted py-5"><i class="bi bi-inbox display-6 d-block mb-2"></i><small>Chua co khach nao nhan tin</small></div>';

        // Re-attach click
        guestListEl.querySelectorAll('.guest-item').forEach(function(el){
            el.addEventListener('click', function(){
                openGuestChat(parseInt(this.dataset.gid), this.dataset.name);
            });
        });
    }

    guestSearch.addEventListener('input', renderGuestList);

    // ---- Message helpers ----
    function appendMsg(side, content, time){
        var d = document.createElement('div');
        d.className = 'smsg '+side;
        var av = side==='staff-me' ? '&#128104;&#8205;&#128188;' : '&#128100;';
        d.innerHTML = '<div class="sav">'+av+'</div>'
            + '<div><div class="sbub">'+esc(content).replace(/\n/g,'<br>')+'</div>'
            + '<div class="stime '+(side==='staff-me'?'text-end':'')+'\">'+(time||'')+'</div></div>';
        staffMsgs.appendChild(d);
    }
    function appendSys(text){
        var d = document.createElement('div');
        d.className = 'smsg sys-msg';
        d.innerHTML = '<div class="sbub">'+esc(text)+'</div>';
        staffMsgs.appendChild(d);
    }
    function scrollBottom(){ staffMsgs.scrollTop = staffMsgs.scrollHeight; }
    function esc(s){ return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

    // ---- Init ----
    connectAll();
    renderGuestList();

})();
</script>
</t:layout>
