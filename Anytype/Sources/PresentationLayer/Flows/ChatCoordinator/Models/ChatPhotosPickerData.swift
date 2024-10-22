import PhotosUI
import SwiftUI

struct ChatPhotosPickerData {
    let id = UUID()
    let selectedItems: [PhotosPickerItem]
    let handler: (_ result: [PhotosPickerItem]) -> Void
}
