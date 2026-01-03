import prisma from "../config/database.config.js";
export async function create(data) {
    return prisma.twoFactor.create({
        data,
    });
}
export async function findByUserId(userId) {
    return prisma.twoFactor.findUnique({
        where: { userId },
    });
}
export async function updateStatus(userId, isEnabled) {
    return prisma.twoFactor.update({
        where: { userId },
        data: { isEnabled },
    });
}
export async function update(userId, data) {
    return prisma.twoFactor.update({
        where: { userId },
        data,
    });
}
export async function updateBackupCodes(userId, backupCodes) {
    return prisma.twoFactor.update({
        where: { userId },
        data: { backupCodes },
    });
}
export async function remove(userId) {
    await prisma.twoFactor.delete({
        where: { userId },
    });
}
//# sourceMappingURL=twoFactor.repository.js.map