import BlocksModels
import Combine

final class SetViewSettingsCardSizeViewModel: CheckPopupViewViewModelProtocol {
    let title: String = Loc.Set.View.Settings.CardSize.title
    @Published private(set) var items: [CheckPopupItem] = []

    private var selectedSize: DataviewViewSize
    private let onSelect: (DataviewViewSize) -> Void

    // MARK: - Initializer

    init(
        selectedSize: DataviewViewSize,
        onSelect: @escaping (DataviewViewSize) -> Void
    ) {
        self.selectedSize = selectedSize
        self.onSelect = onSelect
        self.items = self.buildPopupItems()
    }
    
    func buildPopupItems() -> [CheckPopupItem] {
        DataviewViewSize.availableCases.compactMap { size in
            CheckPopupItem(
                id: String(size.rawValue),
                iconAsset: nil,
                title: size.value,
                subtitle: nil,
                isSelected: size == selectedSize
            )
        }
    }

    func onTap(itemId: String) {
        guard let size =  DataviewViewSize(rawValue: Int(itemId) ?? 0),
              size != selectedSize else {
            return
        }

        selectedSize = size
        onSelect(size)
        items = buildPopupItems()
    }
}
