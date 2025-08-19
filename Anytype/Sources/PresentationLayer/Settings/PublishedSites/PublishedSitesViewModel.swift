import SwiftUI
import Services
import AnytypeCore


@MainActor
final class PublishedSitesViewModel: ObservableObject {
    @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    @Injected(\.accountParticipantsStorage)
    private var participantStorage: any AccountParticipantsStorageProtocol
    @Injected(\.publishedUrlBuilder)
    private var urlBuilder: any PublishedUrlBuilderProtocol
    
    private let dateFormatter = HistoryDateFormatter()
    private let byteCountFormatter = ByteCountFormatter.fileFormatter
    
    @Published var sites: [PublishState]?
    @Published var error: String?
    @Published var safariUrl: URL?
    @Published var toastBarData: ToastBarData?
    
    lazy var domain: DomainType? = { participantStorage.participants.first?.publishingDomain }()
    
    var pageNavigation: PageNavigation?
    
    func loadData() async {
        do {
            sites = try await publishingService.list()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        dateFormatter.localizedDateString(for: date)
    }
    
    func formattedSize(_ size: Int64) -> String {
        byteCountFormatter.string(fromByteCount: size)
    }
    
    func onOpenObjectTap(_ site: PublishState) {
        pageNavigation?.open(.editor(.page(
            EditorPageObject(objectId: site.objectId, spaceId: site.spaceId)
        )))
    }
    
    func onViewInBrowserTap(_ site: PublishState) {
        AnytypeAnalytics.instance().logClickShareObjectOpenPage(objectType: site.details.analyticsType, route: .mySites)
        guard let domain else { return }
        guard let publishedUrl = urlBuilder.buildPublishedUrl(domain: domain, customPath: site.uri) else { return }
        
        
        safariUrl = publishedUrl
    }
    
    func onCopyLinkTap(_ site: PublishState) {
        AnytypeAnalytics.instance().logClickShareObjectCopyUrl(objectType: site.details.analyticsType)
        guard let domain else { return }
        guard let publishedUrl = urlBuilder.buildPublishedUrl(domain: domain, customPath: site.uri) else { return }
        
        UIPasteboard.general.string = publishedUrl.absoluteString
        toastBarData = ToastBarData(Loc.copiedToClipboard(Loc.link))
    }
    
    func onUnpublishTap(_ site: PublishState) async throws {
        AnytypeAnalytics.instance().logClickShareObjectUnpublish(objectType: site.details.analyticsType)
        
        try await publishingService.remove(spaceId: site.spaceId, objectId: site.objectId)
        
        AnytypeAnalytics.instance().logShareObjectUnpublish(objectType: site.details.analyticsType)
        toastBarData = ToastBarData(Loc.PublishingToWeb.unpublished)
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        await loadData()
    }
}
