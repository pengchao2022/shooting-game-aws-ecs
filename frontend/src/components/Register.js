import React, { useState } from 'react';
import { register } from '../api';

export default function Register() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleRegister = async (e) => {
    e.preventDefault();
    await register(username, password);
    alert("Registered! Now login.");
    window.location.href = "/";
  };

  return (
    <div className="login-box">
      <h2>Register</h2>
      <form onSubmit={handleRegister}>
        <input placeholder="Username" onChange={(e) => setUsername(e.target.value)} />
        <input placeholder="Password" type="password" onChange={(e) => setPassword(e.target.value)} />
        <button>Register</button>
      </form>
    </div>
  );
}
