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
            "Invalid QR Code"
        case .invalidFormat:
            "Invalid QR Code"
        case .wrongLinkType:
            "Invalid QR Code"
        case .custom(let string):
            "Scanning error"
        }
    }
    
    var message: String {
        switch self {
        case .notAnUrl:
            "The scanned QR code doesn’t contain a valid URL"
        case .invalidFormat:
            "The scanned QR code contains URL in invalid format"
        case .wrongLinkType:
            "The scanned QR code contains different action"
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
            BottomAlertButton(text: "Try again", style: .primary) {
                tryAgain()
            }
            
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
        
    }
    
    
}
