from flask import Flask, request, jsonify
from deepface import DeepFace
import base64
import tempfile
import os

app = Flask(__name__)

@app.route("/verify", methods=["POST"])
def verify():
    try:
        data = request.get_json()

        wallet = data.get("wallet_address")
        live_b64 = data.get("image_base64")
        reference_b64 = data.get("reference_base64")
        reference_name = data.get("reference_filename")

        # Validate inputs
        if not live_b64 or not reference_b64:
            return jsonify({
                "verified": False,
                "distance": None,
                "error": "Both live and reference images are required."
            }), 400

        # Decode Base64 → bytes
        live_bytes = base64.b64decode(live_b64)
        ref_bytes = base64.b64decode(reference_b64)

        # Save both images as temp files
        fd1, path_live = tempfile.mkstemp(suffix=".jpg")
        fd2, path_ref = tempfile.mkstemp(
            suffix=f"_{reference_name}" if reference_name else ".jpg"
        )

        with os.fdopen(fd1, "wb") as f:
            f.write(live_bytes)
        with os.fdopen(fd2, "wb") as f:
            f.write(ref_bytes)

        # DeepFace comparison
        result = DeepFace.verify(
            img1_path=path_live,
            img2_path=path_ref,
            model_name="Facenet"
        )

        verified = result.get("verified")
        distance = result.get("distance")

        return jsonify({
            "verified": bool(verified),
            "distance": float(distance) if distance is not None else None
        })

    except Exception as e:
        return jsonify({
            "verified": False,
            "distance": None,
            "error": str(e)
        }), 500


if __name__ == "__main__":
    # You can change host= to "127.0.0.1" if needed
    app.run(host="0.0.0.0", port=8000)
