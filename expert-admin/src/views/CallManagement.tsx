import React, { useState, useEffect } from 'react';
import { PhoneCall, Video, Phone, Clock, Search, ShieldCheck, RefreshCw } from 'lucide-react';
import { CallLogItem } from '../types';
import { api } from '../services/api';

interface CallManagementProps {
  calls: CallLogItem[];
  onRefreshCalls?: () => void;
}

export const CallManagement: React.FC<CallManagementProps> = ({ calls, onRefreshCalls }) => {
  const [search, setSearch] = useState<string>('');
  const [filterType, setFilterType] = useState<string>('ALL');
  const [liveCalls, setLiveCalls] = useState<CallLogItem[]>(calls || []);
  const [isLoading, setIsLoading] = useState<boolean>(false);

  const fetchCalls = async () => {
    setIsLoading(true);
    try {
      const data = await api.getCallLogs();
      setLiveCalls(data);
      if (onRefreshCalls) onRefreshCalls();
    } catch (err) {
      console.warn('Failed to fetch call logs:', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (calls && calls.length > 0) {
      setLiveCalls(calls);
    } else {
      fetchCalls();
    }
  }, [calls]);

  const formatInr = (val: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(val);
  };

  const filteredCalls = (liveCalls || []).filter((c) => {
    const matchesSearch =
      (c.customerName || '').toLowerCase().includes(search.toLowerCase()) ||
      (c.expertName || '').toLowerCase().includes(search.toLowerCase()) ||
      (c.callId || '').toLowerCase().includes(search.toLowerCase());
    const matchesType = filterType === 'ALL' || c.callType === filterType;
    return matchesSearch && matchesType;
  });

  return (
    <div className="space-y-4">
      {/* Search & Filter Header */}
      <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs flex flex-wrap items-center justify-between gap-4">
        <div className="relative flex-1 min-w-[280px]">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search className="w-4 h-4" />
          </div>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search consultation by participant or Call ID..."
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-blue-500 focus:bg-white"
          />
        </div>

        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2">
            <span className="text-xs text-slate-500 font-medium">Channel:</span>
            <select
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
              className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-xs font-medium text-slate-700 focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              <option value="ALL">All Types ({liveCalls.length})</option>
              <option value="VIDEO">Video Consultations</option>
              <option value="AUDIO">Voice Consultations</option>
            </select>
          </div>

          <button
            onClick={fetchCalls}
            disabled={isLoading}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 hover:bg-blue-100 border border-blue-200 text-blue-700 rounded-lg text-xs font-semibold transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>
      </div>

      {/* Calls Table */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
          <div>
            <h2 className="text-sm font-bold text-slate-900">Consultation Session Records</h2>
            <p className="text-xs text-slate-500">Live Agora RTC call logs and billing breakdown from PostgreSQL</p>
          </div>
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
            {liveCalls.length} Recorded Session{liveCalls.length === 1 ? '' : 's'}
          </span>
        </div>

        {filteredCalls.length === 0 ? (
          <div className="p-12 text-center">
            <div className="w-12 h-12 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center mb-3">
              <PhoneCall className="w-6 h-6" />
            </div>
            <h3 className="text-sm font-semibold text-slate-800">No consultation calls match</h3>
            <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
              When customers connect with creators via Agora RTC channels, session metrics and financial splits will be recorded here.
            </p>
            <button
              onClick={fetchCalls}
              className="mt-4 inline-flex items-center gap-1.5 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-xs font-semibold shadow-xs"
            >
              <RefreshCw className="w-3.5 h-3.5" />
              Reload Call Logs
            </button>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Session ID</th>
                  <th className="py-3 px-6">Customer & Creator</th>
                  <th className="py-3 px-6">Channel Type</th>
                  <th className="py-3 px-6">Duration</th>
                  <th className="py-3 px-6">Rate / Min</th>
                  <th className="py-3 px-6">Gross Spend</th>
                  <th className="py-3 px-6">Commission (20%)</th>
                  <th className="py-3 px-6">Creator Payout</th>
                  <th className="py-3 px-6">Call Status</th>
                  <th className="py-3 px-6">Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {filteredCalls.map((call) => (
                  <tr key={call.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3.5 px-6 font-mono text-slate-500 text-[11px]">
                      {call.callId}
                    </td>
                    <td className="py-3.5 px-6">
                      <div className="font-semibold text-slate-900">{call.customerName}</div>
                      <div className="text-[11px] text-slate-400">with {call.expertName}</div>
                    </td>
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-semibold border ${
                        call.callType === 'VIDEO'
                          ? 'bg-blue-50 text-blue-700 border-blue-200'
                          : 'bg-emerald-50 text-emerald-700 border-emerald-200'
                      }`}>
                        {call.callType === 'VIDEO' ? <Video className="w-3 h-3" /> : <Phone className="w-3 h-3" />}
                        {call.callType}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 font-mono font-medium text-slate-700">
                      {Math.floor(call.durationSeconds / 60)}m {call.durationSeconds % 60}s
                    </td>
                    <td className="py-3.5 px-6 font-mono text-slate-600">
                      ₹{call.ratePerMinute}/m
                    </td>
                    <td className="py-3.5 px-6 font-semibold text-slate-900">
                      {formatInr(call.totalAmount)}
                    </td>
                    <td className="py-3.5 px-6 font-medium text-emerald-600">
                      {formatInr(call.commissionAmount)}
                    </td>
                    <td className="py-3.5 px-6 font-medium text-slate-900">
                      {formatInr(call.expertEarnings)}
                    </td>
                    <td className="py-3.5 px-6">
                      <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        {call.status}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 text-slate-400 whitespace-nowrap">
                      {call.createdAt}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};
