import { useEffect, useState } from 'react';
import { fetchLibrarianDashboard } from '../lib/api';
import { Link } from 'react-router-dom';
import { formatDateMMDDYYYY } from '../lib/format';

export default function DashboardLibrarian() {
  const [tab, setTab] = useState<'borrowings' | 'stats'>('borrowings');
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    fetchLibrarianDashboard().then(setData).catch(() => setData(null));
  }, []);

  if (!data) return <div className="p-6">Loading...</div>;

  return (
    <div className="p-6 max-w-5xl mx-auto">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-xl font-semibold">Library Dashboard</h1>
        <Link to="/" className="text-blue-600">Home</Link>
      </div>
      
      <div className="flex gap-2 mb-4">
        <button className={`px-3 py-2 border rounded ${tab==='borrowings'?'bg-gray-100':''}`} onClick={() => setTab('borrowings')}>My Borrowings</button>
        <button className={`px-3 py-2 border rounded ${tab==='stats'?'bg-gray-100':''}`} onClick={() => setTab('stats')}>Library Stats</button>
      </div>

      {tab === 'borrowings' ? (
        <table className="w-full border text-sm">
          <thead className="bg-gray-100">
            <tr>
              <th className="p-2 border">Title</th>
              <th className="p-2 border">Due Date</th>
              <th className="p-2 border">Overdue</th>
            </tr>
          </thead>
          <tbody>
            {data.borrowings.map((bb: any) => (
              <tr key={bb.borrowing_id}>
                <td className="p-2 border">{bb.book.title}</td>
                <td className="p-2 border">{formatDateMMDDYYYY(bb.due_date)}</td>
                <td className="p-2 border">{bb.overdue ? 'Yes' : 'No'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : (
        <div className="space-y-4">
          <div className="grid grid-cols-3 gap-4 text-center">
            <div className="p-4 border rounded">
              <div className="text-sm text-gray-500">Total Books</div>
              <div className="text-2xl font-semibold">{data.total_books}</div>
            </div>
            <div className="p-4 border rounded">
              <div className="text-sm text-gray-500">Total Borrowed</div>
              <div className="text-2xl font-semibold">{data.total_borrowed}</div>
            </div>
            <div className="p-4 border rounded">
              <div className="text-sm text-gray-500">Due Today</div>
              <div className="text-2xl font-semibold">{data.books_due_today.length}</div>
            </div>
          </div>
          <h2 className="text-lg font-semibold">Books Due Today</h2>
          <table className="w-full border text-sm">
            <thead className="bg-gray-100">
              <tr>
                <th className="p-2 border">Book</th>
                <th className="p-2 border">User</th>
                <th className="p-2 border">Due Date</th>
              </tr>
            </thead>
            <tbody>
              {data.books_due_today.map((row: any, idx: number) => (
                <tr key={idx}>
                  <td className="p-2 border text-center">{row.book.title}</td>
                  <td className="p-2 border text-center">{row.borrowing.user.name} ({row.borrowing.user.email})</td>
                  <td className="p-2 border text-center">{formatDateMMDDYYYY(row.borrowing.due_date)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}


