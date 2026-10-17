import React, { useState, useEffect } from 'react';
import {
  Award,
  Search,
  Star,
  CheckCircle2,
  XCircle,
  Phone,
  Video,
  Edit2,
  Loader2,
  ShieldCheck,
  Wallet,
} from 'lucide-react';
import { CreatorItem } from '../types';
import { api } from '../services/api';

export const CreatorsList: React.FC = () => {
  const [creators, setCreators] = useState<CreatorItem[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [search, setSearch] = useState<string>('');
  const [editingCreator, setEditingCreator] = useState<CreatorItem | null>(null);
  const [newAudioRate, setNewAudioRate] = useState<number>(0);
  const [newVideoRate, setNewVideoRate] = useState<number>(0);
  const [isUpdatingRates, setIsUpdatingRates] = useState<boolean>(false);

  const loadCreators = async () => {
    setIsLoading(true);
    try {
      const data = await api.getCreators();
      setCreators(data);
    } catch (err) {
      console.error('Failed to load creators:', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadCreators();
  }, []);

  const handleToggleApproval = async (creator: CreatorItem) => {
    try {
      await api.toggleCreatorApproval(creator.id, !creator.isApproved);
      loadCreators();
    } catch (err: any) {
      alert(`Approval toggle failed: ${err.message || 'Unknown error'}`);
    }
  };

  const handleOpenRateModal = (creator: CreatorItem) => {
    setEditingCreator(creator);
    setNewAudioRate(creator.audioRatePerMin);
    setNewVideoRate(creator.videoRatePerMin);
  };

  const handleSaveRates = async () => {
    if (!editingCreator) return;
    setIsUpdatingRates(true);
    try {
      await api.updateCreatorRates(editingCreator.id, newAudioRate, newVideoRate);
      setEditingCreator(null);
      loadCreators();
    } catch (err: any) {
      alert(`Rate update failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsUpdatingRates(false);
    }
  };

  const filteredCreators = creators.filter((c) =>
    c.fullName.toLowerCase().includes(search.toLowerCase()) ||
    c.headline.toLowerCase().includes(search.toLowerCase()) ||
    c.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-4">
      {/* Search Header */}
      <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs flex items-center justify-between">
        <div className="relative flex-1 max-w-md">
          <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
            <Search className="w-4 h-4" />
          </div>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search creators by name, skill, or email..."
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-blue-500 focus:bg-white"
          />
        </div>

        <div className="text-xs text-slate-500 font-medium">
          Total Creators: <span className="font-bold text-slate-900">{creators.length}</span>
        </div>
      </div>

      {/* Creators Table */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
          <div>
            <h2 className="text-sm font-bold text-slate-900">Creator Profiles & Call Tariffs</h2>
            <p className="text-xs text-slate-500">Live consultation experts registered in PostgreSQL</p>
          </div>
        </div>

        {isLoading ? (
          <div className="p-12 text-center text-slate-400">
            <Loader2 className="w-6 h-6 animate-spin mx-auto mb-2 text-blue-600" />
            <span className="text-xs">Loading creator roster...</span>
          </div>
        ) : filteredCreators.length === 0 ? (
          <div className="p-12 text-center">
            <div className="w-12 h-12 rounded-full bg-slate-100 text-slate-400 mx-auto flex items-center justify-center mb-3">
              <Award className="w-6 h-6" />
            </div>
            <h3 className="text-sm font-semibold text-slate-800">No creator profiles found</h3>
            <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
              When consultation experts complete registration or are approved, their profiles and call rates will be manageable here.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Creator & Headline</th>
                  <th className="py-3 px-6">Category</th>
                  <th className="py-3 px-6">Audio Rate</th>
                  <th className="py-3 px-6">Video Rate</th>
                  <th className="py-3 px-6">Rating & Sessions</th>
                  <th className="py-3 px-6">Wallet Balance</th>
                  <th className="py-3 px-6">KYC Status</th>
                  <th className="py-3 px-6">Consultation Status</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {filteredCreators.map((c) => (
                  <tr key={c.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3.5 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-amber-100 text-amber-800 font-bold flex items-center justify-center text-xs">
                          {c.fullName.slice(0, 2).toUpperCase()}
                        </div>
                        <div>
                          <div className="font-semibold text-slate-900">{c.fullName}</div>
                          <div className="text-[11px] text-slate-400 truncate max-w-[180px]">{c.headline}</div>
                        </div>
                      </div>
                    </td>
                    <td className="py-3.5 px-6">
                      <span className="px-2 py-0.5 rounded text-[10px] font-medium bg-slate-100 text-slate-700">
                        {c.categoryName}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 font-semibold text-slate-900">
                      ₹{c.audioRatePerMin}/min
                    </td>
                    <td className="py-3.5 px-6 font-semibold text-slate-900">
                      ₹{c.videoRatePerMin}/min
                    </td>
                    <td className="py-3.5 px-6">
                      <div className="flex items-center gap-1 font-semibold text-slate-900">
                        <Star className="w-3.5 h-3.5 text-amber-500 fill-amber-500" />
                        <span>{c.ratingAverage.toFixed(1)}</span>
                        <span className="text-slate-400 font-normal">({c.totalConsultations} calls)</span>
                      </div>
                    </td>
                    <td className="py-3.5 px-6 font-semibold text-emerald-600">
                      ₹{c.walletBalance.toLocaleString('en-IN')}
                    </td>
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold border ${
                        c.kycStatus === 'APPROVED'
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : c.kycStatus === 'PENDING'
                          ? 'bg-amber-50 text-amber-700 border-amber-200'
                          : 'bg-slate-100 text-slate-600 border-slate-200'
                      }`}>
                        {c.kycStatus}
                      </span>
                    </td>
                    <td className="py-3.5 px-6">
                      <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold border ${
                        c.isApproved
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : 'bg-rose-50 text-rose-700 border-rose-200'
                      }`}>
                        {c.isApproved ? <CheckCircle2 className="w-3 h-3" /> : <XCircle className="w-3 h-3" />}
                        {c.isApproved ? 'APPROVED' : 'DISABLED'}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 text-right space-x-1.5 whitespace-nowrap">
                      <button
                        onClick={() => handleOpenRateModal(c)}
                        title="Edit Per-Minute Rates"
                        className="px-2 py-1 rounded text-xs font-medium text-slate-600 hover:bg-slate-100 border border-slate-200"
                      >
                        <Edit2 className="w-3 h-3 inline mr-1" /> Rates
                      </button>
                      <button
                        onClick={() => handleToggleApproval(c)}
                        className={`px-2.5 py-1 rounded text-xs font-semibold border transition-colors ${
                          c.isApproved
                            ? 'text-rose-600 hover:bg-rose-50 border-rose-200'
                            : 'text-emerald-600 hover:bg-emerald-50 border-emerald-200'
                        }`}
                      >
                        {c.isApproved ? 'Revoke' : 'Approve'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Edit Rates Modal */}
      {editingCreator && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-slate-200 rounded-xl max-w-sm w-full p-6 shadow-xl">
            <div className="flex items-center gap-3 text-slate-900 mb-4">
              <div className="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center">
                <Edit2 className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold">Configure Call Tariffs</h3>
                <p className="text-xs text-slate-500">{editingCreator.fullName}</p>
              </div>
            </div>

            <div className="space-y-3 mb-5">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Audio Call Rate (₹ / minute)
                </label>
                <input
                  type="number"
                  min="0"
                  step="1"
                  value={newAudioRate}
                  onChange={(e) => setNewAudioRate(Number(e.target.value))}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Video Call Rate (₹ / minute)
                </label>
                <input
                  type="number"
                  min="0"
                  step="1"
                  value={newVideoRate}
                  onChange={(e) => setNewVideoRate(Number(e.target.value))}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
            </div>

            <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
              <button
                onClick={() => setEditingCreator(null)}
                disabled={isUpdatingRates}
                className="px-3 py-1.5 rounded-lg text-xs font-medium text-slate-600 hover:bg-slate-100"
              >
                Cancel
              </button>
              <button
                onClick={handleSaveRates}
                disabled={isUpdatingRates}
                className="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-blue-600 hover:bg-blue-700 text-white shadow-xs flex items-center gap-1.5"
              >
                {isUpdatingRates && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                Save Tariffs
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
