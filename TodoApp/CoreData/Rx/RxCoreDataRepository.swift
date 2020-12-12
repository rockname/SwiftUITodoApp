import CoreData
import RxSwift

struct RxCoreDataTaskRepository: RxTaskRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func save(task: Task) -> Single<Task> {
        .create { observer in
            do {
                let newTask = CoreDataTask(context: context)
                newTask.uuid = task.id
                newTask.title = task.title
                newTask.hasDone = task.hasDone
                try context.save()
                observer(.success(task))
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }

    func fetch() -> Single<[Task]> {
        .create { observer in
            do {
                let fetchRequest: NSFetchRequest<CoreDataTask> = CoreDataTask.fetchRequest()
                let tasks = try context.fetch(fetchRequest)
                observer(.success(tasks.map { coreDataTask in
                    Task(
                        id: coreDataTask.uuid!,
                        title: coreDataTask.title!,
                        hasDone: coreDataTask.hasDone
                    )
                }))
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }

    func delete(taskID: String) -> Single<Void> {
        .create { observer in
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataTask.entity().name!)
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", taskID)
                fetchRequest.fetchLimit = 1
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                let _ = try context.execute(batchDeleteRequest)
                observer(.success(()))
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }

    func update(task: Task) -> Single<Task> {
        .create { observer in
            do {
                let fetchRequest: NSFetchRequest<CoreDataTask> = CoreDataTask.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", task.id)
                fetchRequest.fetchLimit = 1
                guard let fetchedTask = try context.fetch(fetchRequest).first else {
                    observer(.success(task))
                    return Disposables.create()
                }

                fetchedTask.title = task.title
                fetchedTask.hasDone = task.hasDone
                try context.save()
                observer(.success(task))
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }
}
