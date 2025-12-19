import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.util.Base64;

public class KeyGeneratorUtil {

    // Generate RSA KeyPair (Public Key + Private Key)
    public static KeyPair generateRSAKeyPair() {
        try {
            KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
            keyGen.initialize(2048);  // Secure for wallet system
            return keyGen.generateKeyPair();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error generating RSA key pair", e);
        }
    }

    // Convert PublicKey to Base64 String for storing in DB
    public static String publicKeyToString(PublicKey publicKey) {
        return Base64.getEncoder().encodeToString(publicKey.getEncoded());
    }

    // Convert PrivateKey to Base64 String for encryption + storage in DB
    public static String privateKeyToString(PrivateKey privateKey) {
        return Base64.getEncoder().encodeToString(privateKey.getEncoded());
    }

    // Convert Base64 string back to PublicKey 
    public static PublicKey stringToPublicKey(String pubKeyStr) {
        // Implement only if needed later
        return null;
    }

    // Convert Base64 string back to PrivateKey 
    public static PrivateKey stringToPrivateKey(String privKeyStr) {
        // Implement only if needed later
        return null;
    }
}
