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
        .presentationDetentsHeightAndLargeLegacy(height: 250)
        .presentationDragIndicatorHiddenLegacy()
    }
    
    @ViewBuilder
    private var plus: some View {
        if model.canCreateNewSpace {
            Button {
                model.onTapNewSpace()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Color.Background.highlightedOfSelected
                            .cornerRadius(8)
                            .border(8, color: Color.Shape.secondary)
                        IconView(icon: .asset(.X24.plus))
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 48, height: 48)
                    AnytypeText(Loc.Gallery.installToNew, style: .uxTitle2Regular, color: .Text.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(height: 64)
            }
        }
    }
    
    private var spaces: some View {
        ForEach(model.spaces) { space in
            Button {
                model.onTapSpace(spaceView: space)
            } label: {
                HStack(spacing: 12) {
                    IconView(icon: space.objectIconImage)
                        .frame(width: 48, height: 48)
                    AnytypeText(space.name, style: .uxTitle2Regular, color: .Text.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .frame(height: 64)
            }
        }
    }
}
