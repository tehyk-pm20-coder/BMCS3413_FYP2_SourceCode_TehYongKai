package model;

import java.sql.Timestamp;

public class BlockAuditRecord {
    private int blockId;
    private int ticketId;
    private int eventId;
    private int userId;
    private String fullName;
    private String eventName;
    private String seatType;
    private double price;
    private String previousHash;
    private String blockHash;
    private Timestamp purchaseTime;
    private String signature;
    private String recomputedHash;
    private boolean tampered;
    private String ticketStateHash;
    private String currentStateHash;

    public int getBlockId() {
        return blockId;
    }

    public void setBlockId(int blockId) {
        this.blockId = blockId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public String getSeatType() {
        return seatType;
    }

    public void setSeatType(String seatType) {
        this.seatType = seatType;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getPreviousHash() {
        return previousHash;
    }

    public void setPreviousHash(String previousHash) {
        this.previousHash = previousHash;
    }

    public String getBlockHash() {
        return blockHash;
    }

    public void setBlockHash(String blockHash) {
        this.blockHash = blockHash;
    }

    public Timestamp getPurchaseTime() {
        return purchaseTime;
    }

    public void setPurchaseTime(Timestamp purchaseTime) {
        this.purchaseTime = purchaseTime;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public String getRecomputedHash() {
        return recomputedHash;
    }

    public void setRecomputedHash(String recomputedHash) {
        this.recomputedHash = recomputedHash;
    }

    public boolean isTampered() {
        return tampered;
    }

    public void setTampered(boolean tampered) {
        this.tampered = tampered;
    }

    public String getTicketStateHash() {
        return ticketStateHash;
    }

    public void setTicketStateHash(String ticketStateHash) {
        this.ticketStateHash = ticketStateHash;
    }

    public String getCurrentStateHash() {
        return currentStateHash;
    }

    public void setCurrentStateHash(String currentStateHash) {
        this.currentStateHash = currentStateHash;
    }
}
