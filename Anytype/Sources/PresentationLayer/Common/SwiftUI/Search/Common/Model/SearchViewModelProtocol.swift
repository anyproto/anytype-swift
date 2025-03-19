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
        if case .minimal = mode { return true }
        return false
    }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}
