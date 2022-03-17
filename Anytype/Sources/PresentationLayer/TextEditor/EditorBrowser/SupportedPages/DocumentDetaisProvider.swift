import BlocksModels
import AnytypeCore

protocol DocumentDetaisProvider {
    var objectId: BlockId { get }
    var screenData: EditorScreenData { get }
    var details: ObjectDetails? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    var objectId: BlockId {
        viewModel.document.objectId
    }
    
    var screenData: EditorScreenData {
        EditorScreenData(pageId: objectId, type: .page)
    }
    
    var details: ObjectDetails? {
        viewModel.document.details
    }
}

extension EditorSetHostingController: DocumentDetaisProvider {
    var screenData: EditorScreenData {
        EditorScreenData(pageId: objectId, type: .set)
    }
    
    var details: ObjectDetails? {
        model.document.details
    }
}
