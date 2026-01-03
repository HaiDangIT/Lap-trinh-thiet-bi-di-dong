export declare const Permissions: {
    readonly USER_READ: "user:read";
    readonly USER_WRITE: "user:write";
    readonly USER_DELETE: "user:delete";
    readonly USER_MANAGE_ROLES: "user:manage-roles";
    readonly CALENDAR_READ: "calendar:read";
    readonly CALENDAR_WRITE: "calendar:write";
    readonly CALENDAR_DELETE: "calendar:delete";
    readonly CALENDAR_SHARE: "calendar:share";
    readonly EVENT_READ: "event:read";
    readonly EVENT_WRITE: "event:write";
    readonly EVENT_DELETE: "event:delete";
    readonly EVENT_MANAGE_ATTENDEES: "event:manage-attendees";
    readonly ADMIN_MANAGE_USERS: "admin:manage-users";
    readonly ADMIN_MANAGE_ROLES: "admin:manage-roles";
    readonly ADMIN_VIEW_LOGS: "admin:view-logs";
    readonly ADMIN_SYSTEM_CONFIG: "admin:system-config";
};
export type Permission = (typeof Permissions)[keyof typeof Permissions];
export declare const Roles: {
    readonly ADMIN: "ADMIN";
    readonly MANAGER: "MANAGER";
    readonly USER: "USER";
};
export type RoleName = (typeof Roles)[keyof typeof Roles];
export declare const RolePermissions: Record<RoleName, Permission[]>;
//# sourceMappingURL=permissions.config.d.ts.map