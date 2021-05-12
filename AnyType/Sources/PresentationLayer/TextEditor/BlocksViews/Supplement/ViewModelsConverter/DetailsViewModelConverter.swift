import Foundation
import BlocksModels

class DetailsViewModelConverter {
    fileprivate let document: BaseDocument
    func convert(_ model: BaseDocument.ActiveModel, kind: BaseDocument.DetailsContentKind) -> PageBlockViewModel? {
        switch kind {
        case .title: return PageTitleViewModel(model)
        case .iconEmoji: return DocumentIconViewModel(model)
        case .iconColor: return nil
        case .iconImage: return nil
        }
    }
    
    init(_ document: BaseDocument) {
        self.document = document
    }
}
