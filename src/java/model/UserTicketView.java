package model;

import java.sql.Timestamp;

/**
 * View model representing a ticket owned by the logged-in user along with
 * optional resale listing information.
 */
public class UserTicketView {

    private int ticketId;
    private int eventId;
    private String eventName;
    private Timestamp eventDate;
    private String venue;
    private String seatType;
    private double price;
    private String ticketStatus;
    private Integer listingId;
    private Double listingPrice;
    private String listingStatus;
    private Timestamp listingCreatedAt;
    private String walletAddress;
    private String ticketStateHash;
    private String signature;
    private Timestamp purchaseTime;
    private Timestamp lastResaleSoldAt;
    private Integer lastResaleBuyerId;

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public Timestamp getEventDate() {
        return eventDate;
    }

    public void setEventDate(Timestamp eventDate) {
        this.eventDate = eventDate;
    }

    public String getVenue() {
        return venue;
    }

    public void setVenue(String venue) {
        this.venue = venue;
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

    public String getTicketStatus() {
        return ticketStatus;
    }

    public void setTicketStatus(String ticketStatus) {
        this.ticketStatus = ticketStatus;
    }

    public Integer getListingId() {
        return listingId;
    }

    public void setListingId(Integer listingId) {
        this.listingId = listingId;
    }

    public Double getListingPrice() {
        return listingPrice;
    }

    public void setListingPrice(Double listingPrice) {
        this.listingPrice = listingPrice;
    }

    public String getListingStatus() {
        return listingStatus;
    }

    public void setListingStatus(String listingStatus) {
        this.listingStatus = listingStatus;
    }

    public Timestamp getListingCreatedAt() {
        return listingCreatedAt;
    }

    public void setListingCreatedAt(Timestamp listingCreatedAt) {
        this.listingCreatedAt = listingCreatedAt;
    }

    public String getWalletAddress() {
        return walletAddress;
    }

    public void setWalletAddress(String walletAddress) {
        this.walletAddress = walletAddress;
    }

    public String getTicketStateHash() {
        return ticketStateHash;
    }

    public void setTicketStateHash(String ticketStateHash) {
        this.ticketStateHash = ticketStateHash;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public Timestamp getPurchaseTime() {
        return purchaseTime;
    }

    public void setPurchaseTime(Timestamp purchaseTime) {
        this.purchaseTime = purchaseTime;
    }

    public Timestamp getLastResaleSoldAt() {
        return lastResaleSoldAt;
    }

    public void setLastResaleSoldAt(Timestamp lastResaleSoldAt) {
        this.lastResaleSoldAt = lastResaleSoldAt;
    }

    public Integer getLastResaleBuyerId() {
        return lastResaleBuyerId;
    }

    public void setLastResaleBuyerId(Integer lastResaleBuyerId) {
        this.lastResaleBuyerId = lastResaleBuyerId;
    }
}
