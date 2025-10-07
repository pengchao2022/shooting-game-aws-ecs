import React, { useState } from 'react';
import { login } from '../api';

export default function Login({ setToken }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    const res = await login(username, password);
    localStorage.setItem('token', res.data.token);
    setToken(res.data.token);
    window.location.href = '/game';
  };

  return (
    <div className="login-box">
      <h2>Login</h2>
      <form onSubmit={handleLogin}>
        <input placeholder="Username" onChange={(e) => setUsername(e.target.value)} />
        <input placeholder="Password" type="password" onChange={(e) => setPassword(e.target.value)} />
        <button>Login</button>
      </form>
      <a href="/register">Register</a>
    </div>
  );
}
