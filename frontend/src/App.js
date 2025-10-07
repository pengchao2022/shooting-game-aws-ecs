import React, { useState } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Login from './components/Login';
import Register from './components/Register';
import Game from './components/Game';
import './styles.css';

function App() {
  const [token, setToken] = useState(localStorage.getItem('token'));

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login setToken={setToken} />} />
        <Route path="/register" element={<Register />} />
        <Route path="/game" element={<Game token={token} />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
