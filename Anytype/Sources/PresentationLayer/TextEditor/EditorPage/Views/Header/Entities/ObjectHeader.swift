import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(state: ObjectHeaderFilledState, isShimmering: Bool)
    case empty(data: ObjectHeaderEmptyData, isShimmering: Bool)

    static func filled(state: ObjectHeaderFilledState) -> Self {
        .filled(state: state, isShimmering: false)
    }

    static func empty(
        usecase: ObjectHeaderEmptyData.ObjectHeaderEmptyUsecase,
        onTap: @escaping () -> Void
    ) -> Self {
        return .empty(data: .init(presentationStyle: usecase, onTap: onTap), isShimmering: false)
    }
}
extension ObjectHeader: ContentConfigurationProvider {
    var hashable: AnyHashable { "ObjectHeader" }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case .filled(let filledState, let isShimmering):
            return ObjectHeaderFilledConfiguration(
                state: filledState,
                isShimmering: isShimmering,
                sizeConfiguration: .editorSizeConfiguration(width: maxWidth)
            ).cellBlockConfiguration(
                dragConfiguration: nil,
                styleConfiguration: nil
            )
        case .empty(let data, let isShimmering):
            return ObjectHeaderEmptyConfiguration(data: data, isShimmering: isShimmering)
                .cellBlockConfiguration(dragConfiguration: nil, styleConfiguration: nil)
        }
    }
    
}
