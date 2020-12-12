import Foundation
import Combine

class TasksViewModel: ObservableObject {
    @Published var taskCellViewModels = [TaskCellViewModel]()

    private let taskRepository: TaskRepository
  
    private var cancellables = Set<AnyCancellable>()

    init(taskRepository: TaskRepository) {
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
            .replaceError(with: [])
            .map { [taskRepository] tasks in
                tasks.map { TaskCellViewModel(task: $0, taskRepository: taskRepository) }
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .assign(to: \.taskCellViewModels, on: self)
            .store(in: &cancellables)
    }

    private func removeTasks(atOffsets indexSet: IndexSet) {
        indexSet.lazy.map { self.taskCellViewModels[$0] }.forEach { taskCellViewModel in
            taskRepository.delete(taskID: taskCellViewModel.task.id)
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { print($0) }, receiveValue: { [unowned self] _ in
                    self.taskCellViewModels.remove(atOffsets: indexSet)
                })
                .store(in: &cancellables)
        }
    }

    private func addTask(task: Task) {
        taskRepository.save(task: task)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { print($0) }, receiveValue: { [unowned self] _ in
                self.taskCellViewModels.append(TaskCellViewModel(task: task, taskRepository: self.taskRepository))
            })
            .store(in: &cancellables)
    }
}
