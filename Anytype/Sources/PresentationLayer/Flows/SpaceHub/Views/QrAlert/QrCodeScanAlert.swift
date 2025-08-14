import SwiftUI
import Loc

enum QrCodeScanAlertError: Identifiable {
    case notAnUrl
    case invalidFormat
    case wrongLinkType
    case custom(String)
    
    var id: String { message }
    
    var title: String {
        switch self {
        case .notAnUrl:
            Loc.Qr.Scan.Error.InvalidQR.title
        case .invalidFormat:
            Loc.Qr.Scan.Error.InvalidQR.title
        case .wrongLinkType:
            Loc.Qr.Scan.Error.InvalidQR.title
        case .custom(let string):
            Loc.Qr.Scan.Error.Custom.title
        }
    }
    
    var message: String {
        switch self {
        case .notAnUrl:
            Loc.Qr.Scan.Error.NotUrl.message
        case .invalidFormat:
            Loc.Qr.Scan.Error.InvalidFormat.message
        case .wrongLinkType:
            Loc.Qr.Scan.Error.WrongLink.message
        case .custom(let string):
            string
        }
    }
}

struct QrCodeScanAlert: View {
    let error: QrCodeScanAlertError
    let tryAgain: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(title: error.title, message: error.message, icon: .Dialog.exclamation) {
            BottomAlertButton(text: Loc.tryAgain, style: .primary) {
                tryAgain()
            }
            
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
        
    }
    
    
}
