import SwiftUI

protocol SearchDataProtocol: Identifiable {
    var usecase: ObjectIconImageUsecase { get }
    var iconImage: ObjectIconImage? { get }

    var title: String { get }
    var description: String { get }
    var callout: String { get }
    var typeId: String { get }

    var shouldShowDescription: Bool { get }
    var descriptionTextColor: Color { get }
    var descriptionFont: AnytypeFont { get }
    
    var shouldShowCallout: Bool { get }
    
    var verticalInset: CGFloat { get }
    
    var editorScreenData: EditorScreenData { get }
}

struct SearchDataSection<SearchData: SearchDataProtocol>: Identifiable {
    let id = UUID()
    let searchData: [SearchData]
    let sectionName: String
}

protocol SearchViewModelProtocol: ObservableObject {
    associatedtype SearchDataType: SearchDataProtocol

    var searchData: [SearchDataSection<SearchDataType>] { get }
    var placeholder: String { get }
    var onSelect: (SearchDataType) -> () { get }
    
    func search(text: String)
}
