const express = require("express");

const { prisma } = require("../lib/prisma");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();

router.use(requireAuth);

router.get("/", async (req, res, next) => {
  try {
    const savedJobs = await prisma.savedJob.findMany({
      where: { userId: req.user.userId },
      include: { post: true },
      orderBy: { createdAt: "desc" }
    });

    return res.json(
      savedJobs.map((savedJob) => ({
        id: savedJob.id,
        postId: savedJob.postId,
        savedAt: savedJob.createdAt,
        post: savedJob.post
      }))
    );
  } catch (error) {
    return next(error);
  }
});

router.post("/:postId", async (req, res, next) => {
  try {
    const postId = Number(req.params.postId);
    if (!Number.isInteger(postId) || postId <= 0) {
      return res.status(400).json({ message: "Invalid post id" });
    }

    const post = await prisma.post.findUnique({ where: { id: postId } });
    if (!post) {
      return res.status(404).json({ message: "Post not found" });
    }

    const savedJob = await prisma.savedJob.upsert({
      where: {
        userId_postId: {
          userId: req.user.userId,
          postId
        }
      },
      create: {
        userId: req.user.userId,
        postId
      },
      update: {}
    });

    return res.status(201).json(savedJob);
  } catch (error) {
    return next(error);
  }
});

router.delete("/:postId", async (req, res, next) => {
  try {
    const postId = Number(req.params.postId);
    if (!Number.isInteger(postId) || postId <= 0) {
      return res.status(400).json({ message: "Invalid post id" });
    }

    await prisma.savedJob.deleteMany({
      where: {
        userId: req.user.userId,
        postId
      }
    });

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
});

module.exports = { savedJobsRouter: router };
