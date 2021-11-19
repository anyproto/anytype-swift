import Combine
import BlocksModels
import AnytypeCore
import ProtobufMessages

final class EditorSetViewModel: ObservableObject {
    let document: BaseDocument
    var router: EditorRouterProtocol!
    var dataView: BlockDataview!
    var dataViewId: BlockId!
    var records: [ObjectDetails] = []
    
    var colums: [String] {
        dataView.activeView?.relations.filter { $0.isVisible }.map(\.key) ?? []
    }
    
    var rows: [String] {
        records.map { $0.title }
    }
    
    init(document: BaseDocument) {
        self.document = document
//        document.updatePublisher.sink { [weak self] in
//            self?.onDashboardChange(updateResult: $0)
//        }.store(in: &cancellables)
        
        if !document.open() {
            // TODO: Return
        }
        
        let dataViews = document.flattenBlocks.compactMap { block -> BlockDataview? in
            if case .dataView(let data) = block.information.content {
                dataViewId = block.information.id
                return data
            }
            return nil
        }
        anytypeAssert(dataViews.isNotEmpty, "No dataview block for set", domain: .editorSet)
        dataView = dataViews[0]
        
        let viewId = dataView.activeViewId.isNotEmpty ? dataView.activeViewId : dataView.activeView?.id ?? ""
        guard let response = Anytype_Rpc.Block.Dataview.ViewSetActive.Service.invoke(
            contextID: document.objectId, blockID: dataViewId, viewID: viewId, offset: 0, limit: 300
        ).getValue() else { return }
        
        let data = response.event.messages.compactMap { message -> Anytype_Event.Block.Dataview.RecordsSet? in
            switch message.value! {
            case .blockDataviewRecordsSet(let data):
                return data
            default:
                return nil
            }
        }.first!
        
        self.records = data.records.compactMap { record -> ObjectDetails? in
            let idValue = record.fields["id"]
            let idString = idValue?.unwrapedListValue.stringValue
                
            guard let id = idString, id.isNotEmpty else { return nil }
            
            return ObjectDetails(id: id, values: record.fields)
        }
    }
    
    func onAppear() {
        
    }
}
