
import java.security.MessageDigest;

public class BlockchainUtil {

    // Compute SHA-256 hash of a string
    public static String sha256(String data) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(data.getBytes("UTF-8"));

        StringBuilder hex = new StringBuilder();
        for (byte b : hash) {
            String h = Integer.toHexString(0xff & b);
            if (h.length() == 1) hex.append('0');
            hex.append(h);
        }
        return hex.toString();
    }

    // Build block content using a ticket state hash (preferred for resale/versioning)
    public static String buildBlockDataFromStateHash(int ticketId, String ticketStateHash, String prevHash) {
        return ticketId + "|" + ticketStateHash + "|" + prevHash;
    }

    // Deterministic ticket snapshot string for hashing current ticket state (status excluded to allow marketplace listing)
    public static String buildTicketStateData(int ticketId, int userId, int eventId,
                                              String seatType, double price) {
        return ticketId + "|" + userId + "|" + eventId + "|" + seatType + "|" + price;
    }
}
