const asyncHandler = require('../../utils/errorHandler/asyncHandler.js');
const userService = require('./userService.js');

const register = asyncHandler(async (req, res) => {
  const result = await userService.register(req.body);

  res.status(201).json({
    success: true,
    data: result,
  });
});

const login = asyncHandler(async (req, res) => {
  const result = await userService.login(req.body);

  res.status(200).json({
    success: true,
    data: result,
  });
});

const getMe = asyncHandler(async (req, res) => {
  const user = await userService.getCurrentUser(req.user.id);

  res.status(200).json({
    success: true,
    data: user,
  });
});

const updateProfile = asyncHandler(async (req, res) => {
  const result = await userService.updateProfile(req.user.id, req.body);

  res.status(200).json({
    success: true,
    data: result,
  });
});

const getAllUsers = asyncHandler(async (req, res) => {
  const users = await userService.getAllUsers();

  res.status(200).json({
    success: true,
    data: users,
  });
});

const deleteUser = asyncHandler(async (req, res) => {
  const result = await userService.deleteUser(req.params.id);

  res.status(200).json({
    success: true,
    message: result.message,
  });
});

const updateUserRole = asyncHandler(async (req, res) => {
  const result = await userService.updateUserRole(req.params.id, req.body.role);

  res.status(200).json({
    success: true,
    data: result,
  });
});

module.exports = {
  register,
  login,
  getMe,
  updateProfile,
  getAllUsers,
  deleteUser,
  updateUserRole,
};