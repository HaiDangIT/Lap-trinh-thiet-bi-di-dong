import {} from "@prisma/client";
import calendarRepository from "../repositories/calendar.repository.js";
import userRepository from "../repositories/user.repository.js";
import { ValidationError, NotFoundError, ForbiddenError, } from "../utils/errors.js";
export class CalendarService {
    /**
     * Tạo calendar mới
     */
    async createCalendar(userId, dto) {
        // Kiểm tra user tồn tại
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new NotFoundError("User not found");
        }
        // Nếu đây là primary calendar và user chưa có primary calendar nào
        let isPrimary = dto.isPrimary || false;
        const existingPrimary = await calendarRepository.findPrimaryByUserId(userId);
        if (!existingPrimary) {
            // Đây là calendar đầu tiên, tự động set làm primary
            isPrimary = true;
        }
        const calendar = await calendarRepository.create({
            name: dto.name,
            colorCode: dto.colorCode || "#039BE5",
            isPrimary,
            user: {
                connect: { id: userId },
            },
        });
        return calendar;
    }
    /**
     * Lấy tất cả calendars của user
     */
    async getUserCalendars(userId) {
        return calendarRepository.findByUserId(userId);
    }
    /**
     * Lấy calendar theo ID
     */
    async getCalendarById(id, userId) {
        const calendar = await calendarRepository.findById(id);
        if (!calendar) {
            throw new NotFoundError("Calendar not found");
        }
        // Kiểm tra quyền truy cập
        if (calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this calendar");
        }
        return calendar;
    }
    /**
     * Cập nhật calendar
     */
    async updateCalendar(id, userId, dto) {
        const calendar = await calendarRepository.findById(id);
        if (!calendar) {
            throw new NotFoundError("Calendar not found");
        }
        // Kiểm tra quyền
        if (calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this calendar");
        }
        const updateData = {};
        if (dto.name !== undefined) {
            updateData.name = dto.name;
        }
        if (dto.colorCode !== undefined) {
            updateData.colorCode = dto.colorCode;
        }
        // Nếu set làm primary
        if (dto.isPrimary === true) {
            return calendarRepository.setPrimary(id, userId);
        }
        return calendarRepository.update(id, updateData);
    }
    /**
     * Xóa calendar
     */
    async deleteCalendar(id, userId) {
        const calendar = await calendarRepository.findById(id);
        if (!calendar) {
            throw new NotFoundError("Calendar not found");
        }
        // Kiểm tra quyền
        if (calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this calendar");
        }
        // Không cho xóa primary calendar nếu còn calendar khác
        if (calendar.isPrimary) {
            const calendarsCount = await calendarRepository.countByUserId(userId);
            if (calendarsCount > 1) {
                throw new ValidationError("Cannot delete primary calendar. Please set another calendar as primary first.");
            }
        }
        await calendarRepository.delete(id);
    }
    /**
     * Set calendar làm primary
     */
    async setPrimaryCalendar(id, userId) {
        const calendar = await calendarRepository.findById(id);
        if (!calendar) {
            throw new NotFoundError("Calendar not found");
        }
        // Kiểm tra quyền
        if (calendar.userId !== userId) {
            throw new ForbiddenError("You do not have access to this calendar");
        }
        return calendarRepository.setPrimary(id, userId);
    }
}
export default new CalendarService();
//# sourceMappingURL=calendar.service.js.map