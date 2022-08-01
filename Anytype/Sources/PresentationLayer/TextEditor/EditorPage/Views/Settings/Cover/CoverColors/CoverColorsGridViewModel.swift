import SwiftUI

final class CoverColorsGridViewModel: GridItemViewModelProtocol {
    typealias Item = BackgroundType
    typealias Section = GridItemSection<Item>

    let searchAvailability: SearchAvailability = .unavailable
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
            Section(title: Loc.gradients, items: BackgroundType.allGradients),
            Section(title: Loc.solidColors, items: BackgroundType.allColors )
        ]
    }
}

extension BackgroundType: GridItemViewModel {
    var view: AnyView {
        switch self {
        case .color(let coverColor):
            return Color(hex: coverColor.data.hex)
                .eraseToAnyView()
        case .gradient(let gradient):
            return gradient.data.asLinearGradient()
                .eraseToAnyView()
        }
    }

    var id: String {
        switch self {
        case .color(let coverColor):
            return coverColor.data.id
        case .gradient(let coverGradient):
            return coverGradient.id
        }
    }
}
