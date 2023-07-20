import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(state: ObjectHeaderFilledState, isShimmering: Bool)
    case empty(data: ObjectHeaderEmptyData, isShimmering: Bool)

    static func filled(state: ObjectHeaderFilledState) -> Self {
        .filled(state: state, isShimmering: false)
    }

    static func empty(data: ObjectHeaderEmptyData) -> Self {
        .empty(data: data, isShimmering: false)
    }
}
extension ObjectHeader: ContentConfigurationProvider {
    var hashable: AnyHashable {
        hashValue as AnyHashable
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case .filled(let filledState, let isShimmering):
            return ObjectHeaderFilledConfiguration(
                state: filledState,
                isShimmering: isShimmering,
                sizeConfiguration: .editorSizeConfiguration(width: maxWidth)
            )
                .cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
        case .empty(let data, let isShimmering):
            return ObjectHeaderEmptyConfiguration(data: data, isShimmering: isShimmering)
                .cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
        }
    }
    
}
