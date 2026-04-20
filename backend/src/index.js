const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");

const { prisma } = require("./lib/prisma");
const { authRouter } = require("./routes/auth.routes");
const { postsRouter } = require("./routes/posts.routes");
const { savedJobsRouter } = require("./routes/saved-jobs.routes");
const { usersRouter } = require("./routes/users.routes");

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 4000);
const corsOrigin = process.env.CORS_ORIGIN || "*";

app.use(
  cors({
    origin: corsOrigin === "*" ? true : corsOrigin.split(",").map((item) => item.trim())
  })
);
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    service: "dragon-jobs-backend",
    timestamp: new Date().toISOString()
  });
});

app.use("/auth", authRouter);
app.use("/posts", postsRouter);
app.use("/saved-jobs", savedJobsRouter);
app.use("/users", usersRouter);

app.use((error, _req, res, _next) => {
  console.error(error);

  const statusCode = Number(error.statusCode) || 500;
  const message = error.message || "Internal server error";
  res.status(statusCode).json({ message });
});

const server = app.listen(port, () => {
  console.log(`Dragon Jobs backend listening on http://localhost:${port}`);
});

async function shutdown(signal) {
  console.log(`${signal} received. Shutting down gracefully...`);
  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
}

process.on("SIGINT", () => shutdown("SIGINT"));
process.on("SIGTERM", () => shutdown("SIGTERM"));
