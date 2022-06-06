import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewIconMenuViewModel: CheckPopupViewViewModelProtocol {
    let title = "Icon".localized
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var iconSize: ObjectPreviewViewSection.MainSectionItem.IconSize
    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    private let onSelect: (ObjectPreviewViewSection.MainSectionItem.IconSize) -> Void

    // MARK: - Initializer

    init(iconSize: ObjectPreviewViewSection.MainSectionItem.IconSize,
         onSelect: @escaping (ObjectPreviewViewSection.MainSectionItem.IconSize) -> Void) {
        self.iconSize = iconSize
        self.onSelect = onSelect
        self.updatePreviewFields(iconSize)
    }

    func updatePreviewFields(_ iconSize: ObjectPreviewViewSection.MainSectionItem.IconSize) {
        items = buildObjectPreviewPopupItem(iconSize: iconSize)
    }

    func buildObjectPreviewPopupItem(iconSize: ObjectPreviewViewSection.MainSectionItem.IconSize) -> [CheckPopupItem] {
        ObjectPreviewViewSection.MainSectionItem.IconSize.allCases.map { icon -> CheckPopupItem in
            let isSelected = iconSize == icon
            return CheckPopupItem(id: icon.rawValue, icon: nil, title: icon.name, subtitle: nil, isSelected: isSelected)
        }
    }

    func onTap(itemId: String) {
        guard let iconSize = ObjectPreviewViewSection.MainSectionItem.IconSize(rawValue: itemId) else { return }

        onSelect(iconSize)
        updatePreviewFields(iconSize)
    }
}
