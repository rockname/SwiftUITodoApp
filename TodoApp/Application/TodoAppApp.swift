import SwiftUI

@main
struct TodoAppApp: App {
    @Environment(\.scenePhase) private var scenePhase

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active, .inactive: break
            case .background: persistenceController.saveContext()
            @unknown default: fatalError()
            }
        }
    }
}
