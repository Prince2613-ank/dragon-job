const express = require("express");

const { PostType } = require("@prisma/client");
const { prisma } = require("../lib/prisma");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();

const allowedPostTypes = new Set(Object.values(PostType));

function serializePost(post) {
  return {
    id: post.id,
    postType: post.postType,
    role: post.role,
    company: post.company,
    salary: post.salary,
    location: post.location,
    description: post.description,
    createdById: post.createdById,
    createdAt: post.createdAt
  };
}

router.get("/", async (req, res, next) => {
  try {
    const { type } = req.query || {};

    if (type && !allowedPostTypes.has(type)) {
      return res.status(400).json({
        message: "Invalid type. Allowed: job, internship, daily_wage"
      });
    }

    const posts = await prisma.post.findMany({
      where: type ? { postType: type } : undefined,
      orderBy: { createdAt: "desc" }
    });

    return res.json(posts.map(serializePost));
  } catch (error) {
    return next(error);
  }
});

router.get("/:id", async (req, res, next) => {
  try {
    const postId = Number(req.params.id);
    if (!Number.isInteger(postId) || postId <= 0) {
      return res.status(400).json({ message: "Invalid post id" });
    }

    const post = await prisma.post.findUnique({ where: { id: postId } });
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    return res.json(serializePost(post));
  } catch (error) {
    return next(error);
  }
});

router.post("/", requireAuth, async (req, res, next) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({
        message: "Only admin users can create posts"
      });
    }

    const { postType, role, company, salary, location, description } = req.body || {};

    if (!postType || !role || !company || !salary || !location || !description) {
      return res.status(400).json({ message: "All post fields are required" });
    }

    if (!allowedPostTypes.has(postType)) {
      return res.status(400).json({
        message: "Invalid postType. Allowed: job, internship, daily_wage"
      });
    }

    const post = await prisma.post.create({
      data: {
        postType,
        role: String(role).trim(),
        company: String(company).trim(),
        salary: String(salary).trim(),
        location: String(location).trim(),
        description: String(description).trim(),
        createdById: req.user.userId
      }
    });

    return res.status(201).json(serializePost(post));
  } catch (error) {
    return next(error);
  }
});

module.exports = { postsRouter: router };
