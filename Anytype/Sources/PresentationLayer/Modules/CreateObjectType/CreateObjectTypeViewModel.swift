import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class CreateObjectTypeViewModel {

    @ObservationIgnored @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol
    @ObservationIgnored
    private let data: CreateObjectTypeData
    @ObservationIgnored
    private let completion: ((_ type: ObjectType) -> ())?

    @ObservationIgnored
    let info: ObjectTypeInfo

    init(data: CreateObjectTypeData, completion: ((_ type: ObjectType) -> ())?) {
        self.data = data
        self.info = ObjectTypeInfo(singularName: data.name, pluralName: data.name, icon: nil, color: nil, mode: .create)
        self.completion = completion
    }

    func onAppear() {
        AnytypeAnalytics.instance().logScreenCreateType(route: data.route)
    }

    func onCreate(info: ObjectTypeInfo) {
        Task {
            let type = try await typesService.createType(name: info.singularName, pluralName: info.pluralName, icon: info.icon, color: info.color, spaceId: data.spaceId)

            AnytypeAnalytics.instance().logCreateObjectType(route: data.route)

            completion?(type)
        }
    }
}
