import SwiftUI
import Services
import AnytypeCore

@MainActor
@Observable
final class PublishedSitesViewModel {
    @ObservationIgnored @Injected(\.publishingService)
    private var publishingService: any PublishingServiceProtocol
    @ObservationIgnored @Injected(\.participantsStorage)
    private var participantStorage: any ParticipantsStorageProtocol
    @ObservationIgnored @Injected(\.publishedUrlBuilder)
    private var urlBuilder: any PublishedUrlBuilderProtocol

    @ObservationIgnored
    private let dateFormatter = HistoryDateFormatter()
    @ObservationIgnored
    private let byteCountFormatter = ByteCountFormatter.fileFormatter

    var sites: [PublishState]?
    var error: String?
    var safariUrl: URL?
    var toastBarData: ToastBarData?

    @ObservationIgnored
    lazy var domain: DomainType? = { participantStorage.participants.first?.publishingDomain }()

    @ObservationIgnored
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
