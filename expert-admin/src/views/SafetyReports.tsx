import React, { useState, useEffect } from 'react';
import {
  AlertTriangle,
  CheckCircle2,
  XCircle,
  Clock,
  Loader2,
  ShieldAlert,
  Search,
} from 'lucide-react';
import { SafetyReportItem } from '../types';
import { api } from '../services/api';

export const SafetyReports: React.FC = () => {
  const [reports, setReports] = useState<SafetyReportItem[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [filterStatus, setFilterStatus] = useState<string>('ALL');
  const [selectedReport, setSelectedReport] = useState<SafetyReportItem | null>(null);
  const [moderatorNotes, setModeratorNotes] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  const loadReports = async () => {
    setIsLoading(true);
    try {
      const data = await api.getReports(0, 50, filterStatus);
      setReports(data);
    } catch (err) {
      console.error('Failed to load safety reports:', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadReports();
  }, [filterStatus]);

  const handleResolveSubmit = async (status: 'RESOLVED' | 'DISMISSED') => {
    if (!selectedReport) return;
    setIsSubmitting(true);
    try {
      await api.resolveReport(selectedReport.id, status, moderatorNotes || 'Moderated by Super Admin');
      setSelectedReport(null);
      setModeratorNotes('');
      loadReports();
    } catch (err: any) {
      alert(`Moderation action failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-4">
      {/* Header & Filter */}
      <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs flex items-center justify-between">
        <div>
          <h2 className="text-sm font-bold text-slate-900">Safety Complaints & Content Moderation</h2>
          <p className="text-xs text-slate-500">User and creator misconduct reports recorded in PostgreSQL</p>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-slate-500 font-medium">Status:</span>
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-xs font-medium text-slate-700 focus:outline-none focus:ring-1 focus:ring-blue-500"
          >
            <option value="ALL">All Reports ({reports.length})</option>
            <option value="PENDING">Pending Review</option>
            <option value="RESOLVED">Resolved</option>
            <option value="DISMISSED">Dismissed</option>
          </select>
        </div>
      </div>

      {/* Reports Table */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        {isLoading ? (
          <div className="p-12 text-center text-slate-400">
            <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
            <span className="text-xs">Loading safety reports...</span>
          </div>
        ) : reports.length === 0 ? (
          <div className="p-12 text-center">
            <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 mx-auto flex items-center justify-center mb-3">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <h3 className="text-sm font-semibold text-slate-800">No safety reports pending</h3>
            <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
              Platform consultations and interactions are running cleanly. Any reported complaints will appear here for immediate review.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Complainant</th>
                  <th className="py-3 px-6">Reported Individual</th>
                  <th className="py-3 px-6">Reason / Category</th>
                  <th className="py-3 px-6">Incident Details</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6">Reported On</th>
                  <th className="py-3 px-6 text-right">Moderation</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {reports.map((r) => (
                  <tr key={r.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3.5 px-6 font-semibold text-slate-900">
                      {r.reporterName}
                    </td>
                    <td className="py-3.5 px-6">
                      <div className="font-semibold text-slate-900">{r.reportedUser}</div>
                      <span className="text-[10px] text-slate-400 font-mono">Type: {r.targetType}</span>
                    </td>
                    <td className="py-3.5 px-6">
                      <span className="px-2 py-0.5 rounded text-[10px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                        {r.reason}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 text-slate-600 max-w-xs truncate">
                      {r.details || 'No additional details provided'}
                    </td>
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold border ${
                        r.status === 'RESOLVED'
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : r.status === 'PENDING'
                          ? 'bg-amber-50 text-amber-700 border-amber-200'
                          : 'bg-slate-100 text-slate-600 border-slate-200'
                      }`}>
                        {r.status}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 text-slate-400 whitespace-nowrap">
                      {r.createdAt}
                    </td>
                    <td className="py-3.5 px-6 text-right">
                      {r.status === 'PENDING' && (
                        <button
                          onClick={() => {
                            setSelectedReport(r);
                            setModeratorNotes('');
                          }}
                          className="px-2.5 py-1 rounded text-xs font-semibold bg-blue-600 hover:bg-blue-700 text-white shadow-2xs"
                        >
                          Take Action
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

      {/* Moderation Resolution Modal */}
      {selectedReport && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-slate-200 rounded-xl max-w-md w-full p-6 shadow-xl">
            <div className="flex items-center gap-3 text-slate-900 mb-3">
              <div className="w-10 h-10 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center">
                <ShieldAlert className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold">Review Safety Incident</h3>
                <p className="text-xs text-slate-500">Report against {selectedReport.reportedUser}</p>
              </div>
            </div>

            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200 text-xs mb-4 space-y-1">
              <div><span className="text-slate-500 font-medium">Allegation:</span> <span className="font-semibold text-rose-700">{selectedReport.reason}</span></div>
              <div><span className="text-slate-500 font-medium">Details:</span> <span className="text-slate-800">{selectedReport.details}</span></div>
            </div>

            <div className="mb-4">
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Moderator Decision Notes
              </label>
              <textarea
                rows={2}
                value={moderatorNotes}
                onChange={(e) => setModeratorNotes(e.target.value)}
                placeholder="e.g. Warning issued to creator / caller refunded..."
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-slate-100 gap-2">
              <button
                onClick={() => handleResolveSubmit('DISMISSED')}
                disabled={isSubmitting}
                className="px-2.5 py-1.5 rounded-lg text-xs font-medium text-slate-500 hover:bg-slate-100"
              >
                Dismiss Complaint
              </button>

              <div className="flex items-center gap-2">
                <button
                  onClick={() => setSelectedReport(null)}
                  disabled={isSubmitting}
                  className="px-3 py-1.5 rounded-lg text-xs font-medium text-slate-600 hover:bg-slate-100"
                >
                  Cancel
                </button>
                <button
                  onClick={() => handleResolveSubmit('RESOLVED')}
                  disabled={isSubmitting}
                  className="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs flex items-center gap-1.5"
                >
                  {isSubmitting && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                  Mark Resolved
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
