import SwiftUI

final class RelationValueViewModel: ObservableObject {
    @Published var data: RelationValueViewData
    
    init(data: RelationValueViewData = .empty) {
        self.data = data
    }
    
    func updateData(_ data: RelationValueViewData) {
        self.data = data
    }
}

struct RelationValueViewData {
    let relation: RelationItemModel?
    let style: RelationStyle
    let mode: Mode
    let leftAlign: Bool
    
    init(
        relation: RelationItemModel? = nil,
        style: RelationStyle = .regular(allowMultiLine: false),
        mode: Mode = .button(action: nil),
        leftAlign: Bool = false
    ) {
        self.relation = relation
        self.style = style
        self.mode = mode
        self.leftAlign = leftAlign
    }
    
    enum Mode {
        case button(action: (() -> Void)?)
        case contextMenu([MenuItem])
    }
    
    struct MenuItem {
        let title: String
        let action: () -> Void
    }
    
    static let empty = RelationValueViewData(
        relation: nil,
        style: .regular(allowMultiLine: false),
        mode: .button(action: nil)
    )
}
