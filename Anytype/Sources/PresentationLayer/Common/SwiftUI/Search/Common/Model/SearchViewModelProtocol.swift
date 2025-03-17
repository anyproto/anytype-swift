import SwiftUI

enum SerchDataPresentationMode {
    case full(descriptionInfo: SearchDataDescriptionInfo?, callout: String?)
    case minimal
}

struct SearchDataDescriptionInfo {
    let description: String
    let descriptionTextColor: Color
    let descriptionFont: AnytypeFont
}

protocol SearchDataProtocol: Identifiable {
    var iconImage: Icon? { get }
    var title: String { get }

    var mode: SerchDataPresentationMode { get }
}

extension SearchDataProtocol {
    var isMinimal: Bool {
        switch mode {
        case .full:
            false
        case .minimal:
            true
        }
    }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}
