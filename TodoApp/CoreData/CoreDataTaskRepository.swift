import CoreData
import Combine
import Foundation

struct CoreDataTaskRepository: TaskRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func save(task: Task) -> AnyPublisher<Bool, NSError> {
        let action: Action = {
            let newTask = CoreDataTask(context: context)
            newTask.uuid = task.id
            newTask.title = task.title
            newTask.hasDone = task.hasDone
        }

        return CoreDataSaveModelPublisher(
            action: action,
            context: context
        )
        .eraseToAnyPublisher()
    }

    func fetch() -> AnyPublisher<[Task], NSError> {
        CoreDataFetchResultsPublisher(
            request: CoreDataTask.fetchRequest(),
            context: context
        )
        .map { output in
            output.map { coreDataTask in
                Task(
                    id: coreDataTask.uuid!,
                    title: coreDataTask.title!,
                    hasDone: coreDataTask.hasDone
                )
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(taskID: String) -> AnyPublisher<Void, NSError> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataTask.entity().name!)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", taskID)
        fetchRequest.fetchLimit = 1

        return CoreDataDeleteModelPublisher(
            delete: fetchRequest,
            context: context
        )
        .eraseToAnyPublisher()
    }

    func update(task: Task) -> AnyPublisher<Task, NSError> {
        let fetchRequest: NSFetchRequest<CoreDataTask> = CoreDataTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", task.id)
        fetchRequest.fetchLimit = 1

        return CoreDataFetchResultsPublisher(
            request: fetchRequest,
            context: context
        )
        .flatMap { coreDataTasks -> AnyPublisher<Bool, NSError> in
            guard let coreDataTask = coreDataTasks.first else {
                return Just(false).setFailureType(to: NSError.self).eraseToAnyPublisher()
            }

            let action: Action = {
                coreDataTask.title = task.title
                coreDataTask.hasDone = task.hasDone
            }

            return CoreDataSaveModelPublisher(
                action: action,
                context: context
            ).eraseToAnyPublisher()
        }
        .map { _ in task }
        .eraseToAnyPublisher()
    }
}
