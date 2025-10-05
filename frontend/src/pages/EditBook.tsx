import { useEffect, useState } from 'react';
import { apiFetch, updateBook } from '../lib/api';
import { useNavigate, useParams } from 'react-router-dom';

export default function EditBook() {
  const navigate = useNavigate();
  const params = useParams();
  const id = Number(params.id);
  const isLibrarian = localStorage.getItem('currentUserRoleId') === '1' || localStorage.getItem('currentUserRole') === 'librarian';
  if (!isLibrarian) return <div className="p-6">Forbidden</div>;

  const [title, setTitle] = useState('');
  const [author, setAuthor] = useState('');
  const [genre, setGenre] = useState('');
  const [isbn, setIsbn] = useState('');
  const [totalCopies, setTotalCopies] = useState(0);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    apiFetch(`/books/${id}`).then(r => r.json()).then(b => {
      setTitle(b.title); setAuthor(b.author); setGenre(b.genre); setIsbn(b.isbn); setTotalCopies(b.total_copies || 0);
    });
  }, [id]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    const res = await updateBook(id, { title, author, genre, isbn, total_copies: Number(totalCopies) });
    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      setError(body?.errors?.join(', ') || 'Failed to update book');
      return;
    }
    navigate('/');
  }

  return (
    <div className="p-6 max-w-xl mx-auto">
      <h1 className="text-2xl font-semibold mb-4">Edit Book</h1>
      {error && <div className="mb-3 text-sm text-red-600">{error}</div>}
      <form onSubmit={onSubmit} className="space-y-3">
        <input className="w-full border rounded p-2" placeholder="Title" value={title} onChange={e => setTitle(e.target.value)} required />
        <input className="w-full border rounded p-2" placeholder="Author" value={author} onChange={e => setAuthor(e.target.value)} required />
        <input className="w-full border rounded p-2" placeholder="Genre" value={genre} onChange={e => setGenre(e.target.value)} required />
        <input className="w-full border rounded p-2" placeholder="ISBN" value={isbn} onChange={e => setIsbn(e.target.value)} required />
        <input className="w-full border rounded p-2" placeholder="Total copies" type="number" min={0} value={totalCopies} onChange={e => setTotalCopies(Number(e.target.value))} />
        <div className="flex gap-2">
          <button className="px-3 py-2 bg-blue-600 text-white rounded" type="submit">Save</button>
          <button className="px-3 py-2 border rounded" type="button" onClick={() => navigate('/')}>Cancel</button>
        </div>
      </form>
    </div>
  );
}


