import BlocksModels
import SwiftUI
import FloatingPanel

final class ObjectPreviewIconMenuViewModel: CheckPopuViewViewModelProtocol {
    @Published private(set) var items: [CheckPopupItem] = []

    // MARK: - Private variables

    private let objectPreviewModelBuilder = ObjectPreivewSectionBuilder()

    // MARK: - Initializer

    init(objectPreviewFields: ObjectPreviewFields) {
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

        // TODO: here will be fileds service
    }
}
