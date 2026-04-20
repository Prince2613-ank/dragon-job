const express = require("express");
const multer = require("multer");
const pdfParse = require("pdf-parse");
const mammoth = require("mammoth");
const { PostType } = require("@prisma/client");

const { prisma } = require("../lib/prisma");
const { requireAuth } = require("../middleware/auth");

const router = express.Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }
});

const knownSkills = [
  "HTML",
  "CSS",
  "Flutter",
  "Dart",
  "Firebase",
  "Node.js",
  "Express",
  "PostgreSQL",
  "Prisma",
  "JavaScript",
  "TypeScript",
  "Python",
  "Java",
  "C++",
  "React",
  "React Native",
  "Git",
  "Docker",
  "AWS",
  "GCP",
  "Azure",
  "Machine Learning",
  "AI/ML",
  "Data Analysis",
  "SQL",
  "REST API",
  "UI/UX",
  "Project Management",
  "CI/CD"
];

const allowedPostTypes = new Set(Object.values(PostType));
const nlpStopWords = new Set([
  "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "in", "is", "it",
  "of", "on", "or", "that", "the", "to", "was", "were", "will", "with", "you", "your",
  "we", "our", "they", "their", "this", "these", "those", "can", "should", "must", "have",
  "has", "had", "do", "does", "did", "not", "if", "but", "about", "into", "over", "under"
]);

function extractExtension(filename = "") {
  const parts = String(filename).toLowerCase().split(".");
  return parts.length > 1 ? parts.pop() : "";
}

async function extractTextFromUploadedFile(file) {
  const ext = extractExtension(file.originalname);
  const mime = (file.mimetype || "").toLowerCase();

  if (mime.includes("pdf") || ext === "pdf") {
    const parsed = await pdfParse(file.buffer);
    return parsed.text || "";
  }

  if (
    mime.includes("wordprocessingml.document") ||
    ext === "docx"
  ) {
    const parsed = await mammoth.extractRawText({ buffer: file.buffer });
    return parsed.value || "";
  }

  if (mime.startsWith("text/") || ext === "txt") {
    return file.buffer.toString("utf8");
  }

  throw Object.assign(new Error("Unsupported file format. Use PDF, DOCX, or TXT."), {
    statusCode: 400
  });
}

function normalizeSkill(skill) {
  return String(skill).replace(/\s+/g, " ").trim();
}

function uniqueSkills(skills) {
  const seen = new Set();
  const result = [];

  for (const rawSkill of skills || []) {
    const skill = normalizeSkill(rawSkill);
    if (!skill) continue;
    const key = skill.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    result.push(skill);
  }

  return result;
}

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function containsSkillAsTerm(text, skill) {
  const escaped = escapeRegExp(skill.toLowerCase());
  const pattern = new RegExp(`(^|[^a-z0-9])${escaped}(?=$|[^a-z0-9])`, "i");
  return pattern.test(String(text || "").toLowerCase());
}

function tokenizeForNlp(text) {
  return String(text || "")
    .toLowerCase()
    .replace(/[^a-z0-9+#.\s]/g, " ")
    .split(/\s+/)
    .map((token) => token.trim())
    .filter((token) => token.length > 1 && !nlpStopWords.has(token));
}

function toTermFrequencyMap(tokens) {
  const tf = new Map();
  for (const token of tokens) {
    tf.set(token, (tf.get(token) || 0) + 1);
  }
  return tf;
}

function cosineSimilarity(leftTokens, rightTokens) {
  if (!leftTokens.length || !rightTokens.length) return 0;

  const leftTf = toTermFrequencyMap(leftTokens);
  const rightTf = toTermFrequencyMap(rightTokens);
  const vocab = new Set([...leftTf.keys(), ...rightTf.keys()]);

  let dot = 0;
  let leftNorm = 0;
  let rightNorm = 0;

  for (const term of vocab) {
    const left = leftTf.get(term) || 0;
    const right = rightTf.get(term) || 0;
    dot += left * right;
    leftNorm += left * left;
    rightNorm += right * right;
  }

  if (!leftNorm || !rightNorm) return 0;
  return dot / (Math.sqrt(leftNorm) * Math.sqrt(rightNorm));
}

function heuristicParseResume(text) {
  const normalizedText = text.replace(/\s+/g, " ").trim();
  const lowered = normalizedText.toLowerCase();

  // More accurate skill detection using strict term matching.
  const detectedSkills = knownSkills.filter((skill) => {
    return containsSkillAsTerm(lowered, skill);
  });

  const summary = normalizedText.slice(0, 500);
  const yearMatches = normalizedText.match(/(\d+)\+?\s*(years?|yrs?)/gi) || [];
  const firstYear = yearMatches[0] || "";
  const experienceYears = Number((firstYear.match(/\d+/) || [0])[0]) || 0;

  return {
    summary,
    skills: uniqueSkills(detectedSkills),
    experienceYears,
    strengths: uniqueSkills(detectedSkills).slice(0, 6),
    improvements: []
  };
}

async function callOpenAiJson({ systemPrompt, userPrompt }) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) return null;

  const model = process.env.OPENAI_MODEL || "gpt-4o-mini";

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      model,
      temperature: 0.2,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt }
      ]
    })
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(`OpenAI API error: ${response.status} ${message}`);
  }

  const payload = await response.json();
  const content = payload?.choices?.[0]?.message?.content;

  if (!content) {
    throw new Error("OpenAI response did not include content");
  }

  return JSON.parse(content);
}

async function parseResumeWithAiOrFallback(resumeText) {
  const parserSystemPrompt =
    "You are an expert resume parser. Extract ONLY the skills explicitly mentioned in the resume. Do not infer or assume skills. Return strict JSON only.";
  const parserUserPrompt = `
Extract structured resume data from this text. IMPORTANT: Only extract skills that are EXPLICITLY mentioned in the resume text. Do not infer, assume, or add skills that are not directly stated.

Return JSON exactly with keys:
- summary: string (first 300 chars about the candidate)
- skills: string[] (ONLY skills explicitly mentioned - important: be strict and only include what's actually written)
- experienceYears: number (total years of experience if mentioned)
- strengths: string[] (top 3-6 values/strengths based on resume content)
- improvements: string[] (areas for development if mentioned, otherwise empty array)

Resume text:
${resumeText.slice(0, 20000)}
`;

  try {
    const parsed = await callOpenAiJson({
      systemPrompt: parserSystemPrompt,
      userPrompt: parserUserPrompt
    });

    return {
      parsedResume: {
        summary: String(parsed.summary || ""),
        skills: uniqueSkills(Array.isArray(parsed.skills) ? parsed.skills : []),
        experienceYears: Number(parsed.experienceYears || 0),
        strengths: uniqueSkills(Array.isArray(parsed.strengths) ? parsed.strengths : []),
        improvements: uniqueSkills(Array.isArray(parsed.improvements) ? parsed.improvements : [])
      },
      parserSource: "ai"
    };
  } catch (_error) {
    return {
      parsedResume: heuristicParseResume(resumeText),
      parserSource: "heuristic"
    };
  }
}

function computeHeuristicMatches({ parsedResume, posts, resumeText }) {
  const resumeSkillsLower = new Set(parsedResume.skills.map((s) => s.toLowerCase()));
  const matches = posts.map((post) => {
    const postText = `${post.role} ${post.company} ${post.description} ${post.location}`.toLowerCase();
    const requiredSkills = uniqueSkills(
      knownSkills.filter((skill) => containsSkillAsTerm(postText, skill))
    );

    const matchedSkills = parsedResume.skills.filter((skill) =>
      containsSkillAsTerm(postText, skill)
    );

    const missingSkills = requiredSkills.filter(
      (skill) => !resumeSkillsLower.has(skill.toLowerCase())
    );

    const roleWords = post.role
      .toLowerCase()
      .split(/\s+/)
      .filter((word) => word.length > 2);
    const roleHits = roleWords.filter((word) =>
      resumeText.toLowerCase().includes(word)
    ).length;

    const skillsScore = requiredSkills.length
      ? (matchedSkills.length / requiredSkills.length) * 70
      : Math.min(50, matchedSkills.length * 10);
    const roleScore = Math.min(30, roleHits * 10);
    const score = Math.max(0, Math.min(100, Math.round(skillsScore + roleScore)));

    return {
      postId: post.id,
      score,
      matchedSkills: uniqueSkills(matchedSkills),
      missingSkills: uniqueSkills(missingSkills),
      reason:
        matchedSkills.length > 0
          ? `Resume overlaps with ${matchedSkills.slice(0, 3).join(", ")}.`
          : "Limited overlap detected from resume keywords."
    };
  });

  return matches.sort((a, b) => b.score - a.score);
}

function computeNlpMatches({ parsedResume, posts, resumeText }) {
  const resumeSkillSet = new Set(parsedResume.skills.map((skill) => skill.toLowerCase()));
  const resumeCorpus = `${resumeText} ${parsedResume.summary} ${parsedResume.skills.join(" ")}`;
  const resumeTokens = tokenizeForNlp(resumeCorpus);
  const resumeTokenSet = new Set(resumeTokens);

  const matches = posts.map((post) => {
    const postText = `${post.role} ${post.company} ${post.description} ${post.location}`;
    const postLower = postText.toLowerCase();
    const roleTokens = tokenizeForNlp(post.role);
    const postTokens = tokenizeForNlp(postText);

    const requiredSkills = uniqueSkills(
      knownSkills.filter((skill) => containsSkillAsTerm(postLower, skill))
    );

    const matchedSkills = uniqueSkills(
      requiredSkills.filter((skill) => resumeSkillSet.has(skill.toLowerCase()))
    );

    const missingSkills = uniqueSkills(
      requiredSkills.filter((skill) => !resumeSkillSet.has(skill.toLowerCase()))
    );

    const skillMatchRatio = requiredSkills.length
      ? matchedSkills.length / requiredSkills.length
      : 0;
    const skillScore = skillMatchRatio * 45;

    const semanticSimilarity = cosineSimilarity(resumeTokens, postTokens);
    const semanticScore = semanticSimilarity * 35;

    const roleHits = roleTokens.filter((token) => resumeTokenSet.has(token)).length;
    const roleScore = roleTokens.length ? (roleHits / roleTokens.length) * 20 : 0;

    const score = Math.max(
      0,
      Math.min(100, Math.round(skillScore + semanticScore + roleScore))
    );

    const reason = matchedSkills.length
      ? `NLP alignment found on ${matchedSkills.slice(0, 3).join(", ")} with ${Math.round(
          semanticSimilarity * 100
        )}% semantic similarity.`
      : `NLP semantic similarity is ${Math.round(
          semanticSimilarity * 100
        )}% with limited explicit skill overlap.`;

    return {
      postId: post.id,
      score,
      matchedSkills,
      missingSkills,
      reason
    };
  });

  return matches.sort((a, b) => b.score - a.score);
}

function blendAiWithNlpMatches(aiMatches, nlpMatches) {
  const nlpByPostId = new Map(nlpMatches.map((item) => [item.postId, item]));
  const aiByPostId = new Map(aiMatches.map((item) => [item.postId, item]));
  const postIds = new Set([...nlpByPostId.keys(), ...aiByPostId.keys()]);

  const blended = [...postIds].map((postId) => {
    const ai = aiByPostId.get(postId);
    const nlp = nlpByPostId.get(postId);

    if (ai && nlp) {
      return {
        postId,
        score: Math.round(ai.score * 0.65 + nlp.score * 0.35),
        matchedSkills: uniqueSkills([...ai.matchedSkills, ...nlp.matchedSkills]),
        missingSkills: uniqueSkills([...ai.missingSkills, ...nlp.missingSkills]),
        reason: ai.reason || nlp.reason
      };
    }

    return ai || nlp;
  });

  return blended.sort((a, b) => b.score - a.score);
}

async function computeAiMatches({ parsedResume, posts, resumeText }) {
  const matcherSystemPrompt =
    "You are a resume-job matching engine. Return strict JSON only.";

  const matcherUserPrompt = `
Given this resume and these jobs, score each job from 0 to 100.
Return JSON with key: matches (array).
Each item must contain:
- postId: number
- score: number
- matchedSkills: string[]
- missingSkills: string[]
- reason: string

Resume:
${JSON.stringify(
    {
      summary: parsedResume.summary,
      skills: parsedResume.skills,
      experienceYears: parsedResume.experienceYears,
      strengths: parsedResume.strengths,
      text: resumeText.slice(0, 10000)
    },
    null,
    2
  )}

Jobs:
${JSON.stringify(
    posts.map((post) => ({
      postId: post.id,
      role: post.role,
      company: post.company,
      location: post.location,
      postType: post.postType,
      description: post.description
    })),
    null,
    2
  )}
`;

  const parsed = await callOpenAiJson({
    systemPrompt: matcherSystemPrompt,
    userPrompt: matcherUserPrompt
  });

  if (!parsed || !Array.isArray(parsed.matches)) {
    throw new Error("Invalid AI match response");
  }

  const mapByPostId = new Map(posts.map((post) => [post.id, post]));
  const normalized = parsed.matches
    .map((item) => ({
      postId: Number(item.postId),
      score: Math.max(0, Math.min(100, Math.round(Number(item.score) || 0))),
      matchedSkills: uniqueSkills(Array.isArray(item.matchedSkills) ? item.matchedSkills : []),
      missingSkills: uniqueSkills(Array.isArray(item.missingSkills) ? item.missingSkills : []),
      reason: String(item.reason || "")
    }))
    .filter((item) => mapByPostId.has(item.postId));

  return normalized.sort((a, b) => b.score - a.score);
}

function calculateProfileCompletion({ parsedResume, topMatch }) {
  let score = 0;
  if (parsedResume.summary) score += 25;
  if (parsedResume.skills.length >= 3) score += 25;
  if (parsedResume.experienceYears > 0) score += 20;
  if (topMatch && topMatch.score > 0) score += 30;
  return Math.min(100, score);
}

router.post("/analyze-resume", requireAuth, upload.single("resume"), async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "Resume file is required" });
    }

    const postType = req.query.type ? String(req.query.type) : undefined;
    if (postType && !allowedPostTypes.has(postType)) {
      return res.status(400).json({
        message: "Invalid type. Allowed: job, internship, daily_wage"
      });
    }
    const resumeTextRaw = await extractTextFromUploadedFile(req.file);
    const resumeText = resumeTextRaw.replace(/\s+/g, " ").trim();

    if (!resumeText) {
      return res.status(400).json({ message: "Could not extract text from resume" });
    }

    const posts = await prisma.post.findMany({
      where: postType ? { postType } : undefined,
      orderBy: { createdAt: "desc" },
      take: 50
    });

    const { parsedResume, parserSource } = await parseResumeWithAiOrFallback(resumeText);

    const extractedSkills = uniqueSkills(parsedResume.skills);

    // Include user-managed skills so manual profile updates improve analysis quality.
    const userSkills = await prisma.userSkill.findMany({
      where: { userId: req.user.userId },
      select: { skill: true }
    });
    const profileSkills = uniqueSkills(userSkills.map((item) => item.skill));
    const effectiveSkills = uniqueSkills([...extractedSkills, ...profileSkills]);

    const parsedResumeForMatching = {
      ...parsedResume,
      extractedSkills,
      profileSkills,
      skills: effectiveSkills
    };

    // Persist parsed skills for the authenticated user so skills are user-scoped.
    const parsedSkills = extractedSkills;
    if (parsedSkills.length > 0) {
      await prisma.userSkill.createMany({
        data: parsedSkills.map((skill) => ({
          userId: req.user.userId,
          skill
        })),
        skipDuplicates: true
      });
    }

    let matches = [];
    let matcherSource = "nlp";
    const nlpMatches = computeNlpMatches({ parsedResume: parsedResumeForMatching, posts, resumeText });

    try {
      const aiMatches = await computeAiMatches({ parsedResume: parsedResumeForMatching, posts, resumeText });
      matches = blendAiWithNlpMatches(aiMatches, nlpMatches);
      matcherSource = "ai+nlp";
    } catch (_error) {
      matches = nlpMatches;
    }

    const topMatches = matches.slice(0, 5);
    const topMatch = topMatches[0];
    const matchByPostId = new Map(topMatches.map((item) => [item.postId, item]));

    const recommendedJobs = topMatches.map((match) => {
      const post = posts.find((item) => item.id === match.postId);
      return {
        postId: match.postId,
        score: match.score,
        matchedSkills: match.matchedSkills,
        missingSkills: match.missingSkills,
        reason: match.reason,
        post
      };
    });

    const profileCompletion = calculateProfileCompletion({
      parsedResume: parsedResumeForMatching,
      topMatch
    });

    return res.json({
      parsedResume: parsedResumeForMatching,
      matchScore: topMatch ? topMatch.score : 0,
      matchedSkills: topMatch ? topMatch.matchedSkills : [],
      missingSkills: topMatch ? topMatch.missingSkills : [],
      profileCompletion,
      recommendedJobs,
      source: {
        parser: parserSource,
        matcher: matcherSource
      },
      meta: {
        extractedTextLength: resumeText.length,
        evaluatedPostCount: posts.length,
        matchedPostCount: matchByPostId.size
      }
    });
  } catch (error) {
    return next(error);
  }
});

module.exports = { aiRouter: router };
