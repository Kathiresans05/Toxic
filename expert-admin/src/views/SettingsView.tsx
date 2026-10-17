import React, { useState, useEffect } from 'react';
import { Settings, Save, CheckCircle2, Shield, Database, Radio, Bell } from 'lucide-react';
import { PlatformSettingItem } from '../types';
import { api } from '../services/api';

export const SettingsView: React.FC = () => {
  const [settings, setSettings] = useState<PlatformSettingItem[]>([]);
  const [supportEmail, setSupportEmail] = useState<string>('support@expertapp.com');
  const [autoApproveKyc, setAutoApproveKyc] = useState<boolean>(false);
  const [isSaving, setIsSaving] = useState<boolean>(false);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  const loadSettings = async () => {
    try {
      const data = await api.getSettings();
      setSettings(data);
      data.forEach((s) => {
        if (s.key === 'support_email') setSupportEmail(s.value);
        if (s.key === 'auto_approve_kyc') setAutoApproveKyc(s.value === 'true');
      });
    } catch (err) {
      console.error('Failed to load settings:', err);
    }
  };

  useEffect(() => {
    loadSettings();
  }, []);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSaving(true);
    setSuccessMsg(null);

    try {
      await Promise.all([
        api.updateSetting('support_email', supportEmail),
        api.updateSetting('auto_approve_kyc', String(autoApproveKyc)),
      ]);
      setSuccessMsg('Platform settings saved successfully.');
      loadSettings();
    } catch (err: any) {
      alert(`Save failed: ${err.message || 'Unknown error'}`);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="max-w-3xl space-y-6">
      {successMsg && (
        <div className="p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* General Platform Settings Form */}
      <form onSubmit={handleSave} className="bg-white border border-slate-200 rounded-xl p-6 shadow-2xs space-y-6">
        <div className="border-b border-slate-100 pb-4">
          <h2 className="text-base font-bold text-slate-900">Platform Configuration & Compliance</h2>
          <p className="text-xs text-slate-500 mt-0.5">Global operational defaults for ExpertApp</p>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-700 mb-1">
              Public Support & Billing Email
            </label>
            <input
              type="email"
              value={supportEmail}
              onChange={(e) => setSupportEmail(e.target.value)}
              className="w-full max-w-md px-3.5 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
            <p className="text-[11px] text-slate-400 mt-1">Displayed in mobile apps for customer invoices & dispute inquiries.</p>
          </div>

          <div className="pt-4 border-t border-slate-100">
            <h3 className="text-xs font-bold text-slate-800 uppercase tracking-wider mb-2">
              Creator Verification Policy
            </h3>
            <label className="flex items-start gap-3 cursor-pointer p-3 rounded-lg border border-slate-200 hover:bg-slate-50/50">
              <input
                type="checkbox"
                checked={autoApproveKyc}
                onChange={(e) => setAutoApproveKyc(e.target.checked)}
                className="mt-0.5 h-4 w-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500"
              />
              <div>
                <div className="text-xs font-semibold text-slate-900">Automatic KYC Document Approval</div>
                <div className="text-[11px] text-slate-500 leading-relaxed">
                  When enabled, creators can begin accepting voice and video consultations immediately upon document upload without manual admin sign-off. (Recommended disabled for compliance).
                </div>
              </div>
            </label>
          </div>
        </div>

        <div className="pt-4 border-t border-slate-100 flex items-center justify-end">
          <button
            type="submit"
            disabled={isSaving}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg shadow-2xs flex items-center gap-1.5 transition-colors disabled:opacity-50"
          >
            <Save className="w-3.5 h-3.5" />
            Save Configuration
          </button>
        </div>
      </form>

      {/* Infrastructure Telemetry Info */}
      <div className="bg-white border border-slate-200 rounded-xl p-6 shadow-2xs space-y-4">
        <h3 className="text-sm font-bold text-slate-900 border-b border-slate-100 pb-3 flex items-center gap-2">
          <Database className="w-4 h-4 text-blue-600" /> Infrastructure & Telemetry Stack
        </h3>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
          <div className="p-3 rounded-lg bg-slate-50 border border-slate-200">
            <span className="text-slate-500 block">Primary Database</span>
            <span className="font-semibold text-slate-900 font-mono">PostgreSQL 18 (expert_db)</span>
          </div>

          <div className="p-3 rounded-lg bg-slate-50 border border-slate-200">
            <span className="text-slate-500 block">Backend Framework</span>
            <span className="font-semibold text-slate-900 font-mono">Spring Boot 3.2.4 + Java 17</span>
          </div>

          <div className="p-3 rounded-lg bg-slate-50 border border-slate-200">
            <span className="text-slate-500 block">RTC Audio/Video Provider</span>
            <span className="font-semibold text-slate-900 font-mono">Agora RTC Engine (agora_token)</span>
          </div>

          <div className="p-3 rounded-lg bg-slate-50 border border-slate-200">
            <span className="text-slate-500 block">Payment Gateways</span>
            <span className="font-semibold text-slate-900 font-mono">Razorpay & Cashfree Webhooks</span>
          </div>
        </div>
      </div>
    </div>
  );
};
