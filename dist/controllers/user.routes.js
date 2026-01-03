import { Router } from "express";
import * as userController from "../controllers/user.controller.js";
import { authenticate } from "../midlewares/auth.middleware.js";
import { validateUserRegistration, validateUserLogin, validateUserUpdate, } from "../validator/user.validator.js";
const router = Router();
// Public routes
router.post("/register", validateUserRegistration, userController.register);
router.post("/login", validateUserLogin, userController.login);
// Protected routes
router.get("/me", authenticate, userController.getMe);
router.get("/:id", authenticate, userController.getUserById);
router.put("/:id", authenticate, validateUserUpdate, userController.updateUser);
router.delete("/:id", authenticate, userController.deleteUser);
router.get("/", authenticate, userController.getUsers);
export default router;
//# sourceMappingURL=user.routes.js.map