import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewIconMenuViewModel: CheckPopupViewViewModelProtocol {
    let title = "Icon".localized
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var iconSize: ObjectPreviewViewSection.MainSectionItem.IconSize
    private var cardStyle: ObjectPreviewViewSection.MainSectionItem.CardStyle
    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    private let onSelect: (ObjectPreviewViewSection.MainSectionItem.IconSize) -> Void

    // MARK: - Initializer

    init(iconSize: ObjectPreviewViewSection.MainSectionItem.IconSize,
         cardStyle: ObjectPreviewViewSection.MainSectionItem.CardStyle,
         onSelect: @escaping (ObjectPreviewViewSection.MainSectionItem.IconSize) -> Void) {
        self.iconSize = iconSize
        self.cardStyle = cardStyle
        self.onSelect = onSelect
        self.updatePreviewFields(iconSize)
    }

    func updatePreviewFields(_ currentIconSize: ObjectPreviewViewSection.MainSectionItem.IconSize) {
        items = buildObjectPreviewPopupItem(currentIconSize: currentIconSize)
    }

    func buildObjectPreviewPopupItem(currentIconSize: ObjectPreviewViewSection.MainSectionItem.IconSize) -> [CheckPopupItem] {
        availableIconSizes().map { iconSize in
            let isSelected = currentIconSize == iconSize
            return CheckPopupItem(id: iconSize.rawValue, icon: nil, title: iconSize.name, subtitle: nil, isSelected: isSelected)
        }
    }

    func availableIconSizes() -> [ObjectPreviewViewSection.MainSectionItem.IconSize] {
        switch cardStyle {
        case .text:
            return [.small, .none]
        case .card:
            return [.medium, .none]
        }
    }

    func onTap(itemId: String) {
        guard let iconSize = ObjectPreviewViewSection.MainSectionItem.IconSize(rawValue: itemId) else { return }

        onSelect(iconSize)
        updatePreviewFields(iconSize)
    }
}
