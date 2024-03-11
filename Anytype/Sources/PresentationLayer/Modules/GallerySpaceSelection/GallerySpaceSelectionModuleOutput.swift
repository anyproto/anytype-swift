import Foundation

enum GallerySpaceSelectionResult {
    case space(spaceId: String)
    case newSpace
}

@MainActor
protocol GallerySpaceSelectionModuleOutput: AnyObject {
    func onSelectSpace(result: GallerySpaceSelectionResult)
}
