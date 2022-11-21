import Foundation

extension Notification.Name {
    static let relationEvent = Notification.Name("relationEvent")
}

struct RelationEventsBunch {
    let events: [RelationEvent]

    func send() {
        NotificationCenter.default.post(name: .relationEvent, object: self)
    }
}
