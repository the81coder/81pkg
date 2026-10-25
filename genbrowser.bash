#!/bin/bash

OUTPUT=index.html
PACKAGES_FILE=dists/81main/main/binary-amd64/Packages
REPO_BASE="https://the81coder.github.io/81pkg"

cat > $OUTPUT <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>81manorg APT Repository</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 900px; margin: 2rem auto; padding: 1rem; background: #f9f9f9; color: #222; }
    h1 { color: #2c3e50; }
    .pkg-list { list-style: none; padding-left: 0; }
    .pkg-item { margin: 0.4rem 0; border-bottom: 1px solid #eee; padding: 0.4rem 0; }
    .pkg-name { font-weight: bold; color: #2c3e50; }
    .pkg-ver { color: #666; font-size: 0.9rem; }
    .toggle { cursor: pointer; user-select: none; display: inline-block; width: 1.2rem; text-align: center; color: #1e90ff; font-weight: bold; margin-right: 0.3rem; }
    .toggle:hover { color: #0056b3; }
    .details { display: none; margin: 0.5rem 0 0.5rem 1.5rem; padding: 0.5rem; background: #fff; border: 1px solid #ddd; border-radius: 4px; font-size: 0.9rem; }
    .details.open { display: block; }
    .details pre { margin: 0; white-space: pre-wrap; word-break: break-word; }
    .dl-btn { cursor: pointer; display: inline-block; margin-left: 0.8rem; padding: 0.15rem 0.6rem; background: #28a745; color: #fff; border: none; border-radius: 4px; font-size: 0.85rem; font-weight: bold; }
    .dl-btn:hover { background: #218838; }
    .dl-btn:disabled { background: #aaa; cursor: not-allowed; }
    code, pre { background: #eee; padding: 0.2rem 0.4rem; border-radius: 4px; font-size: 0.95rem; }
    hr { margin: 2rem 0; }
    .modal-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.6); z-index: 1000; justify-content: center; align-items: center; }
    .modal-overlay.show { display: flex; }
    .modal { background: #fff; border-radius: 8px; padding: 1.5rem; width: 90%; max-width: 500px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); }
    .modal h3 { margin-top: 0; color: #2c3e50; }
    .modal .info { font-size: 0.9rem; margin-bottom: 0.8rem; }
    .modal .info span { font-weight: bold; }
    .progress-bar { width: 100%; height: 24px; background: #eee; border-radius: 12px; overflow: hidden; margin: 0.8rem 0; }
    .progress-fill { height: 100%; background: linear-gradient(90deg, #28a745, #20c997); width: 0%; transition: width 0.2s; border-radius: 12px; }
    .stats { display: flex; justify-content: space-between; font-size: 0.85rem; color: #555; }
    .status-text { font-size: 0.9rem; color: #333; margin-top: 0.5rem; }
    .close-btn { margin-top: 1rem; padding: 0.4rem 1rem; background: #dc3545; color: #fff; border: none; border-radius: 4px; cursor: pointer; }
    .close-btn:hover { background: #c82333; }
  </style>
</head>
<body>
  <h1>81manorg APT Repository</h1>
  <p>This is the public package index for the <strong>81pkg</strong> APT repo.</p>
  <h2>Available Packages</h2>
  <ul class="pkg-list">
HTMLEOF

python3 - "$PACKAGES_FILE" "$OUTPUT" "$REPO_BASE" <<'PYEOF'
import sys, json, html

packages_file = sys.argv[1]
output_file = sys.argv[2]
repo_base = sys.argv[3]

packages = []
current = {}
with open(packages_file) as f:
    for line in f:
        line = line.rstrip('\n')
        if line == '':
            if current:
                packages.append(current)
                current = {}
        elif line.startswith(' ') or line.startswith('\t'):
            if current:
                last_key = list(current.keys())[-1]
                current[last_key] += '\n' + line
        else:
            if ': ' in line:
                key, val = line.split(': ', 1)
                current[key] = val
    if current:
        packages.append(current)

packages.sort(key=lambda p: p.get('Package', ''))

EXCLUDE = {'SHA256', 'MD5sum', 'SHA1'}

js_data = {}
html_items = []

for pkg in packages:
    name = pkg.get('Package', '')
    version = pkg.get('Version', '')
    desc = pkg.get('Description', '')
    filename = pkg.get('Filename', '')

    details_lines = []
    for key, val in pkg.items():
        if key not in EXCLUDE:
            details_lines.append(f"{key}: {val}")
    details_text = '\n'.join(details_lines)

    js_data[name] = {
        'version': version,
        'desc': desc,
        'filename': filename,
        'details': details_text
    }

    safe_name = html.escape(name)
    safe_version = html.escape(version)
    html_items.append(
        f'    <li class="pkg-item"><span class="toggle" onclick="toggle(this)">^</span>'
        f'<span class="pkg-name">{safe_name}</span> <span class="pkg-ver">{safe_version}</span> '
        f'<button class="dl-btn" onclick="downloadPkg(\'{name}\')">Download</button>'
        f'<div class="details"><pre>{html.escape(details_text)}</pre></div></li>'
    )

with open(output_file, 'a') as f:
    f.write('\n'.join(html_items) + '\n')

js_json = json.dumps(js_data, ensure_ascii=False)
with open(output_file, 'a') as f:
    f.write(f"  </ul>\n\n")
    # Modal dialog
    f.write("""  <div class="modal-overlay" id="dlModal">
    <div class="modal">
      <h3 id="modalTitle">Downloading...</h3>
      <div class="info" id="modalInfo"></div>
      <div class="progress-bar"><div class="progress-fill" id="progressFill"></div></div>
      <div class="stats">
        <span id="pctText">0%</span>
        <span id="speedText">-- KB/s</span>
        <span id="etaText">ETA: --</span>
      </div>
      <div class="status-text" id="statusText">Preparing download...</div>
      <button class="close-btn" id="closeBtn" onclick="closeModal()" style="display:none;">Close</button>
    </div>
  </div>

  <hr />
  <h3>APT Repo Info</h3>
  <pre>deb [trusted=yes] https://the81coder.github.io/81pkg 81main main</pre>
  <p> NOTICE: Everything here is a Git LFS pointer. </p>

""")
    f.write(f"  <script>\n    const REPO_BASE = '{repo_base}';\n    const PKG_DATA = {js_json};\n")
    f.write("""    function toggle(el) {
      var details = el.parentElement.querySelector('.details');
      details.classList.toggle('open');
      el.textContent = details.classList.contains('open') ? 'v' : '^';
    }

    async function downloadPkg(pkgName) {
      var info = PKG_DATA[pkgName];
      if (!info || !info.filename) { alert('No filename available for ' + pkgName); return; }
      var filename = info.filename;
      var version = info.version;
      var desc = info.desc;

      var btn = event.target;
      btn.disabled = true;

      var modal = document.getElementById('dlModal');
      var title = document.getElementById('modalTitle');
      var infoEl = document.getElementById('modalInfo');
      var fill = document.getElementById('progressFill');
      var pct = document.getElementById('pctText');
      var speed = document.getElementById('speedText');
      var eta = document.getElementById('etaText');
      var status = document.getElementById('statusText');
      var closeBtn = document.getElementById('closeBtn');

      title.textContent = 'Downloading ' + pkgName;
      infoEl.innerHTML = '<span>Package:</span> ' + escHtml(pkgName) + '<br><span>Version:</span> ' + escHtml(version) + '<br><span>Description:</span> ' + escHtml(desc) + '<br><span>File:</span> ' + escHtml(filename);
      fill.style.width = '0%';
      pct.textContent = '0%';
      speed.textContent = '-- KB/s';
      eta.textContent = 'ETA: --';
      status.textContent = 'Starting download...';
      closeBtn.style.display = 'none';
      modal.classList.add('show');

      var url = REPO_BASE + '/' + filename;

      try {
        status.textContent = 'Fetching file...';
        var resp = await fetch(url);
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        var buffer = await resp.arrayBuffer();
        var text = new TextDecoder().decode(buffer);

        var firstLine = text.split('\\n')[0].trim();
        var isLfs = (firstLine === 'version https://git-lfs.github.com/spec/v1' ||
                     firstLine === 'version https://git-lfs.github.com/spec/v2');

        if (isLfs) {
          var lines = text.split('\\n');
          var lfsOid = null, lfsSize = null;
          for (var i = 0; i < lines.length; i++) {
            var m = lines[i].match(/^oid sha256:([a-f0-9]+)$/);
            if (m) lfsOid = m[1];
            m = lines[i].match(/^size (\\d+)$/);
            if (m) lfsSize = parseInt(m[1]);
          }
          if (!lfsOid || !lfsSize) throw new Error('Malformed LFS pointer');

          status.textContent = 'Resolving LFS object...';
          var owner = 'the81coder';
          var repo = '81pkg';
          var apiUrl = 'https://github.com/' + owner + '/' + repo + '.git/info/lfs/objects/batch';
          var body = JSON.stringify({
            operation: 'download',
            transfers: ['basic'],
            objects: [{ oid: lfsOid, size: lfsSize }]
          });
          var apiResp = await fetch(apiUrl, {
            method: 'POST',
            headers: {
              'Accept': 'application/vnd.git-lfs+json',
              'Content-Type': 'application/vnd.git-lfs+json'
            },
            body: body
          });
          if (!apiResp.ok) throw new Error('LFS batch request failed');
          var apiData = await apiResp.json();
          if (!apiData.objects || !apiData.objects[0] || !apiData.objects[0].actions || !apiData.objects[0].actions.download) {
            throw new Error('No LFS download URL received');
          }
          var downloadHref = apiData.objects[0].actions.download.href;

          status.textContent = 'Downloading LFS object...';
          await downloadWithProgress(downloadHref, lfsSize, filename, fill, pct, speed, eta, status);
        } else {
          status.textContent = 'Saving file...';
          var blob = new Blob([buffer]);
          var blobUrl = URL.createObjectURL(blob);
          var a = document.createElement('a');
          a.href = blobUrl;
          a.download = filename;
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(blobUrl);
          fill.style.width = '100%';
          pct.textContent = '100%';
          status.textContent = 'Download complete!';
        }

        closeBtn.style.display = 'inline-block';
      } catch (err) {
        status.textContent = 'Error: ' + err.message;
        closeBtn.style.display = 'inline-block';
      } finally {
        btn.disabled = false;
      }
    }

    async function downloadWithProgress(url, totalSize, filename, fill, pct, speed, eta, status) {
      var resp = await fetch(url);
      if (!resp.ok) throw new Error('Download failed: HTTP ' + resp.status);

      var reader = resp.body.getReader();
      var received = 0;
      var chunks = [];
      var startTime = Date.now();

      while (true) {
        var result = await reader.read();
        if (result.done) break;
        chunks.push(result.value);
        received += result.value.length;

        var percent = totalSize > 0 ? Math.round((received / totalSize) * 100) : 0;
        fill.style.width = percent + '%';
        pct.textContent = percent + '%';

        var elapsed = (Date.now() - startTime) / 1000;
        if (elapsed > 0) {
          var speedBps = received / elapsed;
          var speedStr = speedBps > 1048576
            ? (speedBps / 1048576).toFixed(1) + ' MB/s'
            : (speedBps / 1024).toFixed(1) + ' KB/s';
          speed.textContent = speedStr;

          if (received > 0 && totalSize > 0) {
            var remaining = (totalSize - received) / speedBps;
            var etaStr = remaining > 60
              ? Math.round(remaining / 60) + 'm ' + Math.round(remaining % 60) + 's'
              : Math.round(remaining) + 's';
            eta.textContent = 'ETA: ' + etaStr;
          }
        }
        status.textContent = 'Downloading... ' + formatBytes(received) + ' / ' + formatBytes(totalSize);
      }

      var blob = new Blob(chunks);
      var blobUrl = URL.createObjectURL(blob);
      var a = document.createElement('a');
      a.href = blobUrl;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(blobUrl);
    }

    function formatBytes(bytes) {
      if (bytes === 0) return '0 B';
      var k = 1024;
      var sizes = ['B', 'KB', 'MB', 'GB'];
      var i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
    }

    function escHtml(s) {
      return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    function closeModal() {
      document.getElementById('dlModal').classList.remove('show');
    }
  </script>
</body>
</html>
""")
PYEOF

echo "[✔] Index.html generated!"