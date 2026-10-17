import React from 'react';
import {
  LayoutDashboard,
  BarChart3,
  Users,
  Award,
  FileCheck2,
  PhoneCall,
  Wallet,
  CreditCard,
  Percent,
  AlertTriangle,
  Bell,
  History,
  Settings,
  Activity,
  LogOut,
  Shield,
  ChevronRight,
} from 'lucide-react';

interface SidebarProps {
  currentTab: string;
  setCurrentTab: (tab: string) => void;
  pendingKycCount: number;
  pendingPayoutsCount: number;
  pendingReportsCount?: number;
  onLogout: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  currentTab,
  setCurrentTab,
  pendingKycCount,
  pendingPayoutsCount,
  pendingReportsCount = 0,
  onLogout,
}) => {
  const navigationGroups = [
    {
      title: 'DASHBOARD',
      items: [
        { id: 'overview', label: 'Platform Overview', icon: LayoutDashboard },
        { id: 'analytics', label: 'Reports & Analytics', icon: BarChart3 },
      ],
    },
    {
      title: 'USERS & CREATORS',
      items: [
        { id: 'users', label: 'Customer Directory', icon: Users },
        { id: 'creators', label: 'Creator Management', icon: Award },
        { id: 'kyc', label: 'KYC Verification', icon: FileCheck2, badge: pendingKycCount },
      ],
    },
    {
      title: 'COMMUNICATION',
      items: [
        { id: 'calls', label: 'Call Management', icon: PhoneCall },
      ],
    },
    {
      title: 'FINANCE & BILLING',
      items: [
        { id: 'payments', label: 'Payments & Wallet', icon: Wallet },
        { id: 'payouts', label: 'Creator Withdrawals', icon: CreditCard, badge: pendingPayoutsCount },
        { id: 'pricing', label: 'Commission & Pricing', icon: Percent },
      ],
    },
    {
      title: 'GOVERNANCE & SAFETY',
      items: [
        { id: 'reports', label: 'Safety & Moderation', icon: AlertTriangle, badge: pendingReportsCount },
        { id: 'notifications', label: 'Announcements', icon: Bell },
        { id: 'audit-logs', label: 'Audit Trail', icon: History },
      ],
    },
    {
      title: 'SYSTEM',
      items: [
        { id: 'settings', label: 'Platform Settings', icon: Settings },
        { id: 'monitoring', label: 'System Health', icon: Activity },
      ],
    },
  ];

  return (
    <aside className="w-64 bg-white border-r border-slate-200 flex flex-col justify-between h-screen sticky top-0 select-none">
      {/* Top Branding */}
      <div>
        <div className="h-16 px-5 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-blue-600 text-white flex items-center justify-center font-bold shadow-sm shadow-blue-500/20">
              <Shield className="w-5 h-5" />
            </div>
            <div>
              <span className="text-sm font-bold text-slate-900 tracking-tight block leading-none">
                ExpertAdmin
              </span>
              <span className="text-[11px] text-slate-400 font-medium">Enterprise Console</span>
            </div>
          </div>
          <span className="px-1.5 py-0.5 rounded text-[10px] font-semibold bg-blue-50 text-blue-700 border border-blue-200">
            v1.0
          </span>
        </div>

        {/* Navigation Groups */}
        <div className="px-3 py-4 space-y-6 overflow-y-auto max-h-[calc(100vh-140px)]">
          {navigationGroups.map((group) => (
            <div key={group.title}>
              <div className="px-3 mb-1.5 text-[10px] font-bold tracking-wider text-slate-400 uppercase">
                {group.title}
              </div>
              <div className="space-y-0.5">
                {group.items.map((item) => {
                  const Icon = item.icon;
                  const isActive = currentTab === item.id;
                  const badgeCount = item.badge || 0;

                  return (
                    <button
                      key={item.id}
                      onClick={() => setCurrentTab(item.id)}
                      className={`w-full flex items-center justify-between px-3 py-2 rounded-lg text-xs font-medium transition-all ${
                        isActive
                          ? 'bg-blue-50 text-blue-700 font-semibold shadow-xs'
                          : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                      }`}
                    >
                      <div className="flex items-center gap-2.5 truncate">
                        <Icon className={`w-4 h-4 shrink-0 ${isActive ? 'text-blue-600' : 'text-slate-400'}`} />
                        <span className="truncate">{item.label}</span>
                      </div>

                      {badgeCount > 0 ? (
                        <span className="px-1.5 py-0.2 rounded-full text-[10px] font-bold bg-amber-100 text-amber-800 border border-amber-200">
                          {badgeCount}
                        </span>
                      ) : isActive ? (
                        <ChevronRight className="w-3.5 h-3.5 text-blue-500" />
                      ) : null}
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Admin User Footer & Logout */}
      <div className="p-3 border-t border-slate-100 bg-slate-50/50">
        <div className="flex items-center justify-between p-2 rounded-lg bg-white border border-slate-200/60 shadow-2xs">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="w-8 h-8 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-xs shrink-0">
              AD
            </div>
            <div className="min-w-0">
              <div className="text-xs font-semibold text-slate-900 truncate">Super Admin</div>
              <div className="text-[10px] text-slate-400 truncate">admin@expertapp.com</div>
            </div>
          </div>

          <button
            onClick={onLogout}
            title="Sign Out"
            className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-md transition-colors"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  );
};
