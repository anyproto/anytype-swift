import SwiftUI

protocol SearchDataProtocol: Identifiable {
    var iconImage: Icon? { get }

    var title: String { get }

    var shouldShowDescription: Bool { get }
    var description: String { get }
    var descriptionTextColor: Color { get }
    var descriptionFont: AnytypeFont { get }
    
    var shouldShowCallout: Bool { get }
    var callout: String { get }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}
