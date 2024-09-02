import SwiftUI


struct WallpaperColorsGridView: View {
    
    let spaceIcon: Icon?
    let onCoverSelect: (SpaceWallpaperType) -> ()
    
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
            LazyVGrid(columns: columns, spacing: 0, pinnedViews: []) {
                blurredIconView
                gradientsSection
                colorsSection
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var colorsSection: some View {
        ForEach(CoverColor.allCases) { color in
            colorView(color)
        }
    }
    
    private var gradientsSection: some View {
        ForEach(CoverGradient.allCases) { gradient in
            gradientView(gradient)
        }
    }
    
    private func colorView(_ color: CoverColor) -> some View {
        DashboardWallpaper(wallpaper: .color(color), spaceIcon: spaceIcon)
            .сoverGridAppearance()
            .onTapGesture {
                onCoverSelect(.color(color))
            }
    }
    
    private func gradientView(_ gradient: CoverGradient) -> some View {
        DashboardWallpaper(wallpaper: .gradient(gradient), spaceIcon: spaceIcon)
            .сoverGridAppearance()
            .onTapGesture {
                onCoverSelect(.gradient(gradient))
            }
    }
    
    private var blurredIconView: some View {
        Group {
            if let spaceIcon {
                GeometryReader { geo in
                    DashboardWallpaper(wallpaper: .blurredIcon, spaceIcon: spaceIcon)
                        .frame(width: geo.size.width)
                        .сoverGridAppearance()
                        .onTapGesture {
                            onCoverSelect(.blurredIcon)
                        }
                        .overlay(alignment: .center) {
                            VStack(alignment: .center, spacing: 9) {
                                Image(asset: .X24.blur).frame(width: 24, height: 24)
                                AnytypeText("Blurred\n icon", style: .caption2Regular)
                                    .multilineTextAlignment(.center)
                            }
                        }
                }
            } else {
                EmptyView()
            }
        }
    }
}

private extension View {
    func сoverGridAppearance() -> some View {
        self
            .cornerRadius(4)
            .clipped()
            .frame(height: 208)
            .padding(.top, 16)
    }
    
}

struct WallpaperColorsGridView_Previews: PreviewProvider {
    static var previews: some View {
        MockView {
            WorkspacesStorageMock.shared.spaceView = SpaceView.mock(id: "1337")
        } content: {
            WallpaperColorsGridView(spaceIcon: .object(.space(.gradient(.random))), onCoverSelect: { _ in })
        }
    }
}
