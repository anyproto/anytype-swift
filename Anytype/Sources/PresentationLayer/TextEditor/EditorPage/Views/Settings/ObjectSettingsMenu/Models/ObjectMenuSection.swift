import Foundation

enum ObjectMenuSectionLayout {
    case horizontal
    case vertical
    case collapsible
}

struct ObjectMenuConfiguration {
    let sections: [ObjectMenuSection]
}

struct ObjectMenuSection: Identifiable {
    let items: [ObjectMenuItem]
    let layout: ObjectMenuSectionLayout
    let showDividerBefore: Bool

    var id: String {
        items.map { $0.id }.joined(separator: "-")
    }
}
