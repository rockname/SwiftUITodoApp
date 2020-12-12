import Foundation

struct Factory {
    // MARK: - Repository
    static func create() -> TaskRepository {
        CoreDataTaskRepository(context: PersistenceController.shared.container.viewContext)
    }

    static func create() -> RxTaskRepository {
        RxCoreDataTaskRepository(context: PersistenceController.shared.container.viewContext)
    }
}
