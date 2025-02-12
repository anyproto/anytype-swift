import SwiftUI

protocol SearchDataProtocol: Identifiable {
    var iconImage: Icon? { get }

    var title: String { get }
    var description: String { get }
    var callout: String { get }
    var typeId: String { get }

    var shouldShowDescription: Bool { get }
    var descriptionTextColor: Color { get }
    var descriptionFont: AnytypeFont { get }
    
    var shouldShowCallout: Bool { get }
    
    var verticalInset: CGFloat { get }
    
    var screenData: ScreenData { get }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}
