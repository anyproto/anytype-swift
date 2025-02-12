import SwiftUI

final class CoverColorsGridViewModel: GridItemViewModelProtocol {
    typealias Item = ObjectBackgroundType
    typealias Section = GridItemSection<Item>

    let searchAvailability: SearchAvailability = .unavailable
    let onCoverSelect: (ObjectBackgroundType) -> ()

    lazy var sections: [Section] = backgroundSections()

    init(onCoverSelect: @escaping (ObjectBackgroundType) -> ()) {
        self.onCoverSelect = onCoverSelect
    }

    func didSelectItem(item: ObjectBackgroundType) {
        onCoverSelect(item)
    }    

    private func backgroundSections() -> [Section] {
        [
            Section(title: Loc.gradients, items: ObjectBackgroundType.allGradients),
            Section(title: Loc.solidColors, items: ObjectBackgroundType.allColors )
        ]
    }
}

extension ObjectBackgroundType: GridItemViewModel {
    var view: AnyView {
        switch self {
        case .color(let coverColor):
            return Color(hex: coverColor.data.hex)
                .eraseToAnyView()
        case .gradient(let gradient):
            return CoverGradientView(data: gradient.data)
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
