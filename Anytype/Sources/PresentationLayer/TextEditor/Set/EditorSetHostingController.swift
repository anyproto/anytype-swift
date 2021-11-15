import SwiftUI
import BlocksModels

final class EditorSetHostingController: UIHostingController<EditorSetView> {
    let documentId: BlockId
    let model: EditorSetViewModel
    
    init(documentId: BlockId, model: EditorSetViewModel) {
        self.documentId = documentId
        self.model = model
        
        super.init(rootView: EditorSetView(model: model))
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
