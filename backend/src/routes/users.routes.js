const express = require("express");

const { prisma } = require("../lib/prisma");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();

router.use(requireAuth);

function normalizeSkill(skill) {
  return String(skill || "").replace(/\s+/g, " ").trim();
}

function uniqueSkills(skills = []) {
  const seen = new Set();
  const result = [];

  for (const rawSkill of skills) {
    const skill = normalizeSkill(rawSkill);
    if (!skill) continue;
    const key = skill.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(skill);
  }

  return result;
}

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

router.get("/me/skills", async (req, res, next) => {
  try {
    const skills = await prisma.userSkill.findMany({
      where: { userId: req.user.userId },
      select: { id: true, skill: true },
      orderBy: { skill: "asc" }
    });

    return res.json({
      skills: skills.map((item) => item.skill)
    });
  } catch (error) {
    return next(error);
  }
});

router.put("/me/skills", async (req, res, next) => {
  try {
    const { skills } = req.body || {};

    if (!Array.isArray(skills)) {
      return res.status(400).json({ message: "skills array is required" });
    }

    const normalizedSkills = uniqueSkills(skills);

    await prisma.$transaction(async (tx) => {
      await tx.userSkill.deleteMany({
        where: { userId: req.user.userId }
      });

      if (normalizedSkills.length > 0) {
        await tx.userSkill.createMany({
          data: normalizedSkills.map((skill) => ({
            userId: req.user.userId,
            skill
          })),
          skipDuplicates: true
        });
      }
    });

    return res.json({ skills: normalizedSkills });
  } catch (error) {
    return next(error);
  }
});

router.post("/me/skills", async (req, res, next) => {
  try {
    const skill = normalizeSkill(req.body?.skill);

    if (!skill) {
      return res.status(400).json({ message: "skill is required" });
    }

    const existing = await prisma.userSkill.findFirst({
      where: {
        userId: req.user.userId,
        skill: {
          equals: skill,
          mode: "insensitive"
        }
      }
    });

    if (!existing) {
      await prisma.userSkill.create({
        data: {
          userId: req.user.userId,
          skill
        }
      });
    }

    const skills = await prisma.userSkill.findMany({
      where: { userId: req.user.userId },
      select: { skill: true },
      orderBy: { skill: "asc" }
    });

    return res.status(201).json({ skills: skills.map((item) => item.skill) });
  } catch (error) {
    return next(error);
  }
});

router.delete("/me/skills/:skill", async (req, res, next) => {
  try {
    const skillParam = normalizeSkill(decodeURIComponent(req.params.skill));
    if (!skillParam) {
      return res.status(400).json({ message: "skill is required" });
    }

    const existing = await prisma.userSkill.findFirst({
      where: {
        userId: req.user.userId,
        skill: {
          equals: skillParam,
          mode: "insensitive"
        }
      }
    });

    if (existing) {
      await prisma.userSkill.delete({
        where: { id: existing.id }
      });
    }

    const skills = await prisma.userSkill.findMany({
      where: { userId: req.user.userId },
      select: { skill: true },
      orderBy: { skill: "asc" }
    });

    return res.json({ skills: skills.map((item) => item.skill) });
  } catch (error) {
    return next(error);
  }
});

module.exports = { usersRouter: router };
