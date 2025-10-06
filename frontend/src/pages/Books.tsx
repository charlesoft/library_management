import { useEffect, useState } from 'react';
import { deleteBook, fetchBooks } from '../lib/api';
import { useNavigate } from 'react-router-dom';
import type { Book } from '../lib/api';

export default function Books() {
  const [books, setBooks] = useState<Book[]>([]);
  const [q, setQ] = useState('');
  const [page, setPage] = useState(1);
  const [count, setCount] = useState(0);
  const limit = 10;
  const isLibrarian = localStorage.getItem('currentUserRoleId') === '1' || localStorage.getItem('currentUserRole') === 'librarian';
  const navigate = useNavigate();

  useEffect(() => {
    const offset = (page - 1) * limit;
    fetchBooks({ q, limit, offset }).then(res => {
      setBooks(res.data);
      setCount(res.pagination.count);
    }).catch(() => {
      setBooks([]);
      setCount(0);
    });
  }, [q, page]);

  const canPrev = page > 1;
  const canNext = books.length === limit; // backend returns current page count

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <div className="flex items-center justify-between gap-2 mb-4">
        <div className="flex-1 flex items-center gap-2">
        <input
          className="border rounded p-2 flex-1"
          placeholder="Search by title, author, genre"
          value={q}
          onChange={(e) => { setPage(1); setQ(e.target.value); }}
        />
        </div>
        {isLibrarian && (
          <a href="/books/new" className="px-3 py-2 bg-blue-600 text-white rounded">New Book</a>
        )}
      </div>

      <table className="w-full border text-sm">
        <thead className="bg-gray-100">
          <tr>
            <th className="p-2 border">Title</th>
            <th className="p-2 border">Author</th>
            <th className="p-2 border">Genre</th>
            <th className="p-2 border">ISBN</th>
            <th className="p-2 border text-right">Total Copies</th>
            {isLibrarian && <th className="p-2 border text-center">Actions</th>}
          </tr>
        </thead>
        <tbody>
          {books.map(b => (
            <tr key={b.id}>
              <td className="p-2 border"><a className="text-blue-600" href={`/books/${b.id}`}>{b.title}</a></td>
              <td className="p-2 border">{b.author}</td>
              <td className="p-2 border">{b.genre}</td>
              <td className="p-2 border">{b.isbn}</td>
              <td className="p-2 border text-right">{b.total_copies}</td>
              {isLibrarian && (
                <td className="p-2 border">
                  <div className="flex w-full items-center justify-between gap-2">
                    <button className="px-2 py-1 border rounded flex-1" onClick={() => navigate(`/books/${b.id}/edit`)}>Edit</button>
                    <button className="px-2 py-1 border rounded text-red-600 flex-1" onClick={async () => {
                      if (!confirm('Delete this book?')) return;
                      const res = await deleteBook(b.id);
                      if (res.ok) {
                        setBooks(prev => prev.filter(x => x.id !== b.id));
                      }
                    }}>Delete</button>
                  </div>
                </td>
              )}
            </tr>
          ))}
          {books.length === 0 && (
            <tr><td className="p-4 text-center" colSpan={isLibrarian ? 6 : 5}>No books found</td></tr>
          )}
        </tbody>
      </table>

      <div className="mt-4 flex items-center justify-between">
        <button className="px-3 py-1 border rounded disabled:opacity-50" disabled={!canPrev} onClick={() => setPage(p => p - 1)}>Previous</button>
        <div className="text-sm">Page {page}</div>
        <button className="px-3 py-1 border rounded disabled:opacity-50" disabled={!canNext} onClick={() => setPage(p => p + 1)}>Next</button>
      </div>
    </div>
  );
}


