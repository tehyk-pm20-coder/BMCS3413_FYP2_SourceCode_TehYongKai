import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.UserIdentity;

public class UserIdentityDAO {

    private static final String STATUS_PENDING = "PENDING";
    private static final String STATUS_APPROVED = "APPROVED";
    private static final String STATUS_REJECTED = "REJECTED";

    public static UserIdentity findByUserId(int userId) {
        String sql = "SELECT ui.identity_id, ui.user_id, ui.id_photo_path, ui.face_photo_path, ui.status, "
                + "ui.created_at, ui.updated_at, ui.verified_by, u.fullname, u.email "
                + "FROM user_identity ui INNER JOIN users u ON ui.user_id = u.id WHERE ui.user_id = ?";
        try (Connection conn = requireConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void saveOrUpdate(int userId, String idImagePath, String faceImagePath) throws SQLException {
        Connection conn = requireConnection();
        boolean previousAutoCommit = true;
        try {
            previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            String updateSql = "UPDATE user_identity SET id_photo_path = ?, face_photo_path = ?, status = ?, "
                    + "verified_by = NULL, updated_at = CURRENT_TIMESTAMP WHERE user_id = ?";
            String insertSql = "INSERT INTO user_identity (user_id, id_photo_path, face_photo_path, status) "
                    + "VALUES (?, ?, ?, ?)";

            int affected;
            try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                update.setString(1, idImagePath);
                update.setString(2, faceImagePath);
                update.setString(3, STATUS_PENDING);
                update.setInt(4, userId);
                affected = update.executeUpdate();
            }
            if (affected == 0) {
                try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                    insert.setInt(1, userId);
                    insert.setString(2, idImagePath);
                    insert.setString(3, faceImagePath);
                    insert.setString(4, STATUS_PENDING);
                    insert.executeUpdate();
                }
            }
            updateUserIdentityStatus(conn, userId, mapUserStatus(STATUS_PENDING));
            conn.commit();
        } catch (SQLException ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(previousAutoCommit);
            conn.close();
        }
    }

    public static List<UserIdentity> findAll() {
        List<UserIdentity> identities = new ArrayList<>();
        String sql = "SELECT ui.identity_id, ui.user_id, ui.id_photo_path, ui.face_photo_path, ui.status, "
                + "ui.created_at, ui.updated_at, ui.verified_by, u.fullname, u.email "
                + "FROM user_identity ui INNER JOIN users u ON ui.user_id = u.id "
                + "ORDER BY ui.updated_at DESC";
        try (Connection conn = requireConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                identities.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return identities;
    }

    public static void updateStatus(int identityId, String status, Integer adminId) throws SQLException {
        Connection conn = requireConnection();
        boolean previousAutoCommit = true;
        try {
            previousAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);
            Integer userId = findUserIdForIdentity(conn, identityId);
            if (userId == null) {
                throw new SQLException("Identity record not found for ID " + identityId);
            }
            String sql = "UPDATE user_identity SET status = ?, verified_by = ?, updated_at = CURRENT_TIMESTAMP "
                    + "WHERE identity_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                if (adminId == null) {
                    ps.setNull(2, java.sql.Types.INTEGER);
                } else {
                    ps.setInt(2, adminId);
                }
                ps.setInt(3, identityId);
                ps.executeUpdate();
            }
            String mappedStatus = mapUserStatus(status);
            if (mappedStatus != null) {
                updateUserIdentityStatus(conn, userId, mappedStatus);
            }
            conn.commit();
        } catch (SQLException ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.setAutoCommit(previousAutoCommit);
            conn.close();
        }
    }

    public static Integer findUserIdByFileName(String fileName) {
        String sql = "SELECT user_id FROM user_identity WHERE id_photo_path = ? OR face_photo_path = ? LIMIT 1";
        try (Connection conn = requireConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fileName);
            ps.setString(2, fileName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private static UserIdentity mapRow(ResultSet rs) throws SQLException {
        UserIdentity identity = new UserIdentity();
        identity.setIdentityId(rs.getInt("identity_id"));
        identity.setUserId(rs.getInt("user_id"));
        identity.setIdPhotoPath(rs.getString("id_photo_path"));
        identity.setFacePhotoPath(rs.getString("face_photo_path"));
        identity.setStatus(rs.getString("status"));
        Timestamp created = rs.getTimestamp("created_at");
        Timestamp updated = rs.getTimestamp("updated_at");
        identity.setCreatedAt(created);
        identity.setUpdatedAt(updated);
        int verifier = rs.getInt("verified_by");
        if (!rs.wasNull()) {
            identity.setVerifiedBy(verifier);
        }
        identity.setUserFullname(rs.getString("fullname"));
        identity.setUserEmail(rs.getString("email"));
        return identity;
    }

    private static Integer findUserIdForIdentity(Connection conn, int identityId) throws SQLException {
        String sql = "SELECT user_id FROM user_identity WHERE identity_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, identityId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        }
        return null;
    }

    private static void updateUserIdentityStatus(Connection conn, int userId, String newStatus) throws SQLException {
        if (newStatus == null) {
            return;
        }
        String sql = "UPDATE users SET identity_status = ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private static String mapUserStatus(String identityStatus) {
        if (identityStatus == null) {
            return null;
        }
        switch (identityStatus) {
            case STATUS_APPROVED:
                return "VERIFIED";
            case STATUS_REJECTED:
                return "REJECTED";
            case STATUS_PENDING:
                return "PENDING";
            default:
                return null;
        }
    }

    private static Connection requireConnection() throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Unable to acquire database connection.");
        }
        return conn;
    }
}
