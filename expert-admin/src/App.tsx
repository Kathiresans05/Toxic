import React, { useState, useEffect, useCallback } from 'react';
import { Sidebar } from './components/Sidebar';
import { Header } from './components/Header';
import { Login } from './views/Login';
import { Overview } from './views/Overview';
import { Analytics } from './views/Analytics';
import { UsersList } from './views/UsersList';
import { CreatorsList } from './views/CreatorsList';
import { KycQueue } from './views/KycQueue';
import { CallManagement } from './views/CallManagement';
import { PaymentsWallet } from './views/PaymentsWallet';
import { CreatorPayouts } from './views/CreatorPayouts';
import { CommissionPricing } from './views/CommissionPricing';
import { SafetyReports } from './views/SafetyReports';
import { NotificationsView } from './views/NotificationsView';
import { AuditLogs } from './views/AuditLogs';
import { SettingsView } from './views/SettingsView';
import { SystemHealth } from './views/SystemHealth';
import { DashboardStats, KycItem, CallLogItem, UserItem } from './types';
import { api } from './services/api';

export const App: React.FC = () => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(api.isAuthenticated());
  const [currentTab, setCurrentTab] = useState<string>('overview');
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Live Database Metrics (defaults to 0 / empty before fetch)
  const [stats, setStats] = useState<DashboardStats>({
    totalCustomers: 0,
    totalCreators: 0,
    activeCallsCount: 0,
    completedCallsCount: 0,
    totalGrossVolume: 0,
    totalPlatformRevenue: 0,
    pendingKycCount: 0,
    pendingPayoutsCount: 0,
    pendingReportsCount: 0,
  });

  const [kycList, setKycList] = useState<KycItem[]>([]);
  const [recentCalls, setRecentCalls] = useState<CallLogItem[]>([]);
  const [users, setUsers] = useState<UserItem[]>([]);

  // Fetch real data directly from Spring Boot & PostgreSQL
  const loadAllData = useCallback(async () => {
    setIsRefreshing(true);
    setErrorMessage(null);
    try {
      const [fetchedStats, fetchedKyc, fetchedCalls, fetchedUsers] = await Promise.all([
        api.getDashboardStats().catch(err => {
          console.warn('Stats fetch warning:', err);
          return {
            totalCustomers: 0,
            totalCreators: 0,
            activeCallsCount: 0,
            completedCallsCount: 0,
            totalGrossVolume: 0,
            totalPlatformRevenue: 0,
            pendingKycCount: 0,
            pendingPayoutsCount: 0,
            pendingReportsCount: 0,
          };
        }),
        api.getPendingKyc().catch(() => []),
        api.getCallLogs().catch(() => []),
        api.getUsers().catch(() => []),
      ]);

      setStats(fetchedStats);
      setKycList(fetchedKyc);
      setRecentCalls(fetchedCalls);
      setUsers(fetchedUsers);
    } catch (err: any) {
      console.error('Failed to load live data:', err);
      setErrorMessage('Could not connect to Spring Boot backend. Ensure backend is running on port 8080.');
    } finally {
      setIsRefreshing(false);
    }
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      loadAllData();
    }
  }, [isAuthenticated, loadAllData]);

  // Handle Logout
  const handleLogout = () => {
    api.logout();
    setIsAuthenticated(false);
  };

  // Real KYC Review in Database
  const handleReviewKyc = async (kycId: string, approved: boolean, reason?: string) => {
    try {
      await api.reviewKyc(kycId, approved, reason);
      await loadAllData();
    } catch (err: any) {
      alert(`KYC Review failed: ${err.message || 'Unknown error'}`);
    }
  };

  // If not logged in, show Login Screen
  if (!isAuthenticated) {
    return <Login onLoginSuccess={() => setIsAuthenticated(true)} />;
  }

  const tabTitles: Record<string, { title: string; subtitle: string }> = {
    overview: { title: 'Platform Performance & Operations', subtitle: 'Live production dashboard connected to Spring Boot 3 & PostgreSQL' },
    analytics: { title: 'Reports & Revenue Analytics', subtitle: 'Dynamic consultation trends, channel distribution, and downloadable CSV' },
    users: { title: 'Customer Directory & Accounts', subtitle: 'View registered customers, wallet transactions, and toggle account access' },
    creators: { title: 'Creator Management & Tariffs', subtitle: 'Manage consultation experts, approval status, and per-minute audio/video rates' },
    kyc: { title: 'Creator KYC Verification Queue', subtitle: 'Real-time document review from PostgreSQL database' },
    calls: { title: 'Consultation Call Sessions', subtitle: 'Agora RTC channels, participant duration, and financial settlement breakdown' },
    payments: { title: 'Payment Ledger & Wallet Recharges', subtitle: 'Razorpay webhooks, customer wallet additions, and gateway order IDs' },
    payouts: { title: 'Creator Earnings & Withdrawals', subtitle: 'Process expert withdrawal requests and record IMPS / UPI reference IDs' },
    pricing: { title: 'Commission & Pricing Rules', subtitle: 'Configure platform commission percentage and per-minute tariff limits' },
    reports: { title: 'Safety Complaints & Content Moderation', subtitle: 'Investigate user/creator dispute reports and enforce moderation actions' },
    notifications: { title: 'Platform Announcements & Broadcast', subtitle: 'Publish critical push notifications and alerts directly to mobile apps' },
    'audit-logs': { title: 'Immutable Administrative Audit Trail', subtitle: 'Cryptographically sealed audit records of all financial and security decisions' },
    settings: { title: 'Platform Configuration & Telemetry', subtitle: 'Global support details, verification automation, and infrastructure health' },
    monitoring: { title: 'Prometheus & Actuator Health', subtitle: 'Live JVM heap, HikariCP database pool, and container metrics' },
  };

  const currentMeta = tabTitles[currentTab] || tabTitles.overview;

  return (
    <div className="flex min-h-screen bg-slate-50 text-slate-900 font-sans">
      {/* Left Sidebar */}
      <Sidebar
        currentTab={currentTab}
        setCurrentTab={setCurrentTab}
        pendingKycCount={stats.pendingKycCount}
        pendingPayoutsCount={stats.pendingPayoutsCount}
        pendingReportsCount={stats.pendingReportsCount}
        onLogout={handleLogout}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        <Header
          title={currentMeta.title}
          subtitle={currentMeta.subtitle}
          onRefresh={loadAllData}
          isRefreshing={isRefreshing}
        />

        {errorMessage && (
          <div className="mx-8 mt-4 p-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs flex items-center justify-between">
            <span>{errorMessage}</span>
            <button
              onClick={loadAllData}
              className="px-2.5 py-1 rounded bg-rose-100 hover:bg-rose-200 text-rose-800 font-semibold"
            >
              Retry Connection
            </button>
          </div>
        )}

        <main className="p-8 flex-1 overflow-y-auto">
          {currentTab === 'overview' && (
            <Overview
              stats={stats}
              recentCalls={recentCalls}
              onNavigateTab={setCurrentTab}
            />
          )}

          {currentTab === 'analytics' && (
            <Analytics
              stats={stats}
              calls={recentCalls}
            />
          )}

          {currentTab === 'users' && (
            <UsersList
              users={users}
              onRefreshUsers={loadAllData}
            />
          )}

          {currentTab === 'creators' && (
            <CreatorsList />
          )}

          {currentTab === 'kyc' && (
            <KycQueue
              kycList={kycList}
              onReviewKyc={handleReviewKyc}
            />
          )}

          {currentTab === 'calls' && (
            <CallManagement
              calls={recentCalls}
            />
          )}

          {currentTab === 'payments' && (
            <PaymentsWallet />
          )}

          {currentTab === 'payouts' && (
            <CreatorPayouts />
          )}

          {currentTab === 'pricing' && (
            <CommissionPricing />
          )}

          {currentTab === 'reports' && (
            <SafetyReports />
          )}

          {currentTab === 'notifications' && (
            <NotificationsView />
          )}

          {currentTab === 'audit-logs' && (
            <AuditLogs />
          )}

          {currentTab === 'settings' && (
            <SettingsView />
          )}

          {currentTab === 'monitoring' && (
            <SystemHealth />
          )}
        </main>
      </div>
    </div>
  );
};
