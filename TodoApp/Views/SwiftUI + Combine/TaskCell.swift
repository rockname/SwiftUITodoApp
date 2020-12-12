import SwiftUI

enum InputError: Error {
  case empty
}

struct TaskCell: View {
    @ObservedObject var viewModel: TaskCellViewModel
    var onCommit: (Result<Task, InputError>) -> Void = { _ in }

    var body: some View {
        HStack {
            Image(systemName: viewModel.taskStateIconName)
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    viewModel.onTaskStateIconTapped()
                }
            TextField(
                "Enter task title",
                text: $viewModel.task.title,
                onCommit: {
                    if !viewModel.task.title.isEmpty {
                        onCommit(.success(viewModel.task))
                    }
                    else {
                        onCommit(.failure(.empty))
                    }
                }
            ).id(viewModel.task.id)
        }
    }
}
