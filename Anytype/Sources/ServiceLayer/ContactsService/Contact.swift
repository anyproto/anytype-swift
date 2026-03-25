import Foundation
import Services

struct Contact: Identifiable, Equatable, Hashable {
    let identity: String
    let name: String
    let globalName: String
    let icon: ObjectIcon?
    var id: String { identity }
}
