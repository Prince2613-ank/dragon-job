const { PrismaClient, PostType, UserRole } = require("@prisma/client");
const bcrypt = require("bcryptjs");

const prisma = new PrismaClient();

const seedPosts = [
  {
    postType: PostType.job,
    role: "Flutter Developer",
    company: "TechNova",
    salary: "12 LPA",
    location: "Bengaluru",
    description: "Build and maintain mobile features with Flutter and Dart."
  },
  {
    postType: PostType.job,
    role: "Backend Node.js Engineer",
    company: "CloudForge",
    salary: "14 LPA",
    location: "Hyderabad",
    description: "Design APIs, optimize PostgreSQL queries, and improve backend reliability."
  },
  {
    postType: PostType.job,
    role: "QA Automation Engineer",
    company: "FinStack",
    salary: "10 LPA",
    location: "Pune",
    description: "Write automation suites and improve release confidence for mobile apps."
  },
  {
    postType: PostType.job,
    role: "UI/UX Designer",
    company: "PixelBridge",
    salary: "9 LPA",
    location: "Mumbai",
    description: "Create app flows, prototypes, and high-fidelity interfaces."
  },
  {
    postType: PostType.job,
    role: "DevOps Engineer",
    company: "ScaleGrid",
    salary: "16 LPA",
    location: "Remote",
    description: "Own CI/CD, infrastructure automation, and cloud deployment processes."
  },
  {
    postType: PostType.job,
    role: "React Native Developer",
    company: "AppOrbit",
    salary: "11 LPA",
    location: "Chennai",
    description: "Ship cross-platform features and improve app performance."
  },
  {
    postType: PostType.internship,
    role: "Software Engineer Intern",
    company: "LaunchPad Labs",
    salary: "25000 / month",
    location: "Remote",
    description: "Support product teams in delivering app features and bug fixes."
  },
  {
    postType: PostType.internship,
    role: "Data Analyst Intern",
    company: "InsightHive",
    salary: "18000 / month",
    location: "Delhi",
    description: "Work on dashboards, SQL reports, and product analytics tracking."
  },
  {
    postType: PostType.internship,
    role: "Product Management Intern",
    company: "ShipFast",
    salary: "22000 / month",
    location: "Bengaluru",
    description: "Assist with feature specs, roadmap tracking, and user research."
  },
  {
    postType: PostType.internship,
    role: "Cybersecurity Intern",
    company: "SecureLayer",
    salary: "20000 / month",
    location: "Noida",
    description: "Participate in vulnerability assessment and security hardening tasks."
  },
  {
    postType: PostType.internship,
    role: "AI/ML Intern",
    company: "NeuronWorks",
    salary: "30000 / month",
    location: "Hyderabad",
    description: "Help train and evaluate models used in recommendation systems."
  },
  {
    postType: PostType.internship,
    role: "Mobile App Intern",
    company: "CodeCanvas",
    salary: "21000 / month",
    location: "Kolkata",
    description: "Implement Flutter UI components and integrate REST APIs."
  },
  {
    postType: PostType.daily_wage,
    role: "Electrician",
    company: "QuickFix Services",
    salary: "1200 / day",
    location: "Pune",
    description: "On-demand site visits for residential electrical work."
  },
  {
    postType: PostType.daily_wage,
    role: "Plumber",
    company: "HomeRescue",
    salary: "1000 / day",
    location: "Ahmedabad",
    description: "Fix leaks, install fittings, and perform maintenance work."
  },
  {
    postType: PostType.daily_wage,
    role: "Carpenter",
    company: "WoodCraft",
    salary: "1300 / day",
    location: "Jaipur",
    description: "Furniture repair, installation, and custom carpentry tasks."
  },
  {
    postType: PostType.daily_wage,
    role: "Painter",
    company: "ColorCrew",
    salary: "900 / day",
    location: "Lucknow",
    description: "Interior and exterior painting for homes and small offices."
  },
  {
    postType: PostType.daily_wage,
    role: "AC Technician",
    company: "CoolCare",
    salary: "1500 / day",
    location: "Gurugram",
    description: "Install and service AC units at customer locations."
  },
  {
    postType: PostType.daily_wage,
    role: "Delivery Rider",
    company: "SwiftDrop",
    salary: "800 / day",
    location: "Mumbai",
    description: "City-based pickup and delivery work with flexible shifts."
  }
];

function resolveAdminEmail() {
  const adminEmails = (process.env.ADMIN_EMAILS || "")
    .split(",")
    .map((email) => email.trim().toLowerCase())
    .filter(Boolean);

  if (adminEmails.length > 0) {
    return adminEmails[0];
  }

  return process.env.SEED_ADMIN_EMAIL || "admin@dragonjobs.local";
}

async function upsertSeedUsers() {
  const adminEmail = resolveAdminEmail();
  const userEmail = process.env.SEED_USER_EMAIL || "user@dragonjobs.local";
  const password = process.env.SEED_DEFAULT_PASSWORD || "Password@123";
  const passwordHash = await bcrypt.hash(password, 10);

  const adminUser = await prisma.user.upsert({
    where: { email: adminEmail },
    update: {
      name: "Admin User",
      role: UserRole.admin,
      passwordHash
    },
    create: {
      name: "Admin User",
      email: adminEmail,
      role: UserRole.admin,
      passwordHash
    }
  });

  await prisma.user.upsert({
    where: { email: userEmail },
    update: {
      name: "Normal User",
      role: UserRole.user,
      passwordHash
    },
    create: {
      name: "Normal User",
      email: userEmail,
      role: UserRole.user,
      passwordHash
    }
  });

  return adminUser;
}

async function upsertSeedPosts(createdById) {
  let inserted = 0;
  let skipped = 0;

  for (const post of seedPosts) {
    const existing = await prisma.post.findFirst({
      where: {
        postType: post.postType,
        role: post.role,
        company: post.company,
        location: post.location
      }
    });

    if (existing) {
      skipped += 1;
      continue;
    }

    await prisma.post.create({
      data: {
        ...post,
        createdById
      }
    });

    inserted += 1;
  }

  return { inserted, skipped, total: seedPosts.length };
}

async function main() {
  const adminUser = await upsertSeedUsers();
  const result = await upsertSeedPosts(adminUser.id);

  console.log(`Seed completed: inserted ${result.inserted}, skipped ${result.skipped}, total ${result.total}.`);
  console.log(`Admin seed user: ${adminUser.email}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
