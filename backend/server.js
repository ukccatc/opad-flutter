const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const crypto = require('crypto');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());

// MySQL connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || 's19.thehost.com.ua',
  user: process.env.DB_USER || 'opad2016',
  password: process.env.DB_PASSWORD || 'opad2016',
  database: process.env.DB_NAME || 'opad',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// MD5 hash function (same as WordPress)
function md5Hash(input) {
  const secret = 'fsdfsd6287gf'; // From WordPress functions.php
  return crypto.createHash('md5').update(secret + input).digest('hex');
}

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Get user account by email
app.get('/api/users/account', async (req, res) => {
  try {
    const { email } = req.query;
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const connection = await pool.getConnection();
    const [rows] = await connection.query(
      'SELECT * FROM Users WHERE Email = ?',
      [email]
    );
    connection.release();

    if (rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = rows[0];
    res.json({
      id: user.id,
      Email: user.Email,
      Password: user.Password,
      user_id: user.user_id,
    });
  } catch (error) {
    console.error('Error getting user account:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user stats by email or ID
app.get('/api/users/stats', async (req, res) => {
  try {
    const { emailOrId } = req.query;
    if (!emailOrId) {
      return res.status(400).json({ error: 'Email or ID is required' });
    }

    const connection = await pool.getConnection();

    // Try by email first
    let [rows] = await connection.query(
      'SELECT * FROM Stats WHERE Email = ?',
      [emailOrId]
    );

    // If not found, try by ID
    if (rows.length === 0) {
      [rows] = await connection.query(
        'SELECT * FROM Stats WHERE Id = ?',
        [emailOrId]
      );
    }

    connection.release();

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Stats not found' });
    }

    const stats = rows[0];
    res.json({
      Id: stats.Id.toString(),
      Email: stats.Email,
      Password: stats.Password,
      'Член-профсоюза': stats['Член-профсоюза'].toString(),
      'ФИО': stats['ФИО'],
      'Общая сумма': stats['Общая сумма'],
    });
  } catch (error) {
    console.error('Error getting user stats:', error);
    res.status(500).json({ error: error.message });
  }
});

// Authenticate user
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('🔐 [AUTH] Login attempt for:', email);
    console.log('🔐 [AUTH] Password hash:', password.substring(0, 8) + '...');

    if (!email || !password) {
      console.log('❌ [AUTH] Missing email or password');
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const connection = await pool.getConnection();
    console.log('✅ [AUTH] Database connection established');

    // Check in Users table
    console.log('🔍 [AUTH] Checking Users table for:', email);
    let [rows] = await connection.query(
      'SELECT * FROM Users WHERE Email = ? AND Password = ?',
      [email, password]
    );

    if (rows.length > 0) {
      console.log('✅ [AUTH] User found in Users table');
      connection.release();
      res.json({ success: true });
      return;
    }

    console.log('⚠️ [AUTH] User not found in Users table, checking Stats table');

    // Check in Stats table
    [rows] = await connection.query(
      'SELECT * FROM Stats WHERE Email = ? AND Password = ?',
      [email, password]
    );

    connection.release();

    if (rows.length > 0) {
      console.log('✅ [AUTH] User found in Stats table');
      res.json({ success: true });
    } else {
      console.log('❌ [AUTH] User not found in either table - authentication failed');
      res.json({ success: false });
    }
  } catch (error) {
    console.error('❌ [AUTH] Error authenticating user:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get all users
app.get('/api/users/all', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [rows] = await connection.query(
      'SELECT * FROM Stats ORDER BY ФИО'
    );
    connection.release();

    const users = rows.map(row => ({
      Id: row.Id.toString(),
      Email: row.Email,
      Password: row.Password,
      'Член-профсоюза': row['Член-профсоюза'].toString(),
      'ФИО': row['ФИО'],
      'Общая сумма': row['Общая сумма'],
    }));

    res.json(users);
  } catch (error) {
    console.error('Error getting all users:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get union members
app.get('/api/users/union-members', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [rows] = await connection.query(
      'SELECT * FROM Stats WHERE `Член-профсоюза` = 1 ORDER BY ФИО'
    );
    connection.release();

    const users = rows.map(row => ({
      Id: row.Id.toString(),
      Email: row.Email,
      Password: row.Password,
      'Член-профсоюза': row['Член-профсоюза'].toString(),
      'ФИО': row['ФИО'],
      'Общая сумма': row['Общая сумма'],
    }));

    res.json(users);
  } catch (error) {
    console.error('Error getting union members:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update user password
app.post('/api/users/update-password', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('🔑 [PASSWORD] Password update request for:', email);
    console.log('🔑 [PASSWORD] New password hash:', password.substring(0, 8) + '...');

    if (!email || !password) {
      console.log('❌ [PASSWORD] Missing email or password');
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const connection = await pool.getConnection();
    console.log('✅ [PASSWORD] Database connection established');

    // Update in Users table
    console.log('🔄 [PASSWORD] Updating Users table for:', email);
    const [usersResult] = await connection.query(
      'UPDATE Users SET Password = ? WHERE Email = ?',
      [password, email]
    );
    console.log('🔄 [PASSWORD] Users table update result:', usersResult.affectedRows, 'rows affected');

    // Update in Stats table
    console.log('🔄 [PASSWORD] Updating Stats table for:', email);
    const [statsResult] = await connection.query(
      'UPDATE Stats SET Password = ? WHERE Email = ?',
      [password, email]
    );
    console.log('🔄 [PASSWORD] Stats table update result:', statsResult.affectedRows, 'rows affected');

    connection.release();

    if (usersResult.affectedRows > 0 || statsResult.affectedRows > 0) {
      console.log('✅ [PASSWORD] Password updated successfully');
      res.json({ success: true });
    } else {
      console.log('⚠️ [PASSWORD] No rows were updated - user may not exist');
      res.json({ success: false });
    }
  } catch (error) {
    console.error('❌ [PASSWORD] Error updating password:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get database statistics
app.get('/api/stats/database', async (req, res) => {
  try {
    const connection = await pool.getConnection();

    // Get total users count
    const [totalRows] = await connection.query(
      'SELECT COUNT(*) as count FROM Stats'
    );
    const totalCount = totalRows[0].count;

    // Get union members count
    const [unionRows] = await connection.query(
      'SELECT COUNT(*) as count FROM Stats WHERE `Член-профсоюза` = 1'
    );
    const unionCount = unionRows[0].count;

    // Get total balance sum
    const [balanceRows] = await connection.query(
      'SELECT SUM(`Общая сумма`) as total FROM Stats'
    );
    const totalBalance = balanceRows[0].total || 0;

    connection.release();

    res.json({
      total_users: totalCount,
      union_members: unionCount,
      total_balance: totalBalance,
      non_union_members: totalCount - unionCount,
    });
  } catch (error) {
    console.error('Error getting database stats:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get all articles (from WordPress)
app.get('/api/articles', async (req, res) => {
  try {
    // This would typically fetch from WordPress REST API or a custom table
    // For now, return empty array as placeholder
    res.json([]);
  } catch (error) {
    console.error('Error getting articles:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get article by ID (from WordPress)
app.get('/api/articles/:id', async (req, res) => {
  try {
    const { id } = req.params;
    // This would typically fetch from WordPress REST API or a custom table
    // For now, return 404
    res.status(404).json({ error: 'Article not found' });
  } catch (error) {
    console.error('Error getting article:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Backend API server running on http://localhost:${PORT}`);
  console.log(`📊 Database: ${process.env.DB_HOST || 's19.thehost.com.ua'}`);
});
