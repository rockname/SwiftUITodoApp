import SwiftUI

struct MainView: View {

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                NavigationLink(destination: TasksView(viewModel: .init(taskRepository: Factory.create())).navigationBarTitle("Tasks")) {
                    Text("SwiftUI + Combine")
                }
                NavigationLink(destination: TasksViewController().navigationBarTitle("Tasks")) {
                    Text("UIKit + Combine")
                }
                NavigationLink(destination: RxTasksViewController().navigationBarTitle("Tasks")) {
                    Text("UIKit + RxSwift")
                }
            }
        }
    }
}
