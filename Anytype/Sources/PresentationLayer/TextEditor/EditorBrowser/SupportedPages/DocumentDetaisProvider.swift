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
        let type = details?.editorViewType
        if type.isNil { anytypeAssertionFailure("Nil details in \(self)") }
        
        return EditorScreenData(pageId: objectId, type: type ?? .page)
    }
    
    var details: ObjectDetails? {
        viewModel.document.objectDetails
    }
}

extension EditorSetHostingController: DocumentDetaisProvider {
    var screenData: EditorScreenData {
        let type = details?.editorViewType
        if type.isNil { anytypeAssertionFailure("Nil details in \(self)") }
        
        return EditorScreenData(pageId: objectId, type: type ?? .page)
    }
    
    var details: ObjectDetails? {
        model.document.objectDetails
    }
}
