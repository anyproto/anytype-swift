import BlocksModels
import AnytypeCore

protocol DocumentDetaisProvider {
    
    var screenData: EditorScreenData { get }
    var documentTitle: String? { get }
    var documentDescription: String? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    
    var screenData: EditorScreenData {
        EditorScreenData(pageId: viewModel.document.objectId, type: .page)
    }
    
    var documentTitle: String? {
        viewModel.document.details?.title
    }
    
    var documentDescription: String? {
        viewModel?.document.details?.description
    }
}

extension EditorSetHostingController: DocumentDetaisProvider {
    
    var screenData: EditorScreenData {
        EditorScreenData(pageId: objectId, type: .set())
    }
    
    var documentTitle: String? {
        model.details?.title
    }
    
    var documentDescription: String? {
        model.details?.description
    }
}
