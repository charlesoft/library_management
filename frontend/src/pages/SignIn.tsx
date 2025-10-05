import { useState } from 'react';
import { signIn } from '../lib/api';

export default function SignIn() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    const res = await signIn(email, password);
    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      setError(body?.message || 'Login failed');
      return;
    }
    window.location.href = '/';
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-4">
      <form onSubmit={onSubmit} className="w-full max-w-sm bg-white p-6 rounded shadow">
        <h1 className="text-2xl font-semibold mb-4">Sign In</h1>
        {error && <div className="mb-3 text-sm text-red-600">{error}</div>}
        <label className="block mb-2 text-sm">Email</label>
        <input className="w-full border rounded p-2 mb-4" value={email} onChange={e => setEmail(e.target.value)} type="email" required />
        <label className="block mb-2 text-sm">Password</label>
        <input className="w-full border rounded p-2 mb-4" value={password} onChange={e => setPassword(e.target.value)} type="password" required />
        <button className="w-full bg-blue-600 text-white py-2 rounded">Sign In</button>
        <div className="mt-3 text-sm">
          Don’t have an account? <a className="text-blue-600" href="/signup">Sign up</a>
        </div>
      </form>
    </div>
  );
}


