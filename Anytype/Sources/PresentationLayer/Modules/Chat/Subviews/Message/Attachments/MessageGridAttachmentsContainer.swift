import Foundation
import SwiftUI
import Services

struct MessageGridAttachmentsContainer: View {

    let objects: [[MessageAttachmentDetails]]
    let oneSide: CGFloat
    let spacing: CGFloat
    let onTapObject: (MessageAttachmentDetails) -> Void
    
    private let twoSide: CGFloat
    private let treeSide: CGFloat
    
    init(
        objects: [[MessageAttachmentDetails]],
        oneSide: CGFloat,
        spacing: CGFloat,
        onTapObject: @escaping (MessageAttachmentDetails) -> Void
    ) {
        self.objects = objects
        self.oneSide = oneSide
        self.spacing = spacing
        self.onTapObject = onTapObject
        self.twoSide = (oneSide - spacing) * 0.5
        self.treeSide = (oneSide - spacing * 2) * 0.33
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(objects, id:\.self) { rowObjects in
                HStack(spacing: spacing) {
                    ForEach(rowObjects, id:\.id) { object in
                        Group {
                            switch object.layoutValue {
                            case .video:
                                MessageVideoView(details: object)
                            default: // image and other types (for bugs)
                                ImageIdIconView(imageId: object.id)
                            }
                        }
                        .frame(width: rowItemSize(rowItems: rowObjects.count), height: rowItemSize(rowItems: rowObjects.count))
                        .cornerRadius(4)
                        .onTapGesture {
                            onTapObject(object)
                        }
                    }
                }
            }
        }
        .cornerRadius(16)
    }
    
    private func rowItemSize(rowItems: Int) -> CGFloat? {
        switch rowItems {
        case 3:
            return treeSide
        case 2:
            return twoSide
        case 1:
            return oneSide
        default:
            return nil
        }
    }
}
