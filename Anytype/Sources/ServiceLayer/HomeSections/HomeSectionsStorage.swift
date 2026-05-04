import Foundation
import Combine
import AnytypeCore

protocol HomeSectionsStorageProtocol: Sendable {
    func configuration(spaceId: String) -> HomeSectionsConfiguration
    func setConfiguration(_ configuration: HomeSectionsConfiguration, spaceId: String)
    func configurationPublisher(spaceId: String) -> AnyPublisher<HomeSectionsConfiguration, Never>
}

final class HomeSectionsStorage: HomeSectionsStorageProtocol, Sendable {

    static let userDefaultsKey = "homeSectionsConfigurations"

    private let storage = UserDefaultStorage<[String: HomeSectionsConfiguration]>(
        key: HomeSectionsStorage.userDefaultsKey,
        defaultValue: [:]
    )
    private let subject: CurrentValueSubject<[String: HomeSectionsConfiguration], Never>

    init() {
        self.subject = CurrentValueSubject(storage.value)
    }

    func configuration(spaceId: String) -> HomeSectionsConfiguration {
        storage.value[spaceId] ?? .default
    }

    func setConfiguration(_ configuration: HomeSectionsConfiguration, spaceId: String) {
        storage.value[spaceId] = configuration
        subject.send(storage.value)
    }

    func configurationPublisher(spaceId: String) -> AnyPublisher<HomeSectionsConfiguration, Never> {
        subject
            .map { $0[spaceId] ?? .default }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
