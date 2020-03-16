import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    // --- Registeration ---
    // administrators
    let adminController = AdminController()
    try router.register(collection: adminController)
    // users
    let userController = UserController()
    try router.register(collection: userController)
    // mag categories
    let magCategoryController = MagCategoryController()
    try router.register(collection: magCategoryController)
    // mag
    let magController = MagController()
    try router.register(collection: magController)
    // Tag
    let tagController = TagController()
    try router.register(collection: tagController)
    // Message
    let messageController = MessageController()
    try router.register(collection: messageController)
    // Notification
    let notificationController = NotificationController()
    try router.register(collection: notificationController)
}
