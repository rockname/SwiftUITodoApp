import Foundation
import RxSwift
import RxRelay

class RxTaskCellViewModel {
    private let bag = DisposeBag()

    let task: BehaviorRelay<Task>
    let taskStateIconName: Observable<String>

    private let taskRepository: RxTaskRepository

    init(task: Task, taskRepository: RxTaskRepository) {
        self.taskRepository = taskRepository
        self.task = BehaviorRelay(value: task)
        self.taskStateIconName = self.task
            .map { $0.hasDone ? "checkmark.circle.fill" : "circle" }
        self.task
            .debounce(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] task in
                self.taskRepository.update(task: task)
                    .subscribe()
                    .disposed(by: bag)
            })
            .disposed(by: bag)
    }

    func onTaskStateIconTapped() {
        let current = task.value
        task.accept(Task(id: current.id, title: current.title, hasDone: !current.hasDone))
    }
}
