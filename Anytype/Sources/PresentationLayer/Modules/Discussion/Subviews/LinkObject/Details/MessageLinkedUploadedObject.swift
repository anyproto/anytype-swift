import SwiftUI
import Services

struct MessageLinkedUploadedObject: View {
    
    let details: ObjectDetails
    let onTapObject: () -> Void
    let onTapRemove: () -> Void
    
    var body: some View {
        switch details.layoutValue {
        case .image:
            MessageLinkImageView(details: details, onTapRemove: { _ in
                onTapRemove()
            })
            .onTapGesture {
                onTapObject()
            }
        case .video:
            
        default:
            MessageLinkObjectView(details: details, style: .input, onTapRemove: { _ in
                onTapRemove()
            })
            .onTapGesture {
                onTapObject()
            }
        }
    }
}
