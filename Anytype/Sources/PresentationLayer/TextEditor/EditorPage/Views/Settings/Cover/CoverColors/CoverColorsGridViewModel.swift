import SwiftUI

final class CoverColorsGridViewModel: GridItemViewModelProtocol {
    typealias Item = BackgroundType
    typealias Section = GridItemSection<Item>

    let onCoverSelect: (BackgroundType) -> ()

    lazy var sections: [Section] = backgroundSections()

    init(onCoverSelect: @escaping (BackgroundType) -> ()) {
        self.onCoverSelect = onCoverSelect
    }

    func didSelectItem(item: BackgroundType) {
        onCoverSelect(item)
    }    

    private func backgroundSections() -> [Section] {
        [
            Section(title: "Solid colors".localized, items: CoverConstants.colors.map { BackgroundType.color($0) }),
            Section(title: "Gradients".localized, items: CoverConstants.gradients.map { BackgroundType.gradient($0) })
        ]
    }
}

extension BackgroundType: GridItemViewModel {
    var view: AnyView {
        switch self {
        case .color(let coverColor):
            return Color(hex: coverColor.hex)
                .eraseToAnyView()
        case .gradient(let gradient):
            return gradient.asLinearGradient()
                .eraseToAnyView()
        }
    }

    var id: String {
        switch self {
        case .color(let coverColor):
            return coverColor.id
        case .gradient(let coverGradient):
            return coverGradient.id
        }
    }
}
