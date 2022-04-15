import BlocksModels
import AnytypeCore

protocol DocumentDetaisProvider {
    var objectId: BlockId { get }
    var screenData: EditorScreenData { get }
    var details: ObjectDetails? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    
    var objectId: BlockId {
        viewModel.document.objectId.value
    }
    
    var screenData: EditorScreenData {
        EditorScreenData(pageId: objectId.asAnytypeId!, type: .page)
    }
    
    var details: ObjectDetails? {
        viewModel.document.details
    }
    
}

extension EditorSetHostingController: DocumentDetaisProvider {
    
    var screenData: EditorScreenData {
        EditorScreenData(pageId: objectId.asAnytypeId!, type: .set)
    }
    
    var details: ObjectDetails? {
        model.document.details
    }
    
}
