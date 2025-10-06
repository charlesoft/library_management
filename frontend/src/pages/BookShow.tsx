import { useEffect, useState } from 'react';
import { createBorrowing, fetchBook, returnBorrowing, type BookBorrowing } from '../lib/api';
import { useNavigate, useParams } from 'react-router-dom';
import { formatDateMMDDYYYY } from '../lib/format';

export default function BookShow() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [book, setBook] = useState<any>(null);
  const [borrowings, setBorrowings] = useState<BookBorrowing[]>([]);
  const [currentUserHasActiveBorrowing, setCurrentUserHasActiveBorrowing] = useState(false);
  const [open, setOpen] = useState(false);
  const [dueDate, setDueDate] = useState('');
  const isLoggedIn = Boolean(localStorage.getItem('jwt'));
  const isLibrarian = localStorage.getItem('currentUserRoleId') === '1' || localStorage.getItem('currentUserRole') === 'librarian';

  useEffect(() => {
    if (!id) return;
    fetchBook(Number(id)).then((res) => {
      setBook(res.data.book);
      setBorrowings(res.data.book_borrowings || []);
      setCurrentUserHasActiveBorrowing(Boolean(res.data.current_user_has_active_borrowing));
    }).catch(() => { setBook(null); setBorrowings([]); setCurrentUserHasActiveBorrowing(false); });
  }, [id]);

  async function onBorrow() {
    if (!id) return;
    const res = await createBorrowing(Number(id), dueDate);
    if (res.ok) {
      setOpen(false);
      // refresh book details and borrowings
      const refreshed = await fetchBook(Number(id));
      setBook(refreshed.data.book);
      setBorrowings(refreshed.data.book_borrowings || []);
      setCurrentUserHasActiveBorrowing(Boolean(refreshed.data.current_user_has_active_borrowing));
    }
  }

  async function onReturn(borrowing: BookBorrowing) {
    if (!isLibrarian) return;
    const res = await returnBorrowing(borrowing.id);
    if (res.ok) {
      setBorrowings(prev => prev.map(b => b.id === borrowing.id ? { ...b, returned_date: new Date().toISOString().slice(0,10) } : b));
    }
  }

  if (!book) return <div className="p-6">Loading...</div>;

  return (
    <div className="p-6 max-w-3xl mx-auto">
      <button className="mb-4 text-blue-600" onClick={() => navigate(-1)}>&larr; Back</button>
      <h1 className="text-2xl font-semibold mb-2">{book.title}</h1>
      <div className="grid grid-cols-2 gap-4 text-sm">
        <div><span className="font-medium">Author:</span> {book.author}</div>
        <div><span className="font-medium">Genre:</span> {book.genre}</div>
        <div><span className="font-medium">ISBN:</span> {book.isbn}</div>
        <div><span className="font-medium">Total copies:</span> {book.total_copies}</div>
        <div><span className="font-medium">Available:</span> {book.available ? 'Yes' : 'No'}</div>
      </div>

      {isLoggedIn && (
        <div className="mt-6">
          <button
            className="px-3 py-2 bg-blue-600 text-white rounded disabled:opacity-50"
            onClick={() => setOpen(true)}
            disabled={currentUserHasActiveBorrowing}
          >
            Borrow
          </button>
        </div>
      )}

      <div className="mt-8">
        <h2 className="text-lg font-semibold mb-2">Borrowings</h2>
        <table className="w-full border text-sm">
          <thead className="bg-gray-100">
            <tr>
              {isLibrarian && <th className="p-2 border">User</th>}
              <th className="p-2 border">Borrowed</th>
              <th className="p-2 border">Due</th>
              <th className="p-2 border">Returned</th>
              {isLibrarian && <th className="p-2 border">Actions</th>}
            </tr>
          </thead>
          <tbody>
            {borrowings.map((bb) => {
              const isReturned = Boolean(bb.returned_date);
              return (
                <tr key={bb.id} className={isReturned ? 'bg-green-50' : ''}>
                  {isLibrarian && (
                    <td className="p-2 border text-center">{bb.user_name || '-'}</td>
                  )}
                  <td className="p-2 border text-center">{formatDateMMDDYYYY(bb.borrowing_date)}</td>
                  <td className="p-2 border text-center">{formatDateMMDDYYYY(bb.due_date)}</td>
                  <td className="p-2 border text-center">{isReturned ? formatDateMMDDYYYY(bb.returned_date!) : '-'}</td>
                  {isLibrarian && (
                    <td className="p-2 border text-center">
                      {!isReturned ? (
                        <button className="px-2 py-1 border rounded" onClick={() => onReturn(bb)}>Mark Returned</button>
                      ) : (
                        <span className="text-green-700">Returned</span>
                      )}
                    </td>
                  )}
                </tr>
              );
            })}
            {borrowings.length === 0 && (
              <tr>
                <td className="p-3 text-center" colSpan={isLibrarian ? 4 : 3}>No borrowings yet</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {open && (
        <div className="fixed inset-0 bg-black/30 flex items-center justify-center">
          <div className="bg-white p-6 rounded shadow w-full max-w-sm">
            <h2 className="text-lg font-semibold mb-3">Select due date</h2>
            <input type="date" className="w-full border rounded p-2 mb-4" value={dueDate} onChange={(e) => setDueDate(e.target.value)} />
            <div className="flex gap-2 justify-end">
              <button className="px-3 py-2 border rounded" onClick={() => setOpen(false)}>Cancel</button>
              <button className="px-3 py-2 bg-blue-600 text-white rounded" onClick={onBorrow} disabled={!dueDate}>Confirm</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}


