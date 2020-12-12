import CoreData
import Combine
import Foundation

protocol TaskRepository {
    func save(task: Task) -> AnyPublisher<Bool, NSError>
    func fetch() -> AnyPublisher<[Task], NSError>
    func delete(taskID: String) -> AnyPublisher<Void, NSError>
    func update(task: Task) -> AnyPublisher<Task, NSError>
}
