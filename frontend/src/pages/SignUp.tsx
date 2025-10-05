import { useEffect, useState } from 'react';
import { fetchUserRoles, signUp } from '../lib/api';

type Role = { id: number; name: string };

export default function SignUp() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [roleId, setRoleId] = useState<number | ''>('');
  const [roles, setRoles] = useState<Role[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchUserRoles().then(setRoles).catch(() => setRoles([]));
  }, []);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!roleId) { setError('Please select a role'); return; }
    const res = await signUp({ name, email, password, password_confirmation: passwordConfirmation, user_role_id: roleId });
    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      setError(body?.errors?.join(', ') || 'Sign up failed');
      return;
    }
    window.location.href = '/';
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-4">
      <form onSubmit={onSubmit} className="w-full max-w-sm bg-white p-6 rounded shadow">
        <h1 className="text-2xl font-semibold mb-4">Sign Up</h1>
        {error && <div className="mb-3 text-sm text-red-600">{error}</div>}
        <label className="block mb-2 text-sm">Name</label>
        <input className="w-full border rounded p-2 mb-4" value={name} onChange={e => setName(e.target.value)} required />
        <label className="block mb-2 text-sm">Email</label>
        <input className="w-full border rounded p-2 mb-4" value={email} onChange={e => setEmail(e.target.value)} type="email" required />
        <label className="block mb-2 text-sm">Password</label>
        <input className="w-full border rounded p-2 mb-4" value={password} onChange={e => setPassword(e.target.value)} type="password" required />
        <label className="block mb-2 text-sm">Confirm Password</label>
        <input className="w-full border rounded p-2 mb-4" value={passwordConfirmation} onChange={e => setPasswordConfirmation(e.target.value)} type="password" required />
        <label className="block mb-2 text-sm">Role</label>
        <select className="w-full border rounded p-2 mb-4" value={roleId} onChange={e => setRoleId(Number(e.target.value))} required>
          <option value="">Select role</option>
          {roles.map(r => <option key={r.id} value={r.id}>{r.name}</option>)}
        </select>
        <button className="w-full bg-blue-600 text-white py-2 rounded">Create Account</button>
        <div className="mt-3 text-sm">
          Already have an account? <a className="text-blue-600" href="/signin">Sign in</a>
        </div>
      </form>
    </div>
  );
}


