import Foundation
import SwiftUI
import Services
import WrappingHStack

struct GalleryInstallationPreviewManifestView: View {

    let manifest: GalleryInstallationPreviewViewModel.Manifest
    let onTapInstall: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer.fixedHeight(24)
                TabView {
                    ForEach(manifest.screenshots, id: \.self) { url in
                        AsyncImage(
                            url: url,
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8, style: .continuous)
                            },
                            placeholder: {
                                Image(asset: .X32.plus) // Any image for make placeholder
                                    .resizable()
                                    .redacted(reason: .placeholder)
                                    .cornerRadius(8, style: .continuous)
                            }
                        )
                        .frame(height: 335)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 384)
                .shadow(radius: 40, y: 4)
                Group {
                    AnytypeText(manifest.title, style: .title)
                        .foregroundColor(.Text.primary)
                    Spacer.fixedHeight(8)
                    AnytypeText(manifest.description, style: .bodyRegular)
                        .foregroundColor(.Text.primary)
                    Spacer.fixedHeight(20)
                    WrappingHStack(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                        ForEach(manifest.categories.indices, id: \.self) { index in
                            AnytypeText(manifest.categories[index], style: .caption1Medium)
                                .foregroundColor(.Text.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Color.Shape.tertiary)
                                .cornerRadius(4, style: .continuous)

                        }
                    }
                    Spacer.fixedHeight(16)
                    AnytypeText(manifest.author, style: .caption1Regular)
                        .foregroundColor(.Text.secondary)
                    Spacer.fixedHeight(2)
                    AnytypeText(manifest.fileSize, style: .caption1Regular)
                        .foregroundColor(.Text.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .safeAreaInset(edge: .bottom) {
            StandardButton(Loc.Gallery.install, style: .primaryMedium) {
                onTapInstall()
            }
            .padding(.horizontal, 20)
        }
    }
}
