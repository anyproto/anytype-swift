import SwiftUI
import AnytypeCore
import Services


struct PublishToWebInternalView: View {
    
    @StateObject private var model: PublishToWebInternalViewModel
    
    init(data: PublishToWebViewInternalData, output: (any PublishToWebModuleOutput)?) {
        _model = StateObject(wrappedValue: PublishToWebInternalViewModel(data: data, output: output))
    }
    
    var body: some View {
        content
            .onChange(of: model.showJoinSpaceButton) { showJoin in
                model.updatePreviewForJoinButton(showJoin)
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.publishToWeb)
            
            mainContent
            
            buttons
            
            errorView
        }
        .padding(.horizontal, 16)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            customUrlSection
            
            SectionHeaderView(title: Loc.preferences)
            joinSpaceButtonToggle
            
            Spacer()
            
            PublishingPreview(data: model.previewData)
                .frame(maxWidth: .infinity)
            
            Spacer.fixedHeight(12)
        }
    }
    
    private var customUrlSection: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: Loc.customizeURL)
            
            domain
            
            HStack {
                AnytypeText("/", style: .bodyRegular)
                    .foregroundColor(.Text.secondary)
                TextField(Loc.Publishing.Url.placeholder, text: $model.customPath)
                    .textFieldStyle(PlainTextFieldStyle())
                    .textInputAutocapitalization(.never)
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
    
    @ViewBuilder
    private var domain: some View {
        switch model.domain {
        case .paid(let domainUrl):
            paidDomain(domainUrl: domainUrl)
        case .free(let domainUrl):
            freeDomain(domainUrl: domainUrl)
        }
    }
    
    private func paidDomain(domainUrl: String) -> some View {
        HStack {
            AnytypeText(domainUrl, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .border(10, color: .Shape.primary)
        .background(Color.Shape.transperentTertiary)
        .cornerRadius(10)
    }
    
    private func freeDomain(domainUrl: String) -> some View {
        Button(action: {
            model.onFreeDomainTap()
        }, label: {
            HStack {
                HStack(spacing: 8) {
                    AnytypeText(domainUrl, style: .bodyRegular)
                        .foregroundColor(.Text.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        AnytypeText("Pro", style: .relation1Regular)
                            .foregroundColor(.Control.accent125)
                        Image(systemName: "line.diagonal.arrow")
                            .resizable()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(Color.Control.accent125)
                    }
                    .padding(.horizontal, 6)
                    .background(Color.Control.accent25)
                    .cornerRadius(4, style: .continuous)
                }
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .border(10, color: .Shape.primary)
            .background(Color.Shape.transperentTertiary)
            .cornerRadius(10)
        })
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
    
    @ViewBuilder
    private var buttons: some View {
        if model.status.isNotNil {
            controlButtons
        } else {
            publishButton
        }
    }
    
    private var controlButtons: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(16)
            
            HStack(spacing: 8) {
                AsyncStandardButton(
                    Loc.unpublish,
                    style: .secondaryLarge,
                    action: { try await model.onUnpublishTap() }
                )
                
                AsyncStandardButton(
                    Loc.update,
                    style: .primaryLarge,
                    action: { try await model.onPublishTap() }
                )
            }
            
            Spacer.fixedHeight(16)
        }
    }
    
    private var publishButton: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(16)
            
            AsyncStandardButton(
                Loc.publish,
                style: .primaryLarge,
                action: { try await model.onPublishTap() }
            )
            
            Spacer.fixedHeight(16)
        }
    }
    
    @ViewBuilder
    private var errorView: some View {
        if let error = model.error {
            AnytypeText(error, style: .caption1Regular)
                .foregroundColor(.Pure.red)
        }
    }
}

#Preview {
    PublishToWebInternalView(data: PublishToWebViewInternalData(
        objectId: "",
        spaceId: "",
        domain: .paid("vo.va"),
        status: nil,
        objectDetails: ObjectDetails(id: ""),
        spaceName: "My Space"
    ), output: nil)
}
