import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;


public class DigitalSignatureUtil {

    private static final String KEY_ALGORITHM = "RSA";
    private static final String SIGNATURE_ALGORITHM = "SHA256withRSA";
    private static final Path PRIVATE_KEY_PATH = Paths.get("keys", "private_key.pem");
    private static final Path PUBLIC_KEY_PATH = Paths.get("keys", "public_key.pem");
    private static final String PRIVATE_KEY_RESOURCE = "keys/private_key.pem";
    private static final String PUBLIC_KEY_RESOURCE = "keys/public_key.pem";

    private static PrivateKey privateKey;
    private static PublicKey publicKey;

    static {
        try {
            loadKeysFromPem();
        } catch (Exception e) {
            throw new RuntimeException("Failed to load RSA keys from PEM files", e);
        }
    }

    // Load RSA key pair from PEM files in the keys/ directory
    private static void loadKeysFromPem() throws Exception {
        privateKey = readPrivateKey(PRIVATE_KEY_PATH, PRIVATE_KEY_RESOURCE);
        publicKey = readPublicKey(PUBLIC_KEY_PATH, PUBLIC_KEY_RESOURCE);
    }

    /**
     * Sign arbitrary text data using the server private key.
     */
    public static String sign(String data) {
        try {
            Signature signature = Signature.getInstance(SIGNATURE_ALGORITHM);
            signature.initSign(privateKey);
            signature.update(data.getBytes("UTF-8"));

            byte[] signedBytes = signature.sign();
            return Base64.getEncoder().encodeToString(signedBytes);
        } catch (Exception e) {
            throw new RuntimeException("Error while signing data: " + e.getMessage(), e);
        }
    }

    /**
     * Verify a signature using the public key.
     */
    public static boolean verify(String data, String signature) {
        try {
            Signature sig = Signature.getInstance(SIGNATURE_ALGORITHM);
            sig.initVerify(publicKey);
            sig.update(data.getBytes("UTF-8"));

            byte[] sigBytes = Base64.getDecoder().decode(signature);
            return sig.verify(sigBytes);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    
    public static PublicKey getPublicKey() {
        return publicKey;
    }

    private static PrivateKey readPrivateKey(Path path, String resourceName) throws Exception {
        String clean = readPem(path, resourceName);
        byte[] keyBytes = Base64.getDecoder().decode(clean);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance(KEY_ALGORITHM);
        return kf.generatePrivate(spec);
    }

    private static PublicKey readPublicKey(Path path, String resourceName) throws Exception {
        String clean = readPem(path, resourceName);
        byte[] keyBytes = Base64.getDecoder().decode(clean);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance(KEY_ALGORITHM);
        return kf.generatePublic(spec);
    }

    
    private static String readPem(Path path, String resourceName) throws Exception {
        byte[] bytes;
        if (Files.exists(path)) {
            bytes = Files.readAllBytes(path);
        } else {
            try (InputStream is = DigitalSignatureUtil.class.getClassLoader().getResourceAsStream(resourceName)) {
                if (is == null) {
                    throw new IllegalStateException("Key not found at " + path.toString() + " or classpath:" + resourceName);
                }
                bytes = toByteArray(is);
            }
        }
        String pem = new String(bytes, StandardCharsets.UTF_8);
        return pem.replaceAll("-----BEGIN (.*)-----", "")
                  .replaceAll("-----END (.*)-----", "")
                  .replaceAll("\\s", "");
    }

    private static byte[] toByteArray(InputStream is) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int read;
        while ((read = is.read(buffer)) != -1) {
            baos.write(buffer, 0, read);
        }
        return baos.toByteArray();
    }
}
