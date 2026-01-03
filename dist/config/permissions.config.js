// Permission constants for RBAC
export const Permissions = {
    // User permissions
    USER_READ: "user:read",
    USER_WRITE: "user:write",
    USER_DELETE: "user:delete",
    USER_MANAGE_ROLES: "user:manage-roles",
    // Calendar permissions
    CALENDAR_READ: "calendar:read",
    CALENDAR_WRITE: "calendar:write",
    CALENDAR_DELETE: "calendar:delete",
    CALENDAR_SHARE: "calendar:share",
    // Event permissions
    EVENT_READ: "event:read",
    EVENT_WRITE: "event:write",
    EVENT_DELETE: "event:delete",
    EVENT_MANAGE_ATTENDEES: "event:manage-attendees",
    // Admin permissions
    ADMIN_MANAGE_USERS: "admin:manage-users",
    ADMIN_MANAGE_ROLES: "admin:manage-roles",
    ADMIN_VIEW_LOGS: "admin:view-logs",
    ADMIN_SYSTEM_CONFIG: "admin:system-config",
};
// Role constants
export const Roles = {
    ADMIN: "ADMIN",
    MANAGER: "MANAGER",
    USER: "USER",
};
// Role permissions mapping
export const RolePermissions = {
    [Roles.ADMIN]: [
        // All permissions
        Permissions.USER_READ,
        Permissions.USER_WRITE,
        Permissions.USER_DELETE,
        Permissions.USER_MANAGE_ROLES,
        Permissions.CALENDAR_READ,
        Permissions.CALENDAR_WRITE,
        Permissions.CALENDAR_DELETE,
        Permissions.CALENDAR_SHARE,
        Permissions.EVENT_READ,
        Permissions.EVENT_WRITE,
        Permissions.EVENT_DELETE,
        Permissions.EVENT_MANAGE_ATTENDEES,
        Permissions.ADMIN_MANAGE_USERS,
        Permissions.ADMIN_MANAGE_ROLES,
        Permissions.ADMIN_VIEW_LOGS,
        Permissions.ADMIN_SYSTEM_CONFIG,
    ],
    [Roles.MANAGER]: [
        // Manager can read users and manage calendars/events
        Permissions.USER_READ,
        Permissions.CALENDAR_READ,
        Permissions.CALENDAR_WRITE,
        Permissions.CALENDAR_DELETE,
        Permissions.CALENDAR_SHARE,
        Permissions.EVENT_READ,
        Permissions.EVENT_WRITE,
        Permissions.EVENT_DELETE,
        Permissions.EVENT_MANAGE_ATTENDEES,
    ],
    [Roles.USER]: [
        // Basic user permissions
        Permissions.USER_READ,
        Permissions.CALENDAR_READ,
        Permissions.CALENDAR_WRITE,
        Permissions.EVENT_READ,
        Permissions.EVENT_WRITE,
    ],
};
//# sourceMappingURL=permissions.config.js.map