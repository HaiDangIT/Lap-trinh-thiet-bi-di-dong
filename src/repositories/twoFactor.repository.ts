import prisma from "../config/database.config.js";
import type { TwoFactor } from "@prisma/client";

export async function create(data: {
  userId: string;
  secret: string;
  backupCodes: string[];
}): Promise<TwoFactor> {
  return prisma.twoFactor.create({
    data,
  });
}

export async function findByUserId(userId: string): Promise<TwoFactor | null> {
  return prisma.twoFactor.findUnique({
    where: { userId },
  });
}

export async function updateStatus(
  userId: string,
  isEnabled: boolean
): Promise<TwoFactor> {
  return prisma.twoFactor.update({
    where: { userId },
    data: { isEnabled },
  });
}

export async function update(
  userId: string,
  data: Partial<{ secret: string; backupCodes: string[]; isEnabled: boolean }>
): Promise<TwoFactor> {
  return prisma.twoFactor.update({
    where: { userId },
    data,
  });
}

export async function updateBackupCodes(
  userId: string,
  backupCodes: string[]
): Promise<TwoFactor> {
  return prisma.twoFactor.update({
    where: { userId },
    data: { backupCodes },
  });
}

export async function remove(userId: string): Promise<void> {
  await prisma.twoFactor.delete({
    where: { userId },
  });
}
