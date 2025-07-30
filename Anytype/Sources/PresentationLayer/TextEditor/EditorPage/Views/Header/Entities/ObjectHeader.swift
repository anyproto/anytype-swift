import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(state: ObjectHeaderFilledState, showPublishingBanner: Bool, isShimmering: Bool)
    case empty(data: ObjectHeaderEmptyData, showPublishingBanner: Bool, isShimmering: Bool)

    static func filled(state: ObjectHeaderFilledState, showPublishingBanner: Bool) -> Self {
        .filled(state: state, showPublishingBanner: showPublishingBanner, isShimmering: false)
    }

    static func empty(
        usecase: ObjectHeaderEmptyUsecase,
        showPublishingBanner: Bool,
        onTap: @escaping () -> Void
    ) -> Self {
        return .empty(
            data: ObjectHeaderEmptyData(
                presentationStyle: usecase,
                onTap: onTap
            ),
            showPublishingBanner: showPublishingBanner,
            isShimmering: false
        )
    }
}

extension ObjectHeader: HashableProvier, BlockIdProvider {
    var blockId: String { "ObjectHeader" }
    var hashable: AnyHashable { blockId }
}

extension ObjectHeader: ContentConfigurationProvider {
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
    
    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        switch self {
        case .filled(let filledState, let showPublishingBanner, let isShimmering):
            return ObjectHeaderFilledConfiguration(
                state: filledState,
                isShimmering: isShimmering,
                sizeConfiguration: .editorSizeConfiguration(
                    width: maxWidth,
                    showPublishingBanner: showPublishingBanner
                )
            ).cellBlockConfiguration(
                dragConfiguration: nil,
                styleConfiguration: nil
            )
        case .empty(let data, let showPublishingBanner, let isShimmering):
            return ObjectHeaderEmptyConfiguration(data: data, showPublishingBanner: showPublishingBanner, isShimmering: isShimmering)
                .cellBlockConfiguration(dragConfiguration: nil, styleConfiguration: nil)
        }
    }
    
}
