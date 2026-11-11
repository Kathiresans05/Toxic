import React, { useState, useRef } from 'react';
import {
  FileCheck2,
  CheckCircle2,
  XCircle,
  Eye,
  AlertTriangle,
  Loader2,
  ExternalLink,
  Mic,
  Play,
  Pause,
  Volume2,
} from 'lucide-react';
import { KycItem } from '../types';

interface KycQueueProps {
  kycList: KycItem[];
  onReviewKyc: (kycId: string, approved: boolean, reason?: string) => Promise<void>;
}

export const KycQueue: React.FC<KycQueueProps> = ({ kycList, onReviewKyc }) => {
  const [selectedKyc, setSelectedKyc] = useState<KycItem | null>(null);
  const [previewDocUrl, setPreviewDocUrl] = useState<string | null>(null);
  const [previewVoiceKyc, setPreviewVoiceKyc] = useState<KycItem | null>(null);
  const [isPlayingAudio, setIsPlayingAudio] = useState<boolean>(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [isRejectModalOpen, setIsRejectModalOpen] = useState<boolean>(false);
  const [rejectionReason, setRejectionReason] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  const toggleAudio = () => {
    if (!audioRef.current) return;
    if (isPlayingAudio) {
      audioRef.current.pause();
      setIsPlayingAudio(false);
    } else {
      audioRef.current
        .play()
        .then(() => setIsPlayingAudio(true))
        .catch(() => setIsPlayingAudio(false));
    }
  };

  const handleApprove = async (kycId: string) => {
    setIsSubmitting(true);
    try {
      await onReviewKyc(kycId, true);
      setSelectedKyc(null);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleRejectSubmit = async () => {
    if (!selectedKyc || !rejectionReason.trim()) return;
    setIsSubmitting(true);
    try {
      await onReviewKyc(selectedKyc.id, false, rejectionReason.trim());
      setIsRejectModalOpen(false);
      setSelectedKyc(null);
      setRejectionReason('');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-4">
      {/* Table of pending KYCs */}
      <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-2xs">
        <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between">
          <div>
            <h2 className="text-sm font-bold text-slate-900">Creator KYC Verification Queue</h2>
            <p className="text-xs text-slate-500">
              Government identity documents pending review in PostgreSQL
            </p>
          </div>
          <span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
            {kycList.length} Pending
          </span>
        </div>

        {kycList.length === 0 ? (
          <div className="p-12 text-center">
            <div className="w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 mx-auto flex items-center justify-center mb-3">
              <CheckCircle2 className="w-6 h-6" />
            </div>
            <h3 className="text-sm font-semibold text-slate-800">KYC verification queue is clear</h3>
            <p className="text-xs text-slate-500 mt-1 max-w-sm mx-auto">
              All submitted creator credentials have been audited. New KYC submissions will appear here automatically.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-50/80 border-b border-slate-200 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Creator Details</th>
                  <th className="py-3 px-6">Document Type</th>
                  <th className="py-3 px-6">Document ID</th>
                  <th className="py-3 px-6">Submitted Date</th>
                  <th className="py-3 px-6">Review Documents & Voice Audit</th>
                  <th className="py-3 px-6 text-right">Verification Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-700">
                {kycList.map((kyc) => (
                  <tr key={kyc.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-3.5 px-6">
                      <div className="font-semibold text-slate-900">{kyc.expertName}</div>
                      <div className="text-[11px] text-slate-400">{kyc.expertHeadline}</div>
                    </td>
                    <td className="py-3.5 px-6">
                      <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-100 text-slate-700 border border-slate-200">
                        {kyc.idType}
                      </span>
                    </td>
                    <td className="py-3.5 px-6 font-mono font-medium text-slate-900">
                      {kyc.idNumber}
                    </td>
                    <td className="py-3.5 px-6 text-slate-400">
                      {kyc.createdAt}
                    </td>
                    <td className="py-3.5 px-6">
                      <div className="flex items-center gap-2">
                        {kyc.documentFrontUrl && (
                          <button
                            onClick={() => setPreviewDocUrl(kyc.documentFrontUrl)}
                            className="px-2 py-1 rounded text-[11px] font-medium bg-blue-50 text-blue-700 hover:bg-blue-100 flex items-center gap-1 border border-blue-200"
                          >
                            <Eye className="w-3 h-3" /> Front
                          </button>
                        )}
                        {kyc.documentBackUrl && (
                          <button
                            onClick={() => setPreviewDocUrl(kyc.documentBackUrl!)}
                            className="px-2 py-1 rounded text-[11px] font-medium bg-slate-50 text-slate-700 hover:bg-slate-100 flex items-center gap-1 border border-slate-200"
                          >
                            <Eye className="w-3 h-3" /> Back
                          </button>
                        )}
                        {kyc.selfieUrl && (
                          <button
                            onClick={() => setPreviewDocUrl(kyc.selfieUrl!)}
                            className="px-2 py-1 rounded text-[11px] font-medium bg-purple-50 text-purple-700 hover:bg-purple-100 flex items-center gap-1 border border-purple-200"
                          >
                            <Eye className="w-3 h-3" /> Selfie
                          </button>
                        )}
                        <button
                          onClick={() => {
                            setPreviewVoiceKyc(kyc);
                            setIsPlayingAudio(false);
                          }}
                          className="px-2 py-1 rounded text-[11px] font-semibold bg-amber-50 text-amber-800 hover:bg-amber-100 flex items-center gap-1 border border-amber-300"
                          title="Listen to Voice Sample to verify female creator identity"
                        >
                          <Mic className="w-3 h-3 text-amber-600" /> Voice Check
                        </button>
                      </div>
                    </td>
                    <td className="py-3.5 px-6 text-right space-x-1.5 whitespace-nowrap">
                      <button
                        onClick={() => {
                          setSelectedKyc(kyc);
                          setIsRejectModalOpen(true);
                        }}
                        disabled={isSubmitting}
                        className="px-2.5 py-1 rounded text-xs font-semibold text-rose-600 hover:bg-rose-50 border border-rose-200"
                      >
                        Reject
                      </button>
                      <button
                        onClick={() => handleApprove(kyc.id)}
                        disabled={isSubmitting}
                        className="px-3 py-1 rounded text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-2xs"
                      >
                        Approve
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Document Image Zoom Modal */}
      {previewDocUrl && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-slate-200 rounded-xl max-w-2xl w-full p-4 shadow-2xl">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-3">
              <h3 className="text-sm font-bold text-slate-900">Identity Document Preview</h3>
              <button
                onClick={() => setPreviewDocUrl(null)}
                className="text-slate-400 hover:text-slate-700 text-sm font-bold px-2 py-1"
              >
                ✕ Close
              </button>
            </div>
            <div className="bg-slate-100 rounded-lg p-2 max-h-[70vh] flex items-center justify-center overflow-hidden">
              <img
                src={previewDocUrl}
                alt="KYC Document Preview"
                className="max-h-[65vh] object-contain rounded"
                onError={(e) => {
                  (e.target as any).src = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=800';
                }}
              />
            </div>
          </div>
        </div>
      )}

      {/* Voice Verification & Gender Identification Modal */}
      {previewVoiceKyc && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-slate-200 rounded-2xl max-w-lg w-full p-6 shadow-2xl animate-in fade-in duration-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100 mb-4">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center">
                  <Mic className="w-5 h-5 text-amber-600" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900">Voice Verification Audit</h3>
                  <p className="text-[11px] text-slate-500">{previewVoiceKyc.expertName} • Female Identity Audit</p>
                </div>
              </div>
              <button
                onClick={() => {
                  if (audioRef.current) audioRef.current.pause();
                  setPreviewVoiceKyc(null);
                  setIsPlayingAudio(false);
                }}
                className="text-slate-400 hover:text-slate-700 text-sm font-bold px-2 py-1"
              >
                ✕ Close
              </button>
            </div>

            <div className="bg-amber-50/70 border border-amber-200 rounded-xl p-3.5 mb-5 flex items-start gap-2.5">
              <div className="text-amber-600 font-bold text-base leading-none mt-0.5">⚠️</div>
              <p className="text-xs text-amber-900 leading-relaxed font-medium">
                <strong>Female Creator Verification Protocol:</strong> Listen to this audio recording submitted during KYC to confirm the creator's voice is authentic and female before approving.
              </p>
            </div>

            {/* Audio Waveform Player */}
            <div className="bg-slate-950 rounded-2xl p-6 mb-6 text-white flex flex-col items-center shadow-inner">
              <audio
                ref={audioRef}
                src={previewVoiceKyc.voiceSampleUrl || 'https://actions.google.com/sounds/v1/speech/female_voice_hello.ogg'}
                onEnded={() => setIsPlayingAudio(false)}
                onPause={() => setIsPlayingAudio(false)}
                onPlay={() => setIsPlayingAudio(true)}
                className="hidden"
              />
              <div className="flex items-center gap-1.5 h-14 mb-4">
                {[14, 26, 42, 22, 38, 50, 28, 40, 16, 34, 46, 24, 38, 16, 28, 36, 20].map((h, idx) => (
                  <div
                    key={idx}
                    className={`w-1 rounded-full transition-all duration-300 ${
                      isPlayingAudio ? 'bg-amber-400 animate-pulse' : 'bg-slate-700'
                    }`}
                    style={{ height: isPlayingAudio ? `${h}px` : '12px' }}
                  />
                ))}
              </div>
              <button
                onClick={toggleAudio}
                className="flex items-center gap-2.5 px-6 py-2.5 rounded-full bg-amber-400 hover:bg-amber-300 text-slate-950 font-bold text-xs shadow-md transition-all active:scale-95"
              >
                {isPlayingAudio ? (
                  <>
                    <Pause className="w-4 h-4 fill-slate-950" /> Pause Voice Sample
                  </>
                ) : (
                  <>
                    <Play className="w-4 h-4 fill-slate-950" /> Play Voice Sample (0:15s)
                  </>
                )}
              </button>
              <div className="flex items-center gap-2 mt-3 text-[11px] text-slate-400 font-medium">
                <Volume2 className="w-3.5 h-3.5 text-amber-400" />
                <span>Submitted KYC Audio • Verify Voice Tone</span>
              </div>
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-slate-100 gap-3">
              <button
                onClick={() => {
                  if (audioRef.current) audioRef.current.pause();
                  setSelectedKyc(previewVoiceKyc);
                  setRejectionReason('Voice verification failed: Voice note does not verify as female creator identity.');
                  setPreviewVoiceKyc(null);
                  setIsPlayingAudio(false);
                  setIsRejectModalOpen(true);
                }}
                className="px-3 py-2 rounded-xl text-xs font-semibold text-rose-600 hover:bg-rose-50 border border-rose-200 transition-colors"
              >
                Reject (Voice Mismatch)
              </button>
              <button
                onClick={() => {
                  if (audioRef.current) audioRef.current.pause();
                  const id = previewVoiceKyc.id;
                  setPreviewVoiceKyc(null);
                  setIsPlayingAudio(false);
                  handleApprove(id);
                }}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs flex items-center gap-1.5 transition-colors"
              >
                <CheckCircle2 className="w-4 h-4" /> Approve (Verified Female)
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Rejection Reason Modal */}
      {isRejectModalOpen && selectedKyc && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white border border-slate-200 rounded-xl max-w-md w-full p-6 shadow-xl">
            <div className="flex items-center gap-3 text-slate-900 mb-3">
              <div className="w-10 h-10 rounded-full bg-rose-50 text-rose-600 flex items-center justify-center">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold">Reject Verification</h3>
                <p className="text-xs text-slate-500">{selectedKyc.expertName}</p>
              </div>
            </div>

            <p className="text-xs text-slate-600 mb-3">
              Please specify the precise rationale for rejecting this creator's KYC document. This reason will be recorded securely and notified to the creator.
            </p>

            <textarea
              rows={3}
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
              placeholder="e.g. Document image is blurry / name mismatch with bank profile..."
              className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 focus:outline-none focus:ring-1 focus:ring-rose-500 mb-4"
            />

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
              <button
                onClick={() => {
                  setIsRejectModalOpen(false);
                  setSelectedKyc(null);
                  setRejectionReason('');
                }}
                disabled={isSubmitting}
                className="px-3 py-1.5 rounded-lg text-xs font-medium text-slate-600 hover:bg-slate-100"
              >
                Cancel
              </button>
              <button
                onClick={handleRejectSubmit}
                disabled={isSubmitting || !rejectionReason.trim()}
                className="px-3.5 py-1.5 rounded-lg text-xs font-semibold bg-rose-600 hover:bg-rose-700 text-white shadow-xs flex items-center gap-1.5 disabled:opacity-50"
              >
                {isSubmitting && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                Confirm Rejection
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
