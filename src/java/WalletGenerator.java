import java.security.MessageDigest;
import java.security.SecureRandom;

public class WalletGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();

    // Generate a wallet with hash-based address and no key storage
    public static Wallet generateNewWallet(int userId) {
        try {
            String walletAddress = generateWalletAddress(userId);

            // Build Wallet Object
            Wallet wallet = new Wallet();
            wallet.setUserId(userId);
            wallet.setWalletAddress(walletAddress);
            wallet.setBalance(0.0);       // default balance
            wallet.setStatus("ACTIVE");   // default status

            return wallet;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Wallet generation failed.", e);
        }
    }

    // Generate SHA-256(user_id + timestamp + random_salt) as wallet address
    private static String generateWalletAddress(int userId) throws Exception {
        long now = System.currentTimeMillis();
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);

        String payload = userId + ":" + now + ":" + toHex(salt);
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(payload.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        return toHex(hash);
    }

    private static String toHex(byte[] data) {
        StringBuilder sb = new StringBuilder(data.length * 2);
        for (byte b : data) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
