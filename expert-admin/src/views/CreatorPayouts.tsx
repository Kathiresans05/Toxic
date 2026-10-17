import React, { useState, useEffect } from 'react';
import {
  CreditCard,
  Search,
  CheckCircle2,
  XCircle,
  Clock,
  Loader2,
  Building,
  Send,
} from 'lucide-react';
import { PayoutItem } from '../types';
import { api } from '../services/api';

export const CreatorPayouts: React.FC = () => {
  const [payouts, setPayouts] = useState<PayoutItem[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [filterStatus, setFilterStatus] = useState<string>('ALL');
  const [selectedPayout, setSelectedPayout] = useState<PayoutItem | null>(null);
  const [txnRef, setTxnRef] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState<boolean>(false);

  const loadPayouts = async () => {
    setIsLoading(true);
    try {
      const data = await api.getPayouts(0, 50, filterStatus);
      setPayouts(data);
    } catch (err) {
      console.error('Failed to load payouts:', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadPayouts();
  }, [filterStatus]);

  const formatInr = (val: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(val);
  };

  const handleProcessSubmit = async (status: 'COMPLETED' | 'REJECTED') => {
    if (!selectedPayout) return;
    setIsProcessing(true);
    try {
      await api.processPayout(
        selectedPayout.id,
        status,
        txnRef || `IMPS-${Date.now().toString().slice(-8)}`
      );
      setSelectedPayout(null);
      setTxnRef('');
      loadPayouts();
    } catch (err: any) {
      alert(`Payout processing failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="space-y-4">
      {/* Filter Header */}
      <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs flex items-center justify-between">
        <div>
          <h2 className="text-sm font-bold text-slate-900">Creator Withdrawal Requests</h2>
          <p className="text-xs text-slate-500">Approve bank account transfers and UPI settlements</p>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-slate-500 font-medium">Filter:</span>
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-xs font-medium text-slate-700 focus:outline-none focus:ring-1 focus:ring-blue-500"
          >
            <option value="ALL">All Payouts ({payouts.length})</option>
            <option value="REQUESTED">Pending Approval</option>
            <option value="COMPLETED">Completed</option>
            <option value="REJECTED">Rejected</option>
          </select>
        </div>
      </div>

      {/* Payouts Table */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        {isLoading ? (
          <div className="p-12 text-center text-slate-400">
            <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
            <span className="text-xs">Loading withdrawal records...</span>
          </div>
        ) : payouts.length === 0 ? (
          <div className="p-12 text-center">
            <div className="w-12 h-12 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center mb-3">
              <CreditCard className="w-6 h-6" />
            </div>
            <h3 className="text-sm font-semibold text-slate-800">No withdrawal requests found</h3>
            <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
              When consultation experts request earnings withdrawals to their bank account or UPI ID, they will appear here for verification.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Creator</th>
                  <th className="py-3 px-6">Amount Requested</th>
                  <th className="py-3 px-6">Disbursement Destination</th>
                  <th className="py-3 px-6">Payout Status</th>
                  <th className="py-3 px-6">Transaction Ref</th>
                  <th className="py-3 px-6">Requested At</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {payouts.map((p) => (
                  <tr key={p.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3.5 px-6 font-semibold text-slate-900">
                      {p.creatorName}
                    </td>
                    <td className="py-3.5 px-6 font-bold text-slate-900 text-sm">
                      {formatInr(p.amount)}
                    </td>
                    <td className="py-3.5 px-6">
                      {p.upiId ? (
                        <div className="font-mono text-slate-800 font-medium">
                          UPI: {p.upiId}
                        </div>
                      ) : p.bankAccountNumber ? (
                        <div>
                          <div className="font-mono text-slate-800 font-medium">A/C: {p.bankAccountNumber}</div>
                          <div className="text-[11px] text-slate-400 font-mono">IFSC: {p.bankIfsc}</div>
                        </div>
                      ) : (
                        <span className="text-slate-400">Default Bank Details</span>
                      )}
                    </td>
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold border ${
                        p.status === 'COMPLETED'
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : p.status === 'REQUESTED'
                          ? 'bg-amber-50 text-amber-700 border-amber-200'
                          : 'bg-rose-50 text-rose-700 border-rose-200'
                      }`}>
                        {p.status === 'COMPLETED' ? <CheckCircle2 className="w-3 h-3" /> : <Clock className="w-3 h-3" />}
                        {p.status}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 font-mono text-slate-500 text-[11px]">
                      {p.transactionReference || '—'}
                    </td>
                    <td className="py-3.5 px-6 text-slate-400 whitespace-nowrap">
                      {p.createdAt}
                    </td>
                    <td className="py-3.5 px-6 text-right">
                      {p.status === 'REQUESTED' && (
                        <button
                          onClick={() => {
                            setSelectedPayout(p);
                            setTxnRef(`PAYOUT-${Date.now().toString().slice(-6)}`);
                          }}
                          className="px-2.5 py-1 rounded text-xs font-semibold bg-blue-600 hover:bg-blue-700 text-white shadow-2xs"
                        >
                          Process Payout
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

      {/* Process Payout Dialog */}
      {selectedPayout && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-slate-200 rounded-xl max-w-sm w-full p-6 shadow-xl">
            <div className="flex items-center gap-3 text-slate-900 mb-3">
              <div className="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center">
                <CreditCard className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold">Process Creator Withdrawal</h3>
                <p className="text-xs text-slate-500">{selectedPayout.creatorName}</p>
              </div>
            </div>

            <div className="bg-slate-50 p-3 rounded-lg border border-slate-200 mb-4 text-xs space-y-1">
              <div className="flex justify-between">
                <span className="text-slate-500">Withdrawal Amount:</span>
                <span className="font-bold text-slate-900">{formatInr(selectedPayout.amount)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Payout Destination:</span>
                <span className="font-mono text-slate-800">{selectedPayout.upiId || selectedPayout.bankAccountNumber}</span>
              </div>
            </div>

            <div className="mb-4">
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Bank / IMPS / UPI Reference ID
              </label>
              <input
                type="text"
                value={txnRef}
                onChange={(e) => setTxnRef(e.target.value)}
                placeholder="e.g. UTR / IMPS12345678"
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-mono text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-slate-100 gap-2">
              <button
                onClick={() => handleProcessSubmit('REJECTED')}
                disabled={isProcessing}
                className="px-2.5 py-1.5 rounded-lg text-xs font-semibold text-rose-600 hover:bg-rose-50 border border-rose-200"
              >
                Reject & Refund
              </button>

              <div className="flex items-center gap-2">
                <button
                  onClick={() => setSelectedPayout(null)}
                  disabled={isProcessing}
                  className="px-3 py-1.5 rounded-lg text-xs font-medium text-slate-600 hover:bg-slate-100"
                >
                  Cancel
                </button>
                <button
                  onClick={() => handleProcessSubmit('COMPLETED')}
                  disabled={isProcessing}
                  className="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs flex items-center gap-1.5"
                >
                  {isProcessing && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                  Confirm Disbursal
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
