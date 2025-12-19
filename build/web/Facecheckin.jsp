<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String walletAddress = request.getParameter("wallet_address");
    if (walletAddress == null) {
        walletAddress = "";
    }
    String ticketIdRaw = request.getParameter("ticket_id");
    String ticketId = "";
    if (ticketIdRaw != null && ticketIdRaw.matches("\\d+")) {
        ticketId = ticketIdRaw;
    }
    String safeWallet = walletAddress
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Face Verification Check-In</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #0f172a;
            --card: #0b1222;
            --accent: #4f46e5;
            --accent-2: #06b6d4;
            --muted: #cbd5e1;
            --stroke: rgba(255,255,255,0.08);
            --surface: rgba(255,255,255,0.05);
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Space Grotesk", "Segoe UI", sans-serif;
            background: radial-gradient(circle at 20% 20%, rgba(79,70,229,0.20), rgba(6,182,212,0.08) 30%, #020617 60%);
            color: #e2e8f0;
            min-height: 100vh;
            padding: 32px 18px 42px;
        }
        .shell {
            max-width: 1180px;
            margin: 0 auto;
        }
        .hero {
            background: linear-gradient(135deg, rgba(255,255,255,0.9), rgba(219,234,254,0.94));
            border: 1px solid var(--stroke);
            border-radius: 18px;
            padding: 18px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 20px 60px rgba(0,0,0,0.35);
            color: #0f172a;
        }
        .hero h1 { margin: 0 0 4px; font-size: 24px; letter-spacing: -0.02em; }
        .hero p { margin: 0; color: #1f2937; font-size: 14px; font-weight: 600; }
        .hero .actions { display: flex; gap: 10px; }
        .hero-title .primary { color: #0f172a; }
        .hero-title .accent { color: #1d4ed8; }
        .hero-subtitle .callout { color: #0f172a; }
        .hero-subtitle .accent { color: #0ea5e9; }
        .hero .actions .button {
            background: linear-gradient(135deg, #0ea5e9, #6366f1);
            color: #fff;
            border: none;
            box-shadow: 0 10px 30px rgba(14,165,233,0.35);
        }
        .hero .actions .button.ghost {
            background: linear-gradient(135deg, #6366f1, #0ea5e9);
            color: #fff;
            border: none;
        }
        .button {
            border: 1px solid var(--stroke);
            background: var(--surface);
            color: #fff;
            border-radius: 12px;
            padding: 10px 14px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 10px 25px rgba(0,0,0,0.25);
            transition: transform 120ms ease, box-shadow 120ms ease, background 120ms ease;
        }
        .button:hover { transform: translateY(-1px); box-shadow: 0 16px 35px rgba(0,0,0,0.3); background: rgba(255,255,255,0.07); }
        .button.primary { background: linear-gradient(135deg, #4f46e5, #06b6d4); border: none; }
        .button.ghost { background: transparent; }
        .button:disabled {
            opacity: 0.55;
            cursor: not-allowed;
            box-shadow: none;
            transform: none;
        }
        .content-grid {
            margin-top: 18px;
            display: grid;
            grid-template-columns: 1.05fr 1fr;
            gap: 16px;
        }
        .panel {
            background: var(--card);
            border: 1px solid var(--stroke);
            border-radius: 18px;
            padding: 22px;
            box-shadow: 0 18px 50px rgba(0,0,0,0.32);
            position: relative;
            overflow: hidden;
        }
        .panel::after {
            content: "";
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at 80% 0%, rgba(79,70,229,0.18), transparent 32%),
                        radial-gradient(circle at 10% 90%, rgba(6,182,212,0.12), transparent 28%);
            pointer-events: none;
        }
        .panel h2 { margin: 0 0 8px; letter-spacing: -0.01em; }
        .eyebrow {
            letter-spacing: 0.18em;
            text-transform: uppercase;
            font-size: 12px;
            color: var(--muted);
            margin: 0 0 10px;
        }
        .wallet-box {
            background: rgba(255,255,255,0.03);
            border: 1px dashed var(--stroke);
            border-radius: 14px;
            padding: 14px 16px;
            margin-bottom: 12px;
        }
        .wallet-label { color: var(--muted); font-size: 13px; margin-bottom: 6px; display: block; }
        .wallet-value { font-family: "Space Grotesk", monospace; font-size: 15px; line-height: 1.5; word-break: break-all; }
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(79,70,229,0.22);
            border: 1px solid rgba(79,70,229,0.35);
            color: #c7d2fe;
            font-size: 12px;
            padding: 4px 8px;
            border-radius: 999px;
            margin-top: 8px;
        }
        .steps {
            margin-top: 18px;
            display: grid;
            gap: 10px;
        }
        .step {
            background: rgba(255,255,255,0.02);
            border: 1px solid var(--stroke);
            border-radius: 12px;
            padding: 10px 12px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .step-number {
            width: 26px;
            height: 26px;
            border-radius: 8px;
            background: rgba(79,70,229,0.25);
            border: 1px solid rgba(79,70,229,0.35);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: #cbd5ff;
        }
        .panel p { margin: 0; color: var(--muted); }
        .capture {
            background: linear-gradient(160deg, rgba(11,18,34,0.92), rgba(11,18,34,0.78));
        }
        .capture-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .status-chip {
            padding: 6px 10px;
            border-radius: 10px;
            font-size: 12px;
            border: 1px solid var(--stroke);
        }
        .status-pending { background: rgba(255,255,255,0.06); color: var(--muted); }
        .status-active { background: rgba(6,182,212,0.15); color: #a5f3fc; border-color: rgba(6,182,212,0.45); }
        .status-done { background: rgba(74,222,128,0.12); color: #bbf7d0; border-color: rgba(74,222,128,0.4); }
        .status-fail { background: rgba(248,113,113,0.12); color: #fecdd3; border-color: rgba(248,113,113,0.4); }
        .capture-box {
            height: 320px;
            border-radius: 16px;
            border: 1px solid var(--stroke);
            background: radial-gradient(circle at 20% 20%, rgba(6,182,212,0.25), transparent 38%),
                        radial-gradient(circle at 70% 60%, rgba(79,70,229,0.22), transparent 34%),
                        linear-gradient(145deg, rgba(15,23,42,0.9), rgba(15,23,42,0.75));
            display: grid;
            place-items: center;
            color: #cbd5e1;
            position: relative;
            overflow: hidden;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.02);
        }
        .capture-box video {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 16px;
        }
        .capture-box canvas { display: none; }
        .capture-box::before, .capture-box::after {
            content: "";
            position: absolute;
            width: 180px;
            height: 180px;
            background: radial-gradient(circle, rgba(79,70,229,0.25), transparent 60%);
            filter: blur(14px);
        }
        .capture-box::before { top: -40px; left: -30px; }
        .capture-box::after { bottom: -46px; right: -26px; background: radial-gradient(circle, rgba(6,182,212,0.24), transparent 60%); }
        .capture-overlay {
            position: absolute;
            inset: 18px;
            border: 1px dashed rgba(255,255,255,0.18);
            border-radius: 14px;
        }
        .capture-text { position: relative; z-index: 1; text-align: center; max-width: 340px; }
        .capture-text h3 { margin: 0 0 6px; letter-spacing: -0.01em; }
        .capture-text p { margin: 0; color: var(--muted); font-size: 14px; }
        .actions {
            margin-top: 14px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .result-card {
            margin-top: 14px;
            padding: 12px 14px;
            border-radius: 12px;
            border: 1px solid var(--stroke);
            background: rgba(255,255,255,0.04);
        }
        .result-card h4 { margin: 0 0 4px; }
        .hint { color: var(--muted); font-size: 13px; margin: 6px 0 0; }
        .result-row { display: flex; align-items: center; gap: 8px; margin-top: 6px; }
        .chip {
            display: inline-flex;
            align-items: center;
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid var(--stroke);
            font-weight: 600;
            font-size: 13px;
        }
        .chip.pass {
            background: rgba(74,222,128,0.12);
            color: #bbf7d0;
            border-color: rgba(74,222,128,0.35);
        }
        .chip.fail {
            background: rgba(248,113,113,0.14);
            color: #fecdd3;
            border-color: rgba(248,113,113,0.35);
        }
        .score {
            font-weight: 700;
            color: #e2e8f0;
        }
        .compare-panel {
            margin-top: 14px;
            padding: 12px 14px;
            border-radius: 14px;
            border: 1px dashed var(--stroke);
            background: rgba(255,255,255,0.03);
            display: none;
        }
        .compare-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px;
            margin-top: 10px;
        }
        .compare-item {
            background: rgba(255,255,255,0.04);
            border: 1px solid var(--stroke);
            border-radius: 12px;
            padding: 8px;
        }
        .compare-item h5 {
            margin: 0 0 6px;
            font-size: 13px;
            letter-spacing: 0;
            color: #cbd5e1;
        }
        .compare-item img {
            width: 100%;
            border-radius: 10px;
            object-fit: cover;
            min-height: 150px;
            background: rgba(255,255,255,0.02);
        }
        @media (max-width: 900px) {
            .content-grid { grid-template-columns: 1fr; }
            .capture-box { height: 260px; }
        }
    </style>
</head>
<body>
    <div class="shell">
        <div class="hero">
            <div>
                <h1 class="hero-title"><span class="primary">Face</span> <span class="accent">Verification</span></h1>
                <p class="hero-subtitle"><span class="callout">Match the guest's face</span> to their ticket wallet before entry.</p>
            </div>
            <div class="actions">
                <a href="checkin.jsp"> <button class="button ghost">Back to QR Scan</button></a>
                <a href="MainPage.jsp"> <button class="button">Return to Main</button></a>
            </div>
        </div>

        <div class="content-grid">
            <div class="panel">
                <p class="eyebrow">Ticket Holder</p>
                <h2>Wallet Context</h2>
                <div class="wallet-box">
                    <span class="wallet-label">Wallet Address</span>
                    <div class="wallet-value"><%= safeWallet.isEmpty() ? "No wallet provided" : safeWallet %></div>
                    <div class="badge">Bound to QR check-in</div>
                </div>
                <p class="hint">DeepFace will compare the live capture to the identity linked to this wallet.</p>
                <div class="steps">
                    <div class="step">
                        <span class="step-number">1</span>
                        <div>
                            <strong>Prepare the guest</strong><br>
                            Face the camera straight on with even lighting. Remove hats or glasses when possible.
                        </div>
                    </div>
                    <div class="step">
                        <span class="step-number">2</span>
                        <div>
                            <strong>Start verification</strong><br>
                            Capture a clear frame; we'll compare it to the registered identity using DeepFace.
                        </div>
                    </div>
                    <div class="step">
                        <span class="step-number">3</span>
                        <div>
                            <strong>Review decision</strong><br>
                            If the identity matches, approve the users to check in with this ticket.
                        </div>
                    </div>
                </div>
            </div>

            <div class="panel capture">
                <div class="capture-header">
                    <div>
                        <p class="eyebrow" style="margin-bottom:2px;">Live Capture</p>
                        <h2>Facial Scan</h2>
                    </div>
                    <div id="statusChip" class="status-chip status-pending">Waiting to start</div>
                </div>
                <div class="capture-box" id="captureBox">
                    <video id="liveVideo" autoplay playsinline muted></video>
                    <canvas id="snapshotCanvas"></canvas>
                    <div class="capture-overlay"></div>
                    <div class="capture-text">
                        <h3 id="captureTitle">Camera Ready</h3>
                        <p id="captureSubtext">Start the camera, then capture a frame to verify against DeepFace.</p>
                    </div>
                </div>
                <div class="actions">
                    <a href="checkin.jsp" class="button ghost">Scan another QR</a>
                    <button id="startBtn" class="button primary">Capture & Verify</button>
                    <button id="comparisonBtn" class="button" disabled>View Comparison</button>
                </div>
                <div class="result-card">
                    <h4>Status</h4>
                    <div id="verificationStatus">Waiting to start.</div>
                    <div class="result-row">
                        <span id="decisionChip" class="chip status-pending">Pending</span>
                        <span id="similarityText" class="score"></span>
                        <span id="distanceText" class="score"></span>
                    </div>
                    <p class="hint" id="statusHint">Start the camera to capture and verify the guest.</p>
                </div>
                <div id="comparisonPanel" class="compare-panel">
                    <div class="result-row">
                        <h4 style="margin:0;">Photo Comparison</h4>
                        <span class="hint">Registered Photo & Live Photo(Captured Frame)</span>
                    </div>
                    <div class="compare-grid">
                        <div class="compare-item">
                            <h5>Registered Photo</h5>
                            <img id="registeredImg" alt="Registered face reference">
                        </div>
                        <div class="compare-item">
                            <h5>Live Photo(Captured Frame)</h5>
                            <img id="capturedImg" alt="Captured face frame">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const walletAddress = "<%= safeWallet %>";
        const ticketId = "<%= ticketId %>";
        const statusChip = document.getElementById("statusChip");
        const statusText = document.getElementById("verificationStatus");
        const statusHint = document.getElementById("statusHint");
        const startBtn = document.getElementById("startBtn");
        const comparisonBtn = document.getElementById("comparisonBtn");
        const comparisonPanel = document.getElementById("comparisonPanel");
        const registeredImg = document.getElementById("registeredImg");
        const capturedImg = document.getElementById("capturedImg");
        const captureBox = document.getElementById("captureBox");
        const video = document.getElementById("liveVideo");
        const canvas = document.getElementById("snapshotCanvas");
        const captureTitle = document.getElementById("captureTitle");
        const captureSubtext = document.getElementById("captureSubtext");
        const decisionChip = document.getElementById("decisionChip");
        const similarityText = document.getElementById("similarityText");
        const distanceText = document.getElementById("distanceText");
        let mediaStream = null;
        let lastCaptureDataUrl = "";

        async function ensureCamera() {
            if (mediaStream) {
                return;
            }
            statusChip.textContent = "Requesting camera...";
            statusChip.className = "status-chip status-active";
            try {
                mediaStream = await navigator.mediaDevices.getUserMedia({ video: true });
                video.srcObject = mediaStream;
                await video.play();
                statusChip.textContent = "Camera ready";
                captureTitle.textContent = "Live Preview";
                captureSubtext.textContent = "Align the guest and click Capture & Verify.";
            } catch (err) {
                statusChip.textContent = "Camera error";
                statusChip.className = "status-chip status-done";
                statusText.textContent = "Unable to access camera: " + err.message;
                statusHint.textContent = "Please allow camera permissions and try again.";
                throw err;
            }
        }

        function dataUrlToBase64(dataUrl) {
            if (!dataUrl) return "";
            const parts = dataUrl.split(",");
            return parts.length === 2 ? parts[1] : dataUrl;
        }

        async function captureAndVerify() {
            try {
                await ensureCamera();
            } catch (_) {
                return;
            }

            statusChip.textContent = "Capturing...";
            statusChip.className = "status-chip status-active";
            statusText.textContent = "Capturing frame...";
            statusHint.textContent = "Hold steady while we capture the image.";

            const width = video.videoWidth || 640;
            const height = video.videoHeight || 480;
            canvas.width = width;
            canvas.height = height;
            const ctx = canvas.getContext("2d");
            ctx.drawImage(video, 0, 0, width, height);
            const dataUrl = canvas.toDataURL("image/jpeg", 0.9);
            lastCaptureDataUrl = dataUrl;
            const base64Image = dataUrlToBase64(dataUrl);

            statusChip.textContent = "Sending for verification...";
            statusText.textContent = "Submitting image to DeepFace service...";
            statusHint.textContent = "Awaiting response from FaceVerification servlet.";

            const body = new URLSearchParams();
            body.append("imageData", base64Image);
            body.append("wallet_address", walletAddress);
            if (ticketId) {
                body.append("ticket_id", ticketId);
            }

            fetch("FaceVerification", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: body.toString()
            })
                .then(res => res.json())
                .then(data => {
                    const distance = typeof data.distance === "number" ? data.distance : null;
                    const similarity = typeof data.similarity === "number" ? data.similarity : null;
                    const referenceFile = data.reference_file || null;
                    updateDecision(data.status, distance, similarity, data.message || "", referenceFile);
                })
                .catch(err => {
                    updateDecision("FAIL", null, null, "Verification error: " + err, null);
                });
        }

        function updateDecision(status, distance, similarity, message, referenceFile) {
            const isPass = status === "PASS";
            statusChip.textContent = isPass ? "Verified" : "Verification failed";
            statusChip.className = isPass ? "status-chip status-done" : "status-chip status-fail";
            decisionChip.textContent = isPass ? "PASS" : "FAIL";
            decisionChip.className = "chip " + (isPass ? "pass" : "fail");
            statusText.textContent = message || (isPass ? "Face match successful." : "Face match not verified.");
            statusHint.textContent = walletAddress
                ? "Wallet: " + walletAddress
                : "No wallet was provided from QR scan.";

            if (distance !== null) {
                distanceText.textContent = "Distance: " + distance.toFixed(3);
            } else {
                distanceText.textContent = "";
            }

            if (similarity !== null) {
                const pct = Math.round(similarity * 100);
                similarityText.textContent = "Similarity: " + pct + "%";
            } else {
                similarityText.textContent = "";
            }

            captureTitle.textContent = isPass ? "Match confirmed" : "Try again";
            captureSubtext.textContent = isPass
                ? "Guest is cleared to check in."
                : "Reposition the guest and retry the capture.";

            if (isPass) {
                startBtn.disabled = true;
                startBtn.textContent = "Verification completed";
                if (referenceFile && lastCaptureDataUrl) {
                    const registeredSrc = "identity_image?file=" + encodeURIComponent(referenceFile);
                    registeredImg.src = registeredSrc;
                    capturedImg.src = lastCaptureDataUrl;
                    comparisonBtn.disabled = false;
                }
                statusText.textContent = "Verification Successful, Please enter the concert/event.";
            } else {
                comparisonBtn.disabled = true;
                comparisonPanel.style.display = "none";
            }
        }

        startBtn.addEventListener("click", captureAndVerify);
        comparisonBtn.addEventListener("click", () => {
            if (comparisonBtn.disabled) return;
            comparisonPanel.style.display = comparisonPanel.style.display === "none" ? "block" : "none";
        });
    </script>
</body>
</html>
