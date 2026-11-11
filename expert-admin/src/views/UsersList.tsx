import React, { useState } from 'react';
import { Users, Search, CheckCircle2, XCircle, ShieldAlert, AlertCircle, Loader2, UserCheck, Sparkles, Shield } from 'lucide-react';
import { UserItem } from '../types';
import { api } from '../services/api';

interface UsersListProps {
  users: UserItem[];
  onRefreshUsers: () => void;
}

export const UsersList: React.FC<UsersListProps> = ({ users, onRefreshUsers }) => {
  const [search, setSearch] = useState<string>('');
  const [activeTab, setActiveTab] = useState<'ROLE_CUSTOMER' | 'ROLE_CREATOR' | 'ROLE_ADMIN'>('ROLE_CUSTOMER');
  const [selectedUserForToggle, setSelectedUserForToggle] = useState<UserItem | null>(null);
  const [isProcessing, setIsProcessing] = useState<boolean>(false);

  const customerCount = users.filter((u) => u.role === 'ROLE_CUSTOMER').length;
  const creatorCount = users.filter((u) => u.role === 'ROLE_CREATOR').length;
  const adminCount = users.filter((u) => u.role === 'ROLE_ADMIN').length;

  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.fullName.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      u.phoneNumber.includes(search);
    const matchesRole = u.role === activeTab;
    return matchesSearch && matchesRole;
  });

  const [verifyingUserId, setVerifyingUserId] = useState<string | null>(null);

  const handleToggleStatus = async () => {
    if (!selectedUserForToggle) return;
    setIsProcessing(true);
    try {
      await api.toggleUserStatus(selectedUserForToggle.id, !selectedUserForToggle.active);
      setSelectedUserForToggle(null);
      onRefreshUsers();
    } catch (err: any) {
      alert(`Status update failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsProcessing(false);
    }
  };

  const handleToggleVerification = async (user: UserItem) => {
    setVerifyingUserId(user.id);
    try {
      await api.toggleUserVerification(user.id, !user.verified);
      onRefreshUsers();
    } catch (err: any) {
      alert(`Verification update failed: ${err.message || 'Unknown error'}`);
    } finally {
      setVerifyingUserId(null);
    }
  };

  return (
    <div className="space-y-4">
      {/* Role Segmented Tabs (Option 1) */}
      <div className="bg-white border border-slate-200 rounded-xl p-1.5 shadow-2xs flex flex-wrap gap-1.5 sm:inline-flex">
        <button
          onClick={() => { setActiveTab('ROLE_CUSTOMER'); setSearch(''); }}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-xs font-semibold transition-all ${
            activeTab === 'ROLE_CUSTOMER'
              ? 'bg-blue-600 text-white shadow-xs'
              : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
          }`}
        >
          <UserCheck className="w-4 h-4" />
          <span>Customers</span>
          <span className={`px-1.5 py-0.5 rounded-full text-[10px] font-bold ${
            activeTab === 'ROLE_CUSTOMER' ? 'bg-blue-700/80 text-white' : 'bg-slate-100 text-slate-600'
          }`}>
            {customerCount}
          </span>
        </button>

        <button
          onClick={() => { setActiveTab('ROLE_CREATOR'); setSearch(''); }}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-xs font-semibold transition-all ${
            activeTab === 'ROLE_CREATOR'
              ? 'bg-amber-600 text-white shadow-xs'
              : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
          }`}
        >
          <Sparkles className="w-4 h-4" />
          <span>Creators & Consultants</span>
          <span className={`px-1.5 py-0.5 rounded-full text-[10px] font-bold ${
            activeTab === 'ROLE_CREATOR' ? 'bg-amber-700/80 text-white' : 'bg-slate-100 text-slate-600'
          }`}>
            {creatorCount}
          </span>
        </button>

        <button
          onClick={() => { setActiveTab('ROLE_ADMIN'); setSearch(''); }}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-xs font-semibold transition-all ${
            activeTab === 'ROLE_ADMIN'
              ? 'bg-purple-600 text-white shadow-xs'
              : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
          }`}
        >
          <Shield className="w-4 h-4" />
          <span>Platform Administrators</span>
          <span className={`px-1.5 py-0.5 rounded-full text-[10px] font-bold ${
            activeTab === 'ROLE_ADMIN' ? 'bg-purple-700/80 text-white' : 'bg-slate-100 text-slate-600'
          }`}>
            {adminCount}
          </span>
        </button>
      </div>

      {/* Search Bar */}
      <div className="bg-white border border-slate-200 rounded-xl p-3.5 shadow-2xs flex flex-wrap items-center justify-between gap-4">
        <div className="relative flex-1 min-w-[280px]">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search className="w-4 h-4" />
          </div>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={
              activeTab === 'ROLE_CUSTOMER'
                ? 'Search customers by name, email, or mobile...'
                : activeTab === 'ROLE_CREATOR'
                ? 'Search creators & consultants by name, email, or mobile...'
                : 'Search administrators by name, email, or mobile...'
            }
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-blue-500 focus:bg-white transition-all"
          />
        </div>
        <div className="text-xs text-slate-500 font-medium px-2">
          Filtered: <span className="font-bold text-slate-900">{filteredUsers.length}</span> of {
            activeTab === 'ROLE_CUSTOMER' ? customerCount : activeTab === 'ROLE_CREATOR' ? creatorCount : adminCount
          }
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
          <div>
            <h2 className="text-sm font-bold text-slate-900">
              {activeTab === 'ROLE_CUSTOMER'
                ? 'Customer Directory'
                : activeTab === 'ROLE_CREATOR'
                ? 'Creator & Expert Directory'
                : 'Platform Administrators'}
            </h2>
            <p className="text-xs text-slate-500">
              {activeTab === 'ROLE_CUSTOMER'
                ? `Showing ${filteredUsers.length} registered customers from PostgreSQL`
                : activeTab === 'ROLE_CREATOR'
                ? `Showing ${filteredUsers.length} registered creator accounts from PostgreSQL`
                : `Showing ${filteredUsers.length} platform system administrators`}
            </p>
          </div>
        </div>

        {filteredUsers.length === 0 ? (
          <div className="p-12 text-center">
            <div className="w-12 h-12 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center mb-3">
              <Users className="w-6 h-6" />
            </div>
            <h3 className="text-sm font-semibold text-slate-800">No users match your query</h3>
            <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
              {search ? 'Try clearing your search filters to view registered users.' : 'When customers register via OTP, their profiles will appear here.'}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">User Profile</th>
                  <th className="py-3 px-6">Phone Number</th>
                  <th className="py-3 px-6">Role</th>
                  <th className="py-3 px-6">Account Status</th>
                  {activeTab === 'ROLE_CREATOR' && <th className="py-3 px-6">Verified Badge</th>}
                  <th className="py-3 px-6">Registered On</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {filteredUsers.map((u) => (
                  <tr key={u.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3.5 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-700 font-bold flex items-center justify-center text-xs">
                          {u.fullName.slice(0, 2).toUpperCase()}
                        </div>
                        <div>
                          <div className="font-semibold text-slate-900">{u.fullName}</div>
                          <div className="text-[11px] text-slate-400">{u.email || 'No email attached'}</div>
                        </div>
                      </div>
                    </td>
                    <td className="py-3.5 px-6 font-mono text-slate-600">
                      {u.phoneNumber || 'N/A'}
                    </td>
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold border ${
                        u.role === 'ROLE_ADMIN'
                          ? 'bg-purple-50 text-purple-700 border-purple-200'
                          : u.role === 'ROLE_CREATOR'
                          ? 'bg-amber-50 text-amber-700 border-amber-200'
                          : 'bg-slate-100 text-slate-700 border-slate-200'
                      }`}>
                        {u.role.replace('ROLE_', '')}
                      </span>
                    </td>
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold border ${
                        u.active
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : 'bg-rose-50 text-rose-700 border-rose-200'
                      }`}>
                        {u.active ? <CheckCircle2 className="w-3 h-3" /> : <XCircle className="w-3 h-3" />}
                        {u.active ? 'ACTIVE' : 'SUSPENDED'}
                      </span>
                    </td>
                    {activeTab === 'ROLE_CREATOR' && (
                      <td className="py-3.5 px-6">
                        <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-semibold border ${
                          u.verified ? 'text-blue-700 bg-blue-50 border-blue-200' : 'text-slate-500 bg-slate-50 border-slate-200'
                        }`}>
                          {u.verified && <CheckCircle2 className="w-3 h-3 text-blue-600" />}
                          {u.verified ? 'VERIFIED' : 'UNVERIFIED'}
                        </span>
                      </td>
                    )}
                    <td className="py-3.5 px-6 text-slate-400">
                      {u.createdAt}
                    </td>
                    <td className="py-3.5 px-6 text-right">
                      <div className="flex items-center justify-end gap-2">
                        {u.role === 'ROLE_CREATOR' && (
                          <button
                            onClick={() => handleToggleVerification(u)}
                            disabled={verifyingUserId === u.id}
                            className={`px-2.5 py-1 rounded text-xs font-semibold transition-colors flex items-center gap-1 ${
                              u.verified
                                ? 'text-amber-700 hover:bg-amber-50 border border-amber-300'
                                : 'text-blue-700 hover:bg-blue-50 border border-blue-300'
                            }`}
                          >
                            {verifyingUserId === u.id ? (
                              <Loader2 className="w-3 h-3 animate-spin" />
                            ) : (
                              u.verified ? 'Revoke Badge' : 'Verify Creator'
                            )}
                          </button>
                        )}
                        {u.role !== 'ROLE_ADMIN' && (
                          <button
                            onClick={() => setSelectedUserForToggle(u)}
                            className={`px-2.5 py-1 rounded text-xs font-semibold transition-colors ${
                              u.active
                                ? 'text-rose-600 hover:bg-rose-50 border border-rose-200'
                                : 'text-emerald-600 hover:bg-emerald-50 border border-emerald-200'
                            }`}
                          >
                            {u.active ? 'Suspend' : 'Activate'}
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Confirmation Modal for Suspend/Activate */}
      {selectedUserForToggle && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-slate-200 rounded-xl max-w-sm w-full p-6 shadow-xl">
            <div className="flex items-center gap-3 text-slate-900 mb-3">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                selectedUserForToggle.active ? 'bg-rose-100 text-rose-600' : 'bg-emerald-100 text-emerald-600'
              }`}>
                <ShieldAlert className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold">
                  {selectedUserForToggle.active ? 'Suspend Customer Account' : 'Reactivate Account'}
                </h3>
                <p className="text-xs text-slate-500">Security & policy enforcement</p>
              </div>
            </div>

            <p className="text-xs text-slate-600 mb-4 leading-relaxed">
              Are you sure you want to {selectedUserForToggle.active ? 'suspend' : 'activate'}{' '}
              <span className="font-semibold text-slate-900">{selectedUserForToggle.fullName}</span>?{' '}
              {selectedUserForToggle.active
                ? 'They will be prevented from booking calls or accessing their wallet balance.'
                : 'They will regain access to voice and video consultations.'}
            </p>

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
              <button
                onClick={() => setSelectedUserForToggle(null)}
                disabled={isProcessing}
                className="px-3 py-1.5 rounded-lg text-xs font-medium text-slate-600 hover:bg-slate-100"
              >
                Cancel
              </button>
              <button
                onClick={handleToggleStatus}
                disabled={isProcessing}
                className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold text-white shadow-xs flex items-center gap-1.5 ${
                  selectedUserForToggle.active ? 'bg-rose-600 hover:bg-rose-700' : 'bg-emerald-600 hover:bg-emerald-700'
                }`}
              >
                {isProcessing && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                Confirm {selectedUserForToggle.active ? 'Suspension' : 'Activation'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
