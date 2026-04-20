const express = require("express");

const { prisma } = require("../lib/prisma");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();

router.use(requireAuth);

router.get("/me", async (req, res, next) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true
      }
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.json(user);
  } catch (error) {
    return next(error);
  }
});

router.put("/me", async (req, res, next) => {
  try {
    const { name, email } = req.body || {};

    if (!name || !email) {
      return res.status(400).json({ message: "name and email are required" });
    }

    const normalizedEmail = String(email).toLowerCase().trim();

    const existingWithEmail = await prisma.user.findUnique({
      where: { email: normalizedEmail }
    });

    if (existingWithEmail && existingWithEmail.id !== req.user.userId) {
      return res.status(409).json({ message: "Email already in use" });
    }

    const updatedUser = await prisma.user.update({
      where: { id: req.user.userId },
      data: {
        name: String(name).trim(),
        email: normalizedEmail
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        updatedAt: true
      }
    });

    return res.json(updatedUser);
  } catch (error) {
    return next(error);
  }
});

module.exports = { usersRouter: router };
