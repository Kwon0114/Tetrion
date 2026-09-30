<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SRS Tetris - Online/Local Battle</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@500;700;800&family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet">
<style>
  :root{
    /* Galar-menu palette: soft sky, white cards, playful pastel accents */
    --sky-top: #bfe2ff;
    --sky-mid: #dcf0ff;
    --sky-bottom: #f3f9ff;
    --ink: #2c3660;
    --ink-dim: #7686ab;
    --sword: #4d9fe0;
    --sword-deep: #2c74b3;
    --shield: #ef5f79;
    --shield-deep: #c53f5c;
    --mint: #33c2a6;
    --mint-deep: #1f9c85;
    --gold: #ffc93c;
    --gold-deep: #dd9f13;
    --board-bg: #17213c;
    --board-line: #26325a;

    /* Kept for existing inline JS references — remapped to new palette */
    --bg: var(--sky-bottom);
    --panel: #ffffff;
    --line: #d7e3f3;
    --accent: var(--shield);
    --accent2: var(--mint);
    --text: var(--ink);
    --text-dim: var(--ink-dim);

    /* Surfaces used to be hardcoded (#fff, #eef4fc, #f3f7fd) — now themeable */
    --surface-alt: #eef4fc;
    --surface-input: #f3f7fd;
    --ring: #ffffff;
    --glow-1: #ffffff;
    --glow-2: rgba(255,255,255,.7);
    --pill-dark: #2c3660;

    --radius-lg: 22px;
    --radius-md: 14px;
    --radius-sm: 9px;
    --shadow-card: 0 10px 0 rgba(150, 175, 210, .28), 0 18px 34px rgba(43, 68, 110, .16);
    --shadow-soft: 0 8px 22px rgba(43, 68, 110, .14);
  }
  html[data-theme="dark"]{
    --sky-top: #0a0e1c;
    --sky-mid: #0d1428;
    --sky-bottom: #10182e;
    --ink: #e7ecf7;
    --ink-dim: #8b98bd;
    --board-bg: #0e1526;
    --board-line: #1f2a48;
    --panel: #1b2338;
    --line: #323f60;
    --surface-alt: #232c47;
    --surface-input: #1a2138;
    --ring: #3a4568;
    --glow-1: rgba(120,150,255,.05);
    --glow-2: rgba(120,150,255,.06);
    --pill-dark: #0e1526;
  }
  html, body, .btn, .menu-card, .modal, .panel, .board-wrap, .topbar,
  .key-btn, input.textbox, .keybind-row, .field-row input[type=number], .room-code {
    transition: background-color .25s ease, background .25s ease, color .25s ease, border-color .25s ease, box-shadow .25s ease;
  }
  * { box-sizing: border-box; }
  html, body {
    margin:0; padding:0; min-height:100%;
    background:
      radial-gradient(ellipse 60% 40% at 18% 8%, var(--glow-1) 0%, transparent 60%),
      radial-gradient(ellipse 50% 35% at 88% 4%, var(--glow-2) 0%, transparent 60%),
      linear-gradient(180deg, var(--sky-top) 0%, var(--sky-mid) 45%, var(--sky-bottom) 100%);
    background-attachment: fixed;
    color: var(--ink);
    font-family: 'Nunito', ui-sans-serif, system-ui, sans-serif;
  }
  h1, .mode-label, .p-name, .panel .label, .room-code, .stat b, .btn {
    font-family: 'Baloo 2', 'Nunito', sans-serif;
  }
  .stage { display:flex; align-items:center; justify-content:center; min-height:100vh; padding: 20px; flex-direction:column; gap:18px;}
  .topbar {
    display:flex; gap:12px; align-items:center;
    background: var(--panel); border-radius:999px; padding:8px 10px 8px 20px;
    box-shadow: var(--shadow-soft), inset 0 0 0 2px var(--surface-alt);
  }
  .topbar .mode-label { font-size:14px; font-weight:700; color:var(--ink); letter-spacing:.3px; }
  .players { display:flex; gap:26px; align-items:flex-start; justify-content:center; flex-wrap:wrap; }
  .player-block { display:flex; gap: 18px; align-items:flex-start; }
  .player-block > div:not(.side) { display:flex; flex-direction:column; align-items:center; }
  .board-wrap {
    position:relative; padding:10px; border-radius: var(--radius-lg);
    background: linear-gradient(180deg, var(--panel), var(--surface-alt));
    box-shadow: var(--shadow-card), inset 0 0 0 2px var(--ring);
  }
  .board-wrap canvas { display:block; border-radius: 10px; }
  .p-name {
    display:inline-block; font-size:12px; font-weight:700; letter-spacing:.5px;
    color:#fff; background: var(--pill-dark); padding:5px 16px; border-radius:999px; margin-bottom:10px;
  }
  .overlay {
    position:absolute; inset:0; display:flex; align-items:center; justify-content:center; flex-direction:column;
    background: linear-gradient(180deg, rgba(23,33,60,.62), rgba(23,33,60,.8));
    gap: 10px; text-align:center; padding: 20px; z-index:5; border-radius: inherit;
  }
  .overlay.hidden { display:none; }
  .menu-card {
    background: var(--panel); border-radius: var(--radius-lg); padding: 26px 30px;
    box-shadow: 0 22px 50px rgba(10,22,45,.4), 0 0 0 3px var(--ring);
    max-width: 430px; width: 92vw; display:flex; flex-direction:column; align-items:center; gap:10px;
  }
  .overlay h1 { font-size: 21px; font-weight:800; color: var(--ink); margin:0; letter-spacing:.2px; }
  .overlay p { color: var(--ink-dim); margin:4px 0; font-size:13px; line-height:1.7; }
  .flash-msg {
    position:absolute; top:30%; left:4px; right:4px; text-align:center;
    font-size:13px; font-weight:800; letter-spacing:.6px; line-height:1.3; color: var(--mint);
    text-shadow: 0 2px 0 rgba(0,0,0,.18); pointer-events:none; opacity:0; z-index:6;
    font-family: 'Baloo 2', sans-serif;
  }
  .flash-msg.show { animation: flashPop 1100ms ease-out forwards; }
  @keyframes flashPop {
    0%   { opacity:0; transform:translateY(8px) scale(.85); }
    18%  { opacity:1; transform:translateY(0) scale(1.08); }
    32%  { transform:translateY(0) scale(1); }
    72%  { opacity:1; }
    100% { opacity:0; transform:translateY(-12px) scale(1); }
  }
  .b2b-badge {
    position:absolute; left:14px; top:14px; z-index:4;
    background: var(--gold); border:none; color: #6b4a05;
    font-size:11px; font-weight:800; letter-spacing:.5px; padding:4px 11px; border-radius:999px;
    box-shadow: 0 3px 0 var(--gold-deep);
    pointer-events:none;
  }
  .b2b-badge.hidden { display:none; }
  .btn {
    background: var(--sword); color: #fff; border: none; padding: 12px 22px;
    font-weight: 700; font-size: 13.5px; letter-spacing: .3px;
    cursor: pointer; border-radius: 999px; box-shadow: 0 4px 0 var(--sword-deep), 0 8px 18px rgba(44,116,179,.28);
    transition: transform .08s ease, box-shadow .08s ease;
  }
  .btn.secondary {
    background: var(--panel); color: var(--ink); box-shadow: 0 4px 0 var(--line), 0 6px 14px rgba(43,68,110,.1);
    border: 2px solid var(--surface-alt); padding:10px 20px;
  }
  .btn.btn-coral { background: var(--shield); box-shadow: 0 4px 0 var(--shield-deep), 0 8px 18px rgba(197,63,92,.28); }
  .btn.btn-mint  { background: var(--mint);  box-shadow: 0 4px 0 var(--mint-deep),  0 8px 18px rgba(31,156,133,.28); }
  .btn.btn-gold  { background: var(--gold); color:#6b4a05; box-shadow: 0 4px 0 var(--gold-deep), 0 8px 18px rgba(221,159,19,.28); }
  .btn:hover { transform: translateY(-1px); }
  .btn:active { transform: translateY(3px); box-shadow: 0 1px 0 rgba(0,0,0,.15) !important; }
  .btn-row { display:flex; gap:10px; flex-wrap:wrap; justify-content:center; margin-top:8px; }

  /* Hover tooltip: attach data-tooltip="..." to any element to get a themed
     popover above it on mouse hover (desktop-oriented; on touch devices
     hover doesn't fire, so this degrades to no tooltip rather than breaking). */
  [data-tooltip] { position: relative; }
  [data-tooltip]::after {
    content: attr(data-tooltip);
    position: absolute; bottom: 100%; left: 50%;
    transform: translateX(-50%) translateY(-6px);
    background: var(--pill-dark); color: #fff;
    padding: 9px 12px; border-radius: var(--radius-sm);
    font-size: 11.5px; font-weight: 600; line-height: 1.5;
    font-family: 'Nunito', sans-serif; letter-spacing: 0;
    white-space: normal; width: max-content; max-width: 220px; text-align: left;
    box-shadow: var(--shadow-soft);
    opacity: 0; visibility: hidden; pointer-events: none;
    transition: opacity .15s ease, transform .15s ease;
    z-index: 30;
  }
  [data-tooltip]::before {
    content: ''; position: absolute; bottom: 100%; left: 50%;
    transform: translateX(-50%) translateY(2px);
    border: 6px solid transparent; border-top-color: var(--pill-dark);
    opacity: 0; visibility: hidden; pointer-events: none;
    transition: opacity .15s ease;
    z-index: 30;
  }
  [data-tooltip]:hover::after, [data-tooltip]:focus-visible::after { opacity: 1; visibility: visible; transform: translateX(-50%) translateY(-10px); }
  [data-tooltip]:hover::before, [data-tooltip]:focus-visible::before { opacity: 1; visibility: visible; }
  .side { display:flex; flex-direction:column; gap: 20px; width: 130px; }
  .panel {
    position:relative; background: var(--panel); border:none; border-radius: var(--radius-md);
    padding: 16px 10px 10px 10px; box-shadow: var(--shadow-soft);
  }
  .panel .label {
    position:absolute; top:-11px; left:10px; background: var(--sword); color:#fff;
    font-size: 10px; font-weight:700; letter-spacing:.4px; padding:4px 12px; border-radius:999px;
    box-shadow: 0 3px 0 var(--sword-deep);
  }
  .panel .label.label-hold { background: var(--gold); color:#6b4a05; box-shadow: 0 3px 0 var(--gold-deep); }
  .panel .label.label-next { background: var(--mint); box-shadow: 0 3px 0 var(--mint-deep); }
  .panel .label.label-score-alt { background: var(--shield); box-shadow: 0 3px 0 var(--shield-deep); }
  .panel canvas { display:block; margin: 0 auto; }
  .stat { display:flex; justify-content:space-between; font-size: 12.5px; margin: 5px 0; color:var(--ink); }
  .stat b { color: var(--sword-deep); font-weight:800; font-size:12.5px; }
  .keys { font-size: 10px; color: var(--ink-dim); line-height: 1.8; }
  .keys b { color: var(--ink); }

  /* Settings Modal */
  .modal-back {
    position:fixed; inset:0; background:rgba(23,33,60,.55); display:flex; align-items:center; justify-content:center;
    z-index: 50;
  }
  .modal-back.hidden { display:none; }
  .modal {
    background: var(--panel); border:none; border-radius: var(--radius-lg); padding:22px 26px;
    width: 560px; max-width: 92vw; max-height: 86vh; overflow-y:auto;
    box-shadow: 0 24px 60px rgba(10,22,45,.4), 0 0 0 3px var(--ring);
  }
  .modal h2 { font-size:17px; font-weight:800; color:var(--ink); margin:0 0 14px 0; letter-spacing:.2px; }
  .modal-tabs { display:flex; gap:5px; margin-bottom:16px; background:var(--surface-alt); border-radius:999px; padding:4px; }
  .tab-btn {
    background:transparent; border:none; color:var(--ink-dim); padding:7px 12px; font-size:11px; font-weight:700;
    letter-spacing:.2px; cursor:pointer; border-radius:999px; font-family:'Nunito',sans-serif; flex:1;
  }
  .tab-btn.active { color:#fff; background: var(--sword); box-shadow: 0 3px 0 var(--sword-deep); }
  .tab-panel { display:none; }
  .tab-panel.active { display:block; }
  .field-row { display:flex; align-items:center; justify-content:space-between; margin: 10px 0; gap: 10px; }
  .field-row label { font-size:12.5px; color:var(--ink); font-weight:600; }
  .field-row .hint, p.hint { font-size:10.5px; color:var(--ink-dim); display:block; margin-top:2px; font-weight:400; }
  .field-row input[type=number] {
    width:70px; background:var(--surface-input); border:2px solid var(--line); color:var(--ink);
    padding:6px 7px; border-radius: var(--radius-sm); font-family:inherit; font-size:12px; font-weight:700;
  }
  .field-row input[type=range] { width: 160px; }
  .keybind-row {
    display:flex; align-items:center; justify-content:space-between; margin: 7px 0; padding: 8px 10px;
    background:var(--surface-input); border-radius: var(--radius-sm);
  }
  .keybind-row span.act { font-size:12.5px; font-weight:600; }
  .key-btn {
    background:var(--panel); border:2px solid var(--line); color:var(--sword-deep); font-family:inherit; font-weight:700;
    padding:5px 10px; border-radius:999px; font-size:11.5px; cursor:pointer; min-width: 84px;
  }
  .key-btn.waiting { color: #fff; background: var(--shield); border-color: var(--shield-deep); animation: blink 1s infinite; }
  @keyframes blink { 50% { opacity:.4; } }
  .key-chip-list { display:flex; gap:6px; flex-wrap:wrap; justify-content:flex-end; }
  .key-chip { display:flex; align-items:center; gap:2px; }
  .key-chip .key-btn { min-width: 56px; padding:5px 8px; }
  .key-remove { background:transparent; border:none; color:var(--ink-dim); cursor:pointer; font-size:15px; padding:0 3px; line-height:1; }
  .key-remove:hover { color:var(--shield); }
  .key-add {
    background:transparent; border:2px dashed var(--line); color:var(--ink-dim); font-family:inherit;
    padding:5px 10px; border-radius:999px; font-size:13px; cursor:pointer;
  }
  .key-add:hover { color:var(--mint-deep); border-color:var(--mint); }
  .modal-footer { display:flex; justify-content:flex-end; gap:8px; margin-top:18px; }

  .room-code {
    font-size: 28px; font-weight:800; letter-spacing: 5px; color: var(--ink); margin: 6px 0;
    background:var(--surface-alt); padding:8px 20px; border-radius:999px; box-shadow: inset 0 0 0 2px var(--line);
  }
  .status-line { font-size: 12px; color: var(--ink-dim); min-height: 16px; font-weight:600; }
  input.textbox {
    background:var(--surface-input); border:2px solid var(--line); color:var(--ink); padding:9px 10px;
    border-radius:999px; font-family:inherit; font-size:13px; font-weight:700; letter-spacing:1.5px; text-align:center; width: 180px;
  }

  @media (max-width: 720px) {
    .player-block { flex-direction:column; align-items:center; }
    .side { flex-direction:row; width:auto; flex-wrap:wrap; justify-content:center; }
  }
</style>
<script>
  // Apply saved (or system-preferred) theme before the page paints, to avoid a light-mode flash.
  (function(){
    try {
      const saved = localStorage.getItem('tetrosTheme');
      const theme = saved || (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
      if (theme === 'dark') document.documentElement.setAttribute('data-theme', 'dark');
    } catch (e) {}
  })();
</script>
</head>
<body>

<div class="stage">
  <div class="topbar">
    <span class="mode-label" id="modeLabel">SRS TETRIS</span>
    <button class="btn secondary" id="btnBackToLobby" style="padding:5px 12px; font-size:11px; display:none;">&larr; Lobby</button>
    <button class="btn secondary" id="settingsBtnTop" style="padding:5px 12px; font-size:11px;">Settings</button>
    <button class="btn secondary" id="themeToggleBtn" style="padding:5px 12px; font-size:11px;" aria-label="Toggle dark mode" title="Toggle dark mode">&#127769;</button>
  </div>
  <div class="players" id="playersContainer"></div>
</div>

<!-- Main Menu Overlay -->
<div class="overlay" id="menuOverlay">
  <div class="menu-card">
  <h1>SRS TETRIS</h1>
  <p>SRS rotation + wall kick tables · 180&deg; spin · custom DAS/ARR · key rebinding<br>Supports local 2-player and online (P2P) battles</p>
  <div class="btn-row">
    <button class="btn" id="btnSingle">1 Player</button>
    <button class="btn btn-gold" id="btnLocal2p">Local 2P Battle</button>
    <button class="btn btn-mint" id="btnOnline">Online Battle</button>
  </div>
  <div class="btn-row">
    <button class="btn secondary" id="btnSettingsMenu">Controls</button>
  </div>
  </div>
</div>

<!-- 1 Player Submenu (choice between Normal and Blitz) -->
<div class="overlay hidden" id="onePlayerOverlay">
  <div class="menu-card">
  <h1>1 Player</h1>
  <p class="hint" style="margin: 2px 0 12px 0;">Best: Normal <b class="c-hs-single">0</b> · Blitz <b class="c-hs-blitz">0</b> · PC Streak <b class="c-hs-pc">0</b></p>
  <div class="btn-row">
    <button class="btn" id="btnNormalMode" data-tooltip="Endless — play until you top out.">Normal</button>
    <button class="btn btn-coral" id="btnBlitzMode" data-tooltip="2 minutes on the clock — score as high as you can before time runs out.">Blitz (2:00)</button>
    <button class="btn btn-mint" id="btnPcMode" data-tooltip="10 pieces per round — clear the board completely to keep your streak alive. Stack up 4 rows and you're out.">PC Mode</button>
    <button class="btn secondary" id="btnOnePlayerBack">Back</button>
  </div>
  </div>
</div>

<!-- Online Battle Submenu (choice) -->
<div class="overlay hidden" id="onlineOverlay">
  <div class="menu-card">
  <h1>Online Battle</h1>
  <p id="onlineDesc">Quick Match pairs you with a random opponent, or share a room code for a private match. (Internet connection required)</p>
  <input class="textbox" id="nicknameInput" placeholder="Nickname" maxlength="16" style="width:170px; letter-spacing:normal; font-size:12.5px; margin: 2px 0 6px 0;">
  <p class="hint" style="margin: 0 0 12px 0;">Rank <b class="c-online-rank">C</b> · Rating <b class="c-online-rating">1000</b><span id="onlineStreakInline" style="display:none;"> · <b class="c-online-streak">🔥 0</b></span></p>
  <div id="onlineChoice" class="btn-row">
    <button class="btn btn-mint" id="btnQuickMatch">Quick Match</button>
    <button class="btn" id="btnHost">Create Room</button>
    <button class="btn btn-gold" id="btnJoin">Join Room</button>
    <button class="btn secondary" id="btnOnlineBack">Back</button>
  </div>
  <button type="button" id="qmInfoBtn" style="background:none; border:none; color:var(--ink-dim); font-size:11px; text-decoration:underline; cursor:pointer; margin-top:10px; padding:2px; font-family:inherit;">Why might Quick Match not work?</button>
  <p id="qmInfoText" class="hint" style="display:none; text-align:left; margin: 6px 4px 0 4px; line-height:1.6;">
    Quick Match shares a small pool of 50 open "slots" instead of a real matchmaking queue — this game has no server of its own. <b>It works</b> when fewer than 50 people are searching at the same time and both players' networks allow a direct peer-to-peer connection. <b>It can fail</b> if: all 50 slots are full ("everyone's busy" — just try again in a moment), the shared signaling service has a temporary hiccup (auto-retries once on its own), or a strict firewall/VPN blocks the direct connection between the two browsers. If Quick Match keeps failing, Create Room / Join Room with a shared code goes through the same network path but is easier to retry together with a friend.
  </p>
  </div>
</div>

<!-- Quick Match Screen -->
<div class="overlay hidden" id="quickMatchOverlay">
  <div class="menu-card">
  <h1>Quick Match</h1>
  <p>Looking for another player who's also searching...</p>
  <div class="status-line" id="qmStatus">Connecting...</div>
  <div class="btn-row"><button class="btn secondary" id="btnQmCancel">Cancel</button></div>
  </div>
</div>

<!-- Create Room Screen (independent) -->
<div class="overlay hidden" id="hostOverlay">
  <div class="menu-card">
  <h1>Create Room</h1>
  <p>Share this code with your opponent so they can join.</p>
  <div class="room-code" id="hostCode">------</div>
  <div class="btn-row" style="margin-top:-2px;"><button class="btn secondary" id="btnCopyCode" style="padding:6px 14px; font-size:11px;">Copy Code</button></div>
  <div class="status-line" id="hostStatus">Opening room...</div>
  <div class="btn-row"><button class="btn secondary" id="btnHostBack">Back</button></div>
  </div>
</div>

<!-- Join Room Screen (independent) -->
<div class="overlay hidden" id="joinOverlay">
  <div class="menu-card">
  <h1>Join Room</h1>
  <p>Enter the room code your opponent shared with you.</p>
  <input class="textbox" id="joinCodeInput" placeholder="Enter room code" maxlength="9">
  <div class="btn-row" style="margin-top:10px;">
    <button class="btn" id="btnJoinConfirm">Connect</button>
    <button class="btn secondary" id="btnJoinBack">Back</button>
  </div>
  <div class="status-line" id="joinStatus"></div>
  </div>
</div>

<!-- Settings Modal -->
<div class="modal-back hidden" id="settingsModal">
  <div class="modal">
    <h2>Controls / Speed Settings</h2>
    <div class="modal-tabs">
      <button class="tab-btn active" data-tab="general">General (DAS/ARR)</button>
      <button class="tab-btn" data-tab="single">Controls</button>
    </div>

    <div class="tab-panel active" id="tab-general">
      <div class="field-row">
        <label>DAS (Delayed Auto Shift)
          <span class="hint">Time after pressing a direction key before continuous movement starts</span>
        </label>
        <input type="number" id="dasInput" min="0" max="500" step="1"> ms
      </div>
      <div class="field-row">
        <label>ARR (Auto Repeat Rate)
          <span class="hint">Interval between each cell moved during continuous movement (0 = instantly to the wall)</span>
        </label>
        <input type="number" id="arrInput" min="0" max="200" step="1"> ms
      </div>
      <div class="field-row">
        <label>Soft Drop Speed
          <span class="hint">Interval between each cell dropped downward (0 = instantly to the floor)</span>
        </label>
        <input type="number" id="sdrInput" min="0" max="100" step="1"> ms
      </div>
      <div class="keybind-row">
        <span class="act">Restart (Single Player)</span>
        <div class="key-chip-list" id="restartKeyList"></div>
      </div>
    </div>

    <div class="tab-panel" id="tab-single">
      <p class="hint" style="margin:0 0 8px 0;">Used everywhere — 1 Player, Online Battle, and both players in Local 2P Battle (which is turn-based, so there's no need for separate key sets anymore).</p>
      <div id="singleKeyList"></div>
    </div>

    <div class="modal-footer">
      <button class="btn secondary" id="btnResetKeys">Restore Defaults</button>
      <button class="btn" id="btnCloseSettings">Save &amp; Close</button>
    </div>
  </div>
</div>

<script src="https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js" onerror="this.dataset.failed='1'"></script>
<script>
  // Fallback: if the primary CDN failed to load PeerJS, try a second CDN.
  if (typeof Peer === 'undefined') {
    document.write('<scr' + 'ipt src="https://cdn.jsdelivr.net/npm/peerjs@1.5.2/dist/peerjs.min.js"></scr' + 'ipt>');
  }
</script>
<script>
(function(){
  "use strict";

  // ================= Basic constants / shape definitions =================
  const COLS = 10, ROWS = 20, CELL = 26, NEXT_COUNT = 5, GARBAGE_DELAY_MS = 1500;
  const COLORS = {
    I: '#4fd1c5', O: '#f4d35e', T: '#c084fc', S: '#7bd88f',
    Z: '#ff6b6b', J: '#5b8def', L: '#ffa552', G: '#5a6472'
  };
  const SHAPES = {
    I: { size:4, states:[
      [[0,1],[1,1],[2,1],[3,1]], [[2,0],[2,1],[2,2],[2,3]],
      [[0,2],[1,2],[2,2],[3,2]], [[1,0],[1,1],[1,2],[1,3]] ] },
    O: { size:4, states:[
      [[1,0],[2,0],[1,1],[2,1]], [[1,0],[2,0],[1,1],[2,1]],
      [[1,0],[2,0],[1,1],[2,1]], [[1,0],[2,0],[1,1],[2,1]] ] },
    T: { size:3, states:[
      [[1,0],[0,1],[1,1],[2,1]], [[1,0],[1,1],[2,1],[1,2]],
      [[0,1],[1,1],[2,1],[1,2]], [[1,0],[0,1],[1,1],[1,2]] ] },
    S: { size:3, states:[
      [[1,0],[2,0],[0,1],[1,1]], [[1,0],[1,1],[2,1],[2,2]],
      [[1,1],[2,1],[0,2],[1,2]], [[0,0],[0,1],[1,1],[1,2]] ] },
    Z: { size:3, states:[
      [[0,0],[1,0],[1,1],[2,1]], [[2,0],[1,1],[2,1],[1,2]],
      [[0,1],[1,1],[1,2],[2,2]], [[1,0],[0,1],[1,1],[0,2]] ] },
    J: { size:3, states:[
      [[0,0],[0,1],[1,1],[2,1]], [[1,0],[2,0],[1,1],[1,2]],
      [[0,1],[1,1],[2,1],[2,2]], [[1,0],[1,1],[0,2],[1,2]] ] },
    L: { size:3, states:[
      [[2,0],[0,1],[1,1],[2,1]], [[1,0],[1,1],[1,2],[2,2]],
      [[0,1],[1,1],[2,1],[0,2]], [[0,0],[1,0],[1,1],[1,2]] ] }
  };
  const KICKS_JLSTZ = {
    "0>1": [[0,0],[-1,0],[-1,-1],[0,2],[-1,2]],
    "1>0": [[0,0],[1,0],[1,1],[0,-2],[1,-2]],
    "1>2": [[0,0],[1,0],[1,1],[0,-2],[1,-2]],
    "2>1": [[0,0],[-1,0],[-1,-1],[0,2],[-1,2]],
    "2>3": [[0,0],[1,0],[1,-1],[0,2],[1,2]],
    "3>2": [[0,0],[-1,0],[-1,1],[0,-2],[-1,-2]],
    "3>0": [[0,0],[-1,0],[-1,1],[0,-2],[-1,-2]],
    "0>3": [[0,0],[1,0],[1,-1],[0,2],[1,2]]
  };
  const KICKS_I = {
    "0>1": [[0,0],[-2,0],[1,0],[-2,1],[1,-2]],
    "1>0": [[0,0],[2,0],[-1,0],[2,-1],[-1,2]],
    "1>2": [[0,0],[-1,0],[2,0],[-1,-2],[2,1]],
    "2>1": [[0,0],[1,0],[-2,0],[1,2],[-2,-1]],
    "2>3": [[0,0],[2,0],[-1,0],[2,-1],[-1,2]],
    "3>2": [[0,0],[-2,0],[1,0],[-2,1],[1,-2]],
    "3>0": [[0,0],[1,0],[-2,0],[1,2],[-2,-1]],
    "0>3": [[0,0],[-1,0],[2,0],[-1,-2],[2,1]]
  };
  const KICKS_180 = [[0,0],[1,0],[-1,0],[0,-1],[1,-1],[-1,-1],[0,1]];
  function getKicks(type, from, to){
    if (type === 'O') return [[0,0]];
    const table = type === 'I' ? KICKS_I : KICKS_JLSTZ;
    return table[from + '>' + to] || [[0,0]];
  }

  // ================= Spin (All-Spin) detection =================
  // Generalizes the classic T-Spin "3-corner" rule to every piece that
  // rotates inside a 3x3 bounding box (T, S, Z, L, J): if 3+ of the box's 4
  // corners are occupied (by other blocks/walls/floor) right after a
  // rotation, it's a spin. How Mini vs Full is decided differs per piece,
  // because the pieces aren't geometrically equivalent:
  //   - T never occupies any of its own 4 corners, so its corners split
  //     cleanly into a "front" pair (both enclosed by the point) and a
  //     "back" pair. Full = both front corners filled, Mini = only one.
  //   - S/Z always occupy exactly one of their own 4 corners, so the T-style
  //     pairing doesn't apply (one "front" cell would always be the piece's
  //     own square and could never register as filled). Each S/Z rotation
  //     instead has exactly one true "front" corner — the one corner that's
  //     enclosed by the piece on both adjacent edges. Full = that corner
  //     filled, Mini = it's the empty one among the 3 free corners.
  //   - J/L also occupy one of their own 4 corners, but unlike S/Z the
  //     remaining 3 free corners are all equally adjacent to the elbow (no
  //     single one stands out as "the" front corner) — so instead of a
  //     corner pairing, Full/Mini is decided by immobility: truly wedged in
  //     (can't slide left, right, or down) is Full, otherwise Mini.
  // The I piece has no clean 3x3 pivot at all, so it skips the corner rule
  // entirely and uses the same immobility test, with no Mini tier. O never
  // spins. Separately, any spin reached via a 180° kick, or via the final
  // (deepest) entry of a kick table, always counts as Full regardless of
  // the piece-specific rule above.
  const SPIN_CORNERS = [[0,0],[2,0],[0,2],[2,2]];
  // Front-corner pair for T only — see the block comment above for why this
  // pairing doesn't extend to S/Z/J/L.
  const SPIN_FRONT_CORNERS = { 0:[[0,0],[2,0]], 1:[[2,0],[2,2]], 2:[[0,2],[2,2]], 3:[[0,0],[0,2]] };
  // Each S/Z rotation state's single true "front" corner (see block comment
  // above), indexed by rotation state (0-3).
  const SPIN_FRONT_CORNER_S = [[0,0],[2,0],[2,2],[0,2]];
  const SPIN_FRONT_CORNER_Z = [[2,0],[2,2],[0,2],[0,0]];
  const CLEAR_NAMES = ['', 'SINGLE', 'DOUBLE', 'TRIPLE', 'TETRIS'];
  // Score/attack tables indexed by lines cleared (0-3) for a spin clear.
  // There is no index for 4 (Quad): a 4-line clear is never credited as a
  // spin for any piece — see the cleared===4 guard in clearLines().
  const SPIN_FULL_POINTS = [400, 800, 1200, 1600];
  const SPIN_MINI_POINTS = [100, 200, 400, 800];
  const SPIN_FULL_ATTACK = [0, 2, 4, 6];
  const SPIN_MINI_ATTACK = [0, 1, 1, 2];

  // ================= Seeded RNG (for online sync) =================
  function mulberry32(seed){
    let a = seed >>> 0;
    return function(){
      a |= 0; a = (a + 0x6D2B79F5) | 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
  const PIECE_TYPES = ['I','O','T','S','Z','J','L'];

  // ================= Settings (DAS/ARR/key bindings) =================
  const ACTIONS = ['left','right','softDrop','hardDrop','rotateCW','rotateCCW','rotate180','hold','pause'];
  const ACTION_LABEL = {
    left:'Move Left', right:'Move Right', softDrop:'Soft Drop', hardDrop:'Hard Drop',
    rotateCW:'Rotate CW', rotateCCW:'Rotate CCW', rotate180:'Rotate 180°', hold:'Hold', pause:'Pause'
  };
  // Key profiles are split by context so tweaking one mode never affects another:
  //  - "single"  : used for 1P and Online Battle (full keyboard to yourself)
  //  - "local1"  : Local 2P Player 1 — WASD cluster (left side of keyboard)
  //  - "local2"  : Local 2P Player 2 — Arrow-key cluster (right side of keyboard)
  // Key profiles are split by context so tweaking one mode never affects another:
  //  - "single"  : used for 1P and Online Battle (full keyboard to yourself)
  //  - "local1"  : Local 2P Player 1 — WASD cluster (left side of keyboard)
  //  - "local2"  : Local 2P Player 2 — Arrow-key cluster (right side of keyboard)
  // Each action maps to an ARRAY of key codes — any of them will trigger it.
  const DEFAULT_SETTINGS = {
    das: 150, arr: 30, sdr: 20,
    restart: ['KeyR'],
    single: { left:['ArrowLeft'], right:['ArrowRight'], softDrop:['ArrowDown'], hardDrop:['Space'],
          rotateCW:['ArrowUp'], rotateCCW:['KeyZ'], rotate180:['KeyA'], hold:['KeyC'], pause:['KeyP'] },
    local1: { left:['KeyA'], right:['KeyD'], softDrop:['KeyS'], hardDrop:['KeyW'],
          rotateCW:['KeyE'], rotateCCW:['KeyQ'], rotate180:['KeyR'], hold:['ShiftLeft'], pause:['KeyP'] },
    local2: { left:['ArrowLeft'], right:['ArrowRight'], softDrop:['ArrowDown'], hardDrop:['ArrowUp'],
          rotateCW:['Slash'], rotateCCW:['Period'], rotate180:['Comma'], hold:['Quote'], pause:['KeyP'] }
  };
  // Normalizes a loaded value into a clean array of key codes, falling back
  // to `fallback` (also an array) when missing. Accepts old saves where a
  // single binding was stored as a plain string instead of an array.
  function normalizeKeyList(value, fallback){
    let arr;
    if (Array.isArray(value)) arr = value.slice();
    else if (typeof value === 'string' && value) arr = [value];
    else return fallback.slice();
    arr = arr.filter(v => typeof v === 'string' && v);
    arr = [...new Set(arr)];
    return arr.length ? arr : fallback.slice();
  }
  function normalizeProfile(parsedProfile, defaultProfile){
    const out = {};
    for (const action of ACTIONS){
      out[action] = normalizeKeyList(parsedProfile ? parsedProfile[action] : undefined, defaultProfile[action]);
    }
    return out;
  }
  function loadSettings(){
    try {
      const raw = localStorage.getItem('srsTetrisSettings');
      if (!raw) return JSON.parse(JSON.stringify(DEFAULT_SETTINGS));
      const parsed = JSON.parse(raw);
      return {
        das: parsed.das ?? DEFAULT_SETTINGS.das,
        arr: parsed.arr ?? DEFAULT_SETTINGS.arr,
        sdr: parsed.sdr ?? DEFAULT_SETTINGS.sdr,
        restart: normalizeKeyList(parsed.restart, DEFAULT_SETTINGS.restart),
        // Migrate old single-profile saves (pre-split "p1") into the new "single" slot.
        single: normalizeProfile(parsed.single ?? parsed.p1, DEFAULT_SETTINGS.single),
        local1: normalizeProfile(parsed.local1, DEFAULT_SETTINGS.local1),
        local2: normalizeProfile(parsed.local2, DEFAULT_SETTINGS.local2)
      };
    } catch(e){ return JSON.parse(JSON.stringify(DEFAULT_SETTINGS)); }
  }
  function saveSettings(){ localStorage.setItem('srsTetrisSettings', JSON.stringify(settings)); }
  let settings = loadSettings();

  // ================= High scores (per solo mode, kept in the lobby) =================
  // Only solo modes (Single, Blitz) get a "best score" — Local 2P and Online
  // are head-to-head matches decided by a win/loss each time, not a score
  // you're trying to beat across sessions.
  const HIGH_SCORE_KEY = 'srsTetrisHighScores';
  function loadHighScores(){
    try {
      const raw = localStorage.getItem(HIGH_SCORE_KEY);
      const parsed = raw ? JSON.parse(raw) : {};
      return { single: Number(parsed.single) || 0, blitz: Number(parsed.blitz) || 0, pcBestStreak: Number(parsed.pcBestStreak) || 0 };
    } catch(e){ return { single:0, blitz:0, pcBestStreak:0 }; }
  }
  function saveHighScores(){ localStorage.setItem(HIGH_SCORE_KEY, JSON.stringify(highScores)); }
  let highScores = loadHighScores();
  function renderHighScores(){
    const singleEl = document.querySelector('.c-hs-single');
    const blitzEl = document.querySelector('.c-hs-blitz');
    const pcEl = document.querySelector('.c-hs-pc');
    if (singleEl) singleEl.textContent = highScores.single;
    if (blitzEl) blitzEl.textContent = highScores.blitz;
    if (pcEl) pcEl.textContent = highScores.pcBestStreak;
  }
  // Updates the record for `mode` if `score` beats it, persists it, and
  // refreshes the lobby display. Returns true when a new record was set,
  // so the game-over screen can call it out.
  function maybeRecordHighScore(mode, score){
    if (!(mode in highScores) || score <= highScores[mode]) return false;
    highScores[mode] = score;
    saveHighScores();
    renderHighScores();
    return true;
  }
  renderHighScores();

  // ================= Online rating (Elo-style, with a win-streak bonus) =================
  // Fully client-side (this game has no matchmaking server, only direct P2P
  // connections), so ratings are stored per-browser and exchanged with the
  // opponent at the start of each match. There's no way to prevent someone
  // from editing their own localStorage, but for casual head-to-head play
  // this gives a meaningful sense of progress without needing a backend.
  const RATING_KEY = 'srsTetrisRating';
  const RATING_START = 1000;
  const RATING_FLOOR = 100;
  const RATING_K = 32;
  // Win-streak bonus: each consecutive win beyond the first adds +20% to the
  // rating gained, capped at 2x (reached at a 6-game win streak).
  const STREAK_BONUS_PER_WIN = 0.2;
  const STREAK_BONUS_MAX_MULT = 2.0;
  function loadRating(){
    try {
      const raw = localStorage.getItem(RATING_KEY);
      const parsed = raw ? JSON.parse(raw) : {};
      return {
        rating: Number.isFinite(parsed.rating) ? parsed.rating : RATING_START,
        streak: Number.isFinite(parsed.streak) ? parsed.streak : 0
      };
    } catch(e){ return { rating: RATING_START, streak: 0 }; }
  }
  function saveRating(){ localStorage.setItem(RATING_KEY, JSON.stringify(ratingData)); }
  let ratingData = loadRating();

  // Rank tiers, purely a cosmetic label derived from the numeric rating —
  // the rating itself is still what's used for Elo math and matchmaking
  // display. Ordered lowest to highest; a fresh account (1000) starts in C.
  const RANK_TIERS = [
    { name: 'D', min: -Infinity, color: 'var(--ink-dim)' },
    { name: 'C', min: 900,       color: 'var(--mint-deep)' },
    { name: 'B', min: 1100,      color: 'var(--sword-deep)' },
    { name: 'A', min: 1300,      color: '#c084fc' },
    { name: 'S', min: 1500,      color: 'var(--gold-deep)' },
    { name: 'X', min: 1800,      color: 'var(--shield-deep)' }
  ];
  function getRankTier(rating){
    let tier = RANK_TIERS[0];
    for (const t of RANK_TIERS){ if (rating >= t.min) tier = t; }
    return tier;
  }
  function renderRating(){
    const tier = getRankTier(ratingData.rating);
    // Rank/rating is now shown only on the Online Battle screen (moved out
    // of the main menu to keep the lobby uncluttered).
    const onlineEl = document.querySelector('.c-online-rating');
    const onlineRankEl = document.querySelector('.c-online-rank');
    const onlineStreakEl = document.querySelector('.c-online-streak');
    const onlineStreakRow = document.getElementById('onlineStreakInline');
    if (onlineEl) onlineEl.textContent = Math.round(ratingData.rating);
    if (onlineRankEl){ onlineRankEl.textContent = tier.name; onlineRankEl.style.color = tier.color; }
    if (onlineStreakEl) onlineStreakEl.textContent = `🔥 ${ratingData.streak}`;
    if (onlineStreakRow) onlineStreakRow.style.display = ratingData.streak >= 2 ? '' : 'none';
  }
  renderRating();
  // Applies the result of one online match, updates + persists the rating,
  // and returns { newRating, delta, streak, multiplier, rank } for display.
  function applyMatchResult(didWin, opponentRating){
    const opp = Number.isFinite(opponentRating) ? opponentRating : ratingData.rating;
    const expectedWin = 1 / (1 + Math.pow(10, (opp - ratingData.rating) / 400));
    let delta, multiplier = 1;
    if (didWin){
      ratingData.streak = ratingData.streak > 0 ? ratingData.streak + 1 : 1;
      multiplier = Math.min(1 + (ratingData.streak - 1) * STREAK_BONUS_PER_WIN, STREAK_BONUS_MAX_MULT);
      delta = Math.max(1, Math.round(RATING_K * (1 - expectedWin) * multiplier));
    } else {
      ratingData.streak = 0;
      delta = -Math.max(1, Math.round(RATING_K * expectedWin));
    }
    ratingData.rating = Math.max(RATING_FLOOR, ratingData.rating + delta);
    saveRating();
    renderRating();
    return {
      newRating: Math.round(ratingData.rating), delta, streak: ratingData.streak, multiplier,
      rank: getRankTier(ratingData.rating).name
    };
  }

  // ================= Nickname (shown to online opponents) =================
  // Purely self-declared, like the rating — there's no account system to
  // verify or enforce uniqueness, so treat it the same as any other
  // client-side display name (fine for casual head-to-head play).
  const NICKNAME_KEY = 'srsTetrisNickname';
  const NICKNAME_MAX_LEN = 16;
  function randomGuestName(){ return 'Guest' + Math.floor(1000 + Math.random()*9000); }
  function loadNickname(){
    try {
      const raw = localStorage.getItem(NICKNAME_KEY);
      if (raw && raw.trim()) return raw.trim().slice(0, NICKNAME_MAX_LEN);
    } catch(e){}
    return randomGuestName();
  }
  function saveNickname(name){
    const clean = (name || '').trim().slice(0, NICKNAME_MAX_LEN);
    myNickname = clean || randomGuestName();
    try { localStorage.setItem(NICKNAME_KEY, myNickname); } catch(e){}
    const input = document.getElementById('nicknameInput');
    if (input && input.value !== myNickname) input.value = myNickname;
  }
  let myNickname = loadNickname();
  const nicknameInput = document.getElementById('nicknameInput');
  if (nicknameInput){
    nicknameInput.value = myNickname;
    nicknameInput.addEventListener('change', () => saveNickname(nicknameInput.value));
    nicknameInput.addEventListener('blur', () => saveNickname(nicknameInput.value));
  }

  function keyLabel(code){
    if (!code) return '-';
    const map = { Space:'Space', ArrowLeft:'←', ArrowRight:'→', ArrowUp:'↑', ArrowDown:'↓', Enter:'Enter',
      ShiftLeft:'L-Shift', ShiftRight:'R-Shift', ControlLeft:'L-Ctrl', ControlRight:'R-Ctrl',
      AltLeft:'L-Alt', AltRight:'R-Alt', Slash:'/', Period:'.', Comma:',', Quote:"'", Semicolon:';',
      BracketLeft:'[', BracketRight:']', Backslash:'\\', Minus:'-', Equal:'=', Backquote:'`', Tab:'Tab',
      CapsLock:'Caps', Escape:'Esc', Backspace:'Backspace' };
    if (map[code]) return map[code];
    if (code.startsWith('Key')) return code.slice(3);
    if (code.startsWith('Digit')) return code.slice(5);
    return code;
  }
  // Short label for a whole list of keys bound to one action, e.g. "← / A".
  function keysLabel(arr){
    if (!arr || !arr.length) return '-';
    return arr.map(keyLabel).join(' / ');
  }

  // ================= Shared render utilities =================
  function lighten(hex, amt){
    const n = parseInt(hex.slice(1), 16);
    let r = Math.min(255,(n>>16)+amt), g = Math.min(255,((n>>8)&0xff)+amt), b = Math.min(255,(n&0xff)+amt);
    return `rgb(${r},${g},${b})`;
  }
  function drawCellOn(c, x, y, size, color, ghost){
    const px = x*size, py = y*size;
    if (ghost) { c.strokeStyle = color; c.lineWidth = 2; c.strokeRect(px+2,py+2,size-4,size-4); return; }
    const grad = c.createLinearGradient(px,py,px,py+size);
    grad.addColorStop(0, lighten(color,25)); grad.addColorStop(1,color);
    c.fillStyle = grad; c.fillRect(px+1,py+1,size-2,size-2);
    c.strokeStyle = 'rgba(0,0,0,.35)'; c.strokeRect(px+1,py+1,size-2,size-2);
  }
  function drawGridBase(c, w, h, size){
    c.fillStyle = '#17213c'; c.fillRect(0,0,w,h);
    c.strokeStyle = '#26325a';
    for (let x=0;x<=COLS;x++){ c.beginPath(); c.moveTo(x*size,0); c.lineTo(x*size,h); c.stroke(); }
    for (let y=0;y<=ROWS;y++){ c.beginPath(); c.moveTo(0,y*size); c.lineTo(w,y*size); c.stroke(); }
  }
  function renderMiniPiece(c, canvas, type){
    c.clearRect(0,0,canvas.width,canvas.height);
    if (!type) return;
    const cells = SHAPES[type].states[0];
    const cell = 16;
    const xs = cells.map(p=>p[0]), ys = cells.map(p=>p[1]);
    const minX=Math.min(...xs), maxX=Math.max(...xs), minY=Math.min(...ys), maxY=Math.max(...ys);
    const w=(maxX-minX+1)*cell, h=(maxY-minY+1)*cell;
    const offX=(canvas.width-w)/2 - minX*cell, offY=(canvas.height-h)/2 - minY*cell;
    for (const [cx,cy] of cells){
      const px=offX+cx*cell, py=offY+cy*cell;
      const grad = c.createLinearGradient(px,py,px,py+cell);
      grad.addColorStop(0, lighten(COLORS[type],25)); grad.addColorStop(1, COLORS[type]);
      c.fillStyle = grad; c.fillRect(px+1,py+1,cell-2,cell-2);
    }
  }

  // ================= DOM creation =================
  const playersContainer = document.getElementById('playersContainer');
  function buildPlayerDOM(name){
    const block = document.createElement('div');
    block.className = 'player-block';
    block.innerHTML = `
      <div class="side">
        <div class="panel"><div class="label label-hold">HOLD</div><canvas class="c-hold" width="70" height="46"></canvas></div>
        <div class="panel"><div class="label label-score-alt">SCORE</div>
          <div class="stat c-time-row" style="display:none"><span>Time</span><b class="c-time">2:00</b></div>
          <div class="stat c-pc-streak-row" style="display:none"><span>PC Streak</span><b class="c-pc-streak">0</b></div>
          <div class="stat c-pc-piece-row" style="display:none"><span>Piece</span><b class="c-pc-piece">0/10</b></div>
          <div class="stat"><span>Score</span><b class="c-score">0</b></div>
          <div class="stat"><span>Level</span><b class="c-level">1</b></div>
          <div class="stat"><span>Lines</span><b class="c-lines">0</b></div>
          <div class="stat"><span>Combo</span><b class="c-combo">0</b></div>
          <div class="stat"><span>B2B</span><b class="c-b2b">0</b></div>
          <div class="stat"><span>PPS</span><b class="c-pps">0.00</b></div>
          <div class="stat"><span>APM</span><b class="c-apm">0.0</b></div>
        </div>
      </div>
      <div>
        <div class="p-name">${name}</div>
        <div class="board-wrap">
          <canvas class="c-board" width="${COLS*CELL}" height="${ROWS*CELL}"></canvas>
          <div class="overlay hidden c-overlay"></div>
          <div class="flash-msg c-flash"></div>
          <div class="b2b-badge hidden c-b2b-badge">B2B</div>
        </div>
      </div>
      <div class="side">
        <div class="panel"><div class="label label-next">NEXT</div><canvas class="c-next" width="70" height="240"></canvas></div>
      </div>
    `;
    playersContainer.appendChild(block);
    return {
      block,
      nameEl: block.querySelector('.p-name'),
      boardCanvas: block.querySelector('.c-board'),
      holdCanvas: block.querySelector('.c-hold'),
      nextCanvas: block.querySelector('.c-next'),
      timeEl: block.querySelector('.c-time'),
      timeRowEl: block.querySelector('.c-time-row'),
      pcStreakEl: block.querySelector('.c-pc-streak'),
      pcStreakRowEl: block.querySelector('.c-pc-streak-row'),
      pcPieceEl: block.querySelector('.c-pc-piece'),
      pcPieceRowEl: block.querySelector('.c-pc-piece-row'),
      scoreEl: block.querySelector('.c-score'),
      levelEl: block.querySelector('.c-level'),
      linesEl: block.querySelector('.c-lines'),
      comboEl: block.querySelector('.c-combo'),
      b2bEl: block.querySelector('.c-b2b'),
      ppsEl: block.querySelector('.c-pps'),
      apmEl: block.querySelector('.c-apm'),
      overlayEl: block.querySelector('.c-overlay'),
      flashEl: block.querySelector('.c-flash'),
      b2bBadgeEl: block.querySelector('.c-b2b-badge')
    };
  }
  // Pops a short-lived message (combo / perfect clear) over the board.
  function showFlash(dom, text, color){
    const el = dom.flashEl;
    if (!el) return;
    el.textContent = text;
    el.style.color = color || '';
    el.classList.remove('show');
    void el.offsetWidth; // restart the CSS animation
    el.classList.add('show');
  }
  function clearPlayers(){ playersContainer.innerHTML = ''; }

  // ================= Game class =================
  class Game {
    constructor(opts){
      this.dom = opts.dom;
      this.keys = opts.keys;
      this.seed = opts.seed != null ? opts.seed : Math.floor(Math.random()*1e9);
      this.rng = mulberry32(this.seed);
      this.onAttack = opts.onAttack || null;
      this.onStateUpdate = opts.onStateUpdate || null;
      this.onGameOverCb = opts.onGameOverCb || null;
      this.timeLimit = opts.timeLimit || null; // ms; set for Blitz mode
      this.pregameDelay = opts.pregameDelay || 0; // ms; countdown shown before play actually starts
      this.pcRoundSize = opts.pcRoundSize || null; // set for Perfect Clear Practice: pieces per round
      this.onPcProgress = opts.onPcProgress || null; // (piecesUsed, roundSize) after every placement in PC mode
      this.onPcResult = opts.onPcResult || null; // (success:boolean) when a PC round ends
      // Turn-based mode (used by Local 2P Battle): when set, the board freezes
      // after `turnPieceLimit` pieces lock instead of continuing, and fires
      // onTurnEnd so the controller can hand control to the other player.
      this.turnPieceLimit = opts.turnPieceLimit || null;
      this.onTurnEnd = opts.onTurnEnd || null;
      this.piecesInTurn = 0;
      this.turnActive = true;
      this.startInactive = !!opts.startInactive; // true for whichever player waits out the opening turn
      this.opponent = null;
      this.ctx = this.dom.boardCanvas.getContext('2d');
      this.holdCtx = this.dom.holdCanvas.getContext('2d');
      this.nextCtx = this.dom.nextCanvas.getContext('2d');
      this.bagQueue = [];
      this.pendingGarbage = 0;
      this.garbageTimer = 0;
      this.piecesPlaced = 0;
      this.attacksSent = 0;
      this.gameStartTime = 0;
      this.hudTimer = 0;
      this.input = {
        leftDown:false, rightDown:false, softDown:false,
        dir:null, dasTimer:0, dasCharged:false, arrTimer:0, softTimer:0
      };
    }
    // Standard 7-bag randomizer: each bag is a shuffled permutation of all 7
    // piece types, and a new bag is only generated once the current one is
    // fully drawn — guaranteeing no piece is ever seen twice before the
    // other six have appeared.
    makeBag(){
      const bag = PIECE_TYPES.slice();
      for (let i=bag.length-1;i>0;i--){ const j = Math.floor(this.rng()*(i+1)); [bag[i],bag[j]]=[bag[j],bag[i]]; }
      return bag;
    }
    nextType(){
      if (this.bagQueue.length === 0) this.bagQueue = this.makeBag();
      return this.bagQueue.shift();
    }
    newGrid(){ const g=[]; for(let r=0;r<ROWS;r++) g.push(new Array(COLS).fill(null)); return g; }
    start(){
      this.grid = this.newGrid();
      this.score=0; this.level=1; this.linesCleared=0; this.combo=0; this.b2b=0;
      this.lastActionWasRotation=false; this.lastKickWasFinal=false; this.lastRotationWas180=false;
      this.gameOver=false;
      this.holdType=null; this.holdUsed=false;
      this.bagQueue = this.makeBag();
      this.pendingGarbage = 0; this.garbageTimer = 0;
      this.piecesPlaced = 0; this.attacksSent = 0;
      this.gameStartTime = performance.now(); this.hudTimer = 0;
      this.nextQueue = Array.from({length: NEXT_COUNT}, () => this.nextType());
      this.dropAccum = 0;
      if (this.pcRoundSize){
        this.pcPiecesUsed = 0;
        if (this.onPcProgress) this.onPcProgress(0, this.pcRoundSize);
      }
      if (this.timeLimit != null){
        this.timeRemaining = this.timeLimit;
        this.timeFlashDone = new Set();
        if (this.dom.timeRowEl) this.dom.timeRowEl.style.display = '';
        this.updateTimeDisplay();
      } else if (this.dom.timeRowEl){
        this.dom.timeRowEl.style.display = 'none';
      }
      this.spawnNext();
      this.renderHold(); this.updateHUD(); this.renderNext();
      // Pregame countdown (e.g. Blitz's 3-second grace period): the board
      // and first piece are already drawn above, but nothing moves and no
      // input is accepted until it reaches zero.
      this.pregameRemaining = this.pregameDelay;
      if (this.pregameRemaining > 0) this.updatePregameDisplay();
      else this.dom.overlayEl.classList.add('hidden');
      this.piecesInTurn = 0;
      if (this.startInactive){
        // This player waits out the opening turn (turn-based Local 2P):
        // freeze immediately, discarding the piece spawnNext() just gave
        // them — it's an invisible one-piece nudge to the bag/RNG state,
        // never actually rendered or playable.
        this.turnActive = false;
        this.current = null;
      } else {
        this.turnActive = true;
      }
    }
    // Shows the big countdown number over the board during the pregame delay.
    updatePregameDisplay(){
      const secLeft = Math.ceil(this.pregameRemaining/1000);
      this.dom.overlayEl.innerHTML = `<h1 style="font-size:44px;">${secLeft > 0 ? secLeft : 'GO!'}</h1>`;
      this.dom.overlayEl.classList.remove('hidden');
    }
    // Formats/updates the mm:ss countdown display for Blitz mode, turning
    // the number red in the final 10 seconds as a visual warning.
    updateTimeDisplay(){
      if (!this.dom.timeEl) return;
      const totalSec = Math.max(0, Math.ceil(this.timeRemaining/1000));
      const m = Math.floor(totalSec/60), s = totalSec%60;
      this.dom.timeEl.textContent = `${m}:${s.toString().padStart(2,'0')}`;
      this.dom.timeEl.style.color = totalSec <= 10 ? 'var(--accent)' : '';
    }
    spawnPiece(type){
      const def = SHAPES[type];
      return { type, rot:0, x:3, y: type==='I' ? -1 : -2 };
    }
    currentCells(p){ p = p||this.current; return SHAPES[p.type].states[p.rot].map(([cx,cy])=>[p.x+cx,p.y+cy]); }
    collides(p, dx, dy, rot){
      const r = rot===undefined ? p.rot : rot;
      const cells = SHAPES[p.type].states[r];
      for (const [cx,cy] of cells){
        const x=p.x+cx+dx, y=p.y+cy+dy;
        if (x<0||x>=COLS||y>=ROWS) return true;
        if (y>=0 && this.grid[y][x]) return true;
      }
      return false;
    }
    isGrounded(){ return this.collides(this.current,0,1); }
    // Checks whether the piece that's about to lock qualifies as a spin.
    // Must be called BEFORE the piece's cells are written into this.grid.
    detectSpin(){
      if (!this.lastActionWasRotation) return null;
      const type = this.current.type;
      if (type === 'O') return null;
      const p = this.current;
      const filled = (cx,cy) => {
        const x = p.x+cx, y = p.y+cy;
        if (y < 0) return false; // open space above the board never "counts"
        if (x < 0 || x >= COLS || y >= ROWS) return true; // walls/floor count as filled
        return !!this.grid[y][x];
      };
      if (type === 'I'){
        // No clean 3x3 pivot for I — fall back to a plain immobility test.
        const stuck = this.collides(p,-1,0) && this.collides(p,1,0) && this.collides(p,0,1);
        return stuck ? { type, tier:'full' } : null;
      }
      const cornerCount = SPIN_CORNERS.filter(([cx,cy])=>filled(cx,cy)).length;
      // S/Z always occupy one of their own 4 corners (see note above), so
      // only 3 corners are ever eligible to be "filled" at all — that
      // corner's own cell can never register in `filled()`. Applying the
      // generic "3 of 4" threshold to S/Z therefore silently demanded that
      // ALL 3 eligible corners be filled, which forces the front corner
      // (one of those 3) to always be filled just to pass this gate —
      // making the Mini branch below unreachable. S/Z instead need only
      // 2 of their 3 eligible corners to register as a spin at all.
      const minCorners = (type === 'S' || type === 'Z') ? 2 : 3;
      if (cornerCount < minCorners) return null;
      let tier;
      if (type === 'S' || type === 'Z'){
        // Only one corner is ever a genuine "front" check for S/Z (see note
        // above), so full-tier hinges on that single corner instead of a pair.
        const front = (type === 'S' ? SPIN_FRONT_CORNER_S : SPIN_FRONT_CORNER_Z)[p.rot];
        tier = filled(front[0], front[1]) ? 'full' : 'mini';
      } else if (type === 'J' || type === 'L'){
        // J/L have no clean "front pair" the way T does — of the three
        // corners not covered by the elbow itself, all three sit equally
        // close to the piece (one shared edge-neighbor each), so there's no
        // single pair to call "front". Fall back to the same immobility
        // test used for I: truly wedged in (can't slide left, right, or
        // down) counts as Full; still able to slide out despite meeting the
        // 3-corner minimum is Mini.
        const stuck = this.collides(p,-1,0) && this.collides(p,1,0) && this.collides(p,0,1);
        tier = stuck ? 'full' : 'mini';
      } else {
        // T — the only piece whose 3x3 box corners are all genuinely free
        // (T never occupies one of its own corners), so the classic
        // 2-corners-in-front / 2-behind pairing applies cleanly.
        const frontCount = SPIN_FRONT_CORNERS[p.rot].filter(([cx,cy])=>filled(cx,cy)).length;
        tier = frontCount === 2 ? 'full' : 'mini';
      }
      if (this.lastKickWasFinal) tier = 'full'; // deep final-kick spins always count as full
      if (this.lastRotationWas180) tier = 'full'; // a spin reached via a 180° turn always counts as full
      return { type, tier };
    }
    spawnNext(){
      if (this.pendingGarbage>0 && this.garbageTimer >= GARBAGE_DELAY_MS){
        this.insertGarbage(this.pendingGarbage); this.pendingGarbage=0; this.garbageTimer=0;
      }
      const type = this.nextQueue.shift();
      this.nextQueue.push(this.nextType());
      this.current = this.spawnPiece(type);
      this.isLocking=false; this.lockTimer=0; this.lockResets=0;
      this.lastActionWasRotation=false; this.lastKickWasFinal=false; this.lastRotationWas180=false;
      // Reset DAS/ARR charge on every new piece. Without this, a held
      // direction key that was already auto-repeating against the previous
      // piece stays "charged" and immediately auto-shifts the brand-new
      // piece too, which looked like pieces kept snapping/sticking to a
      // wall right after spawning. The very next repeated keydown from the
      // still-held key will re-arm it normally (fresh DAS timing).
      this.input.dasTimer = 0; this.input.dasCharged = false; this.input.arrTimer = 0;
      this.input.leftDown = false; this.input.rightDown = false; this.input.dir = null;
      if (this.collides(this.current,0,0)) this.endGame();
      this.renderNext();
      this.broadcastState();
    }
    insertGarbage(count){
      // All lines from the same garbage batch share one gap column, so the
      // whole attack lines up into a single climbable notch (like a real
      // Tetris garbage attack) instead of each row getting its own random hole.
      const gapCol = Math.floor(Math.random()*COLS);
      for (let i=0;i<count;i++){
        this.grid.shift();
        const row = new Array(COLS).fill('G');
        row[gapCol] = null;
        this.grid.push(row);
      }
      if (this.grid[0].some(c=>c)) this.endGame();
    }
    // Incoming attacks combine into a single pending batch. Each new hit
    // resets the countdown, giving a fresh window to clear lines and cancel
    // it out before it actually lands on the board.
    queueGarbage(n){ this.pendingGarbage += n; this.garbageTimer = 0; }
    lockPiece(){
      const cells = this.currentCells(this.current);
      if (cells.every(([,y])=>y<0)){ this.endGame(); return; }
      const spin = this.detectSpin(); // must run before cells are written below
      for (const [x,y] of cells){ if (y>=0) this.grid[y][x] = this.current.type; }
      this.piecesPlaced++;
      this.holdUsed = false;
      const { cleared, attack } = this.clearLines(spin);
      let outAttack = attack;
      // Cancel: an outgoing attack first offsets our own pending incoming
      // garbage before any surplus is sent to the opponent.
      if (outAttack>0 && this.pendingGarbage>0){
        const canceled = Math.min(outAttack, this.pendingGarbage);
        this.pendingGarbage -= canceled;
        outAttack -= canceled;
        if (this.pendingGarbage===0) this.garbageTimer = 0;
      }
      if (outAttack>0){
        this.attacksSent += outAttack;
        if (this.opponent) this.opponent.queueGarbage(outAttack);
        else if (this.onAttack) this.onAttack(outAttack);
      }
      this.updateHUD();
      if (this.gameOver) return;
      // PC Mode fails the moment the stack rises above 4 rows tall, even if
      // the round's piece count hasn't run out yet.
      if (this.pcRoundSize && this.stackHeight() > 4){ this.endGame('stackout'); return; }
      if (this.pcRoundSize){
        this.pcPiecesUsed = (this.pcPiecesUsed||0) + 1;
        if (this.onPcProgress) this.onPcProgress(this.pcPiecesUsed, this.pcRoundSize);
        if (this.lastClearWasPerfect){
          if (this.onPcResult) this.onPcResult(true);
          this.startPcRound();
          return;
        } else if (this.pcPiecesUsed >= this.pcRoundSize){
          if (this.onPcResult) this.onPcResult(false);
          this.startPcRound();
          return;
        }
      }
      // Turn-based Local 2P: freeze after the turn's piece quota instead of
      // continuing, and let the controller hand control to the other player.
      if (this.turnPieceLimit){
        this.piecesInTurn = (this.piecesInTurn||0) + 1;
        if (this.piecesInTurn >= this.turnPieceLimit){
          this.turnActive = false;
          this.current = null;
          this.updateHUD();
          if (this.onTurnEnd) this.onTurnEnd();
          return;
        }
      }
      this.spawnNext();
    }
    // Called by the controller when it's this player's turn to play again
    // (turn-based Local 2P): resets the per-turn piece counter and spawns
    // the first piece of the new turn.
    beginTurn(){
      this.piecesInTurn = 0;
      this.turnActive = true;
      this.spawnNext();
    }
    // Wipes the board clean and hands the player a fresh batch of pieces to
    // build another Perfect Clear attempt with, without ending the session.
    startPcRound(){
      this.grid = this.newGrid();
      this.pcPiecesUsed = 0;
      this.holdType = null; this.holdUsed = false; this.renderHold();
      this.combo = 0; this.b2b = 0;
      this.updateHUD();
      if (this.onPcProgress) this.onPcProgress(0, this.pcRoundSize);
      this.spawnNext();
    }
    clearLines(spin){
      this.lastClearWasPerfect = false;
      let cleared=0;
      for (let r=ROWS-1;r>=0;r--){
        if (this.grid[r].every(c=>c)){ this.grid.splice(r,1); this.grid.unshift(new Array(COLS).fill(null)); cleared++; r++; }
      }
      // A 4-line clear is never credited as a spin, for any piece. T, S, Z, J,
      // and L can only ever touch 3 distinct rows at once (their bounding box
      // is 3x3), so a "T-Spin Quad" (or S/Z/J/L equivalent) is geometrically
      // impossible — a spin object reaching this point with cleared===4 would
      // only ever come from I (which can span 4 rows vertically), and no
      // mainstream ruleset recognizes a "spin Tetris" for any piece. A 4-line
      // clear is always just a plain Tetris/Quad, regardless of rotation.
      if (cleared === 4) spin = null;
      let attack = 0;
      const spinLabel = spin ? `${spin.type}-SPIN${spin.tier==='mini' ? ' MINI' : ''}` : '';

      if (cleared === 0){
        // A spin that didn't clear any lines still earns a small bonus, but
        // doesn't touch the combo or Back-to-Back streaks (those only ever
        // change on an actual line clear).
        this.combo = 0;
        if (spin){
          this.score += (spin.tier==='full' ? SPIN_FULL_POINTS[0] : SPIN_MINI_POINTS[0]) * this.level;
          showFlash(this.dom, spinLabel, spin.tier==='full' ? 'var(--accent)' : '');
          this.updateHUD();
        }
        return { cleared, attack };
      }

      // Base clear score/attack: a spin clear replaces the normal line-clear
      // table with its own (higher) values; a plain Tetris (4 lines, no
      // spin) is the only non-spin clear that counts as "difficult".
      let points, isDifficult;
      if (spin){
        points = (spin.tier==='full' ? SPIN_FULL_POINTS : SPIN_MINI_POINTS)[cleared];
        attack = (spin.tier==='full' ? SPIN_FULL_ATTACK : SPIN_MINI_ATTACK)[cleared];
        isDifficult = true;
      } else {
        points = [0,100,300,500,800][cleared];
        attack = [0,0,1,2,4][cleared];
        isDifficult = (cleared === 4);
      }
      this.score += points*this.level; this.linesCleared += cleared;
      // PC Practice keeps gravity constant (level 1) round after round, so
      // the drill stays about arrangement, not about outrunning the clock.
      this.level = this.pcRoundSize ? 1 : Math.floor(this.linesCleared/10)+1;

      // Perfect Clear (All Clear): the whole board is empty after this clear.
      // Checked here (before the B2B logic below) because a Perfect Clear
      // extends the Back-to-Back streak on its own — even a plain single-line
      // clear that happens to empty the whole board still keeps B2B alive.
      const isPerfectClear = this.grid.every(row => row.every(c => c===null));
      this.lastClearWasPerfect = isPerfectClear;

      // Back-to-Back: consecutive "difficult" clears (Tetris, any all-spin
      // clear, or a Perfect Clear) chain together for a stacking bonus —
      // the qualifying clear's own base score (points*level) is multiplied
      // by 1.5x in total (the base was already added above, so only the
      // extra +0.5x needs adding here).
      if (isDifficult || isPerfectClear){
        this.b2b += 1;
        if (this.b2b > 1){
          const bonus = Math.floor(points*this.level*0.5);
          this.score += bonus;
          attack += 1;
        }
      } else {
        this.b2b = 0;
      }

      // Combo: each consecutive placement that clears at least one line
      // bumps the streak. Bonus = current combo value * 50, starting once
      // the streak reaches 2 (matching the "COMBO xN" flash/HUD, which also
      // stays at 0 until the 2nd consecutive clear).
      this.combo += 1;
      if (this.combo > 1) this.score += 50 * this.combo;

      // Attack also scales with combo, matching TETR.IO's "Multiplier"
      // combo system: attack = floor(base * (1 + 0.25 * comboIndex)), where
      // comboIndex is 0 on the *second* consecutive clear (TETR.IO counts
      // your first combo hit as "combo 0"). If the base attack is 0 (e.g. a
      // string of plain Singles), TETR.IO instead ramps it up on a log
      // curve so long small-clear combos still build toward real damage
      // without exploding — same formula used here.
      if (this.combo > 1){
        const comboIndex = this.combo - 2;
        attack = attack > 0
          ? Math.floor(attack * (1 + 0.25 * comboIndex))
          : Math.floor(Math.log1p(1.25 * comboIndex));
      }

      // Flash message: announces the spin/Tetris (the B2B streak itself is
      // shown persistently via the left-edge badge, not repeated here).
      if (spin){
        showFlash(this.dom, `${spinLabel} ${CLEAR_NAMES[cleared]}`.trim(), 'var(--accent)');
      } else if (cleared === 4){
        showFlash(this.dom, 'TETROS!', 'var(--accent)');
      } else if (this.combo > 1){
        showFlash(this.dom, `COMBO x${this.combo}`);
      }

      if (isPerfectClear){
        this.score += 3500 * this.level;
        showFlash(this.dom, 'PERFECT CLEAR!', 'var(--accent)');
      }

      this.updateHUD();
      return { cleared, attack };
    }
    updateHUD(){
      this.dom.scoreEl.textContent=this.score; this.dom.levelEl.textContent=this.level; this.dom.linesEl.textContent=this.linesCleared;
      if (this.dom.comboEl) this.dom.comboEl.textContent = this.combo>1 ? this.combo : 0;
      if (this.dom.b2bEl) this.dom.b2bEl.textContent = this.b2b>1 ? this.b2b : 0;
      if (this.dom.b2bBadgeEl){
        if (this.b2b > 1){
          this.dom.b2bBadgeEl.textContent = `B2B x${this.b2b}`;
          this.dom.b2bBadgeEl.classList.remove('hidden');
        } else {
          this.dom.b2bBadgeEl.classList.add('hidden');
        }
      }
      const elapsedSec = Math.max(0.001, (performance.now() - this.gameStartTime) / 1000);
      this.dom.ppsEl.textContent = (this.piecesPlaced / elapsedSec).toFixed(2);
      this.dom.apmEl.textContent = (this.attacksSent / (elapsedSec / 60)).toFixed(1);
    }
    resetLock(){
      if (this.isGrounded()){
        if (this.lockResets < 15){ this.isLocking=true; this.lockTimer=0; this.lockResets++; }
      } else { this.isLocking=false; this.lockTimer=0; }
    }
    move(dx){ if (!this.gameOver && !this.collides(this.current,dx,0)){ this.current.x+=dx; this.lastActionWasRotation=false; this.lastRotationWas180=false; this.resetLock(); this.broadcastState(); } }
    softDropStep(){
      if (this.gameOver) return;
      if (!this.collides(this.current,0,1)){ this.current.y+=1; this.score+=1; this.lastActionWasRotation=false; this.lastRotationWas180=false; this.updateHUD(); this.resetLock(); }
      else { this.isLocking=true; }
    }
    hardDrop(){
      if (this.gameOver) return;
      let dist=0;
      while(!this.collides(this.current,0,1)){ this.current.y+=1; dist++; }
      this.score += dist*2; this.updateHUD();
      this.lockPiece();
      this.broadcastState();
    }
    tryRotate(dir){
      if (this.gameOver) return;
      const from=this.current.rot, to=(from+dir+4)%4;
      const kicks = getKicks(this.current.type, from, to);
      for (let i=0;i<kicks.length;i++){
        const [dx,dy] = kicks[i];
        if (!this.collides(this.current,dx,dy,to)){
          this.current.x+=dx; this.current.y+=dy; this.current.rot=to;
          this.lastActionWasRotation = true;
          this.lastKickWasFinal = (i === kicks.length-1 && kicks.length>1);
          this.lastRotationWas180 = false;
          this.resetLock(); this.broadcastState(); return;
        }
      }
    }
    tryRotate180(){
      if (this.gameOver) return;
      const from=this.current.rot, to=(from+2)%4;
      for (let i=0;i<KICKS_180.length;i++){
        const [dx,dy] = KICKS_180[i];
        if (!this.collides(this.current,dx,dy,to)){
          this.current.x+=dx; this.current.y+=dy; this.current.rot=to;
          this.lastActionWasRotation = true;
          this.lastKickWasFinal = (i === KICKS_180.length-1);
          this.lastRotationWas180 = true;
          this.resetLock(); this.broadcastState(); return;
        }
      }
    }
    holdPiece(){
      if (this.gameOver || this.holdUsed) return;
      this.holdUsed = true;
      const type = this.current.type;
      if (this.holdType===null){ this.holdType=type; this.spawnNext(); }
      else { const swap=this.holdType; this.holdType=type; this.current=this.spawnPiece(swap); this.isLocking=false; this.lockTimer=0; this.lockResets=0; this.lastActionWasRotation=false; this.lastKickWasFinal=false; this.lastRotationWas180=false; }
      this.renderHold();
    }
    endGame(reason){
      this.gameOver = true;
      this.endReason = reason || 'topout';
      if (this.onGameOverCb) this.onGameOverCb(this.endReason);
    }
    ghostY(){ let gy=this.current.y; while(!this.collides(this.current,0,gy-this.current.y+1)) gy++; return gy; }
    // Height of the stack in rows, measured up from the floor — 0 when the
    // board is empty, ROWS when a filled cell reaches the very top row.
    stackHeight(){
      for (let r=0;r<ROWS;r++){ if (this.grid[r].some(c=>c)) return ROWS - r; }
      return 0;
    }
    dropInterval(){ return Math.max(80, 1000-(this.level-1)*70); }

    // ---- Input handling (DAS/ARR) ----
    handleKeyDown(code, repeat){
      if (this.pregameRemaining > 0) return;
      if (!this.turnActive) return; // waiting for the other player's turn (turn-based Local 2P)
      const k = this.keys;
      if (k.left.includes(code)){ if(!this.input.leftDown){ this.input.leftDown=true; this.input.dir='left'; this.input.dasTimer=0; this.input.dasCharged=false; this.move(-1); } return; }
      if (k.right.includes(code)){ if(!this.input.rightDown){ this.input.rightDown=true; this.input.dir='right'; this.input.dasTimer=0; this.input.dasCharged=false; this.move(1); } return; }
      if (k.softDrop.includes(code)){ if(!this.input.softDown){ this.input.softDown=true; this.input.softTimer=0; this.softDropStep(); } return; }
      if (repeat) return;
      if (k.rotateCW.includes(code)){ this.tryRotate(1); return; }
      if (k.rotateCCW.includes(code)){ this.tryRotate(-1); return; }
      if (k.rotate180.includes(code)){ this.tryRotate180(); return; }
      if (k.hardDrop.includes(code)){ this.hardDrop(); return; }
      if (k.hold.includes(code)){ this.holdPiece(); return; }
    }
    handleKeyUp(code){
      if (this.pregameRemaining > 0) return;
      if (!this.turnActive) return;
      const k=this.keys;
      if (k.left.includes(code)){ this.input.leftDown=false; this.input.dir = this.input.rightDown ? 'right' : null; this.input.dasTimer=0; this.input.dasCharged=false; }
      if (k.right.includes(code)){ this.input.rightDown=false; this.input.dir = this.input.leftDown ? 'left' : null; this.input.dasTimer=0; this.input.dasCharged=false; }
      if (k.softDrop.includes(code)){ this.input.softDown=false; }
    }
    updateInput(dt, dasMs, arrMs, sdrMs){
      const inp = this.input;
      if (inp.dir){
        inp.dasTimer += dt;
        if (!inp.dasCharged && inp.dasTimer >= dasMs){
          inp.dasCharged = true; inp.arrTimer = 0;
          if (arrMs<=0){ while(!this.collides(this.current, inp.dir==='left'?-1:1, 0)) this.move(inp.dir==='left'?-1:1); }
          else this.move(inp.dir==='left'?-1:1);
        } else if (inp.dasCharged){
          inp.arrTimer += dt;
          if (arrMs<=0){ while(!this.collides(this.current, inp.dir==='left'?-1:1, 0)) this.move(inp.dir==='left'?-1:1); }
          else { while (inp.arrTimer>=arrMs){ this.move(inp.dir==='left'?-1:1); inp.arrTimer -= arrMs; } }
        }
      }
      if (inp.softDown){
        inp.softTimer += dt;
        if (sdrMs<=0){ while(!this.collides(this.current,0,1)) this.softDropStep(); }
        else { while (inp.softTimer>=sdrMs){ this.softDropStep(); inp.softTimer -= sdrMs; } }
      }
    }
    update(dt, dasMs, arrMs, sdrMs){
      if (this.gameOver) return;
      if (!this.turnActive) return; // frozen, waiting for the other player's turn (turn-based Local 2P)
      if (this.pregameRemaining > 0){
        this.pregameRemaining -= dt;
        if (this.pregameRemaining <= 0){
          this.pregameRemaining = 0;
          this.dom.overlayEl.classList.add('hidden');
          this.gameStartTime = performance.now(); // PPS/APM/time-limit clocks start now, not at start()
          this.dropAccum = 0;
        } else {
          this.updatePregameDisplay();
        }
        return;
      }
      if (this.timeLimit != null){
        this.timeRemaining -= dt;
        if (this.timeRemaining <= 0){
          this.timeRemaining = 0;
          this.updateTimeDisplay();
          this.endGame('timeup');
          return;
        }
        this.updateTimeDisplay();
        const remainingSec = Math.ceil(this.timeRemaining/1000);
        if ([30,10,5,4,3,2,1].includes(remainingSec) && !this.timeFlashDone.has(remainingSec)){
          this.timeFlashDone.add(remainingSec);
          showFlash(this.dom, remainingSec<=5 ? String(remainingSec) : `${remainingSec}s LEFT`, 'var(--accent)');
        }
      }
      this.hudTimer += dt;
      if (this.hudTimer >= 250){ this.hudTimer = 0; this.updateHUD(); this.broadcastState(); }
      if (this.pendingGarbage>0){
        this.garbageTimer += dt;
        if (this.garbageTimer >= GARBAGE_DELAY_MS){
          const amt = this.pendingGarbage;
          this.pendingGarbage = 0; this.garbageTimer = 0;
          this.insertGarbage(amt);
          // Shift the falling piece up along with the stack so it doesn't
          // appear to sink into the newly-added garbage rows.
          if (this.current) this.current.y -= amt;
          if (this.gameOver) return;
        }
      }
      this.updateInput(dt, dasMs, arrMs, sdrMs);
      if (this.gameOver) return;
      if (this.isLocking){
        this.lockTimer += dt;
        if (this.lockTimer > 500) this.lockPiece();
      } else {
        this.dropAccum += dt;
        if (this.dropAccum > this.dropInterval()){
          this.dropAccum = 0;
          if (!this.collides(this.current,0,1)){ this.current.y += 1; this.lastActionWasRotation=false; this.lastRotationWas180=false; }
          else { this.isLocking=true; this.lockTimer=0; }
        }
      }
    }
    draw(){
      const c = this.ctx;
      drawGridBase(c, COLS*CELL, ROWS*CELL, CELL);
      for (let r=0;r<ROWS;r++) for (let col=0;col<COLS;col++) if (this.grid[r][col]) drawCellOn(c,col,r,CELL,COLORS[this.grid[r][col]],false);
      if (this.current && !this.gameOver){
        const gy = this.ghostY();
        const ghostCells = SHAPES[this.current.type].states[this.current.rot];
        for (const [cx,cy] of ghostCells){ const y=gy+cy; if (y>=0) drawCellOn(c,this.current.x+cx,y,CELL,COLORS[this.current.type],true); }
        const cells = this.currentCells();
        for (const [x,y] of cells){ if (y>=0) drawCellOn(c,x,y,CELL,COLORS[this.current.type],false); }
      }
      this.drawGarbageMeter(c);
    }
    // Small warning bar on the right edge of the board showing how many
    // garbage lines are pending, brightening as the cancel window runs out.
    drawGarbageMeter(c){
      if (this.pendingGarbage<=0) return;
      const barW = 6;
      const x = COLS*CELL - barW - 2;
      const count = Math.min(this.pendingGarbage, ROWS);
      const progress = Math.min(1, this.garbageTimer / GARBAGE_DELAY_MS);
      c.fillStyle = `rgba(255,93,93,${(0.35+0.55*progress).toFixed(2)})`;
      for (let i=0;i<count;i++){
        const y = ROWS*CELL - (i+1)*CELL;
        c.fillRect(x, y+2, barW, CELL-4);
      }
    }
    renderHold(){ renderMiniPiece(this.holdCtx, this.dom.holdCanvas, this.holdType); }
    renderNext(){
      this.nextCtx.clearRect(0,0,this.dom.nextCanvas.width,this.dom.nextCanvas.height);
      for (let i=0;i<NEXT_COUNT;i++){
        const type = this.nextQueue[i];
        if (!type) continue;
        const cells = SHAPES[type].states[0];
        const cell = 14;
        const xs=cells.map(p=>p[0]), ys=cells.map(p=>p[1]);
        const minX=Math.min(...xs), maxX=Math.max(...xs), minY=Math.min(...ys), maxY=Math.max(...ys);
        const w=(maxX-minX+1)*cell, h=(maxY-minY+1)*cell;
        const slotH = this.dom.nextCanvas.height / NEXT_COUNT;
        const offX=(this.dom.nextCanvas.width-w)/2-minX*cell;
        const offY = i*slotH + (slotH-h)/2 - minY*cell;
        for (const [cx,cy] of cells){
          const px=offX+cx*cell, py=offY+cy*cell;
          const grad = this.nextCtx.createLinearGradient(px,py,px,py+cell);
          grad.addColorStop(0, lighten(COLORS[type],25)); grad.addColorStop(1, COLORS[type]);
          this.nextCtx.fillStyle = grad; this.nextCtx.fillRect(px+1,py+1,cell-2,cell-2);
        }
      }
    }
    getSnapshot(){
      const elapsedSec = Math.max(0.001, (performance.now() - this.gameStartTime) / 1000);
      return { grid: this.grid, current: this.current ? {type:this.current.type, rot:this.current.rot, x:this.current.x, y:this.current.y} : null,
        score:this.score, level:this.level, lines:this.linesCleared, gameOver:this.gameOver,
        pps: (this.piecesPlaced / elapsedSec).toFixed(2), apm: (this.attacksSent / (elapsedSec / 60)).toFixed(1) };
    }
    broadcastState(){
      if (!this.onStateUpdate) return;
      const now = performance.now();
      if (this._lastBroadcast && now - this._lastBroadcast < 120) return;
      this._lastBroadcast = now;
      this.onStateUpdate(this.getSnapshot());
    }
  }

  // ================= Remote board viewer (online opponent screen) =================
  class RemoteView {
    constructor(dom){ this.dom=dom; this.ctx=dom.boardCanvas.getContext('2d'); this.holdCtx=dom.holdCanvas.getContext('2d'); }
    render(state){
      if (!state) return;
      const c = this.ctx;
      drawGridBase(c, COLS*CELL, ROWS*CELL, CELL);
      for (let r=0;r<ROWS;r++) for (let col=0;col<COLS;col++) if (state.grid[r][col]) drawCellOn(c,col,r,CELL,COLORS[state.grid[r][col]],false);
      if (state.current){
        const cells = SHAPES[state.current.type].states[state.current.rot];
        for (const [cx,cy] of cells){ const x=state.current.x+cx, y=state.current.y+cy; if (y>=0) drawCellOn(c,x,y,CELL,COLORS[state.current.type],false); }
      }
      this.dom.scoreEl.textContent = state.score;
      this.dom.levelEl.textContent = state.level;
      this.dom.linesEl.textContent = state.lines;
      if (state.pps != null) this.dom.ppsEl.textContent = state.pps;
      if (state.apm != null) this.dom.apmEl.textContent = state.apm;
    }
  }

  // ================= Main controller =================
  let activeGames = [];
  let remoteView = null;
  let rafId = null, lastTime = 0, running = false, paused = false;
  let currentMode = null; // 'single' | 'local2p' | 'online'
  let peer = null, conn = null;

  const modeLabel = document.getElementById('modeLabel');
  const settingsBtnTop = document.getElementById('settingsBtnTop');
  const menuOverlay = document.getElementById('menuOverlay');
  const onePlayerOverlay = document.getElementById('onePlayerOverlay');
  const onlineOverlay = document.getElementById('onlineOverlay');
  const btnBackToLobby = document.getElementById('btnBackToLobby');

  // Shows the topbar "Lobby" button once a mode has actually started, so it
  // isn't sitting there uselessly while the player is still on the menu.
  function showLobbyButton(){ btnBackToLobby.style.display = ''; }

  // Leaves whatever mode is currently running and returns to the main menu.
  // Leaving an online match forfeits it (the opponent's connection drops,
  // which reads to them as a loss), so that case gets a confirmation prompt
  // first; other modes just quit immediately since nothing is at stake.
  function returnToLobby(){
    if (currentMode === 'online' && conn && conn.open){
      const ok = confirm('Leave online battle? This will disconnect you and end the match immediately.');
      if (!ok) return;
    }
    stopAll();
    currentMode = null;
    btnBackToLobby.style.display = 'none';
    document.querySelectorAll('.overlay').forEach(o => o.classList.add('hidden'));
    menuOverlay.classList.remove('hidden');
  }
  btnBackToLobby.addEventListener('click', returnToLobby);

  // Stops the game loop / clears the boards, but leaves any active P2P
  // connection (peer/conn) untouched. Use this when starting a game that
  // may need to keep an already-established online connection alive.
  function stopBoardsOnly(){
    running = false; paused = false;
    if (rafId) cancelAnimationFrame(rafId);
    activeGames = [];
    remoteView = null;
    clearPlayers();
    modeLabel.textContent = 'SRS TETRIS';
  }
  // Full teardown: stops the game loop AND closes/destroys any P2P
  // connection. Use this when actually leaving online play (going back to
  // the menu, or switching to single/local play).
  function stopAll(){
    stopBoardsOnly();
    qmCancelled = true;
    connAttemptId++; // invalidate any pending connection timeout/handlers
    if (conn){ try{ conn.close(); }catch(e){} conn=null; }
    if (peer){ try{ peer.destroy(); }catch(e){} peer=null; }
  }

  function loop(time){
    if (!running) return;
    const dt = time - lastTime; lastTime = time;
    if (!paused){
      for (const g of activeGames) g.update(dt, settings.das, settings.arr, settings.sdr);
      for (const g of activeGames) g.draw();
    }
    rafId = requestAnimationFrame(loop);
  }

  function showGameOverOverlay(dom, title, desc){
    dom.overlayEl.innerHTML = `<div class="menu-card" style="padding:20px 24px;"><h1 style="font-size:17px;">${title}</h1><p style="font-size:12px;">${desc}</p></div>`;
    dom.overlayEl.classList.remove('hidden');
  }
  // Used by turn-based Local 2P to mark whichever board isn't currently active.
  function showWaitingOverlay(dom, text){
    dom.overlayEl.innerHTML = `<div class="menu-card" style="padding:20px 24px;"><h1 style="font-size:16px;">${text}</h1></div>`;
    dom.overlayEl.classList.remove('hidden');
  }
  function hideOverlay(dom){ dom.overlayEl.classList.add('hidden'); }

  // ---- Single player ----
  function startSingle(){
    stopAll();
    currentMode = 'single';
    showLobbyButton();
    modeLabel.textContent = '1 Player';
    const dom = buildPlayerDOM('PLAYER');
    const g = new Game({ dom, keys: settings.single,
      onGameOverCb: () => {
        const isRecord = maybeRecordHighScore('single', g.score);
        showGameOverOverlay(dom, 'GAME OVER', `Final score: ${g.score}${isRecord ? ' — NEW RECORD!' : ''}`);
      } });
    g.start();
    activeGames = [g];
    running = true; lastTime = performance.now();
    rafId = requestAnimationFrame(loop);
  }

  // ---- Blitz (2-minute time attack, score as high as you can) ----
  const BLITZ_DURATION_MS = 120000;
  function startBlitz(){
    stopAll();
    currentMode = 'blitz';
    showLobbyButton();
    modeLabel.textContent = 'BLITZ MODE';
    const dom = buildPlayerDOM('BLITZ');
    const g = new Game({ dom, keys: settings.single, timeLimit: BLITZ_DURATION_MS, pregameDelay: 3000,
      onGameOverCb: (reason) => {
        const title = reason === 'timeup' ? "TIME'S UP" : 'TOPPED OUT';
        const isRecord = maybeRecordHighScore('blitz', g.score);
        showGameOverOverlay(dom, title, `Final score: ${g.score}${isRecord ? ' — NEW RECORD!' : ''}`);
      } });
    g.start();
    activeGames = [g];
    running = true; lastTime = performance.now();
    rafId = requestAnimationFrame(loop);
  }

  // ---- Perfect Clear Practice (10 pieces per round, clear the board to keep your streak) ----
  const PC_ROUND_SIZE = 10;
  function startPcPractice(){
    stopAll();
    currentMode = 'pc';
    showLobbyButton();
    modeLabel.textContent = 'PC MODE';
    const dom = buildPlayerDOM('PC MODE');
    if (dom.pcStreakRowEl) dom.pcStreakRowEl.style.display = '';
    if (dom.pcPieceRowEl) dom.pcPieceRowEl.style.display = '';
    let pcStreak = 0;
    const g = new Game({ dom, keys: settings.single, pcRoundSize: PC_ROUND_SIZE,
      onPcProgress: (used, total) => { if (dom.pcPieceEl) dom.pcPieceEl.textContent = `${used}/${total}`; },
      onPcResult: (success) => {
        if (success){
          pcStreak++;
          maybeRecordHighScore('pcBestStreak', pcStreak);
          showFlash(dom, 'PERFECT CLEAR!', 'var(--accent2)');
        } else {
          pcStreak = 0;
          showFlash(dom, 'NOT CLEAR — RESET', 'var(--accent)');
        }
        if (dom.pcStreakEl) dom.pcStreakEl.textContent = pcStreak;
      },
      // A genuine top-out is essentially unreachable in a 10-piece round, but
      // if it somehow happens, just start the practice session over.
      onGameOverCb: () => startPcPractice() });
    g.start();
    activeGames = [g];
    running = true; lastTime = performance.now();
    rafId = requestAnimationFrame(loop);
  }

  // ---- Local 2P ----
  // Turn-based: real-time simultaneous split-keyboard play was too hectic on
  // one physical keyboard, so instead players alternate full turns of
  // TURN_PIECES pieces each. Whatever garbage a turn generates is batched up
  // and dumped on the other player's board all at once right as their turn
  // starts (no real-time attack/cancel window, since only one side is ever
  // actually playing at a time).
  const LOCAL2P_TURN_PIECES = 7;
  function startLocal2p(){
    stopAll();
    currentMode = 'local2p';
    showLobbyButton();
    const dom1 = buildPlayerDOM('PLAYER 1');
    const dom2 = buildPlayerDOM('PLAYER 2');
    const seed = Math.floor(Math.random()*1e9);
    let matchOver = false;
    let pending1 = 0, pending2 = 0; // garbage accumulated during each player's turn, sent when it ends

    function setTurnLabel(activePlayer){
      modeLabel.textContent = `Local 2P Battle — Player ${activePlayer}'s turn (${LOCAL2P_TURN_PIECES} pieces)`;
    }

    const g1 = new Game({ dom: dom1, keys: settings.single, seed, turnPieceLimit: LOCAL2P_TURN_PIECES,
      onAttack: (n) => { pending1 += n; },
      onTurnEnd: () => {
        if (matchOver) return;
        showWaitingOverlay(dom1, 'Passing the board to Player 2...');
        setTurnLabel(2);
        const amt = pending1; pending1 = 0;
        if (amt > 0) g2.insertGarbage(amt);
        if (!g2.gameOver){ hideOverlay(dom2); g2.beginTurn(); }
      },
      onGameOverCb: () => {
        matchOver = true;
        showGameOverOverlay(dom1, 'GAME OVER', 'Defeat');
        showGameOverOverlay(dom2, 'WIN!', 'Victory');
        g2.gameOver = true; // stop the other board so it can't later overwrite this result
      } });
    const g2 = new Game({ dom: dom2, keys: settings.single, seed, turnPieceLimit: LOCAL2P_TURN_PIECES, startInactive: true,
      onAttack: (n) => { pending2 += n; },
      onTurnEnd: () => {
        if (matchOver) return;
        showWaitingOverlay(dom2, 'Passing the board to Player 1...');
        setTurnLabel(1);
        const amt = pending2; pending2 = 0;
        if (amt > 0) g1.insertGarbage(amt);
        if (!g1.gameOver){ hideOverlay(dom1); g1.beginTurn(); }
      },
      onGameOverCb: () => {
        matchOver = true;
        showGameOverOverlay(dom2, 'GAME OVER', 'Defeat');
        showGameOverOverlay(dom1, 'WIN!', 'Victory');
        g1.gameOver = true;
      } });
    g1.start(); g2.start();
    showWaitingOverlay(dom2, "Player 1 is up first — Player 2, wait your turn");
    setTurnLabel(1);
    activeGames = [g1, g2];
    running = true; lastTime = performance.now();
    rafId = requestAnimationFrame(loop);
  }

  // ---- Online ----
  // ---- PeerJS error handling shared by all four connection flows ----
  // The default `new Peer()` call goes through PeerJS's shared, free public
  // broker (0.peerjs.com) — there's no dedicated server for this game. That
  // shared broker occasionally answers a brand-new connection with a
  // transient failure (rate limiting, a momentary hiccup, etc.) that
  // typically succeeds a second later. Rather than surface a cryptic error
  // code on the very first try, each flow below retries once automatically
  // for these specific error types before showing anything to the player.
  const TRANSIENT_PEER_ERRORS = new Set(['server-error', 'network', 'socket-error', 'socket-closed']);
  function peerErrorMessage(err){
    if (TRANSIENT_PEER_ERRORS.has(err.type)){
      return "Couldn't reach the matchmaking server. This game uses a shared free signaling service (not something we host ourselves), and it occasionally has hiccups. Check your internet connection, or an ad-blocker/VPN that might be blocking it, then try again.";
    }
    return 'Error: ' + err.type + (err.message ? ' — ' + err.message : '');
  }
  function genRoomCode(){
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let s = '';
    for (let i=0;i<5;i++) s += chars[Math.floor(Math.random()*chars.length)];
    return 'TET-' + s;
  }

  function startOnlineGame(seed, isHost, knownOpponentRating, knownOpponentName){
    stopBoardsOnly();
    currentMode = 'online';
    showLobbyButton();
    modeLabel.textContent = 'Online Battle' + (isHost ? ' (Host)' : ' (Guest)');
    onlineOverlay.classList.add('hidden');
    document.getElementById('hostOverlay').classList.add('hidden');
    document.getElementById('joinOverlay').classList.add('hidden');
    document.getElementById('quickMatchOverlay').classList.add('hidden');
    const domMe = buildPlayerDOM('Me');
    const domOp = buildPlayerDOM('Opponent');
    let matchOver = false; // once the match is decided, ignore any later gameover/disconnect noise
    // The opponent's rating/name, used to weight the Elo-style rating change
    // at match end and to label their board. Known immediately if we're the
    // guest (sent alongside the seed); arrive slightly later via a 'hello'
    // message if we're the host.
    let opponentRating = Number.isFinite(knownOpponentRating) ? knownOpponentRating : null;
    let opponentName = knownOpponentName || 'Opponent';
    // Shows each player's chosen nickname + rank + current Online Rating
    // right in their name badge, so both sides can size up the match during
    // the pregame countdown.
    const nameWithRating = (base, rating) => Number.isFinite(rating) ? `${base} · ${getRankTier(rating).name} ${Math.round(rating)}` : base;
    domMe.nameEl.textContent = nameWithRating(myNickname, ratingData.rating);
    domOp.nameEl.textContent = nameWithRating(opponentName, opponentRating);
    const g = new Game({
      dom: domMe, keys: settings.single, seed, pregameDelay: 3000,
      onAttack: (n) => { if (conn && conn.open) conn.send({ type:'garbage', count:n }); },
      onStateUpdate: (state) => { if (conn && conn.open) conn.send({ type:'state', state }); },
      onGameOverCb: () => {
        if (matchOver) return;
        matchOver = true;
        const result = applyMatchResult(false, opponentRating);
        showGameOverOverlay(domMe, 'GAME OVER', `Defeat<br><b>Rating: ${result.newRating} [${result.rank}] (${result.delta})</b>`);
        if (conn && conn.open) conn.send({ type:'gameover' });
      }
    });
    remoteView = new RemoteView(domOp);
    g.start();
    activeGames = [g];
    running = true; lastTime = performance.now();
    rafId = requestAnimationFrame(loop);

    if (conn){
      conn.on('data', (data) => {
        if (data.type === 'garbage') g.queueGarbage(data.count);
        else if (data.type === 'state') remoteView.render(data.state);
        else if (data.type === 'hello'){
          opponentRating = data.rating;
          opponentName = data.name || opponentName;
          domOp.nameEl.textContent = nameWithRating(opponentName, opponentRating);
        }
        else if (data.type === 'gameover'){
          if (matchOver) return;
          matchOver = true;
          g.gameOver = true; // opponent topped out first — the match is over, stop my board too
          const result = applyMatchResult(true, opponentRating);
          const streakNote = result.streak >= 2 ? ` — ${result.streak} win streak, x${result.multiplier.toFixed(1)} bonus!` : '';
          showGameOverOverlay(domOp, 'WIN!', `Opponent has topped out<br><b>Rating: ${result.newRating} [${result.rank}] (+${result.delta})</b>${streakNote}`);
        }
      });
      conn.on('close', () => {
        if (matchOver) return; // normal end-of-match disconnects shouldn't overwrite the real result
        matchOver = true;
        g.gameOver = true;
        showGameOverOverlay(domOp, 'Disconnected', 'Connection to opponent was lost');
      });
      conn.on('error', () => {
        if (matchOver) return;
        matchOver = true;
        g.gameOver = true;
        showGameOverOverlay(domOp, 'Connection Error', 'Lost connection to opponent');
      });
    }
  }

  // Online - create room
  let isConnectingOnline = false;
  // Bumped every time the user backs out of / cancels a connection attempt
  // (Back, Cancel, or returning to the menu). Each attachGuestConnHandlers/
  // attachHostConnHandlers call captures the token value at its start; if it
  // no longer matches by the time a delayed callback (the 15s timeout, or a
  // late 'close'/'error') fires, that callback is stale and does nothing.
  // Without this, backing out and retrying within 15s could let an old
  // attempt's timeout message overwrite the new attempt's status text.
  let connAttemptId = 0;
  // How long to wait for the WebRTC data channel to actually open before
  // giving up. This matters because a failed ICE negotiation (strict NAT,
  // symmetric NAT, corporate/mobile firewall blocking UDP, etc.) does NOT
  // reliably fire 'error' or 'close' on the connection — it just hangs
  // forever with no event at all. Without an explicit timeout, the UI gets
  // stuck on "Connecting..." / "Opponent connected. Starting game..." with
  // no way out except manually going back.
  const CONNECT_TIMEOUT_MS = 15000;

  // Shared logic for "I just connected TO someone else's room/slot" (the guest side).
  // Used by both Join Room and Quick Match.
  function attachGuestConnHandlers(c, statusEl){
    const myAttempt = ++connAttemptId;
    let settled = false;
    const timeoutId = setTimeout(() => {
      if (settled || myAttempt !== connAttemptId) return;
      settled = true;
      isConnectingOnline = false;
      try{ c.close(); }catch(e){}
      if (conn === c) conn = null;
      statusEl.textContent = 'Connection timed out (this can happen if either player is behind a strict firewall/NAT). Try again.';
    }, CONNECT_TIMEOUT_MS);

    function onOpen(){
      if (settled || myAttempt !== connAttemptId) return;
      settled = true;
      clearTimeout(timeoutId);
      isConnectingOnline = false;
      statusEl.textContent = 'Connected. Waiting for game to start...';
    }
    if (c.open) onOpen(); else c.on('open', onOpen);

    // One-shot: stop listening once the seed arrives, so this handler doesn't
    // stay attached (and doing nothing) alongside the game's own 'data'
    // listener for the rest of the match.
    function onSeedData(data){
      if (data.type === 'seed'){
        c.off('data', onSeedData);
        if (myAttempt !== connAttemptId) return; // superseded — don't start a stale match
        if (c.open) c.send({ type:'hello', rating: ratingData.rating, name: myNickname });
        startOnlineGame(data.seed, false, data.rating, data.name);
      }
    }
    c.on('data', onSeedData);

    c.on('close', () => {
      if (settled || myAttempt !== connAttemptId) return;
      settled = true;
      clearTimeout(timeoutId);
      isConnectingOnline = false;
      if (conn === c) conn = null;
      statusEl.textContent = 'Connection closed before the game started. Try again.';
    });
    c.on('error', () => {
      if (settled || myAttempt !== connAttemptId) return;
      settled = true;
      clearTimeout(timeoutId);
      isConnectingOnline = false;
      if (conn === c) conn = null;
      statusEl.textContent = 'Connection failed. Try again.';
    });
  }

  // Shared logic for "someone just connected TO my room/slot" (the host side).
  // Used by both Create Room and Quick Match.
  function attachHostConnHandlers(c, statusEl, waitingText){
    const myAttempt = ++connAttemptId;
    let settled = false;
    statusEl.textContent = 'Opponent connected. Starting game...';
    const timeoutId = setTimeout(() => {
      if (settled || myAttempt !== connAttemptId) return;
      settled = true;
      try{ c.close(); }catch(e){}
      if (conn === c) conn = null;
      statusEl.textContent = 'Connection timed out (this can happen if either player is behind a strict firewall/NAT). ' + waitingText;
    }, CONNECT_TIMEOUT_MS);

    // NOTE: the data channel can already be open by the time we get here
    // (PeerJS fires 'open' at most once, and depending on ICE/negotiation
    // timing it can happen before this handler is attached). Without this
    // check, that already-fired 'open' is missed forever and the host waits
    // out the full CONNECT_TIMEOUT_MS before failing — the intermittent
    // "sometimes it just hangs" bug. Mirrors the same guard already used on
    // the guest side in attachGuestConnHandlers.
    function onOpen(){
      if (settled || myAttempt !== connAttemptId) return;
      settled = true;
      clearTimeout(timeoutId);
      const seed = Math.floor(Math.random()*1e9);
      c.send({ type:'seed', seed, rating: ratingData.rating, name: myNickname });
      startOnlineGame(seed, true);
    }
    if (c.open) onOpen(); else c.on('open', onOpen);
    c.on('close', () => {
      if (settled) return;
      if (currentMode === 'online') return; // game already started normally, ignore
      if (myAttempt !== connAttemptId) return;
      settled = true;
      clearTimeout(timeoutId);
      if (conn === c) conn = null;
      statusEl.textContent = 'Opponent disconnected before the game started. ' + waitingText;
    });
    c.on('error', () => {
      if (settled) return;
      if (currentMode === 'online') return;
      if (myAttempt !== connAttemptId) return;
      settled = true;
      clearTimeout(timeoutId);
      if (conn === c) conn = null;
      statusEl.textContent = 'Connection to opponent failed. ' + waitingText;
    });
  }

  function hostRoom(){
    onlineOverlay.classList.add('hidden');
    document.getElementById('hostOverlay').classList.remove('hidden');
    if (peer) return; // already hosting a room from a previous click
    if (typeof Peer === 'undefined'){
      document.getElementById('hostCode').textContent = '----';
      document.getElementById('hostStatus').textContent = 'Could not load the online play library (PeerJS). Check your internet connection, or that unpkg.com / jsdelivr.net are not blocked, then reload the page.';
      return;
    }
    const code = genRoomCode();
    document.getElementById('hostCode').textContent = code;
    startHostPeer(code, ++connAttemptId, 0);
  }
  function startHostPeer(code, myAttempt, retryCount){
    const statusEl = document.getElementById('hostStatus');
    statusEl.textContent = retryCount > 0 ? 'Reconnecting to matchmaking server...' : 'Opening room...';
    peer = new Peer(code);
    peer.on('open', () => { statusEl.textContent = 'Waiting for opponent... (share this code)'; });
    peer.on('connection', (c) => {
      // Only pair with the first guest that connects; politely reject anyone else.
      if (conn){ try{ c.close(); }catch(e){} return; }
      conn = c;
      attachHostConnHandlers(conn, statusEl, 'Waiting for opponent... (share this code)');
    });
    peer.on('error', (err) => {
      // The peer is unusable after an error (e.g. the room code was already
      // taken, or the broker rejected it); clear it so clicking "Create
      // Room" again actually retries instead of silently no-op'ing on the
      // old broken peer.
      try{ peer.destroy(); }catch(e){}
      peer = null;
      if (myAttempt !== connAttemptId) return; // superseded by Back/retry elsewhere
      if (retryCount === 0 && TRANSIENT_PEER_ERRORS.has(err.type)){
        setTimeout(() => { if (myAttempt === connAttemptId) startHostPeer(code, myAttempt, 1); }, 1500);
        return;
      }
      statusEl.textContent = peerErrorMessage(err) + (err.type === 'unavailable-id' ? ' (the code may already be in use) — go back and try again' : '');
    });
  }


  // Online - join room
  function joinRoom(){
    onlineOverlay.classList.add('hidden');
    document.getElementById('joinOverlay').classList.remove('hidden');
    document.getElementById('joinStatus').textContent = '';
    document.getElementById('joinCodeInput').focus();
  }
  function confirmJoin(){
    if (isConnectingOnline) return; // ignore repeated clicks while a connection attempt is in flight
    if (typeof Peer === 'undefined'){
      document.getElementById('joinStatus').textContent = 'Could not load the online play library (PeerJS). Check your internet connection, or that unpkg.com / jsdelivr.net are not blocked, then reload the page.';
      return;
    }
    const code = document.getElementById('joinCodeInput').value.replace(/\s+/g,'').toUpperCase();
    if (!code) return;
    isConnectingOnline = true;
    startJoinPeer(code, ++connAttemptId, 0);
  }
  function startJoinPeer(code, myAttempt, retryCount){
    const statusEl = document.getElementById('joinStatus');
    statusEl.textContent = retryCount > 0 ? 'Reconnecting to matchmaking server...' : 'Connecting...';
    peer = new Peer();
    peer.on('open', () => {
      conn = peer.connect(code);
      attachGuestConnHandlers(conn, statusEl);
    });
    peer.on('error', (err) => {
      if (myAttempt !== connAttemptId) return; // superseded by Back/retry elsewhere
      if (retryCount === 0 && TRANSIENT_PEER_ERRORS.has(err.type)){
        try{ peer.destroy(); }catch(e){}
        peer = null;
        setTimeout(() => { if (myAttempt === connAttemptId) startJoinPeer(code, myAttempt, 1); }, 1500);
        return;
      }
      isConnectingOnline = false;
      statusEl.textContent = peerErrorMessage(err);
    });
  }

  // Online - quick match
  // There is no backend/lobby server in this app, so instead we treat
  // PeerJS's own peer-ID namespace as a makeshift lobby: a small, fixed set
  // of "slot" IDs (TETROS-QM-0, TETROS-QM-1, ...). Quick Match scans the
  // slots in order — if a slot is already registered, we join it as a
  // guest; if a slot is free, we claim it and wait there as a host. A
  // slot's ID is automatically released by the PeerJS broker whenever that
  // player's tab closes or loses connection, so there's no stale-lobby
  // cleanup to worry about.
  const QM_PREFIX = 'TETROS-QM-';
  const QM_SLOTS = 50;
  const QM_PROBE_TIMEOUT_MS = 4000;
  let qmCancelled = false;

  function quickMatch(){
    onlineOverlay.classList.add('hidden');
    document.getElementById('quickMatchOverlay').classList.remove('hidden');
    const statusEl = document.getElementById('qmStatus');
    // Defensive cleanup: if a previous attempt (Host/Join/Quick Match) left a
    // peer or connection lying around, clear it before starting fresh so its
    // stray event handlers can't fire mid-search and show a bogus error.
    connAttemptId++;
    if (conn){ try{ conn.close(); }catch(e){} conn = null; }
    if (peer){ try{ peer.destroy(); }catch(e){} peer = null; }
    qmCancelled = false;
    if (typeof Peer === 'undefined'){
      statusEl.textContent = 'Could not load the online play library (PeerJS). Check your internet connection, or that unpkg.com / jsdelivr.net are not blocked, then reload the page.';
      return;
    }
    startQmProbePeer(connAttemptId, 0);
  }
  function startQmProbePeer(myAttempt, retryCount){
    const statusEl = document.getElementById('qmStatus');
    statusEl.textContent = retryCount > 0 ? 'Reconnecting to matchmaking server...' : 'Connecting...';
    peer = new Peer();
    peer.on('open', () => { qmScanSlot(0); });
    peer.on('error', (err) => {
      // Per-slot 'peer-unavailable' errors are handled inside qmScanSlot;
      // anything else here is an unrelated/fatal error for the probing peer.
      if (qmCancelled || myAttempt !== connAttemptId || err.type === 'peer-unavailable') return;
      if (retryCount === 0 && TRANSIENT_PEER_ERRORS.has(err.type)){
        try{ peer.destroy(); }catch(e){}
        peer = null;
        setTimeout(() => { if (!qmCancelled && myAttempt === connAttemptId) startQmProbePeer(myAttempt, 1); }, 1500);
        return;
      }
      statusEl.textContent = peerErrorMessage(err);
    });
  }

  function qmScanSlot(i){
    if (qmCancelled) return;
    const statusEl = document.getElementById('qmStatus');
    if (i >= QM_SLOTS){
      statusEl.textContent = 'No open matches right now — everyone\'s busy. Try again in a moment.';
      return;
    }
    const slotId = QM_PREFIX + i;
    statusEl.textContent = `Searching for an opponent... (${i+1}/${QM_SLOTS})`;
    let settled = false;
    const probe = peer.connect(slotId, { reliable: true });

    const to = setTimeout(() => {
      if (settled) return;
      settled = true;
      peer.off('error', onErr);
      try{ probe.close(); }catch(e){}
      qmScanSlot(i+1);
    }, QM_PROBE_TIMEOUT_MS);

    function onErr(err){
      if (settled) return;
      if (err.type === 'peer-unavailable'){
        // Nobody is registered at this slot — it's free, try to claim it.
        settled = true;
        clearTimeout(to);
        peer.off('error', onErr);
        qmClaimSlot(i);
      }
    }
    peer.on('error', onErr);

    probe.on('open', () => {
      if (settled) return;
      settled = true;
      clearTimeout(to);
      peer.off('error', onErr);
      conn = probe;
      statusEl.textContent = 'Opponent found! Connecting...';
      attachGuestConnHandlers(conn, statusEl);
    });
  }

  function qmClaimSlot(i){
    if (qmCancelled) return;
    const statusEl = document.getElementById('qmStatus');
    const slotId = QM_PREFIX + i;
    // The probing peer has a random ID and can't be renamed, so swap it out
    // for a fresh peer registered under this specific slot ID.
    try{ peer.destroy(); }catch(e){}
    peer = new Peer(slotId);
    peer.on('open', () => {
      if (qmCancelled) return;
      statusEl.textContent = 'Waiting for an opponent to join...';
    });
    peer.on('connection', (c) => {
      if (conn){ try{ c.close(); }catch(e){} return; }
      conn = c;
      attachHostConnHandlers(conn, statusEl, 'Waiting for an opponent to join...');
    });
    peer.on('error', (err) => {
      if (qmCancelled) return;
      if (err.type === 'unavailable-id'){
        // Lost a race — someone else grabbed this slot a moment ago.
        // Start a fresh probing peer and keep scanning from the next slot.
        try{ peer.destroy(); }catch(e){}
        peer = new Peer();
        peer.on('open', () => qmScanSlot(i+1));
        // 'peer-unavailable' here is the normal, expected outcome while
        // scanning for a free slot — it's already handled inside
        // qmScanSlot's own error listener, so ignore it here to avoid
        // flashing a spurious "Error: peer-unavailable" message.
        peer.on('error', (e2) => { if (!qmCancelled && e2.type !== 'peer-unavailable') statusEl.textContent = peerErrorMessage(e2); });
      } else {
        statusEl.textContent = peerErrorMessage(err);
      }
    });
  }

  function cancelQuickMatch(){
    qmCancelled = true;
    connAttemptId++; // invalidate any pending connection timeout/handlers
    if (conn){ try{ conn.close(); }catch(e){} conn = null; }
    if (peer){ try{ peer.destroy(); }catch(e){} peer = null; }
    document.getElementById('quickMatchOverlay').classList.add('hidden');
    onlineOverlay.classList.remove('hidden');
  }


  // ================= Menu/button events =================
  document.getElementById('btnSingle').addEventListener('click', () => {
    menuOverlay.classList.add('hidden'); onePlayerOverlay.classList.remove('hidden');
  });
  document.getElementById('btnNormalMode').addEventListener('click', () => { onePlayerOverlay.classList.add('hidden'); startSingle(); });
  document.getElementById('btnBlitzMode').addEventListener('click', () => { onePlayerOverlay.classList.add('hidden'); startBlitz(); });
  document.getElementById('btnPcMode').addEventListener('click', () => { onePlayerOverlay.classList.add('hidden'); startPcPractice(); });
  document.getElementById('btnOnePlayerBack').addEventListener('click', () => { onePlayerOverlay.classList.add('hidden'); menuOverlay.classList.remove('hidden'); });
  document.getElementById('btnLocal2p').addEventListener('click', () => { menuOverlay.classList.add('hidden'); startLocal2p(); });
  document.getElementById('btnOnline').addEventListener('click', () => {
    menuOverlay.classList.add('hidden'); onlineOverlay.classList.remove('hidden');
    document.getElementById('hostOverlay').classList.add('hidden');
    document.getElementById('joinOverlay').classList.add('hidden');
    document.getElementById('qmInfoText').style.display = 'none';
  });
  document.getElementById('btnOnlineBack').addEventListener('click', () => { onlineOverlay.classList.add('hidden'); menuOverlay.classList.remove('hidden'); });
  document.getElementById('btnQuickMatch').addEventListener('click', quickMatch);
  document.getElementById('qmInfoBtn').addEventListener('click', () => {
    const el = document.getElementById('qmInfoText');
    el.style.display = el.style.display === 'none' ? '' : 'none';
  });
  document.getElementById('btnQmCancel').addEventListener('click', cancelQuickMatch);
  document.getElementById('btnHost').addEventListener('click', hostRoom);
  document.getElementById('btnJoin').addEventListener('click', joinRoom);
  document.getElementById('btnJoinConfirm').addEventListener('click', confirmJoin);
  document.getElementById('joinCodeInput').addEventListener('input', (e) => {
    e.target.value = e.target.value.toUpperCase();
  });
  document.getElementById('joinCodeInput').addEventListener('keydown', (e) => {
    if (e.key === 'Enter') confirmJoin();
  });
  document.getElementById('btnCopyCode').addEventListener('click', () => {
    const code = document.getElementById('hostCode').textContent;
    const btn = document.getElementById('btnCopyCode');
    navigator.clipboard.writeText(code).then(() => {
      const original = btn.textContent;
      btn.textContent = 'Copied!';
      setTimeout(() => { btn.textContent = original; }, 1200);
    }).catch(() => {});
  });
  document.getElementById('btnHostBack').addEventListener('click', () => {
    connAttemptId++; // invalidate any pending connection timeout/handlers
    if (conn) { try{ conn.close(); }catch(e){} conn=null; }
    if (peer) { peer.destroy(); peer=null; }
    document.getElementById('hostOverlay').classList.add('hidden');
    onlineOverlay.classList.remove('hidden');
  });
  document.getElementById('btnJoinBack').addEventListener('click', () => {
    connAttemptId++; // invalidate any pending connection timeout/handlers
    if (conn) { try{ conn.close(); }catch(e){} conn=null; }
    if (peer) { peer.destroy(); peer=null; }
    isConnectingOnline = false;
    document.getElementById('joinOverlay').classList.add('hidden');
    onlineOverlay.classList.remove('hidden');
  });
  // ================= Settings modal =================
  const settingsModal = document.getElementById('settingsModal');
  const dasInput = document.getElementById('dasInput');
  const arrInput = document.getElementById('arrInput');
  const sdrInput = document.getElementById('sdrInput');
  const restartKeyList = document.getElementById('restartKeyList');
  let waitingBind = null; // {kind:'profile', profileKey, action, mode, idx} or {kind:'global', mode, idx}

  function startWaitingBind(wb, btn){
    document.querySelectorAll('.key-btn').forEach(b => b.classList.remove('waiting'));
    waitingBind = wb;
    btn.textContent = '...';
    btn.classList.add('waiting');
  }
  // Renders one action's bound keys as chips (click to rebind, × to remove)
  // plus a trailing "+" button to add another key to that same action.
  function renderKeyChips(wrap, keys, onChipClick, onRemove, onAdd){
    wrap.innerHTML = '';
    keys.forEach((code, idx) => {
      const chip = document.createElement('span');
      chip.className = 'key-chip';
      const btn = document.createElement('button');
      btn.className = 'key-btn';
      btn.textContent = keyLabel(code);
      btn.title = 'Click to change this key';
      btn.addEventListener('click', () => onChipClick(idx, btn));
      chip.appendChild(btn);
      if (keys.length > 1){
        const rm = document.createElement('button');
        rm.className = 'key-remove';
        rm.textContent = '×';
        rm.title = 'Remove this key';
        rm.addEventListener('click', (ev) => { ev.stopPropagation(); onRemove(idx); });
        chip.appendChild(rm);
      }
      wrap.appendChild(chip);
    });
    const addBtn = document.createElement('button');
    addBtn.className = 'key-add';
    addBtn.textContent = '+';
    addBtn.title = 'Add another key for this action';
    addBtn.addEventListener('click', () => onAdd(addBtn));
    wrap.appendChild(addBtn);
  }
  function renderKeyList(container, profileKey){
    container.innerHTML = '';
    for (const action of ACTIONS){
      const row = document.createElement('div');
      row.className = 'keybind-row';
      const label = document.createElement('span');
      label.className = 'act';
      label.textContent = ACTION_LABEL[action];
      row.appendChild(label);
      const wrap = document.createElement('div');
      wrap.className = 'key-chip-list';
      renderKeyChips(wrap, settings[profileKey][action],
        (idx, btn) => startWaitingBind({ kind:'profile', profileKey, action, mode:'replace', idx }, btn),
        (idx) => { settings[profileKey][action].splice(idx,1); renderAllKeyLists(); },
        (btn) => startWaitingBind({ kind:'profile', profileKey, action, mode:'add' }, btn));
      row.appendChild(wrap);
      container.appendChild(row);
    }
  }
  function renderRestartRow(){
    renderKeyChips(restartKeyList, settings.restart,
      (idx, btn) => startWaitingBind({ kind:'global', mode:'replace', idx }, btn),
      (idx) => { settings.restart.splice(idx,1); renderRestartRow(); },
      (btn) => startWaitingBind({ kind:'global', mode:'add' }, btn));
  }
  function renderAllKeyLists(){
    renderKeyList(document.getElementById('singleKeyList'), 'single');
    renderRestartRow();
  }
  function openSettings(){
    dasInput.value = settings.das; arrInput.value = settings.arr; sdrInput.value = settings.sdr;
    renderAllKeyLists();
    settingsModal.classList.remove('hidden');
  }
  function closeSettings(){
    settings.das = Math.max(0, parseInt(dasInput.value)||0);
    settings.arr = Math.max(0, parseInt(arrInput.value)||0);
    settings.sdr = Math.max(0, parseInt(sdrInput.value)||0);
    waitingBind = null;
    saveSettings();
    settingsModal.classList.add('hidden');
  }
  document.getElementById('settingsBtnTop').addEventListener('click', openSettings);
  // ================= Dark mode toggle =================
  (function(){
    const themeBtn = document.getElementById('themeToggleBtn');
    function isDark(){ return document.documentElement.getAttribute('data-theme') === 'dark'; }
    function updateIcon(){ themeBtn.innerHTML = isDark() ? '&#9728;&#65039;' : '&#127769;'; }
    function setTheme(theme){
      if (theme === 'dark') document.documentElement.setAttribute('data-theme', 'dark');
      else document.documentElement.removeAttribute('data-theme');
      try { localStorage.setItem('tetrosTheme', theme); } catch(e){}
      updateIcon();
    }
    themeBtn.addEventListener('click', () => setTheme(isDark() ? 'light' : 'dark'));
    updateIcon();
  })();
  document.getElementById('btnSettingsMenu').addEventListener('click', openSettings);
  document.getElementById('btnCloseSettings').addEventListener('click', closeSettings);
  document.getElementById('btnResetKeys').addEventListener('click', () => {
    settings = JSON.parse(JSON.stringify(DEFAULT_SETTINGS));
    dasInput.value = settings.das; arrInput.value = settings.arr; sdrInput.value = settings.sdr;
    renderAllKeyLists();
  });
  document.querySelectorAll('.tab-btn').forEach(tb => {
    tb.addEventListener('click', () => {
      document.querySelectorAll('.tab-btn').forEach(b=>b.classList.remove('active'));
      document.querySelectorAll('.tab-panel').forEach(p=>p.classList.remove('active'));
      tb.classList.add('active');
      document.getElementById('tab-' + tb.dataset.tab).classList.add('active');
    });
  });

  // Key rebind capture (highest priority while settings modal is open)
  window.addEventListener('keydown', (e) => {
    if (waitingBind){
      e.preventDefault();
      const wb = waitingBind;
      waitingBind = null;
      if (e.code === 'Escape'){
        if (wb.kind === 'global') renderRestartRow(); else renderAllKeyLists();
        return;
      }
      if (wb.kind === 'global'){
        let arr = settings.restart.slice();
        if (wb.mode === 'replace') arr[wb.idx] = e.code;
        else if (!arr.includes(e.code)) arr.push(e.code);
        settings.restart = [...new Set(arr)];
        renderRestartRow();
        return;
      }
      // Remove this key from any OTHER action within the same profile, so one
      // physical key never triggers two different actions at once.
      const profile = settings[wb.profileKey];
      for (const act of ACTIONS){
        if (act === wb.action) continue;
        profile[act] = profile[act].filter(c => c !== e.code);
      }
      let arr = profile[wb.action].slice();
      if (wb.mode === 'replace') arr[wb.idx] = e.code;
      else if (!arr.includes(e.code)) arr.push(e.code);
      profile[wb.action] = [...new Set(arr)];
      renderAllKeyLists();
      return;
    }
  }, true);

  // ================= Gameplay input =================
  function isSettingsOpen(){ return !settingsModal.classList.contains('hidden'); }
  window.addEventListener('keydown', (e) => {
    if (isSettingsOpen() || waitingBind) return;
    if (activeGames.length === 0) return;
    if ((currentMode === 'single' || currentMode === 'blitz' || currentMode === 'pc') && settings.restart.includes(e.code) && !e.repeat){
      e.preventDefault();
      if (currentMode === 'blitz') startBlitz(); else if (currentMode === 'pc') startPcPractice(); else startSingle();
      return;
    }
    let used = false;
    let pauseToggled = false; // only toggle once per keypress even if both players share the same pause key
    for (const g of activeGames){
      if (Object.values(g.keys).some(arr => arr.includes(e.code))) used = true;
      if (g.keys.pause.includes(e.code) && !e.repeat){
        if (!pauseToggled){ paused = !paused; pauseToggled = true; }
        continue;
      }
      g.handleKeyDown(e.code, e.repeat);
    }
    if (used) e.preventDefault();
  });
  window.addEventListener('keyup', (e) => {
    if (isSettingsOpen() || waitingBind) return;
    for (const g of activeGames) g.handleKeyUp(e.code);
  });
})();
</script>
</body>
</html>
