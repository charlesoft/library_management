import { BrowserRouter, Link, Route, Routes } from 'react-router-dom'
import './index.css'
import SignIn from './pages/SignIn'
import SignUp from './pages/SignUp'
import { apiFetch } from './lib/api'
import Books from './pages/Books'
import NewBook from './pages/NewBook'
import EditBook from './pages/EditBook'

function App() {
  const isLoggedIn = Boolean(localStorage.getItem('jwt'))

  async function handleSignOut() {
    try {
      await apiFetch('/auth/sign_out', { method: 'DELETE' })
    } catch (e) {
      // ignore
    } finally {
      localStorage.removeItem('jwt')
      window.location.href = '/signin'
    }
  }

  return (
    <BrowserRouter>
      <nav className="p-4 border-b flex gap-4">
        {isLoggedIn ? (
          <button onClick={handleSignOut} className="text-red-600">Sign Out</button>
        ) : (
          <>
            <Link to="/signin" className="text-blue-600">Sign In</Link>
            <Link to="/signup" className="text-blue-600">Sign Up</Link>
          </>
        )}
      </nav>
      <Routes>
        <Route path="/signin" element={<SignIn />} />
        <Route path="/signup" element={<SignUp />} />
        <Route path="/" element={<Books />} />
        <Route path="/books/new" element={<NewBook />} />
        <Route path="/books/:id/edit" element={<EditBook />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
