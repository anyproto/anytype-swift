import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewIconMenuViewModel: CheckPopuViewViewModelProtocol {
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private var objectPreviewFields: ObjectPreviewFields
    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()
    private let onSelect: (ObjectPreviewFields) -> Void

    // MARK: - Initializer

    init(objectPreviewFields: ObjectPreviewFields, onSelect: @escaping (ObjectPreviewFields) -> Void) {
        self.objectPreviewFields = objectPreviewFields
        self.onSelect = onSelect
        self.updatePreviewFields(objectPreviewFields)
    }

    func updatePreviewFields(_ objectPreviewFields: ObjectPreviewFields) {
        items = buildObjectPreviewPopupItem(objectPreviewFields: objectPreviewFields)
    }

    func buildObjectPreviewPopupItem(objectPreviewFields: ObjectPreviewFields) -> [CheckPopupItem] {
        ObjectPreviewFields.Icon.allCases.map { icon -> CheckPopupItem in
            let isSelected = objectPreviewFields.icon == icon
            return CheckPopupItem(id: icon.rawValue, icon: nil, title: icon.name, subtitle: nil, isSelected: isSelected)
        }
    }

    func onTap(itemId: String) {
        guard let icon = ObjectPreviewFields.Icon(rawValue: itemId) else { return }

        objectPreviewFields = ObjectPreviewFields(
            icon: icon,
            layout: objectPreviewFields.layout,
            withName: objectPreviewFields.withName,
            featuredRelationsIds: objectPreviewFields.featuredRelationsIds
        )

        onSelect(objectPreviewFields)
        updatePreviewFields(objectPreviewFields)
    }
}
