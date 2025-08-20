import Foundation
import SwiftUI
import Services

struct MessageCommonObjectView: View {
    
    let icon: Icon
    let title: String
    let description: String
    let style: MessageAttachmentStyle
    let size: String?
    let syncStatus: SyncStatus?
    let syncError: SyncError?
    
    var body: some View {
        HStack(spacing: 12) {
            MessageFileUploadingStatus(icon: icon, syncStatus: syncStatus, syncError: syncError)
            
            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .anytypeStyle(.previewTitle2Medium)
//                    .foregroundColor(style.titleColor)
//                HStack(spacing: 6) {
////                    Text(description)
////                        .anytypeStyle(.relation3Regular)
//                    if let size {
//                        Circle()
//                            .fill(style.descriptionColor)
//                            .frame(width: 3, height: 3)
//                        Text(size)
//                            .anytypeStyle(.relation3Regular)
//                    }
//                }
//                .foregroundColor(style.descriptionColor)
            }
//            .lineLimit(1)
            Spacer()
        }
        .padding(12)
    }
}
