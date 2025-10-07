import axios from 'axios';

const API_URL = process.env.REACT_APP_API_URL || "http://localhost:4000";

export const register = (username, password) =>
  axios.post(`${API_URL}/register`, { username, password });

export const login = (username, password) =>
  axios.post(`${API_URL}/login`, { username, password });
