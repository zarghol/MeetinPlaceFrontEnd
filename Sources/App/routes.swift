import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let controller = Controller()

    let authGroup = router.grouped(User.authSessionsMiddleware())

    authGroup.get("meetings", use: controller.meetings)
    authGroup.get(use: controller.connexion)
    authGroup.post("connexion", use: controller.connect)
    authGroup.get("disconnect", use: controller.disconnect)
    authGroup.get("home", use: controller.myMeetings)
    authGroup.post("createTalk", use: controller.createTalk)
}

// Besoin de quoi ?
// 1. Page de connexion
// 2. Ajouter un talk ( + édition)
// 3. Liste de ses meetings (support édition / suppression)
// 4. Liste des meetings par date
