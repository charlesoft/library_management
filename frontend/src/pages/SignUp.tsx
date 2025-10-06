import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { signUp } from '../lib/api';

export default function SignUp() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [roleId] = useState<number | ''>('');
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {}, []);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    const res = await signUp({ name, email, password, password_confirmation: passwordConfirmation, user_role_id: roleId as any });
    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      setError(body?.errors?.join(', ') || 'Sign up failed');
      return;
    }
    try {
      const body = await res.clone().json();
      const roleId = body?.user?.user_role_id;
      const userId = body?.user?.id;
      if (roleId != null) localStorage.setItem('currentUserRoleId', String(roleId));
      if (userId != null) localStorage.setItem('currentUserId', String(userId));
    } catch (_) {}
    navigate('/');
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
        {/* Role selection removed - defaults to member server-side */}
        <button className="w-full bg-blue-600 text-white py-2 rounded">Create Account</button>
        <div className="mt-3 text-sm">
          Already have an account? <a className="text-blue-600" href="/signin">Sign in</a>
        </div>
      </form>
    </div>
  );
}


