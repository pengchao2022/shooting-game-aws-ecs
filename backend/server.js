require('dotenv').config();
const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const authRoutes = require('./auth');
const { players, initPlayer, handleMove } = require('./game');

const app = express();
app.use(cors());
app.use(express.json());
app.use(authRoutes);

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  try {
    socket.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch (e) {
    next(new Error('Unauthorized'));
  }
});

io.on('connection', (socket) => {
  initPlayer(socket.id);
  console.log(`Player ${socket.user.username} connected`);
  
  socket.on('move', (key) => handleMove(socket.id, key));
  
  socket.on('disconnect', () => delete players[socket.id]);
});

setInterval(() => {
  io.emit('state', Object.values(players));
}, 100);

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => console.log(`Server running on ${PORT}`));
