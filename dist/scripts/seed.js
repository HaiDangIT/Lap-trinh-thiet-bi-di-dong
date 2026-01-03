import prisma from "../config/database.config.js";
import { hashPassword } from "../utils/crypto.util.js";
import { Roles, RolePermissions } from "../config/permissions.config.js";
/**
 * Seed database with sample data
 */
async function seed() {
    try {
        console.log("🌱 Starting database seeding...");
        // Clean existing data (optional - be careful in production!)
        console.log("🧹 Cleaning existing data...");
        await prisma.reminder.deleteMany();
        await prisma.attendee.deleteMany();
        await prisma.eventException.deleteMany();
        await prisma.recurrenceRule.deleteMany();
        await prisma.event.deleteMany();
        await prisma.calendar.deleteMany();
        await prisma.userRole.deleteMany();
        await prisma.roleClaim.deleteMany();
        await prisma.role.deleteMany();
        await prisma.user.deleteMany();
        // Create roles with permissions
        console.log("🔐 Creating roles and permissions...");
        const adminRole = await prisma.role.create({
            data: {
                name: Roles.ADMIN,
                description: "Administrator with full system access",
                roleClaims: {
                    create: RolePermissions[Roles.ADMIN].map((permission) => ({
                        claimType: "permission",
                        claimValue: permission,
                    })),
                },
            },
        });
        const managerRole = await prisma.role.create({
            data: {
                name: Roles.MANAGER,
                description: "Manager with calendar and event management permissions",
                roleClaims: {
                    create: RolePermissions[Roles.MANAGER].map((permission) => ({
                        claimType: "permission",
                        claimValue: permission,
                    })),
                },
            },
        });
        const userRole = await prisma.role.create({
            data: {
                name: Roles.USER,
                description: "Regular user with basic permissions",
                roleClaims: {
                    create: RolePermissions[Roles.USER].map((permission) => ({
                        claimType: "permission",
                        claimValue: permission,
                    })),
                },
            },
        });
        console.log(`✅ Created 3 roles with permissions`);
        // Create users
        console.log("👤 Creating users...");
        const user1 = await prisma.user.create({
            data: {
                email: "admin@example.com",
                passwordHash: hashPassword("admin123"),
                fullName: "Admin User",
                timezone: "Asia/Ho_Chi_Minh",
                userRoles: {
                    create: {
                        roleId: adminRole.id,
                    },
                },
            },
        });
        const user2 = await prisma.user.create({
            data: {
                email: "manager@example.com",
                passwordHash: hashPassword("manager123"),
                fullName: "Manager User",
                timezone: "America/New_York",
                userRoles: {
                    create: {
                        roleId: managerRole.id,
                    },
                },
            },
        });
        const user3 = await prisma.user.create({
            data: {
                email: "user@example.com",
                passwordHash: hashPassword("user123"),
                fullName: "Regular User",
                timezone: "Europe/London",
                userRoles: {
                    create: {
                        roleId: userRole.id,
                    },
                },
            },
        });
        console.log(`✅ Created 3 users with roles`);
        // Create calendars
        console.log("📅 Creating calendars...");
        const workCalendar = await prisma.calendar.create({
            data: {
                name: "Work",
                colorCode: "#039BE5",
                isPrimary: true,
                userId: user1.id,
            },
        });
        const personalCalendar = await prisma.calendar.create({
            data: {
                name: "Personal",
                colorCode: "#33B679",
                isPrimary: false,
                userId: user1.id,
            },
        });
        const familyCalendar = await prisma.calendar.create({
            data: {
                name: "Family",
                colorCode: "#E67C73",
                isPrimary: false,
                userId: user1.id,
            },
        });
        const user2Calendar = await prisma.calendar.create({
            data: {
                name: "My Calendar",
                colorCode: "#8E24AA",
                isPrimary: true,
                userId: user2.id,
            },
        });
        console.log(`✅ Created ${4} calendars`);
        // Create events
        console.log("📆 Creating events...");
        // Event 1: Team Meeting (Recurring - Every Monday)
        const teamMeeting = await prisma.event.create({
            data: {
                title: "Team Meeting",
                description: "Weekly team sync-up meeting",
                location: "Conference Room A",
                startTime: new Date("2026-01-05T09:00:00Z"),
                endTime: new Date("2026-01-05T10:00:00Z"),
                isAllDay: false,
                isRecurring: true,
                calendarId: workCalendar.id,
                creatorId: user1.id,
                recurrenceRule: {
                    create: {
                        frequency: "WEEKLY",
                        interval: 1,
                        byDay: "MO",
                    },
                },
                attendees: {
                    create: [
                        {
                            email: user1.email,
                            name: user1.fullName,
                            responseStatus: "accepted",
                        },
                        {
                            email: user2.email,
                            name: user2.fullName,
                            responseStatus: "needsAction",
                        },
                        {
                            email: user3.email,
                            name: user3.fullName,
                            responseStatus: "needsAction",
                        },
                    ],
                },
                reminders: {
                    create: [
                        {
                            minutesBefore: 15,
                            method: "PUSH",
                        },
                        {
                            minutesBefore: 60,
                            method: "EMAIL",
                        },
                    ],
                },
            },
        });
        // Event 2: Project Deadline
        const projectDeadline = await prisma.event.create({
            data: {
                title: "Project Alpha Deadline",
                description: "Final submission for Project Alpha",
                startTime: new Date("2026-01-15T00:00:00Z"),
                endTime: new Date("2026-01-15T23:59:59Z"),
                isAllDay: true,
                isRecurring: false,
                calendarId: workCalendar.id,
                creatorId: user1.id,
                reminders: {
                    create: [
                        {
                            minutesBefore: 1440, // 1 day before
                            method: "PUSH",
                        },
                    ],
                },
            },
        });
        // Event 3: Gym Session (Recurring - Monday, Wednesday, Friday)
        const gymSession = await prisma.event.create({
            data: {
                title: "Gym Session",
                description: "Morning workout",
                location: "Downtown Gym",
                startTime: new Date("2026-01-06T06:00:00Z"),
                endTime: new Date("2026-01-06T07:00:00Z"),
                isAllDay: false,
                isRecurring: true,
                calendarId: personalCalendar.id,
                creatorId: user1.id,
                recurrenceRule: {
                    create: {
                        frequency: "WEEKLY",
                        interval: 1,
                        byDay: "MO,WE,FR",
                        count: 20, // 20 sessions
                    },
                },
                reminders: {
                    create: [
                        {
                            minutesBefore: 30,
                            method: "PUSH",
                        },
                    ],
                },
            },
        });
        // Event 4: Doctor Appointment
        const doctorAppt = await prisma.event.create({
            data: {
                title: "Doctor Appointment",
                description: "Annual health checkup",
                location: "City Hospital",
                startTime: new Date("2026-01-20T14:00:00Z"),
                endTime: new Date("2026-01-20T15:00:00Z"),
                isAllDay: false,
                isRecurring: false,
                calendarId: personalCalendar.id,
                creatorId: user1.id,
                reminders: {
                    create: [
                        {
                            minutesBefore: 60,
                            method: "PUSH",
                        },
                        {
                            minutesBefore: 1440, // 1 day
                            method: "EMAIL",
                        },
                    ],
                },
            },
        });
        // Event 5: Family Dinner (Recurring - Every Sunday)
        const familyDinner = await prisma.event.create({
            data: {
                title: "Family Dinner",
                description: "Sunday family gathering",
                location: "Home",
                startTime: new Date("2026-01-04T18:00:00Z"),
                endTime: new Date("2026-01-04T20:00:00Z"),
                isAllDay: false,
                isRecurring: true,
                calendarId: familyCalendar.id,
                creatorId: user1.id,
                recurrenceRule: {
                    create: {
                        frequency: "WEEKLY",
                        interval: 1,
                        byDay: "SU",
                    },
                },
            },
        });
        // Event 6: Birthday Party
        const birthday = await prisma.event.create({
            data: {
                title: "Mom's Birthday Party",
                description: "Celebrate at the restaurant",
                location: "Le Petit Restaurant",
                startTime: new Date("2026-01-25T19:00:00Z"),
                endTime: new Date("2026-01-25T22:00:00Z"),
                isAllDay: false,
                isRecurring: false,
                calendarId: familyCalendar.id,
                creatorId: user1.id,
                attendees: {
                    create: [
                        {
                            email: user1.email,
                            name: user1.fullName,
                            responseStatus: "accepted",
                        },
                        {
                            email: "dad@family.com",
                            name: "Dad",
                            responseStatus: "accepted",
                        },
                        {
                            email: "sister@family.com",
                            name: "Sister",
                            responseStatus: "tentative",
                        },
                    ],
                },
                reminders: {
                    create: [
                        {
                            minutesBefore: 120,
                            method: "PUSH",
                        },
                    ],
                },
            },
        });
        // Event 7: Daily Standup (Recurring - Every weekday)
        const dailyStandup = await prisma.event.create({
            data: {
                title: "Daily Standup",
                description: "15-minute daily sync",
                location: "Virtual - Zoom",
                startTime: new Date("2026-01-05T02:00:00Z"),
                endTime: new Date("2026-01-05T02:15:00Z"),
                isAllDay: false,
                isRecurring: true,
                calendarId: workCalendar.id,
                creatorId: user1.id,
                recurrenceRule: {
                    create: {
                        frequency: "WEEKLY",
                        interval: 1,
                        byDay: "MO,TU,WE,TH,FR",
                    },
                },
                reminders: {
                    create: [
                        {
                            minutesBefore: 5,
                            method: "PUSH",
                        },
                    ],
                },
            },
        });
        // User 2's events
        const user2Event = await prisma.event.create({
            data: {
                title: "Client Presentation",
                description: "Quarterly results presentation",
                location: "Client Office",
                startTime: new Date("2026-01-12T14:00:00Z"),
                endTime: new Date("2026-01-12T16:00:00Z"),
                isAllDay: false,
                isRecurring: false,
                calendarId: user2Calendar.id,
                creatorId: user2.id,
                reminders: {
                    create: [
                        {
                            minutesBefore: 30,
                            method: "PUSH",
                        },
                    ],
                },
            },
        });
        console.log(`✅ Created ${8} events`);
        // Create an exception for one recurring event
        console.log("⚠️  Creating event exception...");
        await prisma.eventException.create({
            data: {
                eventId: teamMeeting.id,
                originalStartTime: new Date("2026-01-12T09:00:00Z"),
                isCancelled: false,
                newStartTime: new Date("2026-01-12T10:00:00Z"), // Moved 1 hour later
                newEndTime: new Date("2026-01-12T11:00:00Z"),
                updatedTitle: "Team Meeting (Rescheduled)",
            },
        });
        console.log("✅ Created event exception");
        // Summary
        console.log("\n✨ Database seeding completed successfully!");
        console.log("\n📊 Summary:");
        console.log(`   Users: ${3}`);
        console.log(`   Calendars: ${4}`);
        console.log(`   Events: ${8}`);
        console.log(`   Attendees: ${await prisma.attendee.count()}`);
        console.log(`   Reminders: ${await prisma.reminder.count()}`);
        console.log(`   Recurrence Rules: ${await prisma.recurrenceRule.count()}`);
        console.log(`   Event Exceptions: ${1}`);
        console.log("\n🔐 Test Credentials:");
        console.log("   Admin:");
        console.log("     Email: admin@example.com");
        console.log("     Password: admin123");
        console.log("     User ID:", user1.id);
        console.log("\n   Manager:");
        console.log("     Email: manager@example.com");
        console.log("     Password: manager123");
        console.log("     User ID:", user2.id);
        console.log("\n   Regular User:");
        console.log("     Email: user@example.com");
        console.log("     Password: user123");
        console.log("     User ID:", user3.id);
    }
    catch (error) {
        console.error("❌ Error seeding database:", error);
        throw error;
    }
    finally {
        await prisma.$disconnect();
    }
}
// Run seed
seed().catch((error) => {
    console.error(error);
    process.exit(1);
});
//# sourceMappingURL=seed.js.map