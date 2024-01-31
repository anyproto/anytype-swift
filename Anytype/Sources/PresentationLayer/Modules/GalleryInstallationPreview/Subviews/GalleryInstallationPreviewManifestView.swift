import Foundation
import SwiftUI
import Services

struct GalleryInstallationPreviewManifestView: View {

    let manifest: GalleryManifest
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottom) {
                        TabView {
                            ForEach(manifest.screenshots, id: \.self) { url in
                                AsyncImage(
                                    url: URL(string: url),
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
