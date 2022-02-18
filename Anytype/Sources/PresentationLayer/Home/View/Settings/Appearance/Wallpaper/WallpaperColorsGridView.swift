import SwiftUI

struct WallpaperColorsGridView: View {
    
    let onCoverSelect: (BackgroundType) -> ()
    
    private let columns: [GridItem] = {
        if UIDevice.isPad {
            return [GridItem(.adaptive(minimum: 100), spacing: 16)]
        } else {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible()),
            ]
        }
    }()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: columns,
                spacing: 16,
                pinnedViews: []
            ) {
                colorsSection
                gradientsSection
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var colorsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Solid colors".localized)) {
            ForEach(Wallpapers.colors) { color in
                Color(hex: color.hex)
                    .cornerRadius(4)
                    .frame(height: 208)
                    .onTapGesture {
                        onCoverSelect(.color(color))
                    }
            }
        }
    }
    
    private var gradientsSection: some View {
        Section(header: PickerSectionHeaderView(title: "Gradients".localized)) {
            ForEach(Wallpapers.gradients) { gradient in
                gradient.asLinearGradient()
                .cornerRadius(4)
                .frame(height: 208)
                .onTapGesture {
                    onCoverSelect(.gradient(gradient))
                }
            }
        }
    }
}

struct WallpaperColorsGridView_Previews: PreviewProvider {
    static var previews: some View {
        WallpaperColorsGridView(onCoverSelect: { _ in })
    }
}
