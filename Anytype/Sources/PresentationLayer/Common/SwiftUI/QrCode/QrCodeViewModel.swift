import Foundation
import QRCode
import UIKit

@MainActor
@Observable
final class QrCodeViewModel {

    @ObservationIgnored
    private let analyticsType: ScreenQrAnalyticsType
    @ObservationIgnored
    private let route: ScreenQrRoute

    @ObservationIgnored
    let document: QRCode.Document
    @ObservationIgnored
    let title: String
    var sharedData: DataIdentifiable?
    
    init(title: String, data: String, analyticsType: ScreenQrAnalyticsType, route: ScreenQrRoute) {
        self.title = title
        self.analyticsType = analyticsType
        self.route = route
        
        document = (try? QRCode.Document(utf8String: data)) ?? QRCode.Document()
        document.design.backgroundColor(UIColor.white.cgColor)
        
        if let icon = UIImage(asset: .QrCode.smile)?.cgImage {
            let p = CGPath(rect: CGRect(x: 0.33, y: 0.33, width: 0.34, height: 0.34), transform: nil)
            let logoTemplate = QRCode.LogoTemplate(
                image: icon,
                path: p,
                inset: 4
            )
            document.logoTemplate = logoTemplate
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenQr(type: analyticsType, route: route)
    }
    
    func onShare() {
        AnytypeAnalytics.instance().logClickQr()
        sharedData = try? document.jpegData(dimension: 600).identifiable
    }
}
