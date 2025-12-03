const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize({
  database: process.env.DATABASE_NAME || 'your_db_name',
  username: process.env.DATABASE_USER || 'postgres',
  password: process.env.DATABASE_PASSWORD || 'your_password',
  host: process.env.DATABASE_HOST || 'localhost',
  port: process.env.DATABASE_PORT || 5432,
  dialect: 'postgres',
  logging: process.env.NODE_ENV === 'development' ? console.log : false,
});

// Test the connection
sequelize.authenticate()
  .then(() => {
    console.log('✓ Database connection established successfully');
  })
  .catch((error) => {
    console.error('✗ Unable to connect to the database:', error);
  });

module.exports = sequelize;