import React from 'react';
import { RefreshCw, Search, ShieldCheck, AlertCircle } from 'lucide-react';

interface HeaderProps {
  title: string;
  subtitle: string;
  onRefresh: () => void;
  isRefreshing: boolean;
  backendOnline?: boolean;
  searchQuery?: string;
  onSearchChange?: (val: string) => void;
  searchPlaceholder?: string;
}

export const Header: React.FC<HeaderProps> = ({
  title,
  subtitle,
  onRefresh,
  isRefreshing,
  backendOnline = true,
  searchQuery = '',
  onSearchChange,
  searchPlaceholder = 'Quick search records, ID, or phone...',
}) => {
  return (
    <header className="h-16 bg-white border-b border-slate-200 px-8 flex items-center justify-between sticky top-0 z-10 select-none">
      {/* Title & Breadcrumbs */}
      <div>
        <h1 className="text-base font-bold text-slate-900 leading-tight tracking-tight">
          {title}
        </h1>
        <p className="text-xs text-slate-500 mt-0.5">{subtitle}</p>
      </div>

      {/* Action Bar */}
      <div className="flex items-center gap-3">
        {/* Search Input (if applicable) */}
        {onSearchChange && (
          <div className="relative w-64">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
              <Search className="w-3.5 h-3.5" />
            </div>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => onSearchChange(e.target.value)}
              placeholder={searchPlaceholder}
              className="w-full pl-9 pr-3 py-1.5 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-1 focus:ring-blue-500 focus:bg-white transition-all"
            />
          </div>
        )}

        {/* Live Backend Status */}
        <div className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full border text-[11px] font-medium transition-colors ${
          backendOnline
            ? 'bg-emerald-50 border-emerald-200/80 text-emerald-800'
            : 'bg-rose-50 border-rose-200 text-rose-700'
        }`}>
          <span className={`w-2 h-2 rounded-full ${backendOnline ? 'bg-emerald-500 animate-pulse' : 'bg-rose-500'}`} />
          {backendOnline ? (
            <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
          ) : (
            <AlertCircle className="w-3.5 h-3.5 text-rose-600" />
          )}
          <span>{backendOnline ? 'Spring Boot 3 API' : 'Backend Offline'}</span>
        </div>

        {/* Refresh Button */}
        <button
          onClick={onRefresh}
          disabled={isRefreshing}
          title="Refresh Data from Server"
          className="p-1.5 text-slate-500 hover:text-slate-900 hover:bg-slate-100 rounded-lg border border-slate-200 transition-colors disabled:opacity-50"
        >
          <RefreshCw className={`w-4 h-4 ${isRefreshing ? 'animate-spin text-blue-600' : ''}`} />
        </button>
      </div>
    </header>
  );
};
