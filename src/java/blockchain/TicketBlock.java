
import java.sql.ResultSet;
import java.sql.SQLException;

public class TicketBlock {

    private int blockId;
    private int ticketId;
    private String previousHash;
    private String blockHash;
    private String ticketStateHash;

    public TicketBlock(int blockId, int ticketId, String previousHash, String blockHash) {
        this.blockId = blockId;
        this.ticketId = ticketId;
        this.previousHash = previousHash;
        this.blockHash = blockHash;
    }

    public TicketBlock(int blockId, int ticketId, String previousHash, String blockHash, String ticketStateHash) {
        this(blockId, ticketId, previousHash, blockHash);
        this.ticketStateHash = ticketStateHash;
    }

    
    public TicketBlock(ResultSet rs) throws SQLException {
        this.blockId = rs.getInt("block_id");
        this.ticketId = rs.getInt("ticket_id");
        this.previousHash = rs.getString("previous_hash");
        this.blockHash = rs.getString("block_hash");
        this.ticketStateHash = rs.getString("ticket_state_hash");
    }

    public int getBlockId() {
        return blockId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public String getPreviousHash() {
        return previousHash;
    }

    public String getBlockHash() {
        return blockHash;
    }

    public String getTicketStateHash() {
        return ticketStateHash;
    }
}
