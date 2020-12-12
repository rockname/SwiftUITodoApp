import RxSwift

protocol RxTaskRepository {
    func save(task: Task) -> Single<Task>
    func fetch() -> Single<[Task]>
    func delete(taskID: String) -> Single<Void>
    func update(task: Task) -> Single<Task>
}
