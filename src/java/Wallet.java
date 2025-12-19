public class Wallet {

    private int walletId;
    private int userId;
    private String walletAddress;
    private double balance;
    private String status;

    public Wallet() {}

    public Wallet(int walletId, int userId, String walletAddress, double balance, String status) {
        this.walletId = walletId;
        this.userId = userId;
        this.walletAddress = walletAddress;
        this.balance = balance;
        this.status = status;
    }

    // Getters and Setters
    public int getWalletId() {
        return walletId;
    }

    public void setWalletId(int walletId) {
        this.walletId = walletId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getWalletAddress() {
        return walletAddress;
    }

    public void setWalletAddress(String walletAddress) {
        this.walletAddress = walletAddress;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
