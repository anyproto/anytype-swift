import Foundation
import SharedContentManager
import Services
import AnytypeCore

@MainActor
final class ShareOptionsViewModel: ObservableObject {
    
    @Injected(\.sharedContentManager)
    private var contentManager: SharedContentManagerProtocol
    @Injected(\.shareOptionsInteractor)
    private var interactor: ShareOptionsInteractorProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    
    private weak var output: ShareOptionsModuleOutput?
    
    // First Group
    @Published var availableOptions: [ShareSaveAsType] = []
    @Published var newContainerTitle: String = ""
    @Published var newObjectTitle: String = ""
    @Published var newBlockTitle: String = ""
    @Published var saveAsType: ShareSaveAsType = .object
    // Second Group
    @Published var spaceName: String = ""
    @Published var linkTitle: String = ""
    @Published var linkObjectName: String = ""
    // Navigation
    @Published var isSaveButtonAvailable = false
    @Published var dismiss = false
    @Published var saveInProgress = false
    // Debug
    @Published var debugInfo: SharedContentDebugInfo? = nil
    
    private var saveOptions: SharedSaveOptions?
    private var counter = ShareContentCounter(textCount: 0, bookmarksCount: 0, filesCount: 0)
    private var spaceDetails: SpaceView?
    private var linkObjectDetails: ObjectDetails?
    
    init(
        output: ShareOptionsModuleOutput?
    ) {
        self.output = output
        setupData()
        if #available(iOS 17.0, *) {
            SharingTip().invalidate(reason: .actionPerformed)
        }
    }
    
    func onTapSaveAsContainer() {
        saveAsType = .container
        updateDataState()
    }
    
    func onTapSaveAsNewObject() {
        saveAsType = .object
        updateDataState()
    }
    
    func onTapSaveAsBlock() {
        saveAsType = .block
        updateDataState()
    }
    
    func onTapCancel() {
        try? contentManager.clearSharedContent()
        dismiss.toggle()
    }
    
    func onTapSave() {
        guard let saveOptions else {
            anytypeAssertionFailure("Try to save sharing content without save options", info: [
                "saveAsType": "\(saveAsType)",
                "spaceDetailsIsNit": spaceDetails.isNil.description,
                "linkObjectDetailsIsNil": linkObjectDetails.isNil.description,
                "counter": "\(counter)"
            ])
            return
        }
        
        Task {
            saveInProgress = true
            let content = try contentManager.getSharedContent()
            try await interactor.saveContent(saveOptions: saveOptions, content: content)
            try contentManager.clearSharedContent()
            dismiss.toggle()
        }
    }
    
    func onTapSelectSpace() {
        output?.onSpaceSelection { [weak self] newSpaceView in
            self?.spaceDetails = newSpaceView
            self?.updateDataState()
        }
    }
    
    func onTapLinkObject() {
        guard let spaceDetails else {
            anytypeAssertionFailure("Try open document selection without space")
            return
        }
        output?.onDocumentSelection(
            data: ObjectSearchModuleData(
                spaceId: spaceDetails.targetSpaceId,
                title: linkTitle,
                layoutLimits: saveAsType.supportedLayouts,
                onSelect: { [weak self] searchData in
                    self?.linkObjectDetails = searchData.details
                    self?.updateDataState()
                }
            )
        )
    }
    // MARK: - Private
    
    private func setupData() {
        guard let content = try? contentManager.getSharedContent() else {
            try? contentManager.clearSharedContent()
            return
        }
        
        counter.textCount = content.items.filter(\.isText).count
        counter.bookmarksCount = content.items.filter(\.isUrl).count
        counter.filesCount = content.items.filter(\.isFile).count
        spaceDetails = activeWorkpaceStorage.spaceView()
        
        updateAvailableOptions()
        updateDataState()
        
        if FeatureFlags.sharingExtensionShowContentTypes {
            debugInfo = content.debugInfo
        }
    }
    
    private func updateDataState() {
        validateLinkToObject()
        updateSaveButton()
        updateTitles()
    }
    
    private func updateAvailableOptions() {
        if counter.onlyText {
            availableOptions = [.container, .block]
        } else if counter.onlyBookmarks || counter.onlyFiles {
            let otherItems = counter.bookmarksCount + counter.filesCount
            availableOptions = otherItems > 1 ? [.container, .object, .block] : [.object, .block]
        } else {
            // Different objects
            availableOptions = [.container, .block]
        }
        saveAsType = availableOptions.first ?? .object
    }
    
    private func updateTitles() {
        if counter.onlyText {
            newObjectTitle = Loc.Sharing.Text.noteObject
            newBlockTitle = Loc.Sharing.Text.textBlock
        } else if counter.onlyBookmarks {
            newObjectTitle = Loc.Sharing.Url.newObject(counter.bookmarksCount)
            newBlockTitle = Loc.Sharing.Url.block(counter.bookmarksCount)
        } else if counter.onlyFiles {
            newObjectTitle = Loc.Sharing.File.newObject(counter.filesCount)
            newBlockTitle = Loc.Sharing.File.block(counter.filesCount)
        } else {
            newObjectTitle = ""
            newBlockTitle = Loc.Sharing.Any.block
        }
        
        newContainerTitle = Loc.Sharing.Text.noteObject
        
        switch saveAsType {
        case .object, .container:
            linkTitle = Loc.Sharing.linkTo
        case .block:
            linkTitle = Loc.Sharing.addTo
        }
        
        spaceName = spaceDetails?.title ?? ""
        linkObjectName = linkObjectDetails?.title ?? ""
    }
    
    private func updateSaveButton() {
        updateSpaceOptions()
        isSaveButtonAvailable = saveOptions.isNotNil
    }
    
    private func updateSpaceOptions() {
        guard let spaceDetails else {
            saveOptions = nil
            return
        }
        
        switch saveAsType {
        case .container:
            saveOptions = .container(spaceId: spaceDetails.targetSpaceId, linkToObject: linkObjectDetails)
        case .object:
            saveOptions = .newObject(spaceId: spaceDetails.targetSpaceId, linkToObject: linkObjectDetails)
        case .block:
            if let linkObjectDetails {
                saveOptions = .blocks(spaceId: spaceDetails.targetSpaceId, addToObject: linkObjectDetails)
            } else {
                saveOptions = nil
            }
        }
    }
    
    private func validateLinkToObject() {
        guard let linkObjectDetails else { return }
        
        if !saveAsType.supportedLayouts.contains(linkObjectDetails.layoutValue) {
            self.linkObjectDetails = nil
        }
        
        if linkObjectDetails.spaceId != spaceDetails?.targetSpaceId {
            self.linkObjectDetails = nil
        }
    }
}
