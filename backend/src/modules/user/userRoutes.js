const express = require('express');
const userController = require('./userController.js');
const { protect, authorize } = require('../../Middleware/auth.js');

const router = express.Router();

// Public routes
router.post('/register', userController.register);
router.post('/login', userController.login);

// Protected routes (any authenticated user)
router.get('/me', protect, userController.getMe);
router.put('/profile', protect, userController.updateProfile);

// Admin only routes
router.get('/users', protect, authorize('admin'), userController.getAllUsers);
router.delete('/users/:id', protect, authorize('admin'), userController.deleteUser);
router.put('/users/:id/role', protect, authorize('admin'), userController.updateUserRole);

module.exports = router;