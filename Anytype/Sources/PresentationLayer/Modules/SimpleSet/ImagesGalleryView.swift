import SwiftUI

struct ImagesGalleryView: View {
        
    let imageIds: [String]
    let onImageSelected: (String) -> Void
    let onImageIdAppear: (String) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: Consants.spacing),
        GridItem(.flexible(), spacing: Consants.spacing)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: Consants.spacing) {
                ForEach(imageIds, id:\.self) { imageId in
                    galleryItem(for: imageId)
                }
            }
            .padding(.vertical, 8)
        }
        .scrollIndicators(.never)
        .scrollDismissesKeyboard(.immediately)
    }
    
    private func galleryItem(for imageId: String) -> some View {
        ImageIdIconView(imageId: imageId)
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(12, style: .continuous)
            .onAppear {
                onImageIdAppear(imageId)
            }
            .onTapGesture {
                onImageSelected(imageId)
            }
    }
}

extension ImagesGalleryView {
    enum Consants {
        static let spacing: CGFloat = 10
    }
}
