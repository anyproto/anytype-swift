import BlocksModels

protocol DocumentDetaisProvider {
    var objectId: BlockId { get }
    var screenData: EditorScreenData? { get }
    var details: ObjectDetails? { get }
}

extension EditorPageController: DocumentDetaisProvider {
    var objectId: BlockId {
        viewModel.document.objectId
    }
    
    var screenData: EditorScreenData? {
        guard let details = details else { return nil }
        
        return EditorScreenData(pageId: objectId, type: details.editorViewType)
    }
    
    var details: ObjectDetails? {
        viewModel.document.objectDetails
    }
}

extension EditorSetHostingController: DocumentDetaisProvider {
    var screenData: EditorScreenData? {
        guard let details = details else { return nil }
        
        return EditorScreenData(pageId: objectId, type: details.editorViewType)
    }
    
    var details: ObjectDetails? {
        model.document.objectDetails
    }
}
