import Foundation

struct Task: Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var hasDone: Bool = false
}
