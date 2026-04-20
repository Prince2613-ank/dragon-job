const { PrismaClient, PostType } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  const postCount = await prisma.post.count();

  if (postCount > 0) {
    console.log("Seed skipped: posts already exist.");
    return;
  }

  await prisma.post.createMany({
    data: [
      {
        postType: PostType.job,
        role: "Flutter Developer",
        company: "TechNova",
        salary: "12 LPA",
        location: "Bengaluru",
        description: "Build and maintain mobile features with Flutter."
      },
      {
        postType: PostType.internship,
        role: "Software Engineer Intern",
        company: "LaunchPad Labs",
        salary: "25000 / month",
        location: "Remote",
        description: "Support product teams in delivering app features."
      },
      {
        postType: PostType.daily_wage,
        role: "Electrician",
        company: "QuickFix Services",
        salary: "1200 / day",
        location: "Pune",
        description: "On-demand site visits for residential electrical work."
      }
    ]
  });

  console.log("Seed completed: sample posts inserted.");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
