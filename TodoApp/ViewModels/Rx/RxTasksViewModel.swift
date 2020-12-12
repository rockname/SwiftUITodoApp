import Foundation
import RxSwift
import RxRelay

class RxTasksViewModel {
    private let bag = DisposeBag()

    let taskCellViewModels = BehaviorRelay<[RxTaskCellViewModel]>(value: [])

    private let taskRepository: RxTaskRepository

    init(taskRepository: RxTaskRepository) {
        self.taskRepository = taskRepository
    }

    func onAppear() {
        fetchTasks()
    }

    func onTaskDeleted(atOffsets indexSet: IndexSet) {
        removeTasks(atOffsets: indexSet)
    }

    func onTaskAdded(task: Task) {
        addTask(task: task)
    }

    private func fetchTasks() {
        taskRepository.fetch()
            .map { [taskRepository] tasks in
                tasks.map { RxTaskCellViewModel(task: $0, taskRepository: taskRepository) }
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] viewModels in
                self.taskCellViewModels.accept(viewModels)
            })
            .disposed(by: bag)
    }

    private func removeTasks(atOffsets indexSet: IndexSet) {
        indexSet.lazy.map { self.taskCellViewModels.value[$0] }.forEach { taskCellViewModel in
            taskRepository.delete(taskID: taskCellViewModel.task.value.id)
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [unowned self] _ in
                    var current = self.taskCellViewModels.value
                    current.remove(atOffsets: indexSet)
                    self.taskCellViewModels.accept(current)
                })
                .disposed(by: bag)
        }
    }

    private func addTask(task: Task) {
        taskRepository.save(task: task)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] _ in
                var current = self.taskCellViewModels.value
                current.append(RxTaskCellViewModel(task: task, taskRepository: self.taskRepository))
                self.taskCellViewModels.accept(current)
            })
            .disposed(by: bag)
    }
}
