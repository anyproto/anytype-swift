import SwiftUI
import Services
import AnytypeCore
import Loc

@MainActor
protocol PublishingPreviewOutput: AnyObject {
    func onPreviewTap()
    func onPreviewOpenWebPage()
    func onPreviewShareLink()
    func onPreviewCopyLink()
}

struct PublishingPreview: View {
    let data: PublishingPreviewData
    let isPublished: Bool
    weak var output: (any PublishingPreviewOutput)?
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            content
                .onAppear {
                    screenSize = geometry.size
                }
                .onChange(of: geometry.size) { newSize in
                    screenSize = newSize
                }
        }
        .frame(height: screenSize.width * 0.65)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            browserHeader
            previewContent
        }
        .background(Color.Background.secondary)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Shape.secondary, lineWidth: 1)
        )
        .if(isPublished) { view in
            view
                .onTapGesture {
                    output?.onPreviewTap()
                }
                .contextMenu {
                    contextMenuContent
                }
        }
    }
    
    private var browserHeader: some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(Color.Control.transparentInactive)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
        }
        .frame(height: 24)
        .background(Color.Shape.secondary)
    }
    
    private var previewContent: some View {
        VStack(spacing: 0) {
            if data.showJoinButton {
                spaceHeader
            } else {
                Spacer.fixedHeight(8)
            }
            
            if data.cover != nil || data.icon != nil {
                coverSection
            }
            
            contentSection
            
            Spacer()
        }
        .animation(.default, value: data.showJoinButton)
    }
    
    private var spaceHeader: some View {
        HStack {
            AnytypeText(data.spaceName, style: .caption2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
            
            Spacer()
            
            joinButton
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .frame(height: 28)
    }
    
    private var joinButton: some View {
        HStack(spacing: 4) {
            AnytypeText(Loc.join, style: .caption2Medium)
                .foregroundColor(.Text.inversion)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2.5)
        .background(Color.Control.primary)
        .cornerRadius(4)
    }
    
    @ViewBuilder
    private var coverSection: some View {
        ZStack(alignment: .bottomLeading) {
            coverBackground
            iconOverlay
                .offset(y: data.cover.isNotNil ? max(8, screenSize.width * 0.01) : 0)
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private var iconOverlay: some View {
        if let icon = data.icon {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.Background.primary)
                    .frame(
                        width: min(40, screenSize.width * 0.1) + 1,
                        height: min(40, screenSize.width * 0.1) + 1
                    )
                
                ObjectIconView(icon: icon)
                    .frame(
                        width: min(40, screenSize.width * 0.1),
                        height: min(40, screenSize.width * 0.1)
                    )
            }
            .padding(.leading, 24)
        }
    }
    
    @ViewBuilder
    private var coverBackground: some View {
        Group {
            if let cover = data.cover {
                ObjectHeaderCoverView(
                    objectCover: .cover(cover),
                    fitImage: false
                )
                .frame(height: screenSize.width * 0.23)
            } else if data.icon.isNotNil {
                Rectangle()
                    .fill(Color.Background.primary)
                    .frame(height: screenSize.width * 0.12)
            } else {
                EmptyView()
            }
        }
        .cornerRadius(4)
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AnytypeText(data.title, style: .uxTitle2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(Color.Shape.secondary)
                    .frame(
                        width: min(240, screenSize.width * 0.8),
                        height: 6
                    )
                    .cornerRadius(1)
                
                Rectangle()
                    .fill(Color.Shape.secondary)
                    .frame(
                        width: min(140, screenSize.width * 0.6),
                        height: 6
                    )
                    .cornerRadius(1)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            output?.onPreviewOpenWebPage()
        } label: {
            Label(Loc.openWebPage, systemImage: "arrow.up.forward.app")
        }
        
        Button {
            output?.onPreviewShareLink()
        } label: {
            Label(Loc.SpaceShare.Share.link, systemImage: "square.and.arrow.up")
        }
        
        Button {
            output?.onPreviewCopyLink()
        } label: {
            Label(Loc.Actions.copyLink, systemImage: "doc.on.doc")
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // Branch 1: Has cover + icon + join button
            VStack(spacing: 8) {
                AnytypeText("Cover + Icon + Join Button", style: .caption1Medium)
                    .foregroundColor(.Text.secondary)
                PublishingPreview(data: PublishingPreviewData(
                    spaceName: "Anytype Design",
                    title: "What I Learned as a Product Designer",
                    cover: .gradient(GradientColor(
                        start: UIColor(red: 1.0, green: 0.655, blue: 0.149, alpha: 1.0),
                        end: UIColor(red: 0.612, green: 0.153, blue: 0.69, alpha: 1.0)
                    )),
                    icon: .emoji(Emoji("🎨")!),
                    showJoinButton: true
                ), isPublished: true, output: nil)
            }
            
            // Branch 2: Has cover but no icon
            VStack(spacing: 8) {
                AnytypeText("Cover Only (No Icon)", style: .caption1Medium)
                    .foregroundColor(.Text.secondary)
                PublishingPreview(data: PublishingPreviewData(
                    spaceName: "Design Blog",
                    title: "Understanding Design Systems",
                    cover: .gradient(GradientColor(
                        start: UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),
                        end: UIColor(red: 0.8, green: 0.2, blue: 0.9, alpha: 1.0)
                    )),
                    icon: nil,
                    showJoinButton: false
                ), isPublished: false, output: nil)
            }
            
            // Branch 3: No cover but has icon (white background)
            VStack(spacing: 8) {
                AnytypeText("Icon Only (White Background)", style: .caption1Medium)
                    .foregroundColor(.Text.secondary)
                PublishingPreview(data: PublishingPreviewData(
                    spaceName: "Personal Space",
                    title: "My Daily Notes",
                    cover: nil,
                    icon: .emoji(Emoji("📝")!),
                    showJoinButton: true
                ), isPublished: true, output: nil)
            }
            
            // Branch 4: No cover and no icon (no cover section)
            VStack(spacing: 8) {
                AnytypeText("No Cover, No Icon", style: .caption1Medium)
                    .foregroundColor(.Text.secondary)
                PublishingPreview(data: PublishingPreviewData(
                    spaceName: "Simple Space",
                    title: "Welcome to Anytype",
                    cover: nil,
                    icon: nil,
                    showJoinButton: false
                ), isPublished: false, output: nil)
            }
        }
        .padding()
    }
    .background(Color.Background.primary)
}
