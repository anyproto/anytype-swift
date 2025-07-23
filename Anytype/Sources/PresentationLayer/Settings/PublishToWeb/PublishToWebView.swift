import SwiftUI
import AnytypeCore

struct PublishToWebViewData: Identifiable, Hashable {
    let objectId: String
    let spaceId: String
    
    var id: Int { hashValue }
}


struct PublishToWebView: View {
    
    @StateObject private var model: PublishToWebViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: PublishToWebViewData) {
        _model = StateObject(wrappedValue: PublishToWebViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.publishToWeb)
            
            content
            
            publishButton
            
            errorView
        }
        .padding(.horizontal, 16)
        
        .task { await model.onAppear() }
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                customUrlSection
                
                SectionHeaderView(title: Loc.preferences)
                joinSpaceButtonToggle
                
                Spacer()
                
                previewSection
                
                Spacer.fixedHeight(12)
            }
        }
        .disabled(model.state.isError)
    }
    
    private var customUrlSection: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: Loc.customizeURL)
            
            HStack {
                AnytypeText(model.domain, style: .bodyRegular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .border(10, color: .Shape.primary)
            .background(Color.Shape.transperentTertiary)
            .cornerRadius(10)
            
            HStack {
                AnytypeText("/", style: .bodyRegular)
                    .foregroundColor(.Text.secondary)
                TextField(Loc.Publishing.Url.placeholder, text: $model.customPath)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                    .foregroundColor(.Text.primary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .border(10, color: .Shape.primary)
            .background(Color.Background.primary)
            .cornerRadius(10)
        }
    }
    
    private var joinSpaceButtonToggle: some View {
        HStack {
            HStack(spacing: 12) {
                Image(asset: .X24.plusRounded)
                    .frame(width: 24, height: 24)
                    .foregroundStyle( Color.Control.secondary)
                
                AnytypeText(Loc.joinSpaceButton, style: .uxBodyRegular)
                    .foregroundColor(.Text.primary)
            }
            
            Spacer()
            
            Toggle("", isOn: $model.showJoinSpaceButton)
                .toggleStyle(SwitchToggleStyle(tint: .Control.accent80))
            
            Spacer.fixedWidth(6)
        }

        .padding(.vertical, 16)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange)
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 8) {
                        AnytypeText("Preview Placeholder", style: .uxTitle2Medium)
                            .foregroundColor(.white)
                        AnytypeText("Your published page will appear here", style: .uxCalloutRegular)
                            .foregroundColor(.white.opacity(0.8))
                    }
                )
        }
    }
    
    private var publishButton: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(16)
            
            StandardButton(
                Loc.publish,
                style: .primaryLarge,
                action: { model.onPublishTap() }
            )
            .disabled(!model.canPublish)
            
            Spacer.fixedHeight(16)
        }
    }
    
    @ViewBuilder
    private var errorView: some View {
        switch model.state {
        case .error(let error):
            AnytypeText(error, style: .caption1Regular)
                .foregroundColor(.Pure.red)
            
        case .ok:
            EmptyView()
        }
    }
}

#Preview {
    PublishToWebView(data: PublishToWebViewData(objectId: "", spaceId: ""))
}
