struct SetObjectCreationData: Identifiable {
    let setDocument: any SetDocumentProtocol
    let viewId: String
    let onTemplateSelection: (ObjectCreationSetting) -> Void
    
    var id: String { setDocument.objectId }
}
