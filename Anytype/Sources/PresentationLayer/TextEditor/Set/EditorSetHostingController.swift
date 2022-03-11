import SwiftUI
import BlocksModels

final class EditorSetHostingController: UIHostingController<EditorSetView> {
    let objectId: BlockId
    let model: EditorSetViewModel
    
    init(objectId: BlockId, model: EditorSetViewModel) {
        self.objectId = objectId
        self.model = model
        
        super.init(rootView: EditorSetView(model: model))
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
