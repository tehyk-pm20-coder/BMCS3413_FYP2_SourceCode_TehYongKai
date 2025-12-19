import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WalletCRUD {

    // Insert new wallet
    public boolean insertWallet(Wallet wallet) {
        String sql = "INSERT INTO wallets (user_id, wallet_address, balance, status) "
                   + "VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, wallet.getUserId());
            stmt.setString(2, wallet.getWalletAddress());
            stmt.setDouble(3, wallet.getBalance());
            stmt.setString(4, wallet.getStatus());

            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    // Get wallet by user ID
    public Wallet getWalletByUserId(int userId) {
        String sql = "SELECT * FROM wallets WHERE user_id = ?";
        Wallet wallet = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                wallet = mapWallet(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return wallet;
    }


    // Get wallet by wallet ID
    public Wallet getWalletById(int walletId) {
        String sql = "SELECT * FROM wallets WHERE wallet_id = ?";
        Wallet wallet = null;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, walletId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                wallet = mapWallet(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return wallet;
    }


    // Update wallet status
    public boolean updateStatus(int walletId, String status) {
        String sql = "UPDATE wallets SET status = ? WHERE wallet_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, walletId);

            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    // Update wallet balance
    public boolean updateBalance(int walletId, double newBalance) {
        String sql = "UPDATE wallets SET balance = ? WHERE wallet_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDouble(1, newBalance);
            stmt.setInt(2, walletId);

            return stmt.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    // List all wallets
    public List<Wallet> getAllWallets() {
        List<Wallet> list = new ArrayList<>();
        String sql = "SELECT * FROM wallets";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                list.add(mapWallet(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }


    // Helper method to map ResultSet → Wallet object
    private Wallet mapWallet(ResultSet rs) throws Exception {
        Wallet wallet = new Wallet();

        wallet.setWalletId(rs.getInt("wallet_id"));
        wallet.setUserId(rs.getInt("user_id"));
        wallet.setWalletAddress(rs.getString("wallet_address"));
        wallet.setBalance(rs.getDouble("balance"));
        wallet.setStatus(rs.getString("status"));

        return wallet;
    }
}
