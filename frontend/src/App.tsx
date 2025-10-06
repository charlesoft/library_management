import { useEffect, useRef, useState } from 'react'
import { BrowserRouter, Link, Route, Routes } from 'react-router-dom'
import './index.css'
import SignIn from './pages/SignIn'
import SignUp from './pages/SignUp'
import { apiFetch } from './lib/api'
import Books from './pages/Books'
import NewBook from './pages/NewBook'
import EditBook from './pages/EditBook'
import BookShow from './pages/BookShow'
import DashboardLibrarian from './pages/DashboardLibrarian'
import DashboardMember from './pages/DashboardMember'

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(Boolean(localStorage.getItem('jwt')))
  const [name, setName] = useState<string | null>(localStorage.getItem('currentUserName'))
  const [roleId, setRoleId] = useState<string | null>(localStorage.getItem('currentUserRoleId'))
  const [menuOpen, setMenuOpen] = useState(false)
  const menuRef = useRef<HTMLDivElement | null>(null)

  const isLibrarian = roleId === '1' || localStorage.getItem('currentUserRole') === 'librarian'

  useEffect(() => {
    function onAuthChanged() {
      setIsLoggedIn(Boolean(localStorage.getItem('jwt')))
      setName(localStorage.getItem('currentUserName'))
      setRoleId(localStorage.getItem('currentUserRoleId'))
      setMenuOpen(false)
    }
    window.addEventListener('auth:changed', onAuthChanged)
    return () => window.removeEventListener('auth:changed', onAuthChanged)
  }, [])

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (!menuOpen) return
      const target = e.target as Node
      if (menuRef.current && !menuRef.current.contains(target)) {
        setMenuOpen(false)
      }
    }
    function handleEsc(e: KeyboardEvent) {
      if (e.key === 'Escape') setMenuOpen(false)
    }
    document.addEventListener('click', handleClickOutside)
    document.addEventListener('keydown', handleEsc)
    return () => {
      document.removeEventListener('click', handleClickOutside)
      document.removeEventListener('keydown', handleEsc)
    }
  }, [menuOpen])

  async function handleSignOut() {
    try {
      await apiFetch('/auth/sign_out', { method: 'DELETE' })
    } catch (e) {
      // ignore
    } finally {
      localStorage.removeItem('jwt')
      localStorage.removeItem('currentUserName')
      localStorage.removeItem('currentUserId')
      localStorage.removeItem('currentUserRoleId')
      localStorage.removeItem('currentUserRole')
      window.dispatchEvent(new Event('auth:changed'))
      window.location.href = '/signin'
    }
  }

  return (
    <BrowserRouter>
      <nav className="p-4 border-b flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link to="/" className="font-medium">Home</Link>
        </div>
        <div className="flex items-center gap-4">
          {isLoggedIn ? (
            <div className="relative" ref={menuRef}>
              <button
                className="px-2 py-1 border rounded"
                aria-haspopup="menu"
                aria-expanded={menuOpen}
                onClick={() => setMenuOpen(o => !o)}
              >
                {name || 'Account'}
              </button>
              {menuOpen && (
              <div className="absolute right-0 mt-2 w-48 border rounded bg-white shadow">
                <div className="px-3 py-2 border-b text-sm">{name || 'Signed in'}</div>
                <Link
                  to={isLibrarian ? '/dashboard/librarian' : '/dashboard/member'}
                  className="block px-3 py-2 text-sm hover:bg-gray-50"
                  onClick={() => setMenuOpen(false)}
                >
                  My Dashboard
                </Link>
                <button
                  className="w-full text-left px-3 py-2 text-sm text-red-600 hover:bg-gray-50"
                  onClick={handleSignOut}
                >
                  Sign Out
                </button>
              </div>
              )}
            </div>
          ) : (
            <>
              <Link to="/signin" className="text-blue-600">Sign In</Link>
              <Link to="/signup" className="text-blue-600">Sign Up</Link>
            </>
          )}
        </div>
      </nav>
      <Routes>
        <Route path="/signin" element={<SignIn />} />
        <Route path="/signup" element={<SignUp />} />
        <Route path="/" element={<Books />} />
        <Route path="/books/new" element={<NewBook />} />
        <Route path="/books/:id/edit" element={<EditBook />} />
        <Route path="/books/:id" element={<BookShow />} />
        <Route path="/dashboard/librarian" element={<DashboardLibrarian />} />
        <Route path="/dashboard/member" element={<DashboardMember />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
