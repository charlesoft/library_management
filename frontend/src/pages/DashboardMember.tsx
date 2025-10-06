import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { fetchMemberDashboard } from '../lib/api';
import { formatDateMMDDYYYY } from '../lib/format';

export default function DashboardMember() {
  const [data, setData] = useState<any>(null);
  const [tab, setTab] = useState<'all' | 'overdue'>('all');

  useEffect(() => {
    fetchMemberDashboard().then(setData).catch(() => setData(null));
  }, []);

  if (!data) return <div className="p-6">Loading...</div>;

  return (
    <div className="p-6 max-w-5xl mx-auto">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-xl font-semibold">My Borrowed Books</h1>
      </div>
      <div className="flex gap-2 mb-4">
        <button
          className={`px-3 py-2 border rounded ${tab==='all' ? 'bg-blue-600 text-white border-blue-600' : 'bg-white hover:bg-gray-50'}`}
          onClick={() => setTab('all')}
        >
          All Borrowings
        </button>
        <button
          className={`px-3 py-2 border rounded ${tab==='overdue' ? 'bg-red-600 text-white border-red-600' : 'bg-white hover:bg-gray-50'}`}
          onClick={() => setTab('overdue')}
        >
          Overdue books
        </button>
      </div>
      <table className="w-full border text-sm">
        <thead className="bg-gray-100">
          <tr>
            <th className="p-2 border">Title</th>
            <th className="p-2 border">Due Date</th>
            <th className="p-2 border">Returned At</th>
            {tab === 'all' && <th className="p-2 border">Overdue</th>}
          </tr>
        </thead>
        <tbody>
          {(tab === 'all' ? data.borrowings : data.overdue_borrowings).map((bb: any) => (
            <tr key={bb.borrowing_id}>
              <td className="p-2 border"><Link to={`/books/${bb.book.id}`} className="text-blue-600">{bb.book.title}</Link></td>
              <td className="p-2 border">{formatDateMMDDYYYY(bb.due_date)}</td>
              <td className="p-2 border">{bb.returned_date ? formatDateMMDDYYYY(bb.returned_date) : '-'}</td>
              {tab === 'all' && (
                <td className="p-2 border">{bb.overdue ? 'Yes' : 'No'}</td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}


