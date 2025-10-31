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
            .onChange(of: model.showJoinSpaceButton) { _, showJoin in
                model.updatePreviewForJoinButton(showJoin)
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.publishToWeb)
            
            topContent
            
            Spacer()
            
            bottomContent
        }
        .padding(.horizontal, 16)
    }
    
    private var topContent: some View {
        VStack(spacing: 0) {
            customUrlSection
            
            SectionHeaderView(title: Loc.preferences)
            joinSpaceButtonToggle
        }
    }
    
    private var customUrlSection: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.customizeURL)
            domain
            Spacer.fixedHeight(8)
            customPathInput
        }
    }
    
    private var customPathInput: some View {
        HStack(spacing: 0) {
            AnytypeText("/", style: .bodyRegular)
                .foregroundColor(.Text.primary)
            TextField(Loc.Publishing.Url.placeholder, text: $model.customPath)
                .textFieldStyle(PlainTextFieldStyle())
                .textInputAutocapitalization(.never)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .foregroundColor(.Text.primary)
        }
        .padding(12)
        .border(10, color: .Shape.primary)
        .background(Color.Background.primary)
        .cornerRadius(10)
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
        HStack(spacing: 0) {
            Image(asset: .X24.plusRounded)
                .frame(width: 24, height: 24)
                .foregroundStyle( Color.Control.secondary)
            
            Spacer.fixedWidth(6)
            
            AnytypeText(Loc.joinSpaceButton, style: .uxBodyRegular)
                .lineLimit(1)
                .foregroundColor(.Text.primary)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            Toggle("", isOn: $model.showJoinSpaceButton)
                .toggleStyle(SwitchToggleStyle(tint: .Control.accent80))
            
            Spacer.fixedWidth(6)
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var bottomContent: some View {
        Spacer.fixedHeight(16)
        
        PublishingPreview(data: model.previewData, isPublished: model.status.isNotNil, output: model)
            .frame(maxWidth: .infinity)
        
        Spacer.fixedHeight(12)
        
        buttons
        
        Spacer.fixedHeight(10)
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
                    action: { try await model.onPublishTap(action: .update) }
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
                action: { try await model.onPublishTap(action: .create) }
            )
            
            Spacer.fixedHeight(16)
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
