import Foundation
import Services

@MainActor
final class CreateObjectTypeViewModel: ObservableObject {
    
    @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol
    private let data: CreateObjectTypeData
    private let completion: ((_ type: ObjectType) -> ())?
    
    let info: ObjectTypeInfo
    
    init(data: CreateObjectTypeData, completion: ((_ type: ObjectType) -> ())?) {
        self.data = data
        self.info = ObjectTypeInfo(singularName: data.name, pluralName: data.name, icon: nil, color: nil, mode: .create)
        self.completion = completion
    }
    
    func onCreate(info: ObjectTypeInfo) {
        Task {
            let type = try await typesService.createType(name: info.singularName, pluralName: info.pluralName, icon: info.icon, color: info.color, spaceId: data.spaceId)
            
            AnytypeAnalytics.instance().logCreateObjectType(spaceId: data.spaceId)
        }
    }
}
