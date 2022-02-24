import SwiftUI


protocol SearchDataProtocol: Identifiable {
    var usecase: ObjectIconImageUsecase { get }
    var iconImage: ObjectIconImage { get }

    var title: String { get }
    var description: String { get }
    var callout: String { get }

    var shouldShowDescription: Bool { get }
    var descriptionTextColor: Color { get }
    var descriptionFont: AnytypeFont { get }
    
    var shouldShowCallout: Bool { get }
    
    var verticalInset: CGFloat { get }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}

// For iOS 14 calls from UIKit
protocol Dismissible: AnyObject {
    var onDismiss: () -> () { get set }
}

protocol SearchViewModelProtocol: ObservableObject, Dismissible {
    associatedtype SearchDataType: SearchDataProtocol

    var searchData: [SearchDataSection<SearchDataType>] { get }
    var onSelect: (SearchDataType) -> () { get }
    var onDismiss: () -> () { get set }

    func search(text: String)
}
