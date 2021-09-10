import BlocksModels
import UIKit

final class ObjectHeaderBuilder {
    
    func objectHeader(details: DetailsDataProtocol?) -> ObjectHeader {
        guard let details = details else {
            return .empty
        }
        return buildObjectHeader(details: details)
    }
    
    func objectHeaderForLocalEvent(details: DetailsDataProtocol?, event: ObjectHeaderLocalEvent) -> ObjectHeader {
        guard let details = details else {
            return fakeHeader(event: event)
        }
        
        let header = buildObjectHeader(details: details)
        
        return header.modifiedByLocalEvent(event) ?? .empty
    }
    
    private func fakeHeader(event: ObjectHeaderLocalEvent) -> ObjectHeader {
        switch event {
        case .iconUploading(let uIImage):
            return ObjectHeader.iconOnly(
                .preview(.basic(uIImage), .left)
            )
        case .coverUploading(let uIImage):
            return ObjectHeader.coverOnly(
                .preview(uIImage)
            )
        }
    }
    
    private func buildObjectHeader(details: DetailsDataProtocol) -> ObjectHeader {
        let layoutAlign = details.layoutAlign ?? .left
        
        if let icon = details.icon, let cover = details.documentCover {
            return .iconAndCover(
                icon: .icon(icon, layoutAlign),
                cover: .cover(cover)
            )
        }
        
        if let icon = details.icon {
            return .iconOnly(
                .icon(icon, layoutAlign)
            )
        }
        
        if let cover = details.documentCover {
            return .coverOnly(.cover(cover))
        }
        
        return .empty
    }
}
