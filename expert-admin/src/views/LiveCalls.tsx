import React from 'react';
import { PhoneCall, Video, User, Clock, AlertOctagon } from 'lucide-react';
import { CallLogItem } from '../types';

interface LiveCallsProps {
  calls: CallLogItem[];
  onEndCall?: (callId: string) => void;
}

export const LiveCalls: React.FC<LiveCallsProps> = ({ calls, onEndCall }) => {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-base font-bold text-white">Consultation Calls & Agora RTC Audits</h3>
          <p className="text-xs text-slate-400">Real-time channel activity, audio/video sessions, and completed billing history</p>
        </div>
      </div>

      <div className="glass-panel rounded-2xl border border-slate-800 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-900/80 text-slate-400 border-b border-slate-800">
              <tr>
                <th className="py-3 px-4 font-semibold">Call ID & Channel</th>
                <th className="py-3 px-4 font-semibold">Customer</th>
                <th className="py-3 px-4 font-semibold">Creator</th>
                <th className="py-3 px-4 font-semibold">Type</th>
                <th className="py-3 px-4 font-semibold">Duration</th>
                <th className="py-3 px-4 font-semibold">Total / Commission</th>
                <th className="py-3 px-4 font-semibold">Status</th>
                <th className="py-3 px-4 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {calls.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-12 text-center text-slate-500">
                    No consultation sessions recorded.
                  </td>
                </tr>
              ) : (
                calls.map((call) => (
                  <tr key={call.id} className="hover:bg-slate-800/30 transition-colors">
                    <td className="py-3.5 px-4 font-mono text-[11px] text-slate-300">
                      <div>{call.callId}</div>
                      <div className="text-slate-500 text-[10px]">agora_channel_{call.callId}</div>
                    </td>
                    <td className="py-3.5 px-4 font-medium text-slate-200">
                      {call.customerName}
                    </td>
                    <td className="py-3.5 px-4 font-medium text-slate-200">
                      {call.expertName}
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-slate-800 text-slate-300 text-[11px]">
                        {call.callType === 'VIDEO' ? <Video className="w-3 h-3 text-emerald-400" /> : <PhoneCall className="w-3 h-3 text-blue-400" />}
                        {call.callType}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-slate-300">
                      <span className="flex items-center gap-1">
                        <Clock className="w-3 h-3 text-slate-500" />
                        {Math.floor(call.durationSeconds / 60)}m {call.durationSeconds % 60}s
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className="font-semibold text-slate-200">₹{call.totalAmount}</span>
                      <span className="block text-[10px] text-emerald-400">
                        Platform: ₹{call.commissionAmount}
                      </span>
                    </td>
                    <td className="py-3.5 px-4">
                      <span className={`px-2 py-0.5 rounded-full text-[10px] font-semibold border ${
                        call.status === 'CONNECTED' 
                          ? 'bg-blue-500/10 text-blue-400 border-blue-500/20 animate-pulse'
                          : 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
                      }`}>
                        {call.status}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-right">
                      {call.status === 'CONNECTED' && onEndCall ? (
                        <button
                          onClick={() => onEndCall(call.callId)}
                          className="px-2.5 py-1 rounded bg-rose-500/10 text-rose-400 hover:bg-rose-500/20 text-[11px] font-medium transition-colors"
                        >
                          Force End
                        </button>
                      ) : (
                        <span className="text-slate-500 text-[11px]">—</span>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
