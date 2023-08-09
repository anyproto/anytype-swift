import Foundation
import Combine
import Services
import UIKit

@MainActor
final class SpaceSettingsViewModel: ObservableObject {
    
    private enum Constants {
        static let subSpaceId = "SpaceSettingsViewModel-Space"
    }
    
    // MARK: - DI
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let dateFormatter = DateFormatter.relationDateFormatter
    private weak var output: SpaceSettingsModuleOutput?
    
    // MARK: - State
    
    private var subscriptions: [AnyCancellable] = []
    private var dataLoaded: Bool = false
    
    @Published var spaceName: String = ""
    @Published var spaceType: String = ""
    @Published var spaceIcon: ObjectIconImage?
    @Published var profileIcon: ObjectIconImage = .imageAsset(.SettingsOld.accountAndData)
    @Published var info = [SettingsInfoModel]()
    @Published var snackBarData = ToastBarData.empty
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        output: SpaceSettingsModuleOutput?
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.objectActionsService = objectActionsService
        self.relationDetailsStorage = relationDetailsStorage
        self.output = output
        
        setupSubscription()
    }
    
    func onChangeIconTap() {
        output?.onChangeIconSelected(objectId: activeWorkspaceStorage.workspaceInfo.workspaceObjectId)
    }
    
    func onStorageTap() {
        
    }
    
    func onPersonalizationTap() {
        
    }
    
    // MARK: - Private
    
    private func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subSpaceId,
            objectId: activeWorkspaceStorage.workspaceInfo.workspaceObjectId,
            additionalKeys: [.createdDate, .creator, .spaceAccessibility]
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceIcon = details.objectIconImage
        spaceType = details.spaceAccessibilityValue?.fullName ?? ""
        buildInfoBlock(details: details)
        
        if !dataLoaded {
            spaceName = details.name
            dataLoaded = true
            $spaceName
                .delay(for: 0.3, scheduler: DispatchQueue.main)
                .sink { [weak self] name in
                    self?.updateSpaceName(name: name)
                }
                .store(in: &subscriptions)
        }
    }
    
    private func buildInfoBlock(details: ObjectDetails) {
        
        info.removeAll()
        
        if let spaceRelationDetails = try? relationDetailsStorage.relationsDetails(for: .spaceId) {
            info.append(
                SettingsInfoModel(title: spaceRelationDetails.name, subtitle: details.spaceId, onTap: { [weak self] in
                    UIPasteboard.general.string = details.spaceId
                    self?.snackBarData = .init(text: Loc.copiedToClipboard(details.spaceId), showSnackBar: true)
                })
            )
        }
        
        if let createdDateDetails = try? relationDetailsStorage.relationsDetails(for: .createdDate) {
            let date = details.createdDate.map { dateFormatter.string(from: $0) } ?? Loc.unknown
            info.append(
                SettingsInfoModel(title: createdDateDetails.name, subtitle: date)
            )
        }
    }
    
    private func updateSpaceName(name: String) {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: activeWorkspaceStorage.workspaceInfo.workspaceObjectId,
                details: [.name(name)]
            )
        }
    }
}
