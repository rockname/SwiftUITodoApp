import SwiftUI

struct TasksView: View {
    @ObservedObject var viewModel: TasksViewModel
    @State var shouldShowNewTaskButton = false

    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(viewModel.taskCellViewModels) { taskCellViewModel in
                    TaskCell(viewModel: taskCellViewModel)
                }
                .onDelete { indexSet in
                    viewModel.onTaskDeleted(atOffsets: indexSet)
                }
                if shouldShowNewTaskButton {
                    TaskCell(viewModel: .init(task: .init(), taskRepository: Factory.create())) { result in
                        if case .success(let task) = result {
                            viewModel.onTaskAdded(task: task)
                        }
                        shouldShowNewTaskButton.toggle()
                    }
                }
            }
            Button(action: { shouldShowNewTaskButton.toggle() }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("New Task")
                }
            }
            .padding()
            .accentColor(Color(UIColor.systemBlue))
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
