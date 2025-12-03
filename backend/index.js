require('dotenv').config();
const express = require('express');
const sequelize = require('./src/DB/connection');
const globalErrorHandler = require('./src/utils/errorHandler/globalErrorHandler');
const notFoundHandler = require('./src/utils/errorHandler/notFoundHandler');
const userRoutes = require('./src/modules/user/userRoutes');

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection
sequelize.authenticate()
  .then(() => console.log('✓ Database connected successfully'))
  .catch((error) => console.error('✗ Unable to connect to the database:', error));

// Routes
app.use('/api/auth', userRoutes);

// Error handlers (must be at the end)
app.use(notFoundHandler);
app.use(globalErrorHandler);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`✓ Server running on port ${PORT}`);
});