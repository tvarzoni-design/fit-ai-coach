const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

async function runMigration() {
  const client = new Client({
    connectionString: 'postgresql://fitcoach:paZPtZlzW29t3UJrbG0On1vKP0QtfxF1@dpg-d9bfp9oqmsqc738pgnm0-a.postgres.render.com:5432/fit_ai_coach',
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('Connected to database');

    const sql = fs.readFileSync(path.join(__dirname, '..', 'database', 'migrations', '001_initial_schema.sql'), 'utf8');
    await client.query(sql);
    console.log('Migration executed successfully');
  } catch (err) {
    console.error('Migration error:', err.message);
  } finally {
    await client.end();
  }
}

runMigration();
