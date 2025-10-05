export const API_BASE = import.meta.env.VITE_API_BASE || 'http://localhost:3000/api/v1';

export type Book = {
  id: number;
  title: string;
  author: string;
  genre: string;
  isbn: string;
  total_copies: number;
};

function getAuthToken(): string | null {
  return localStorage.getItem('jwt');
}

export async function apiFetch(path: string, options: RequestInit = {}) {
  const headers = new Headers(options.headers as HeadersInit);
  headers.set('Content-Type', 'application/json');
  const token = getAuthToken();
  if (token) headers.set('Authorization', token); // token already includes Bearer from backend response

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
  });
  return res;
}

export async function signIn(email: string, password: string) {
  const res = await apiFetch('/auth/sign_in', {
    method: 'POST',
    body: JSON.stringify({ user: { email, password } })
  });
  const auth = res.headers.get('Authorization');
  if (auth) localStorage.setItem('jwt', auth);
  return res;
}

export async function signUp(payload: { name: string; email: string; password: string; password_confirmation: string; user_role_id: number; }) {
  const res = await apiFetch('/auth', {
    method: 'POST',
    body: JSON.stringify({ user: payload })
  });
  const auth = res.headers.get('Authorization');
  if (auth) localStorage.setItem('jwt', auth);
  return res;
}

export async function fetchUserRoles() {
  const res = await apiFetch('/user_roles');
  return res.json();
}

export async function fetchBooks(params: { q?: string; limit: number; offset: number }): Promise<{ data: Book[]; pagination: { limit: number; offset: number; count: number } }> {
  const qs = new URLSearchParams();
  if (params.q) qs.set('q', params.q);
  qs.set('limit', String(params.limit));
  qs.set('offset', String(params.offset));
  const res = await apiFetch(`/books?${qs.toString()}`);
  if (!res.ok) throw new Error('Failed to load books');
  return res.json();
}

export async function createBook(payload: Omit<Book, 'id'>) {
  return apiFetch('/books', { method: 'POST', body: JSON.stringify({ book: payload }) });
}

export async function updateBook(id: number, payload: Partial<Omit<Book, 'id'>>) {
  return apiFetch(`/books/${id}`, { method: 'PATCH', body: JSON.stringify({ book: payload }) });
}

export async function deleteBook(id: number) {
  return apiFetch(`/books/${id}`, { method: 'DELETE' });
}


