export interface DashboardStats {
  totalCustomers: number;
  totalCreators: number;
  activeCallsCount: number;
  completedCallsCount: number;
  totalGrossVolume: number;
  totalPlatformRevenue: number;
  pendingKycCount: number;
  pendingPayoutsCount: number;
  pendingReportsCount?: number;
}

export interface UserItem {
  id: string;
  email: string;
  phoneNumber: string;
  fullName: string;
  role: 'ROLE_CUSTOMER' | 'ROLE_CREATOR' | 'ROLE_ADMIN';
  active: boolean;
  verified: boolean;
  createdAt: string;
}

export interface CreatorItem {
  id: string;
  userId: string;
  fullName: string;
  email: string;
  phone: string;
  headline: string;
  categoryName?: string;
  audioRatePerMin: number;
  videoRatePerMin: number;
  isAvailable: boolean;
  isApproved: boolean;
  ratingAverage: number;
  totalReviews: number;
  totalConsultations: number;
  walletBalance: number;
  kycStatus: string;
  createdAt: string;
}

export interface KycItem {
  id: string;
  expertName: string;
  expertHeadline: string;
  idType: string;
  idNumber: string;
  documentFrontUrl: string;
  documentBackUrl?: string;
  selfieUrl?: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  rejectionReason?: string;
  createdAt: string;
}

export interface CallLogItem {
  id: string;
  callId: string;
  customerName: string;
  expertName: string;
  callType: 'AUDIO' | 'VIDEO';
  status: string;
  durationSeconds: number;
  ratePerMinute: number;
  totalAmount: number;
  commissionAmount: number;
  expertEarnings: number;
  createdAt: string;
}

export interface TransactionItem {
  id: string;
  referenceId: string;
  user: string;
  type: string;
  amount: number;
  gateway: string;
  gatewayOrderId?: string;
  status: 'PENDING' | 'SUCCESS' | 'FAILED' | 'REFUNDED';
  date: string;
}

export interface PayoutItem {
  id: string;
  creatorName: string;
  amount: number;
  currency: string;
  status: 'REQUESTED' | 'PROCESSING' | 'COMPLETED' | 'REJECTED';
  bankAccountNumber?: string;
  bankIfsc?: string;
  upiId?: string;
  transactionReference?: string;
  createdAt: string;
  processedAt?: string;
}

export interface PlatformSettingItem {
  key: string;
  value: string;
  description: string;
  updatedAt: string;
}

export interface SafetyReportItem {
  id: string;
  reporterName: string;
  reportedUser: string;
  reportedUserId?: string;
  targetType: string;
  reason: string;
  details: string;
  status: 'PENDING' | 'RESOLVED' | 'DISMISSED';
  moderatorNotes?: string;
  createdAt: string;
}

export interface AnnouncementItem {
  id: string;
  title: string;
  message: string;
  targetAudience: 'ALL' | 'CUSTOMERS' | 'CREATORS';
  priority: 'NORMAL' | 'URGENT' | 'INFO';
  active: boolean;
  createdAt: string;
}

export interface AuditLogItem {
  id: string;
  action: string;
  details: string;
  adminEmail: string;
  ipAddress?: string;
  createdAt: string;
}
