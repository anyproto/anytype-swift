import Foundation
import SwiftUI
import Services
import WrappingHStack

struct GalleryInstallationPreviewManifestView: View {

    let manifest: GalleryInstallationPreviewViewModel.Manifest
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottom) {
                        TabView {
                            ForEach(manifest.screenshots, id: \.self) { url in
                                AsyncImage(
                                    url: url,
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 300)
                                            .shadow(radius: 40, y: 4)
                                    },
                                    placeholder: {
                                        Color.gray
                                            .frame(maxHeight: 300)
                                            .redacted(reason: .placeholder)
                                            .cornerRadius(16, style: .continuous)
                                            .shadow(radius: 40, y: 4)
                                    }
                                )
//                                .background(Color.red)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                .padding(.bottom, 40)
                                //                            .cornerRadius(16, style: .continuous)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        
                        LinearGradient(colors: [.white, .clear], startPoint: .bottom, endPoint: .top)
                            .allowsHitTesting(false)
                            .frame(height: 50)
                    }
                    .frame(height: 360)
//                    .background(Color.green)
                    Group {
                        AnytypeText(manifest.title, style: .title, color: .Text.primary)
                        Spacer.fixedHeight(8)
                        AnytypeText(manifest.description, style: .bodyRegular, color: .Text.primary)
                        Spacer.fixedHeight(20)
                        WrappingHStack(manifest.categories, spacing: .constant(8), lineSpacing: 8) { category in
                            AnytypeText(category, style: .caption1Medium, color: .Text.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Color.Stroke.secondary)
                                .cornerRadius(4, style: .continuous)
                        }
                        Spacer.fixedHeight(16)
                        AnytypeText(manifest.author, style: .caption1Regular, color: .Text.secondary)
                        Spacer.fixedHeight(2)
                        AnytypeText(manifest.fileSize, style: .caption1Regular, color: .Text.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        StandardButton("Install", style: .primaryMedium) {
            
        }
        .padding(.horizontal, 20)
    }
}
