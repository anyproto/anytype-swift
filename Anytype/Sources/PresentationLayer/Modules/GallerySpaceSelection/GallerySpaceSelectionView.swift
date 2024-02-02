import Foundation
import SwiftUI

struct GallerySpaceSelectionView: View {
    
    @StateObject var model: GallerySpaceSelectionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScrollView {
                VStack(spacing: 0) {
                    plus
                    spaces
                }
                .padding(.horizontal, 20)
            }
        }
        .presentationCornerRadiusLegacy(16)
        .presentationDetentsMediumAndLargeLegacy()
        .presentationDragIndicatorHiddenLegacy()
    }
    
    private var plus: some View {
        HStack(spacing: 12) {
//            IconView(icon: space.objectIconImage)
//                .frame(width: 48, height: 48)
//            AnytypeText(space.name, style: .uxTitle2Regular, color: .Text.primary)
//            Spacer()
        }
    }
    
    private var spaces: some View {
        ForEach(model.spaces) { space in
            HStack(spacing: 12) {
                IconView(icon: space.objectIconImage)
                    .frame(width: 48, height: 48)
                AnytypeText(space.name, style: .uxTitle2Regular, color: .Text.primary)
                Spacer()
            }
            .frame(height: 64)
        }
    }
}
