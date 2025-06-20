const express = require("express");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const auth = require("../middleware/auth");
const uploadImage = require("../middleware/uploadImage");

const router = express.Router();

// Register
router.post("/register", async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const user = new User({ username, email, password });
    await user.save();

    // Create JWT token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || "your-secret-key",
      { expiresIn: "30d" }
    );

    // Save token as session
    user.sessionToken = token;
    await user.save();

    res.status(201).json({
      message: "User created successfully",
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
      },
      token,
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // Create new token
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || "your-secret-key",
      { expiresIn: "30d" }
    );

    // Save token as session
    user.sessionToken = token;
    await user.save();

    res.json({
      message: "Logged in successfully",
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
      },
      token,
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Logout
router.post("/logout", auth, async (req, res) => {
  try {
    // Clear session token
    req.user.sessionToken = null;
    await req.user.save();

    res.json({ message: "Logged out successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Profil fotoğrafı yükleme
router.post(
  "/upload-pp",
  auth,
  uploadImage.single("profileImage"),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ message: "Dosya yüklenemedi" });
      }

      const imageUrl = `http://localhost:5000/uploads/images/${req.file.filename}`;
      req.user.profilePicture = imageUrl;
      await req.user.save();

      res.json({
        message: "Profil fotoğrafı başarıyla yüklendi",
        imageUrl,
      });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
);

// Get current user
router.get("/me", auth, async (req, res) => {
  res.json({
    user: {
      id: req.user._id,
      username: req.user.username,
      email: req.user.email,
      profilePicture: req.user.profilePicture,
    },
  });
});

module.exports = router;
