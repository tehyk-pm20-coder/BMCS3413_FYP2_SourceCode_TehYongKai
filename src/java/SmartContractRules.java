



public class SmartContractRules {

    /** Cooling-off period (in days) before a resale ticket can be listed again. */
    public static final int RESALE_COOLDOWN_DAYS = 7;
    private static final long MILLIS_PER_DAY = 24L * 60 * 60 * 1000;

    /**
     * Enforce anti-scalping rule:
     * resalePrice must be <= originalPrice
     */
    public static boolean canResellAtPrice(double originalPrice, double resalePrice) {
        return resalePrice <= originalPrice;
    }

    /**
     * Ticket must be:
     * - ACTIVE
     */
    public static boolean canTicketBeListed(String ticketStatus, java.util.Date eventDate) {
        if (!"ACTIVE".equalsIgnoreCase(ticketStatus)) {
            return false;
        }
        // prevent resale after event date
        java.util.Date now = new java.util.Date();
        return eventDate.after(now);
    }

    /**
     * Enforce cooling period after purchase before the ticket can be listed again.
     */
    public static boolean hasCooldownElapsed(java.util.Date purchaseTime) {
        return hasCooldownElapsed(purchaseTime, RESALE_COOLDOWN_DAYS);
    }

    public static boolean hasCooldownElapsed(java.util.Date purchaseTime, int cooldownDays) {
        if (purchaseTime == null || cooldownDays <= 0) {
            return true;
        }
        long elapsed = System.currentTimeMillis() - purchaseTime.getTime();
        long required = cooldownDays * MILLIS_PER_DAY;
        return elapsed >= required;
    }

    public static java.util.Date getCooldownExpiry(java.util.Date purchaseTime) {
        return getCooldownExpiry(purchaseTime, RESALE_COOLDOWN_DAYS);
    }

    public static java.util.Date getCooldownExpiry(java.util.Date purchaseTime, int cooldownDays) {
        if (purchaseTime == null || cooldownDays <= 0) {
            return null;
        }
        return new java.util.Date(purchaseTime.getTime() + cooldownDays * MILLIS_PER_DAY);
    }
}

