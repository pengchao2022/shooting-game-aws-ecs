import React, { useEffect, useRef, useState } from 'react';

const Game = ({ token, user, onLogout }) => {
  const canvasRef = useRef(null);
  const [score, setScore] = useState(0);
  const [gameActive, setGameActive] = useState(false);

  useEffect(() => {
    if (gameActive) {
      startGame();
    }
  }, [gameActive]);

  const startGame = () => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');

    // 游戏状态
    const gameState = {
      player: { x: canvas.width / 2 - 25, y: canvas.height - 50, width: 50, height: 50, speed: 7 },
      bullets: [],
      enemies: [],
      lastEnemySpawn: 0,
      enemySpawnRate: 1000,
      keys: {},
      score: 0
    };

    // 事件监听
    window.addEventListener('keydown', (e) => {
      gameState.keys[e.code] = true;
    });

    window.addEventListener('keyup', (e) => {
      gameState.keys[e.code] = false;
    });

    canvas.addEventListener('click', (e) => {
      const rect = canvas.getBoundingClientRect();
      const clickX = e.clientX - rect.left;
      const clickY = e.clientY - rect.top;
      
      // 发射子弹
      gameState.bullets.push({
        x: gameState.player.x + gameState.player.width / 2 - 2.5,
        y: gameState.player.y,
        width: 5,
        height: 15,
        speed: 10
      });
    });

    // 游戏循环
    function gameLoop(timestamp) {
      if (!gameActive) return;

      ctx.fillStyle = '#1a1a2e';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      // 移动玩家
      if (gameState.keys['ArrowLeft'] && gameState.player.x > 0) {
        gameState.player.x -= gameState.player.speed;
      }
      if (gameState.keys['ArrowRight'] && gameState.player.x < canvas.width - gameState.player.width) {
        gameState.player.x += gameState.player.speed;
      }

      // 生成敌人
      if (timestamp - gameState.lastEnemySpawn > gameState.enemySpawnRate) {
        gameState.enemies.push({
          x: Math.random() * (canvas.width - 30),
          y: -30,
          width: 30,
          height: 30,
          speed: 2 + Math.random() * 2
        });
        gameState.lastEnemySpawn = timestamp;
      }

      // 更新子弹
      gameState.bullets = gameState.bullets.filter(bullet => {
        bullet.y -= bullet.speed;
        
        // 绘制子弹
        ctx.fillStyle = '#4dabf7';
        ctx.fillRect(bullet.x, bullet.y, bullet.width, bullet.height);
        
        return bullet.y > 0;
      });

      // 更新敌人
      gameState.enemies = gameState.enemies.filter(enemy => {
        enemy.y += enemy.speed;
        
        // 绘制敌人
        ctx.fillStyle = '#ff6b6b';
        ctx.fillRect(enemy.x, enemy.y, enemy.width, enemy.height);
        
        // 检测碰撞
        gameState.bullets = gameState.bullets.filter(bullet => {
          if (bullet.x < enemy.x + enemy.width &&
              bullet.x + bullet.width > enemy.x &&
              bullet.y < enemy.y + enemy.height &&
              bullet.y + bullet.height > enemy.y) {
            gameState.score += 10;
            setScore(gameState.score);
            return false; // 移除子弹
          }
          return true;
        });

        // 检测玩家碰撞
        if (enemy.y + enemy.height > gameState.player.y &&
            enemy.x < gameState.player.x + gameState.player.width &&
            enemy.x + enemy.width > gameState.player.x) {
          endGame(gameState.score);
          return false;
        }
        
        return enemy.y < canvas.height;
      });

      // 绘制玩家
      ctx.fillStyle = '#51cf66';
      ctx.fillRect(gameState.player.x, gameState.player.y, gameState.player.width, gameState.player.height);

      requestAnimationFrame(gameLoop);
    }

    function endGame(finalScore) {
      setGameActive(false);
      saveScore(finalScore);
      alert(`Game Over! Your score: ${finalScore}`);
    }

    requestAnimationFrame(gameLoop);
  };

  const saveScore = async (finalScore) => {
    try {
      await fetch(`${process.env.REACT_APP_API_URL}/score`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ score: finalScore })
      });
    } catch (error) {
      console.error('Failed to save score:', error);
    }
  };

  const handleStartGame = () => {
    setScore(0);
    setGameActive(true);
  };

  return (
    <div style={{ padding: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h1>Shooting Game</h1>
        <div>
          <span style={{ marginRight: '20px' }}>Welcome, {user.username}!</span>
          <button onClick={onLogout} style={{ 
            padding: '8px 16px', 
            background: '#ff6b6b', 
            color: 'white', 
            border: 'none', 
            borderRadius: '5px',
            cursor: 'pointer'
          }}>
            Logout
          </button>
        </div>
      </div>
      
      <div style={{ marginBottom: '20px' }}>
        <div style={{ fontSize: '24px', marginBottom: '10px' }}>Score: {score}</div>
        {!gameActive && (
          <button 
            onClick={handleStartGame}
            style={{
              padding: '12px 24px',
              fontSize: '18px',
              background: '#51cf66',
              color: 'white',
              border: 'none',
              borderRadius: '5px',
              cursor: 'pointer'
            }}
          >
            Start Game
          </button>
        )}
      </div>

      <canvas
        ref={canvasRef}
        width={800}
        height={600}
        style={{
          border: '2px solid #444',
          background: '#0c0c1a'
        }}
      />
      
      <div style={{ marginTop: '20px', textAlign: 'left', maxWidth: '800px', margin: '20px auto' }}>
        <h3>How to Play:</h3>
        <ul>
          <li>Use ← → arrow keys to move</li>
          <li>Click to shoot bullets</li>
          <li>Avoid enemies and shoot them to earn points</li>
          <li>Each enemy hit: +10 points</li>
        </ul>
      </div>
    </div>
  );
};

export default Game;