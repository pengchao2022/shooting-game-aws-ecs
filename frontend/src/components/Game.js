import React, { useEffect, useRef } from 'react';
import io from 'socket.io-client';

export default function Game({ token }) {
  const canvasRef = useRef(null);
  const socketRef = useRef();

  useEffect(() => {
    if (!token) {
      window.location.href = "/";
      return;
    }

    socketRef.current = io(process.env.REACT_APP_WS_URL || "http://localhost:4000", {
      auth: { token }
    });

    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d");

    socketRef.current.on("state", (players) => {
      ctx.clearRect(0, 0, 800, 600);
      players.forEach(p => {
        ctx.fillStyle = p.color;
        ctx.fillRect(p.x, p.y, 20, 20);
      });
    });

    const handleKey = (e) => socketRef.current.emit("move", e.key);
    window.addEventListener("keydown", handleKey);

    return () => {
      window.removeEventListener("keydown", handleKey);
      socketRef.current.disconnect();
    };
  }, [token]);

  return <canvas ref={canvasRef} width={800} height={600} />;
}
