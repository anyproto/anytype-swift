import Foundation

struct LinkToObjectSearchModuleData: Identifiable, Hashable, Equatable {
    let spaceId: String
    let currentLinkUrl: URL?
    let currentLinkString: String?
    let route: AnalyticsEventsRouteKind
    
    @EquatableNoop
    var setLinkToObject: (_ blockId: String) -> Void
    @EquatableNoop
    var setLinkToUrl: (_ url: URL) -> Void
    @EquatableNoop
    var removeLink: () -> Void
    @EquatableNoop
    var willShowNextScreen: (() -> Void)?
    
    var id: Int { hashValue }
}
