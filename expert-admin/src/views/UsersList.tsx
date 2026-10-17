import React, { useState } from 'react';
import { Users, Search, CheckCircle2, XCircle, ShieldAlert, AlertCircle, Loader2 } from 'lucide-react';
import { UserItem } from '../types';
import { api } from '../services/api';

interface UsersListProps {
  users: UserItem[];
  onRefreshUsers: () => void;
}

export const UsersList: React.FC<UsersListProps> = ({ users, onRefreshUsers }) => {
  const [search, setSearch] = useState<string>('');
  const [filterRole, setFilterRole] = useState<string>('ALL');
  const [selectedUserForToggle, setSelectedUserForToggle] = useState<UserItem | null>(null);
  const [isProcessing, setIsProcessing] = useState<boolean>(false);

  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.fullName.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      u.phoneNumber.includes(search);
    const matchesRole = filterRole === 'ALL' || u.role === filterRole;
    return matchesSearch && matchesRole;
  });

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

  return (
    <div className="space-y-4">
      {/* Search and Filters Bar */}
      <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs flex flex-wrap items-center justify-between gap-4">
        <div className="relative flex-1 min-w-[280px]">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search className="w-4 h-4" />
          </div>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search customer by name, email, or mobile..."
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-blue-500 focus:bg-white transition-all"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-slate-500 font-medium">Role:</span>
          <select
            value={filterRole}
            onChange={(e) => setFilterRole(e.target.value)}
            className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-xs font-medium text-slate-700 focus:outline-none focus:ring-1 focus:ring-blue-500"
          >
            <option value="ALL">All Roles ({users.length})</option>
            <option value="ROLE_CUSTOMER">Customers</option>
            <option value="ROLE_CREATOR">Creators</option>
            <option value="ROLE_ADMIN">Admins</option>
          </select>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
          <div>
            <h2 className="text-sm font-bold text-slate-900">User Directory</h2>
            <p className="text-xs text-slate-500">
              Showing {filteredUsers.length} registered platform accounts from PostgreSQL
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
                  <th className="py-3 px-6">Verified</th>
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
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold ${
                        u.verified ? 'text-blue-700 bg-blue-50' : 'text-slate-400'
                      }`}>
                        {u.verified ? 'VERIFIED' : 'UNVERIFIED'}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 text-slate-400">
                      {u.createdAt}
                    </td>
                    <td className="py-3.5 px-6 text-right">
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
