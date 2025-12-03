const jwt = require('jsonwebtoken');
const User = require('../../DB/models/User.js');
const AppError = require('../../utils/errorHandler/AppError.js');

const generateToken = (id, email, role) => {
  return jwt.sign(
    { id, email, role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE || '7d' }
  );
};

const register = async (userData) => {
  const { name, email, password, confirmPassword } = userData;

  // Validate input
  if (!name || !email || !password || !confirmPassword) {
    throw new AppError('Please provide all required fields', 400);
  }

  if (password !== confirmPassword) {
    throw new AppError('Passwords do not match', 400);
  }

  // Check if user already exists
  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) {
    throw new AppError('Email already exists', 400);
  }

  // Create user
  const user = await User.create({
    name,
    email,
    password,
    role: 'employee',
  });

  const token = generateToken(user.id, user.email, user.role);

  return {
    success: true,
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  };
};

const login = async (credentials) => {
  const { email, password } = credentials;

  // Validate input
  if (!email || !password) {
    throw new AppError('Please provide email and password', 400);
  }

  // Find user and include password field
  const user = await User.findOne({
    where: { email },
    attributes: { include: ['password'] },
  });

  if (!user) {
    throw new AppError('Invalid credentials', 401);
  }

  // Check password
  const isPasswordValid = await user.comparePassword(password);
  if (!isPasswordValid) {
    throw new AppError('Invalid credentials', 401);
  }

  const token = generateToken(user.id, user.email, user.role);

  return {
    success: true,
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  };
};

const getCurrentUser = async (userId) => {
  const user = await User.findByPk(userId, {
    attributes: { exclude: ['password'] },
  });

  if (!user) {
    throw new AppError('User not found', 404);
  }

  return user;
};

const updateProfile = async (userId, updateData) => {
  const { name, email, password, confirmPassword } = updateData;

  if (password && confirmPassword && password !== confirmPassword) {
    throw new AppError('Passwords do not match', 400);
  }

  const user = await User.findByPk(userId);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  // Check if email already exists (if being changed)
  if (email && email !== user.email) {
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      throw new AppError('Email already exists', 400);
    }
  }

  // Update user
  await user.update({
    name: name || user.name,
    email: email || user.email,
    password: password || user.password,
  });

  return {
    success: true,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  };
};

const updateUserRole = async (userId, newRole) => {
  const validRoles = ['admin', 'employee'];
  
  if (!validRoles.includes(newRole)) {
    throw new AppError('Invalid role', 400);
  }

  const user = await User.findByPk(userId);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  await user.update({ role: newRole });

  return {
    success: true,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  };
};

const getAllUsers = async () => {
  const users = await User.findAll({
    attributes: { exclude: ['password'] },
  });

  return users;
};

const deleteUser = async (userId) => {
  const user = await User.findByPk(userId);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  await user.destroy();

  return {
    success: true,
    message: 'User deleted successfully',
  };
};

module.exports = {
  register,
  login,
  getCurrentUser,
  updateProfile,
  updateUserRole,
  getAllUsers,
  deleteUser,
};
