import PhotosUI
import SwiftUI

struct DiscussionPhotosPickerData {
    let id = UUID()
    let selectedItems: [PhotosPickerItem]
    let handler: (_ result: [PhotosPickerItem]) -> Void
}
