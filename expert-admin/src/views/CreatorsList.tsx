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
  Sparkles,
  ChevronDown,
} from 'lucide-react';
import { CreatorItem } from '../types';
import { api } from '../services/api';

export const CreatorsList: React.FC = () => {
  const [creators, setCreators] = useState<CreatorItem[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [search, setSearch] = useState<string>('');
  const [activeTierFilter, setActiveTierFilter] = useState<'ALL' | 'STANDARD' | 'ELITE'>('ALL');
  const [switchingTierId, setSwitchingTierId] = useState<string | null>(null);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);

  // Manual rate modal (optional override)
  const [editingCreator, setEditingCreator] = useState<CreatorItem | null>(null);
  const [newAudioRate, setNewAudioRate] = useState<number>(0);
  const [newVideoRate, setNewVideoRate] = useState<number>(0);
  const [isUpdatingRates, setIsUpdatingRates] = useState<boolean>(false);

  const loadCreators = async () => {
    setIsLoading(true);
    try {
      const data = await api.getCreators(0, 100, activeTierFilter);
      setCreators(data);
    } catch (err) {
      console.error('Failed to load creators:', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadCreators();
  }, [activeTierFilter]);

  const handleTierSwitch = async (creator: CreatorItem, newTier: 'STANDARD' | 'ELITE') => {
    if (creator.tier === newTier) return;
    setSwitchingTierId(creator.id);
    setStatusMessage(null);
    try {
      await api.updateCreatorTier(creator.id, newTier);
      setStatusMessage(`${creator.fullName} assigned to ${newTier === 'ELITE' ? '👑 Elite Expert' : '🔵 Standard Pro'}. Rates auto-updated!`);
      await loadCreators();
    } catch (err: any) {
      alert(`Tier switch failed: ${err.message || 'Unknown error'}`);
    } finally {
      setSwitchingTierId(null);
    }
  };

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

  const standardCount = creators.filter((c) => c.tier === 'STANDARD').length;
  const eliteCount = creators.filter((c) => c.tier === 'ELITE').length;

  const filteredCreators = creators.filter((c) => {
    const matchesSearch =
      c.fullName.toLowerCase().includes(search.toLowerCase()) ||
      c.headline.toLowerCase().includes(search.toLowerCase()) ||
      c.email.toLowerCase().includes(search.toLowerCase()) ||
      c.phone.includes(search);
    const matchesTier = activeTierFilter === 'ALL' || c.tier === activeTierFilter;
    return matchesSearch && matchesTier;
  });

  return (
    <div className="space-y-4">
      {statusMessage && (
        <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center justify-between shadow-2xs">
          <div className="flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
            <span className="font-medium">{statusMessage}</span>
          </div>
          <button
            onClick={() => setStatusMessage(null)}
            className="text-slate-400 hover:text-slate-600 text-xs font-bold"
          >
            ✕
          </button>
        </div>
      )}

      {/* Tier Filter Tabs & Search Header */}
      <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs flex flex-col sm:flex-row gap-3 sm:items-center sm:justify-between">
        {/* Tier Tabs */}
        <div className="flex items-center gap-1.5 p-1 bg-slate-100 rounded-lg">
          <button
            onClick={() => setActiveTierFilter('ALL')}
            className={`px-3 py-1.5 rounded-md text-xs font-semibold transition-all ${
              activeTierFilter === 'ALL'
                ? 'bg-white text-slate-900 shadow-2xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            All Creators ({creators.length})
          </button>
          <button
            onClick={() => setActiveTierFilter('STANDARD')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-semibold transition-all ${
              activeTierFilter === 'STANDARD'
                ? 'bg-blue-600 text-white shadow-2xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <Award className="w-3.5 h-3.5" />
            <span>Standard Pro</span>
            <span className={`px-1.5 py-0.2 rounded-full text-[10px] font-bold ${
              activeTierFilter === 'STANDARD' ? 'bg-blue-700 text-white' : 'bg-slate-200 text-slate-700'
            }`}>
              {standardCount}
            </span>
          </button>
          <button
            onClick={() => setActiveTierFilter('ELITE')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-semibold transition-all ${
              activeTierFilter === 'ELITE'
                ? 'bg-amber-600 text-white shadow-2xs'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span>Elite Expert</span>
            <span className={`px-1.5 py-0.2 rounded-full text-[10px] font-bold ${
              activeTierFilter === 'ELITE' ? 'bg-amber-700 text-white' : 'bg-slate-200 text-slate-700'
            }`}>
              {eliteCount}
            </span>
          </button>
        </div>

        {/* Search */}
        <div className="relative flex-1 max-w-sm">
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
      </div>

      {/* Creators Table */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
          <div>
            <h2 className="text-sm font-bold text-slate-900">Creator Profiles & Call Tariffs</h2>
            <p className="text-xs text-slate-500">
              Manage creator tiers, automated per-minute rates, and consultation approval status
            </p>
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
              No creators found matching the current search or tier filter.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Creator & Headline</th>
                  <th className="py-3 px-6">Tier Level</th>
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
                        <div className={`w-8 h-8 rounded-full font-bold flex items-center justify-center text-xs ${
                          c.tier === 'ELITE'
                            ? 'bg-amber-100 text-amber-800 border border-amber-300'
                            : 'bg-blue-100 text-blue-800'
                        }`}>
                          {c.fullName.slice(0, 2).toUpperCase()}
                        </div>
                        <div>
                          <div className="font-semibold text-slate-900 flex items-center gap-1.5">
                            <span>{c.fullName}</span>
                            {c.tier === 'ELITE' && (
                              <span className="text-[10px] font-bold text-amber-600" title="Elite Expert">👑</span>
                            )}
                          </div>
                          <div className="text-[11px] text-slate-400 truncate max-w-[180px]">{c.headline}</div>
                        </div>
                      </div>
                    </td>

                    {/* Quick Tier Switcher */}
                    <td className="py-3.5 px-6">
                      <div className="inline-flex rounded-lg border border-slate-200 p-0.5 bg-slate-50">
                        <button
                          disabled={switchingTierId === c.id}
                          onClick={() => handleTierSwitch(c, 'STANDARD')}
                          className={`flex items-center gap-1 px-2 py-1 rounded text-[11px] font-semibold transition-all ${
                            c.tier === 'STANDARD'
                              ? 'bg-blue-600 text-white shadow-2xs'
                              : 'text-slate-500 hover:text-slate-800 hover:bg-slate-100'
                          }`}
                        >
                          <Award className="w-3 h-3" />
                          <span>Standard</span>
                        </button>
                        <button
                          disabled={switchingTierId === c.id}
                          onClick={() => handleTierSwitch(c, 'ELITE')}
                          className={`flex items-center gap-1 px-2 py-1 rounded text-[11px] font-semibold transition-all ${
                            c.tier === 'ELITE'
                              ? 'bg-amber-600 text-white shadow-2xs'
                              : 'text-slate-500 hover:text-slate-800 hover:bg-slate-100'
                          }`}
                        >
                          <Sparkles className="w-3 h-3" />
                          <span>Elite</span>
                        </button>
                      </div>
                    </td>

                    <td className="py-3.5 px-6">
                      <span className="px-2 py-0.5 rounded text-[10px] font-medium bg-slate-100 text-slate-700">
                        {c.categoryName}
                      </span>
                    </td>

                    <td className="py-3.5 px-6">
                      <div className="font-bold text-slate-900 flex items-center gap-1">
                        <Phone className="w-3 h-3 text-slate-400" />
                        <span>₹{c.audioRatePerMin}/m</span>
                      </div>
                    </td>

                    <td className="py-3.5 px-6">
                      <div className="font-bold text-slate-900 flex items-center gap-1">
                        <Video className="w-3 h-3 text-slate-400" />
                        <span>₹{c.videoRatePerMin}/m</span>
                      </div>
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
                        title="Override Custom Rates"
                        className="px-2 py-1 rounded text-xs font-medium text-slate-600 hover:bg-slate-100 border border-slate-200"
                      >
                        <Edit2 className="w-3 h-3 inline mr-1" /> Custom
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

      {/* Optional Rate Override Modal */}
      {editingCreator && (
        <div className="fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 shadow-xl border border-slate-100 space-y-4">
            <div>
              <h3 className="text-sm font-bold text-slate-900">Custom Tariff Override</h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Set custom rates for {editingCreator.fullName}
              </p>
            </div>

            <div className="space-y-3">
              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1">
                  Audio Call Rate (₹ / min)
                </label>
                <input
                  type="number"
                  min="1"
                  value={newAudioRate}
                  onChange={(e) => setNewAudioRate(Number(e.target.value))}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-700 mb-1">
                  Video Call Rate (₹ / min)
                </label>
                <input
                  type="number"
                  min="1"
                  value={newVideoRate}
                  onChange={(e) => setNewVideoRate(Number(e.target.value))}
                  className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
            </div>

            <div className="pt-2 flex items-center justify-end gap-2 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setEditingCreator(null)}
                className="px-3 py-1.5 text-xs text-slate-600 hover:bg-slate-100 rounded-lg font-medium"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={isUpdatingRates}
                onClick={handleSaveRates}
                className="px-3.5 py-1.5 text-xs bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold flex items-center gap-1.5 disabled:opacity-50"
              >
                {isUpdatingRates && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                Save Custom Tariff
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
