'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import { formatCurrency, formatDate } from '@/lib/utils';
import { financialService } from '@/lib/services';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

type TabType = 'overview' | 'transactions';

export default function PaymentsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('overview');
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalRevenue: 0,
    pendingAmount: 0,
    studentCount: 0,
    courseCount: 0,
  });
  const [transactions, setTransactions] = useState<any[]>([]);
  const [filter, setFilter] = useState<'all' | 'pending' | 'completed' | 'failed'>('all');

  useEffect(() => {
    async function fetchData() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      try {
        const statsData = await financialService.getProviderStats(user.id);
        setStats(statsData);
      } catch (e) {
        console.error('Error fetching stats:', e);
      }

      try {
        const transactionsData = await financialService.getTransactionHistory(user.id, 100);
        setTransactions(transactionsData);
      } catch (e) {
        console.error('Error fetching transactions:', e);
      }

      setLoading(false);
    }

    fetchData();
  }, []);

  const handleVerify = async (paymentId: string, status: 'completed' | 'failed', rejectionReason?: string) => {
    const { data: { user } } = await supabase.auth.getUser();
    
    const { error } = await supabase
      .from('payments')
      .update({
        status,
        verified_by: user?.id,
        verified_at: new Date().toISOString(),
        rejection_reason: rejectionReason,
      })
      .eq('id', paymentId);

    if (!error) {
      setTransactions(transactions.map(p => 
        p.id === paymentId ? { ...p, status, verified_at: new Date().toISOString() } : p
      ));
      
      if (status === 'completed') {
        const tx = transactions.find(p => p.id === paymentId);
        if (tx) {
          setStats({
            ...stats,
            totalRevenue: stats.totalRevenue + tx.amount,
            pendingAmount: stats.pendingAmount - tx.amount,
          });
        }
      }
    }
  };

  const filteredTransactions = filter === 'all' 
    ? transactions 
    : transactions.filter(p => p.status === filter);

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'pending':
        return <span className="badge-warning">معلق</span>;
      case 'completed':
        return <span className="badge-success">مكتمل</span>;
      case 'failed':
        return <span className="badge-danger">مرفوض</span>;
      case 'refunded':
        return <span className="badge-info">مسترد</span>;
      default:
        return <span className="badge-default">{status}</span>;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">المدفوعات والأرباح</h1>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="card p-4">
          <p className="text-sm text-gray-500">إجمالي الأرباح</p>
          <p className="text-2xl font-bold text-green-600">{formatCurrency(stats.totalRevenue)}</p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-gray-500">المعلق</p>
          <p className="text-2xl font-bold text-yellow-600">{formatCurrency(stats.pendingAmount)}</p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-gray-500">عدد الطلاب</p>
          <p className="text-2xl font-bold text-gray-900">{stats.studentCount}</p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-gray-500">عدد الكورسات</p>
          <p className="text-2xl font-bold text-gray-900">{stats.courseCount}</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 mb-4 border-b border-gray-200">
        <button
          onClick={() => setActiveTab('overview')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'overview'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          نظرة عامة
        </button>
        <button
          onClick={() => setActiveTab('transactions')}
          className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${
            activeTab === 'transactions'
              ? 'border-primary-600 text-primary-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          العمليات
        </button>
      </div>

      {/* Transactions Tab */}
      {activeTab === 'transactions' && (
        <>
          <div className="flex gap-2 mb-4">
            <button
              onClick={() => setFilter('all')}
              className={`btn ${filter === 'all' ? 'btn-primary' : 'btn-secondary'} btn-sm`}
            >
              الكل ({transactions.length})
            </button>
            <button
              onClick={() => setFilter('pending')}
              className={`btn ${filter === 'pending' ? 'btn-primary' : 'btn-secondary'} btn-sm`}
            >
              المعلق ({transactions.filter(p => p.status === 'pending').length})
            </button>
            <button
              onClick={() => setFilter('completed')}
              className={`btn ${filter === 'completed' ? 'btn-primary' : 'btn-secondary'} btn-sm`}
            >
              المكتمل ({transactions.filter(p => p.status === 'completed').length})
            </button>
          </div>

          {filteredTransactions.length === 0 ? (
            <div className="card p-12 text-center">
              <p className="text-gray-500">لا توجد عمليات</p>
            </div>
          ) : (
            <div className="card">
              <div className="table-container">
                <table className="table">
                  <thead>
                    <tr>
                      <th>الطالب</th>
                      <th>الكورس</th>
                      <th>المبلغ</th>
                      <th>الطريقة</th>
                      <th>الحالة</th>
                      <th>التاريخ</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredTransactions.map(payment => (
                      <tr key={payment.id}>
                        <td>{payment.student?.full_name || payment.student_name || 'غير محدد'}</td>
                        <td>{payment.course?.title || payment.course_name || 'غير محدد'}</td>
                        <td className="font-medium">
                          {formatCurrency(payment.amount, payment.currency)}
                        </td>
                        <td>
                          {payment.payment_method === 'bankTransfer' ? 'تحويل بنكي' : 'محفظة'}
                        </td>
                        <td>{getStatusBadge(payment.status)}</td>
                        <td>{formatDate(payment.created_at)}</td>
                        <td>
                          {payment.status === 'pending' && (
                            <div className="flex gap-2">
                              <button
                                onClick={() => handleVerify(payment.id, 'completed')}
                                className="btn-success btn-sm"
                              >
                                تأكيد
                              </button>
                              <button
                                onClick={() => handleVerify(payment.id, 'failed', 'تم رفض الدفع')}
                                className="btn-danger btn-sm"
                              >
                                رفض
                              </button>
                            </div>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}