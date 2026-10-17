import React, { useState, useEffect } from 'react';
import { Percent, Save, CheckCircle2, Loader2, AlertCircle, Shield } from 'lucide-react';
import { PlatformSettingItem } from '../types';
import { api } from '../services/api';

export const CommissionPricing: React.FC = () => {
  const [settings, setSettings] = useState<PlatformSettingItem[]>([]);
  const [commissionPct, setCommissionPct] = useState<string>('20');
  const [minAudioRate, setMinAudioRate] = useState<string>('10');
  const [maxAudioRate, setMaxAudioRate] = useState<string>('500');
  const [minVideoRate, setMinVideoRate] = useState<string>('20');
  const [maxVideoRate, setMaxVideoRate] = useState<string>('1000');
  const [minPayout, setMinPayout] = useState<string>('500');
  const [isSaving, setIsSaving] = useState<boolean>(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const loadSettings = async () => {
    try {
      const data = await api.getSettings();
      setSettings(data);

      data.forEach((s) => {
        if (s.key === 'platform_commission_pct') setCommissionPct(s.value);
        if (s.key === 'min_audio_rate') setMinAudioRate(s.value);
        if (s.key === 'max_audio_rate') setMaxAudioRate(s.value);
        if (s.key === 'min_video_rate') setMinVideoRate(s.value);
        if (s.key === 'max_video_rate') setMaxVideoRate(s.value);
        if (s.key === 'min_payout_amount') setMinPayout(s.value);
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
        api.updateSetting('min_audio_rate', minAudioRate),
        api.updateSetting('max_audio_rate', maxAudioRate),
        api.updateSetting('min_video_rate', minVideoRate),
        api.updateSetting('max_video_rate', maxVideoRate),
        api.updateSetting('min_payout_amount', minPayout),
      ]);

      setSuccessMessage('Pricing rules & platform commission updated in database successfully.');
      loadSettings();
    } catch (err: any) {
      alert(`Update failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="max-w-3xl space-y-6">
      {successMessage && (
        <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
          <span>{successMessage}</span>
        </div>
      )}

      <form onSubmit={handleSaveAll} className="bg-white border border-slate-200 rounded-xl p-6 shadow-2xs space-y-6">
        <div className="border-b border-slate-100 pb-4 flex items-center justify-between">
          <div>
            <h2 className="text-base font-bold text-slate-900">Platform Commission & Billing Rules</h2>
            <p className="text-xs text-slate-500 mt-0.5">
              Configure universal margin percentages and creator tariff bounds
            </p>
          </div>
          <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200">
            <Shield className="w-3.5 h-3.5" /> Immutable Audit Logged
          </span>
        </div>

        {/* Platform Margin */}
        <div className="space-y-2">
          <label className="block text-xs font-bold text-slate-800 uppercase tracking-wider">
            Platform Retained Commission (%)
          </label>
          <div className="relative max-w-xs">
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
            Current margin: {commissionPct}%. The creator receives {100 - Number(commissionPct || 0)}% of the gross call tariff.
          </p>
        </div>

        {/* Audio Call Limits */}
        <div className="pt-4 border-t border-slate-100">
          <h3 className="text-xs font-bold text-slate-800 uppercase tracking-wider mb-3">
            Voice Call Tariff Bounds (₹ / min)
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs text-slate-600 mb-1 font-medium">Minimum Voice Rate</label>
              <input
                type="number"
                min="0"
                value={minAudioRate}
                onChange={(e) => setMinAudioRate(e.target.value)}
                className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-xs text-slate-600 mb-1 font-medium">Maximum Voice Rate</label>
              <input
                type="number"
                min="0"
                value={maxAudioRate}
                onChange={(e) => setMaxAudioRate(e.target.value)}
                className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>

        {/* Video Call Limits */}
        <div className="pt-4 border-t border-slate-100">
          <h3 className="text-xs font-bold text-slate-800 uppercase tracking-wider mb-3">
            Video Call Tariff Bounds (₹ / min)
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs text-slate-600 mb-1 font-medium">Minimum Video Rate</label>
              <input
                type="number"
                min="0"
                value={minVideoRate}
                onChange={(e) => setMinVideoRate(e.target.value)}
                className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-xs text-slate-600 mb-1 font-medium">Maximum Video Rate</label>
              <input
                type="number"
                min="0"
                value={maxVideoRate}
                onChange={(e) => setMaxVideoRate(e.target.value)}
                className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>

        {/* Withdrawal Minimum */}
        <div className="pt-4 border-t border-slate-100">
          <h3 className="text-xs font-bold text-slate-800 uppercase tracking-wider mb-3">
            Creator Withdrawal Threshold (₹)
          </h3>
          <div className="max-w-xs">
            <input
              type="number"
              min="100"
              value={minPayout}
              onChange={(e) => setMinPayout(e.target.value)}
              className="w-full px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs font-semibold text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
            <p className="text-[11px] text-slate-500 mt-1">
              Minimum wallet balance required before a creator can submit a payout request.
            </p>
          </div>
        </div>

        <div className="pt-4 border-t border-slate-100 flex items-center justify-end">
          <button
            type="submit"
            disabled={isSaving}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg shadow-2xs flex items-center gap-1.5 transition-colors disabled:opacity-50"
          >
            {isSaving ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Save className="w-3.5 h-3.5" />}
            Save Platform Rules
          </button>
        </div>
      </form>
    </div>
  );
};
