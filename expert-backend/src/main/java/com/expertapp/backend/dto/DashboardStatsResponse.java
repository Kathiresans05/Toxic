package com.expertapp.backend.dto;

import java.math.BigDecimal;

public class DashboardStatsResponse {

    private long totalCustomers;
    private long totalCreators;
    private long activeCallsCount;
    private long completedCallsCount;
    private BigDecimal totalGrossVolume = BigDecimal.ZERO;
    private BigDecimal totalPlatformRevenue = BigDecimal.ZERO;
    private long pendingKycCount;
    private long pendingPayoutsCount;
    private long pendingReportsCount;

    public DashboardStatsResponse() {}

    public long getTotalCustomers() { return totalCustomers; }
    public void setTotalCustomers(long totalCustomers) { this.totalCustomers = totalCustomers; }

    public long getTotalCreators() { return totalCreators; }
    public void setTotalCreators(long totalCreators) { this.totalCreators = totalCreators; }

    public long getActiveCallsCount() { return activeCallsCount; }
    public void setActiveCallsCount(long activeCallsCount) { this.activeCallsCount = activeCallsCount; }

    public long getCompletedCallsCount() { return completedCallsCount; }
    public void setCompletedCallsCount(long completedCallsCount) { this.completedCallsCount = completedCallsCount; }

    public BigDecimal getTotalGrossVolume() { return totalGrossVolume; }
    public void setTotalGrossVolume(BigDecimal totalGrossVolume) { this.totalGrossVolume = totalGrossVolume; }

    public BigDecimal getTotalPlatformRevenue() { return totalPlatformRevenue; }
    public void setTotalPlatformRevenue(BigDecimal totalPlatformRevenue) { this.totalPlatformRevenue = totalPlatformRevenue; }

    public long getPendingKycCount() { return pendingKycCount; }
    public void setPendingKycCount(long pendingKycCount) { this.pendingKycCount = pendingKycCount; }

    public long getPendingPayoutsCount() { return pendingPayoutsCount; }
    public void setPendingPayoutsCount(long pendingPayoutsCount) { this.pendingPayoutsCount = pendingPayoutsCount; }

    public long getPendingReportsCount() { return pendingReportsCount; }
    public void setPendingReportsCount(long pendingReportsCount) { this.pendingReportsCount = pendingReportsCount; }
}
