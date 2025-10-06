import { useEffect, useState } from 'react';
import { fetchMemberDashboard } from '../lib/api';
import { Link } from 'react-router-dom';
import { formatDateMMDDYYYY } from '../lib/format';

export default function DashboardMember() {
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    fetchMemberDashboard().then(setData).catch(() => setData(null));
  }, []);

  if (!data) return <div className="p-6">Loading...</div>;

  return (
    <div className="p-6 max-w-5xl mx-auto">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-xl font-semibold">My Borrowed Books</h1>
        <Link to="/" className="text-blue-600">Home</Link>
      </div>
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
    </div>
  );
}


