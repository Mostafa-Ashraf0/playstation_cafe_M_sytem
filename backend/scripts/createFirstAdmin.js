require('dotenv').config();
const sequelize = require('../src/DB/connection.js');
const User = require('../src/DB/models/User');

const createFirstAdmin = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connected successfully');

    const adminExists = await User.findOne({
      where: { email: process.env.ADMIN_EMAIL || 'admin@example.com' }
    });

    if (adminExists) {
      console.log('Admin user already exists');
      process.exit(0);
    }

    const admin = await User.create({
      name: process.env.ADMIN_NAME || 'Admin',
      email: process.env.ADMIN_EMAIL || 'admin@example.com',
      password: process.env.ADMIN_PASSWORD || 'admin123',
      role: 'admin',
    });

    console.log('✓ Admin user created successfully');
    console.log(`Email: ${admin.email}`);
    console.log(`Role: ${admin.role}`);
    process.exit(0);
  } catch (error) {
    console.error('Error creating admin:', error.message);
    process.exit(1);
  }
};

createFirstAdmin();