

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.DatabaseMetaData;
import java.util.ArrayList;
import java.util.List;

public class TicketBlockchain {

    /**
     * Load all blocks from the block chain table in order.
     */
    public static List<TicketBlock> loadChain(Connection conn) throws SQLException {
        List<TicketBlock> blocks = new ArrayList<>();

        boolean hasStateHash = hasTicketStateHashColumn(conn);
        String sql = hasStateHash
                ? "SELECT block_id, ticket_id, previous_hash, block_hash, ticket_state_hash FROM blockchain ORDER BY block_id ASC"
                : "SELECT block_id, ticket_id, previous_hash, block_hash FROM blockchain ORDER BY block_id ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String ticketStateHash = hasStateHash ? rs.getString("ticket_state_hash") : null;
                TicketBlock block = new TicketBlock(
                        rs.getInt("block_id"),
                        rs.getInt("ticket_id"),
                        rs.getString("previous_hash"),
                        rs.getString("block_hash"),
                        ticketStateHash);
                blocks.add(block);
            }
        }

        return blocks;
    }

    /**
     * Validate the entire blockchain:
     *  - Check prevHash chain
     *  - Recompute SHA-256(blockData) for each block
     */
    public static boolean isChainValid() {
        try (Connection conn = DBConnection.getConnection()) {
            return isChainValid(conn);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Validates the blockchain using an existing DB 
     */
    public static boolean isChainValid(Connection conn) throws SQLException {
        if (conn == null) {
            System.err.println("TicketBlockchain: DB connection is null.");
            return false;
        }

        List<TicketBlock> chain = loadChain(conn);
        if (chain.isEmpty()) {
            return true;
        }

        TicketBlock previous = null;

        for (TicketBlock current : chain) {
            if (previous != null) {
                if (!current.getPreviousHash().equals(previous.getBlockHash())) {
                    System.err.println("Blockchain invalid at block_id " + current.getBlockId()
                            + ": previous_hash mismatch.");
                    return false;
                }
            }

            if (!verifyBlockHash(conn, current)) {
                System.err.println("Blockchain invalid at block_id " + current.getBlockId()
                        + ": hash does not match recomputed value.");
                return false;
            }

            previous = current;
        }

        return true;
    }

    /**
     * Rebuild the blockData and recompute SHA-256, then compare to stored hash.
     */
    private static boolean verifyBlockHash(Connection conn, TicketBlock block) {
        try {
            String ticketStateHash = block.getTicketStateHash();
            if (ticketStateHash == null || ticketStateHash.isEmpty()) {
                System.err.println("TicketBlockchain: missing ticket_state_hash for block_id " + block.getBlockId());
                return false;
            }

            String blockData = BlockchainUtil.buildBlockDataFromStateHash(
                    block.getTicketId(),
                    ticketStateHash,
                    block.getPreviousHash()
            );
            String recomputedHash = BlockchainUtil.sha256(blockData);

            return recomputedHash.equals(block.getBlockHash());
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Appends a new block for the specified ticket 
     */
    public static TicketBlock appendBlock(Connection conn, int ticketId) throws Exception {
        if (conn == null) {
            throw new IllegalArgumentException("Connection cannot be null when appending a block.");
        }

        TicketData ticketData = loadTicketData(conn, ticketId);
        if (ticketData == null) {
            throw new SQLException("Ticket " + ticketId + " cannot be found for blockchain insertion.");
        }

        String previousHash = "GENESIS";
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT block_hash FROM blockchain ORDER BY block_id DESC LIMIT 1")) {
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    previousHash = rs.getString(1);
                }
            }
        }

        String ticketStateData = BlockchainUtil.buildTicketStateData(
                ticketId,
                ticketData.userId,
                ticketData.eventId,
                ticketData.seatType,
                ticketData.price
                
        );
        String ticketStateHash = BlockchainUtil.sha256(ticketStateData);

        if (!hasTicketStateHashColumn(conn)) {
            throw new SQLException("ticket_state_hash column is required for block generation.");
        }

        String blockData = BlockchainUtil.buildBlockDataFromStateHash(ticketId, ticketStateHash, previousHash);

        String blockHash = BlockchainUtil.sha256(blockData);

        int blockId;
        try (PreparedStatement insert = conn.prepareStatement(
                "INSERT INTO blockchain (ticket_id, previous_hash, block_hash, ticket_state_hash) VALUES (?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)) {
            insert.setInt(1, ticketId);
            insert.setString(2, previousHash);
            insert.setString(3, blockHash);
            insert.setString(4, ticketStateHash);
            insert.executeUpdate();

            try (ResultSet keys = insert.getGeneratedKeys()) {
                if (keys.next()) {
                    blockId = keys.getInt(1);
                } else {
                    throw new SQLException("Failed to obtain block_id for ticket " + ticketId);
                }
            }
        }

        return new TicketBlock(blockId, ticketId, previousHash, blockHash, ticketStateHash);
    }

    
    public static TicketBlock appendBlock(int ticketId) throws Exception {
        // Prefer the caller to use the connection-aware overload to participate in its transaction.
        try (Connection conn = DBConnection.getConnection()) {
            if (conn == null) {
                throw new SQLException("Unable to obtain database connection for blockchain append.");
            }
            return appendBlock(conn, ticketId);
        }
    }

    private static TicketData loadTicketData(Connection conn, int ticketId) throws SQLException {
        String sql = "SELECT user_id, event_id, seat_type, price, status FROM tickets WHERE ticket_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                TicketData data = new TicketData();
                data.userId = rs.getInt("user_id");
                data.eventId = rs.getInt("event_id");
                data.seatType = rs.getString("seat_type");
                data.price = rs.getDouble("price");
                data.status = rs.getString("status");
                return data;
            }
        }
    }

    private static class TicketData {
        int userId;
        int eventId;
        String seatType;
        double price;
        String status;
    }

    private static boolean hasTicketStateHashColumn(Connection conn) {
        try {
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getColumns(null, null, "blockchain", "ticket_state_hash")) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    
    public static void ensureLatestSnapshotForTicket(Connection conn, int ticketId) throws SQLException {
        
    }
}
