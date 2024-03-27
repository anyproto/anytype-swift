import Foundation
import QRCode
import UIKit

final class QrCodeViewModel: ObservableObject {
    
    let document: QRCode.Document
    let title: String
    @Published var sharedData: Data?
    
    init(title: String, data: String) {
        self.title = title
        
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
    
    func onShare() {
        sharedData = document.jpegData(dimension: 600)
    }
}
