import Foundation
import QRCode
import UIKit

final class QrCodeViewModel: ObservableObject {
    
    private let analyticsType: ScreenQrAnalyticsType
    
    let document: QRCode.Document
    let title: String
    @Published var sharedData: DataIdentifiable?
    
    init(title: String, data: String, analyticsType: ScreenQrAnalyticsType) {
        self.title = title
        self.analyticsType = analyticsType
        
        document = QRCode.Document(generator: QRCodeGenerator_External())
        document.utf8String = data
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
        AnytypeAnalytics.instance().logScreenQr(type: analyticsType)
    }
    
    func onShare() {
        AnytypeAnalytics.instance().logClickQr()
        sharedData = document.jpegData(dimension: 600)?.identifiable
    }
}
