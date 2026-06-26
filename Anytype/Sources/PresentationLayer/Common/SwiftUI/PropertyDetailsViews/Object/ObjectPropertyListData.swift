struct ObjectPropertyListData {
    let configuration: PropertyModuleConfiguration
    let interactor: any ObjectPropertyListInteractorProtocol
    let relationSelectedOptionsModel: PropertySelectedOptionsModel
    // Set only for read-only object relations (links/backlinks): when present, the
    // panel renders these already-resolved objects instead of running a filtered search.
    var preloadedReadOnlyOptions: [ObjectPropertyOption]? = nil
}
