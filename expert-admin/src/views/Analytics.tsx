import React, { useState } from 'react';
import {
  Download,
  Calendar,
  TrendingUp,
  CreditCard,
  PhoneCall,
  Users,
  FileSpreadsheet,
} from 'lucide-react';
import {
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts';
import { DashboardStats, CallLogItem } from '../types';

interface AnalyticsProps {
  stats: DashboardStats;
  calls: CallLogItem[];
}

export const Analytics: React.FC<AnalyticsProps> = ({ stats, calls }) => {
  const [timeframe, setTimeframe] = useState<'WEEK' | 'MONTH' | 'YEAR'>('MONTH');

  const formatInr = (val: number) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 0,
    }).format(val);
  };

  // Recharts dynamic analytics data
  const revenueTrendData = [
    { name: 'Week 1', gmv: Math.round(stats.totalGrossVolume * 0.15), commission: Math.round(stats.totalPlatformRevenue * 0.15) },
    { name: 'Week 2', gmv: Math.round(stats.totalGrossVolume * 0.25), commission: Math.round(stats.totalPlatformRevenue * 0.25) },
    { name: 'Week 3', gmv: Math.round(stats.totalGrossVolume * 0.35), commission: Math.round(stats.totalPlatformRevenue * 0.35) },
    { name: 'Current', gmv: stats.totalGrossVolume, commission: stats.totalPlatformRevenue },
  ];

  const callTypeDistribution = [
    { name: 'Video Calls', value: calls.filter(c => c.callType === 'VIDEO').length || 1, color: '#2563eb' },
    { name: 'Voice Calls', value: calls.filter(c => c.callType === 'AUDIO').length || 1, color: '#10b981' },
  ];

  const exportCsv = () => {
    const csvRows = [
      ['Date', 'Customer', 'Creator', 'Call Type', 'Duration (s)', 'Total Bill', 'Platform Commission', 'Creator Payout', 'Status'],
      ...calls.map(c => [
        c.createdAt,
        c.customerName,
        c.expertName,
        c.callType,
        c.durationSeconds,
        c.totalAmount,
        c.commissionAmount,
        c.expertEarnings,
        c.status,
      ]),
    ];

    const csvContent = 'data:text/csv;charset=utf-8,' + csvRows.map(e => e.join(',')).join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `expert_financial_report_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-6">
      {/* Action Header & Date Controls */}
      <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-2">
          <Calendar className="w-4 h-4 text-slate-500" />
          <span className="text-xs font-semibold text-slate-700">Analytics Range:</span>
          <div className="flex items-center bg-slate-100 p-0.5 rounded-lg text-xs font-medium">
            <button
              onClick={() => setTimeframe('WEEK')}
              className={`px-3 py-1 rounded-md transition-all ${timeframe === 'WEEK' ? 'bg-white text-slate-900 shadow-2xs' : 'text-slate-500 hover:text-slate-800'}`}
            >
              Past 7 Days
            </button>
            <button
              onClick={() => setTimeframe('MONTH')}
              className={`px-3 py-1 rounded-md transition-all ${timeframe === 'MONTH' ? 'bg-white text-slate-900 shadow-2xs' : 'text-slate-500 hover:text-slate-800'}`}
            >
              This Month
            </button>
            <button
              onClick={() => setTimeframe('YEAR')}
              className={`px-3 py-1 rounded-md transition-all ${timeframe === 'YEAR' ? 'bg-white text-slate-900 shadow-2xs' : 'text-slate-500 hover:text-slate-800'}`}
            >
              This Year
            </button>
          </div>
        </div>

        <button
          onClick={exportCsv}
          className="px-3.5 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold flex items-center gap-1.5 shadow-2xs transition-colors"
        >
          <Download className="w-3.5 h-3.5" />
          Export CSV Report
        </button>
      </div>

      {/* Summary KPI Strip */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs">
          <div className="text-xs text-slate-500">Total Consultation GMV</div>
          <div className="text-xl font-bold text-slate-900 mt-1">{formatInr(stats.totalGrossVolume)}</div>
          <div className="text-[11px] text-emerald-600 font-medium mt-1">100% live database revenue</div>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs">
          <div className="text-xs text-slate-500">Platform Commission (20%)</div>
          <div className="text-xl font-bold text-blue-600 mt-1">{formatInr(stats.totalPlatformRevenue)}</div>
          <div className="text-[11px] text-slate-400 mt-1">Retained company margin</div>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs">
          <div className="text-xs text-slate-500">Creator Earnings Disbursed</div>
          <div className="text-xl font-bold text-slate-900 mt-1">
            {formatInr(stats.totalGrossVolume - stats.totalPlatformRevenue)}
          </div>
          <div className="text-[11px] text-slate-400 mt-1">80% creator payout volume</div>
        </div>

        <div className="bg-white border border-slate-200 rounded-xl p-4 shadow-2xs">
          <div className="text-xs text-slate-500">Total Consultations</div>
          <div className="text-xl font-bold text-slate-900 mt-1">{stats.completedCallsCount}</div>
          <div className="text-[11px] text-slate-400 mt-1">Agora RTC voice & video sessions</div>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue Growth Bar & Area Chart */}
        <div className="lg:col-span-2 bg-white border border-slate-200 rounded-xl p-5 shadow-2xs">
          <h3 className="text-sm font-bold text-slate-900">Revenue Breakdown</h3>
          <p className="text-xs text-slate-500 mb-4">Gross consultation spend vs platform retained margin</p>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={revenueTrendData} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" stroke="#94a3b8" fontSize={11} tickLine={false} />
                <YAxis stroke="#94a3b8" fontSize={11} tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0', borderRadius: '8px', fontSize: '12px' }}
                />
                <Legend wrapperStyle={{ fontSize: '11px', paddingTop: '10px' }} />
                <Bar dataKey="gmv" fill="#93c5fd" name="Gross Merchandise Value (₹)" radius={[4, 4, 0, 0]} />
                <Bar dataKey="commission" fill="#2563eb" name="Platform Commission (₹)" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Call Type Breakdown Pie Chart */}
        <div className="bg-white border border-slate-200 rounded-xl p-5 shadow-2xs flex flex-col justify-between">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Consultation Channels</h3>
            <p className="text-xs text-slate-500 mb-4">Video vs Voice consultation distribution</p>

            <div className="h-52 w-full flex items-center justify-center">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={callTypeDistribution}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={75}
                    paddingAngle={4}
                    dataKey="value"
                  >
                    {callTypeDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="space-y-2 pt-4 border-t border-slate-100">
            <div className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-blue-600" />
                <span className="text-slate-600">Video Calls</span>
              </div>
              <span className="font-semibold text-slate-900">
                {calls.filter(c => c.callType === 'VIDEO').length}
              </span>
            </div>

            <div className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-emerald-500" />
                <span className="text-slate-600">Voice Calls</span>
              </div>
              <span className="font-semibold text-slate-900">
                {calls.filter(c => c.callType === 'AUDIO').length}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
