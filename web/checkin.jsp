<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Ticket Check-In Scanner</title>

    <script src="https://unpkg.com/html5-qrcode"></script>

    <style>
        body {
            font-family: "Segoe UI", Arial, sans-serif;
            background: radial-gradient(circle at 20% 20%, #e0f2ff, #f8fafc 45%);
            padding: 40px 20px 60px;
            text-align: center;
            color: #0f172a;
        }
        .shell {
            max-width: 980px;
            margin: 0 auto;
        }
        .hero {
            background: #0f172a;
            color: #fff;
            padding: 18px 22px;
            border-radius: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 16px 40px rgba(15, 23, 42, 0.25);
        }
        .hero h1 { margin: 0; font-size: 24px; text-align: left;}
        .hero p { margin: 4px 0 0; color: #cbd5f5; font-size: 14px; }
        .hero .actions { display: flex; gap: 10px; }
        .hero .actions a button {
            background: #1d4ed8;
            color: #fff;
            border: none;
            border-radius: 10px;
            padding: 10px 14px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 10px 25px rgba(37,99,235,0.3);
        }
        .hero .actions a button:hover { background: #1e40af; }

        .card {
            margin-top: 20px;
            background: #fff;
            border-radius: 18px;
            padding: 24px 28px;
            box-shadow: 0 20px 48px rgba(15, 23, 42, 0.15);
            border: 1px solid #e2e8f0;
        }

        #reader {
            width: 360px;
            margin: 0 auto;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.12);
        }

        .result-box {
            margin-top: 20px;
            padding: 15px;
            border-radius: 12px;
            display: none;
            text-align: left;
            font-size: 15px;
            line-height: 1.5;
        }

        .success {
            background: #dcfce7;
            border: 1px solid #bbf7d0;
            color: #166534;
        }

        .error {
            background: #fee2e2;
            border: 1px solid #fecaca;
            color: #b91c1c;
        }
        .face-cta {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: #fff;
            border: none;
            padding: 10px 16px;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 700;
            box-shadow: 0 12px 28px rgba(34, 197, 94, 0.32);
            transition: transform 120ms ease, box-shadow 120ms ease, background 140ms ease;
        }
        .face-cta:hover {
            background: linear-gradient(135deg, #16a34a, #15803d);
            box-shadow: 0 16px 32px rgba(21, 128, 61, 0.35);
            transform: translateY(-1px);
        }
    </style>
</head>

<body>
    <div class="shell">
        <div class="hero">
            <div>
                <h1>Ticket Check-In</h1>
                <p>Point the user's QR code at the camera to verify entry.</p>
            </div>
            <div class="actions">
                <a href="MainPage.jsp"><button>Back to Main</button></a>
                <a href="checkin.jsp"><button>Refresh</button></a>
            </div>
        </div>

        <div class="card">
            <!-- Camera Scanner -->
            <div id="reader"></div>

            <!-- Result Display Box -->
            <div id="resultBox" class="result-box"></div>
        </div>
    </div>

    <script>
        function onScanSuccess(qrText) {
            // Stop scanning after detecting 1 QR
            scanner.clear();

            const box = document.getElementById("resultBox");
            box.style.display = "block";
            box.className = "result-box";
            box.innerHTML = "QR detected. Verifying ticket...";

            const formData = new URLSearchParams();
            formData.append("qrPayload", qrText);

            fetch("CheckinVerify", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: formData.toString()
            })
                .then(res => res.json())
                .then(data => {
                    if (data.status === "SUCCESS") {
                        const walletAddress = data.wallet_address || "";
                        const faceUrl = "Facecheckin.jsp?wallet_address=" + encodeURIComponent(walletAddress) +
                            "&ticket_id=" + encodeURIComponent(data.ticket_id || "");

                        box.classList.add("success");
                        box.innerHTML =
                            "<h3>Ticket Valid</h3>" +
                            "Ticket ID: " + data.ticket_id + "<br>" +
                            "Event ID: " + data.event_id + "<br>" +
                            "Seat: " + data.seat_type + "<br>" +
                            "Status: " + data.status_value + "<br>" +
                            "Wallet: " + data.wallet_address + "<br>" +
                            "State Hash: " + data.ticket_state_hash + "<br><br>" +
                            "Entry allowed. Will Proceed to Face Comparison (Facial scan)." +
                            (walletAddress ? "<div style='margin-top:14px;'><button class='face-cta' onclick=\"window.location.href='" + faceUrl + "'\">Proceed to Face Verification</button></div>" : "");
                    } else {
                        box.classList.add("error");
                        box.innerHTML =
                            "<h3>Invalid Ticket</h3>" +
                            "Reason: " + data.message + "<br><br>" +
                            "Entry rejected.";
                    }
                })
                .catch(err => {
                    box.classList.add("error");
                    box.innerHTML =
                        "<h3>Error</h3>" +
                        "Could not verify QR: " + err;
                });
        }

        // Initialize QR scanner
        let scanner = new Html5QrcodeScanner(
            "reader",
            { fps: 30, qrbox: 250, supportedScanTypes: [Html5QrcodeScanType.SCAN_TYPE_CAMERA] }
        );

        scanner.render(onScanSuccess);
    </script>

</body>
</html>
