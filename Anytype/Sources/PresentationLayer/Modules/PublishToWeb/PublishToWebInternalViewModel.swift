import Foundation
import SwiftUI
import Services
import AnytypeCore
import ProtobufMessages

enum PublishAction {
    case create
    case update
}

@MainActor
final class PublishToWebInternalViewModel: ObservableObject, PublishingPreviewOutput {
    
    @Published var customPath: String = ""
    @Published var showJoinSpaceButton: Bool = true
    @Published var status: PublishState?
    
    @Published var error: String?
    @Published var previewData: PublishingPreviewData = .empty
    @Published var toastBarData: ToastBarData?
    
    let domain: DomainType
    let objectDetails: ObjectDetails
    
    private weak var output: (any PublishToWebModuleOutput)?
    
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    @Injected(\.publishingPreviewBuilder)
    private var previewBuilder: any PublishingPreviewBuilderProtocol
    @Injected(\.publishedUrlBuilder)
    private var urlBuilder: any PublishedUrlBuilderProtocol
    
    private let spaceId: String
    private let objectId: String
    
    private var analyticsObjectType: AnalyticsObjectType {
        return objectDetails.objectType.analyticsType
    }
    
    init(data: PublishToWebViewInternalData, output: (any PublishToWebModuleOutput)?) {
        spaceId = data.spaceId
        objectId = data.objectId
        domain = data.domain
        status = data.status
        objectDetails = data.objectDetails
        self.output = output
        
        customPath = data.status?.uri ?? data.objectDetails.name
        showJoinSpaceButton = data.status?.joinSpace ?? true
        
        previewData = previewBuilder.buildPreviewData(
            from: data.objectDetails,
            spaceName: data.spaceName,
            showJoinButton: showJoinSpaceButton
        )
    }
    
    func onPublishTap(action: PublishAction) async throws {
        switch action {
        case .create:
            AnytypeAnalytics.instance().logClickShareObjectPublish(objectType: analyticsObjectType)
        case .update:
            AnytypeAnalytics.instance().logClickShareObjectUpdate(objectType: analyticsObjectType)
        }
        
        try await publishingService.create(spaceId: spaceId, objectId: objectId, uri: customPath, joinSpace: showJoinSpaceButton)
        status = try await publishingService.getStatus(spaceId: spaceId, objectId: objectId)
        
        if status.isNotNil {
            switch action {
            case .create:
                AnytypeAnalytics.instance().logShareObjectPublish(objectType: analyticsObjectType)
                toastBarData = ToastBarData(Loc.PublishingToWeb.published)
            case .update:
                AnytypeAnalytics.instance().logShareObjectUpdate(objectType: analyticsObjectType)
                toastBarData = ToastBarData(Loc.PublishingToWeb.updated)
            }
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func onUnpublishTap() async throws {
        AnytypeAnalytics.instance().logClickShareObjectUnpublish(objectType: analyticsObjectType)
        
        try await publishingService.remove(spaceId: spaceId, objectId: objectId)
        status = try await publishingService.getStatus(spaceId: spaceId, objectId: objectId)
        
        if status.isNil {
            AnytypeAnalytics.instance().logShareObjectUnpublish(objectType: analyticsObjectType)
            toastBarData = ToastBarData(Loc.PublishingToWeb.unpublished)
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func onFreeDomainTap() {
        AnytypeAnalytics.instance().logClickUpgradePlanTooltip(type: .publish, route: .publish)
        output?.onShowMembership()
    }
    
    func updatePreviewForJoinButton(_ showJoin: Bool) {
        AnytypeAnalytics.instance().logJoinSpaceButtonToPublish(objectType: analyticsObjectType, type: showJoin)
        previewData = previewBuilder.buildPreviewData(
            from: previewData,
            showJoinButton: showJoin
        )
    }
    
    // MARK: - PublishingPreviewOutput
    
    func onPreviewOpenWebPage() {
        AnytypeAnalytics.instance().logClickShareObjectOpenPage(objectType: analyticsObjectType, route: .menu)
        guard let publishedUrl = urlBuilder.buildPublishedUrl(domain: domain, customPath: customPath) else { return }
        output?.onOpenPreview(url: publishedUrl)
    }
    
    func onPreviewShareLink() {
        AnytypeAnalytics.instance().logClickShareObjectShareLink(objectType: analyticsObjectType)
        guard let publishedUrl = urlBuilder.buildPublishedUrl(domain: domain, customPath: customPath) else { return }
        output?.onSharePreview(url: publishedUrl)
    }
    
    func onPreviewCopyLink() {
        AnytypeAnalytics.instance().logClickShareObjectCopyUrl(objectType: analyticsObjectType)
        guard let publishedUrl = urlBuilder.buildPublishedUrl(domain: domain, customPath: customPath) else { return }
        UIPasteboard.general.string = publishedUrl.absoluteString
        toastBarData = ToastBarData(Loc.copiedToClipboard(Loc.link))
    }
}
