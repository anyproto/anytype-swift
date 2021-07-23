import SwiftUI

extension SwiftUI.Image {
    func correctAspectRatio(ofImage: UIImage, contentMode: ContentMode) -> some View {
        self.aspectRatio(aspectRatio(ofImage.size), contentMode: contentMode)
    }
    
    private func aspectRatio(_ value: CGSize) -> CGFloat {
        guard value.height != 0, value.width != 0 else { return 0 }
        let width = value.width
        let height = value.height
        return width < height ? width / height : height / width
    }
}
