import React, { useState, useEffect } from 'react';
import { Percent, Save, CheckCircle2, Loader2, AlertCircle, Shield, Award, Sparkles, Phone, Video } from 'lucide-react';
import { PlatformSettingItem } from '../types';
import { api } from '../services/api';

export const CommissionPricing: React.FC = () => {
  const [settings, setSettings] = useState<PlatformSettingItem[]>([]);
  const [commissionPct, setCommissionPct] = useState<string>('20');
  const [minPayout, setMinPayout] = useState<string>('500');

  // Tier Pricing State
  const [standardAudioRate, setStandardAudioRate] = useState<string>('7');
  const [standardVideoRate, setStandardVideoRate] = useState<string>('20');
  const [eliteAudioRate, setEliteAudioRate] = useState<string>('25');
  const [eliteVideoRate, setEliteVideoRate] = useState<string>('50');
  const [applyToExisting, setApplyToExisting] = useState<boolean>(true);

  const [isSaving, setIsSaving] = useState<boolean>(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const loadSettings = async () => {
    try {
      const data = await api.getSettings();
      setSettings(data);

      data.forEach((s) => {
        if (s.key === 'platform_commission_pct') setCommissionPct(s.value);
        if (s.key === 'min_payout_amount') setMinPayout(s.value);
        if (s.key === 'tier_standard_audio_rate') setStandardAudioRate(s.value);
        if (s.key === 'tier_standard_video_rate') setStandardVideoRate(s.value);
        if (s.key === 'tier_elite_audio_rate') setEliteAudioRate(s.value);
        if (s.key === 'tier_elite_video_rate') setEliteVideoRate(s.value);
      });
    } catch (err) {
      console.error('Failed to load settings:', err);
    }
  };

  useEffect(() => {
    loadSettings();
  }, []);

  const handleSaveAll = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setSuccessMessage(null);

    try {
      await Promise.all([
        api.updateSetting('platform_commission_pct', commissionPct),
        api.updateSetting('min_payout_amount', minPayout),
        api.updateTierRates('STANDARD', Number(standardAudioRate), Number(standardVideoRate), applyToExisting),
        api.updateTierRates('ELITE', Number(eliteAudioRate), Number(eliteVideoRate), applyToExisting),
      ]);

      setSuccessMessage('Tier tariffs & platform rules successfully updated in PostgreSQL database.');
      loadSettings();
    } catch (err: any) {
      alert(`Update failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="max-w-4xl space-y-6">
      {successMessage && (
        <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center gap-2 shadow-2xs">
          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
          <span>{successMessage}</span>
        </div>
      )}

      <form onSubmit={handleSaveAll} className="space-y-6">
        {/* Tier Pricing Card */}
        <div className="bg-white border border-slate-200 rounded-xl p-6 shadow-2xs space-y-6">
          <div className="border-b border-slate-100 pb-4 flex items-center justify-between">
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-base font-bold text-slate-900">Creator Tier Pricing & Universal Tariffs</h2>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                  Scalable Model
                </span>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Define standardized per-minute consultation rates for Standard Pro and Elite Expert creators. No need to set rates individually!
              </p>
            </div>
            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200">
              <Shield className="w-3.5 h-3.5" /> Auto-Syncs to Apps
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Standard Pro Tier */}
            <div className="rounded-xl border border-blue-100 bg-blue-50/30 p-5 space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="p-1.5 rounded-lg bg-blue-600 text-white shadow-2xs">
                    <Award className="w-4 h-4" />
                  </span>
                  <div>
                    <h3 className="text-sm font-bold text-slate-900">Standard Pro</h3>
                    <p className="text-[11px] text-slate-500">Regular verified consultation experts</p>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-md text-[10px] font-bold bg-blue-100 text-blue-700 border border-blue-200">
                  STANDARD
                </span>
              </div>

              <div className="space-y-3 pt-2">
                <div>
                  <label className="block text-xs font-medium text-slate-700 mb-1 flex items-center gap-1.5">
                    <Phone className="w-3.5 h-3.5 text-blue-600" />
                    <span>Voice Call Rate (₹ / min)</span>
                  </label>
                  <div className="relative">
                    <span className="absolute inset-y-0 left-3 flex items-center text-slate-400 font-semibold text-xs">₹</span>
                    <input
                      type="number"
                      min="1"
                      value={standardAudioRate}
                      onChange={(e) => setStandardAudioRate(e.target.value)}
                      required
                      className="w-full pl-7 pr-3 py-2 bg-white border border-slate-200 rounded-lg text-xs font-bold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-slate-700 mb-1 flex items-center gap-1.5">
                    <Video className="w-3.5 h-3.5 text-blue-600" />
                    <span>Video Call Rate (₹ / min)</span>
                  </label>
                  <div className="relative">
                    <span className="absolute inset-y-0 left-3 flex items-center text-slate-400 font-semibold text-xs">₹</span>
                    <input
                      type="number"
                      min="1"
                      value={standardVideoRate}
                      onChange={(e) => setStandardVideoRate(e.target.value)}
                      required
                      className="w-full pl-7 pr-3 py-2 bg-white border border-slate-200 rounded-lg text-xs font-bold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Elite Expert Tier */}
            <div className="rounded-xl border border-amber-200 bg-amber-50/40 p-5 space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="p-1.5 rounded-lg bg-amber-500 text-white shadow-2xs">
                    <Sparkles className="w-4 h-4" />
                  </span>
                  <div>
                    <h3 className="text-sm font-bold text-slate-900">Elite Expert</h3>
                    <p className="text-[11px] text-slate-500">Celebrity, senior & high-demand specialists</p>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-md text-[10px] font-bold bg-amber-100 text-amber-800 border border-amber-300">
                  👑 ELITE
                </span>
              </div>

              <div className="space-y-3 pt-2">
                <div>
                  <label className="block text-xs font-medium text-slate-700 mb-1 flex items-center gap-1.5">
                    <Phone className="w-3.5 h-3.5 text-amber-600" />
                    <span>Voice Call Rate (₹ / min)</span>
                  </label>
                  <div className="relative">
                    <span className="absolute inset-y-0 left-3 flex items-center text-slate-400 font-semibold text-xs">₹</span>
                    <input
                      type="number"
                      min="1"
                      value={eliteAudioRate}
                      onChange={(e) => setEliteAudioRate(e.target.value)}
                      required
                      className="w-full pl-7 pr-3 py-2 bg-white border border-slate-200 rounded-lg text-xs font-bold text-slate-900 focus:outline-none focus:ring-1 focus:ring-amber-500"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-medium text-slate-700 mb-1 flex items-center gap-1.5">
                    <Video className="w-3.5 h-3.5 text-amber-600" />
                    <span>Video Call Rate (₹ / min)</span>
                  </label>
                  <div className="relative">
                    <span className="absolute inset-y-0 left-3 flex items-center text-slate-400 font-semibold text-xs">₹</span>
                    <input
                      type="number"
                      min="1"
                      value={eliteVideoRate}
                      onChange={(e) => setEliteVideoRate(e.target.value)}
                      required
                      className="w-full pl-7 pr-3 py-2 bg-white border border-slate-200 rounded-lg text-xs font-bold text-slate-900 focus:outline-none focus:ring-1 focus:ring-amber-500"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Bulk Sync Option */}
          <div className="p-3.5 rounded-lg bg-slate-50 border border-slate-200 flex items-center gap-3">
            <input
              type="checkbox"
              id="bulkApply"
              checked={applyToExisting}
              onChange={(e) => setApplyToExisting(e.target.checked)}
              className="w-4 h-4 text-blue-600 rounded border-slate-300 focus:ring-blue-500"
            />
            <label htmlFor="bulkApply" className="text-xs text-slate-700 cursor-pointer">
              <span className="font-bold text-slate-900">Auto-update all existing creators</span>: When checked, saving new rates will instantly update every creator currently assigned to that tier.
            </label>
          </div>
        </div>

        {/* Platform Margin & Financial Rules */}
        <div className="bg-white border border-slate-200 rounded-xl p-6 shadow-2xs space-y-6">
          <div className="border-b border-slate-100 pb-4">
            <h2 className="text-base font-bold text-slate-900">Platform Commission & Payout Threshold</h2>
            <p className="text-xs text-slate-500 mt-0.5">
              Universal platform margin deduction and minimum creator withdrawal limits
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            <div className="space-y-1.5">
              <label className="block text-xs font-bold text-slate-800 uppercase tracking-wider">
                Platform Commission (%)
              </label>
              <div className="relative">
                <input
                  type="number"
                  min="0"
                  max="100"
                  value={commissionPct}
                  onChange={(e) => setCommissionPct(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
                <span className="absolute inset-y-0 right-3 flex items-center text-slate-400 font-bold text-sm">%</span>
              </div>
              <p className="text-[11px] text-slate-500">
                Platform retains {commissionPct}%. Creator receives {100 - Number(commissionPct || 0)}% of gross calls.
              </p>
            </div>

            <div className="space-y-1.5">
              <label className="block text-xs font-bold text-slate-800 uppercase tracking-wider">
                Min. Withdrawal Threshold (₹)
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-3 flex items-center text-slate-400 font-semibold text-sm">₹</span>
                <input
                  type="number"
                  min="100"
                  value={minPayout}
                  onChange={(e) => setMinPayout(e.target.value)}
                  required
                  className="w-full pl-7 pr-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              <p className="text-[11px] text-slate-500">
                Minimum wallet balance required for creator withdrawal requests.
              </p>
            </div>
          </div>

          <div className="pt-4 border-t border-slate-100 flex items-center justify-end">
            <button
              type="submit"
              disabled={isSaving}
              className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-lg shadow-sm flex items-center gap-2 transition-colors disabled:opacity-50"
            >
              {isSaving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
              Save All Platform Rules & Tariffs
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};
