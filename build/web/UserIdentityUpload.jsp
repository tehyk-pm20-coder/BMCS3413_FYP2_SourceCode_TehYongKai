<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="model.UserIdentity"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    UserIdentity identity = (UserIdentity) request.getAttribute("userIdentity");
    List<String> validationErrors = (List<String>) request.getAttribute("validationErrors");
    String flashMessage = (String) request.getAttribute("identityMessage");
    String flashStatus = (String) request.getAttribute("identityStatus");
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Identity Verification</title>
        <link rel="stylesheet" href="Css/Header.css">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/cropperjs@1.5.13/dist/cropper.min.css">
        <style>
            body { background: #f0f4ff; font-family: 'Segoe UI', Tahoma, sans-serif; margin: 0; color: #111; }
            .Header { background: #0f1624; color: #fff; padding: 24px 28px; display: flex; justify-content: space-between; align-items: center; }
            .btn { background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.3); padding: 10px 18px; border-radius: 8px; text-decoration: none; }
            .container { margin-bottom: 10px; }
            nav ul { display: flex; gap: 16px; list-style: none; padding: 16px 24px; margin: 0; background: #fff; border-bottom: 1px solid #e2e8f0; flex-wrap: wrap; }
            nav ul li { font-weight: 600; }
            nav ul li a { color: #0f172a; text-decoration: none; padding: 6px 10px; border-radius: 6px; display: inline-block; }
            nav ul li a:hover, nav ul li.active a { background: #e0f2fe; color: #0c4a6e; }
            .page-wrapper { max-width: 1100px; margin: 30px auto 80px; padding: 0 24px; }
            .card { background: #fff; border-radius: 20px; padding: 28px 32px; box-shadow: 0 25px 55px rgba(15,23,42,0.09); border: 1px solid #dfe6fb; margin-bottom: 24px; }
            .card h2 { margin-top: 0; font-size: 26px; color: #0f172a; }
            .card p { color: #475569; line-height: 1.6; }
            .alert { padding: 16px 20px; border-radius: 14px; margin-bottom: 18px; font-weight: 600; }
            .alert-success { background: #dcfce7; color: #065f46; border: 1px solid #bbf7d0; }
            .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
            .status-pill { display: inline-flex; align-items: center; padding: 6px 14px; border-radius: 999px; font-size: 13px; font-weight: 600; letter-spacing: 0.05em; }
            .status-PENDING { background: #fef9c3; color: #854d0e; }
            .status-APPROVED { background: #dcfce7; color: #166534; }
            .status-REJECTED { background: #fee2e2; color: #991b1b; }
            .preview-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-top: 18px; }
            .preview-grid img { width: 100%; border-radius: 12px; border: 1px solid #cbd5f5; object-fit: cover; max-height: 260px; }
            .upload-form { display: grid; gap: 20px; }
            .upload-form label { font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; color: #475569; display: block; margin-bottom: 8px; }
            .upload-form input[type="file"] { width: 100%; border: 1px dashed #94a3b8; padding: 16px; border-radius: 14px; background: #f8fafc; }
            .upload-form button { padding: 14px 24px; border: none; border-radius: 12px; background: #0f62fe; color: #fff; font-weight: 600; box-shadow: 0 20px 40px rgba(15,98,254,0.35); cursor: pointer; }
            .upload-form button:hover { opacity: 0.95; }
            .note { font-size: 14px; color: #475569; margin-top: 10px; }
            .cropper-wrapper { border: 1px solid #cbd5f5; border-radius: 14px; padding: 16px; background: #f8fafc; margin-top: 12px; }
            .cropper-area { width: 100%; min-height: 320px; max-height: 400px; overflow: hidden; border-radius: 12px; display: flex; justify-content: center; align-items: center; background: #e2e8f0; }
            .cropper-area img { max-width: 100%; max-height: 380px; width: auto; display: block; }
            .crop-actions { display: flex; gap: 12px; align-items: center; margin-top: 12px; flex-wrap: wrap; }
            .crop-actions button { background: #0f172a; color: #fff; border: none; border-radius: 10px; padding: 10px 18px; cursor: pointer; box-shadow: 0 12px 30px rgba(0,0,0,0.18); }
            .crop-result { margin-top: 14px; display: flex; flex-direction: column; gap: 8px; }
            .crop-result img { max-width: 240px; border-radius: 12px; border: 1px solid #cbd5f5; display: none; }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Identity Verification</h2>
            <a class="btn" href="MainPage.jsp">Back to Dashboard</a>
        </div>

        <div class="container">
            <nav>
                <ul>
                    <li><a href="MainPage.jsp">Home</a></li>
                    <li><a href="ViewConcert.jsp">Events</a></li>
                    <li><a href="ResaleMarketplace">Marketplace</a></li>
                    <li><a href="MyTickets">My Tickets</a></li>
                    <li><a href="SupportTicket">Support</a></li>
                    <li class="active"><a href="UserIdentityUpload">Identity Check</a></li>
                    <% if (navIsAdmin) { %>
                    <li><a href="AdminUserIdentity">Admin Approvals</a></li>
                    <% } %>
                </ul>
            </nav>
        </div>

        <section class="page-wrapper">
            <% if (flashMessage != null) { %>
            <div class="alert <%= "success".equals(flashStatus) ? "alert-success" : "alert-error" %>">
                <%= flashMessage %>
            </div>
            <% } %>
            <% if (validationErrors != null && !validationErrors.isEmpty()) { %>
            <div class="alert alert-error">
                <strong>We couldn't submit your documents:</strong>
                <ul>
                    <% for (String err : validationErrors) { %>
                    <li><%= err %></li>
                    <% } %>
                </ul>
            </div>
            <% } %>

            <%
                boolean allowUpload = identity == null || !"APPROVED".equalsIgnoreCase(identity.getStatus());
            %>
            <div class="card">
                <h2>Upload Government ID & Selfie</h2>
                <p>We keep your photos encrypted on the server and use them to verify that every wallet belongs to a real person.</p>
                <% if (allowUpload) { %>
                <form class="upload-form" id="identityForm" action="UserIdentityUpload" method="post" enctype="multipart/form-data">
                    <div>
                        <label for="idPhoto">ID / Passport / IC Photo</label>
                        <input type="file" id="idPhoto" name="idPhoto" accept=".jpg,.jpeg,.png" required>
                        <p class="note">Use a clear scan/photo where the name, number, and expiry are legible.</p>
                    </div>
                    <div>
                        <label for="facePhoto">Live Face Photo (JPG or PNG)</label>
                        <input type="file" id="facePhoto" name="facePhoto" accept=".jpg,.jpeg,.png" required>
                        <div class="cropper-wrapper">
                            <div class="cropper-area">
                                <img id="facePreview" alt="Face preview">
                            </div>
                            <div class="crop-actions">
                                <button id="cropFaceBtn" type="button" disabled>Crop Face Photo</button>
                                <span class="note" id="faceCropStatus"></span>
                            </div>
                            <div class="crop-result">
                                <span class="note">Cropped preview:</span>
                                <img id="faceCroppedPreview" alt="Cropped face preview">
                            </div>
                        </div>
                        <p class="note">Take a selfie holding the same ID next to your face. JPG and PNG uploads are supported for cropping.</p>
                        <input type="hidden" id="croppedFaceData" name="croppedFaceData">
                    </div>
                    <button type="submit">Submit for Review</button>
                    <p class="note">Submitting again will replace previous files and reset the status to pending.</p>
                </form>
                <% } else { %>
                <div class="alert alert-success">
                    Your identity has already been verified. Thank you for completing the verification process.
                </div>
                <% } %>
            </div>

            <div class="card">
                <h2>Submission Status</h2>
                <% if (identity != null) { 
                       String status = identity.getStatus() != null ? identity.getStatus() : "PENDING";
                       java.sql.Timestamp updatedAt = identity.getUpdatedAt();
                       java.sql.Timestamp createdAt = identity.getCreatedAt();
                       String lastUpdated = updatedAt != null ? fmt.format(updatedAt) : (createdAt != null ? fmt.format(createdAt) : "Not available");
                       String idImagePath = identity.getIdPhotoPath();
                       String faceImagePath = identity.getFacePhotoPath();
                %>
                    <div>
                        <span class="status-pill status-<%= status %>"><%= status %></span>
                        <p class="note">Last updated: <%= lastUpdated %></p>
                    </div>
                    <div class="preview-grid">
                        <div>
                            <h4>ID / IC</h4>
                            <% if (idImagePath != null && !idImagePath.isEmpty()) { %>
                            <img src="identity_image?file=<%= idImagePath %>" alt="ID document preview">
                            <% } else { %>
                            <p>No file available.</p>
                            <% } %>
                        </div>
                        <div>
                            <h4>Face Photo</h4>
                            <% if (faceImagePath != null && !faceImagePath.isEmpty()) { %>
                            <img src="identity_image?file=<%= faceImagePath %>" alt="Face photo preview">
                            <% } else { %>
                            <p>No file available.</p>
                            <% } %>
                        </div>
                    </div>
                <% } else { %>
                    <p>No documents uploaded yet. Use the form above to start the verification process.</p>
                <% } %>
            </div>
        </section>
        <script src="https://cdn.jsdelivr.net/npm/cropperjs@1.5.13/dist/cropper.min.js"></script>
        <script>
            (function () {
                const faceInput = document.getElementById('facePhoto');
                const previewImg = document.getElementById('facePreview');
                const cropBtn = document.getElementById('cropFaceBtn');
                const croppedField = document.getElementById('croppedFaceData');
                const croppedPreview = document.getElementById('faceCroppedPreview');
                const statusText = document.getElementById('faceCropStatus');
                const form = document.getElementById('identityForm');
                if (!faceInput || !previewImg || !cropBtn || !croppedField || !croppedPreview || !statusText || !form) {
                    return;
                }
                let cropper = null;

                function resetCropper() {
                    if (cropper) {
                        cropper.destroy();
                        cropper = null;
                    }
                    previewImg.style.display = 'none';
                    previewImg.src = '';
                    cropBtn.disabled = true;
                    statusText.textContent = '';
                }

                faceInput.addEventListener('change', function () {
                    croppedField.value = '';
                    croppedPreview.style.display = 'none';
                    statusText.textContent = '';
                    const file = this.files && this.files[0] ? this.files[0] : null;
                    if (!file) {
                        resetCropper();
                        return;
                    }
                    const reader = new FileReader();
                    reader.onload = function (e) {
                        previewImg.onload = function () {
                            if (cropper) {
                                cropper.destroy();
                            }
                            cropper = new Cropper(previewImg, {
                                aspectRatio: 1,
                                viewMode: 1,
                                autoCropArea: 0.85,
                                responsive: true,
                                background: false,
                                movable: true,
                                zoomable: true,
                                scalable: false
                            });
                            cropBtn.disabled = false;
                        };
                        previewImg.src = e.target.result;
                        previewImg.style.display = 'block';
                    };
                    reader.readAsDataURL(file);
                });

                cropBtn.addEventListener('click', function (event) {
                    event.preventDefault();
                    if (!cropper) {
                        statusText.textContent = 'Select a face photo first.';
                        return;
                    }
                    const canvas = cropper.getCroppedCanvas({width: 600, height: 600});
                    const dataUrl = canvas.toDataURL('image/jpeg', 0.9);
                    croppedField.value = dataUrl;
                    croppedPreview.src = dataUrl;
                    croppedPreview.style.display = 'block';
                    statusText.textContent = 'Crop saved. You can submit whenever you are ready.';
                });

                form.addEventListener('submit', function () {
                    if (cropper && !croppedField.value) {
                        const canvas = cropper.getCroppedCanvas({width: 600, height: 600});
                        croppedField.value = canvas.toDataURL('image/jpeg', 0.9);
                    }
                });
            })();
        </script>
    </body>
</html>
