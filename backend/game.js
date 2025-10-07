const players = {};

function initPlayer(id) {
  players[id] = { x: 100, y: 100, color: `hsl(${Math.random() * 360}, 70%, 50%)` };
}

function handleMove(id, key) {
  const p = players[id];
  if (!p) return;
  if (key === 'ArrowUp') p.y -= 10;
  if (key === 'ArrowDown') p.y += 10;
  if (key === 'ArrowLeft') p.x -= 10;
  if (key === 'ArrowRight') p.x += 10;
}

module.exports = { players, initPlayer, handleMove };
