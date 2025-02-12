import SwiftUI
import Services

struct SpaceDetailsView: View {
    @StateObject private var model: SpaceDetailsViewModel
    
    init(info: AccountInfo) {
        _model = StateObject(wrappedValue: SpaceDetailsViewModel(info: info))
    }
    
    var body: some View {
        content
            .navigationBarHidden(true)
            .task { await model.setupSubscriptions() }
            .snackbar(toastBarData: $model.toastBarData)
            .sheet(item: $model.showIconPickerSpaceId) {
                SpaceObjectIconPickerView(spaceId: $0.value)
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            info
        }
    }

    private var header: some View {
        NavigationHeader(title: "") {
            Button {
                model.onSaveTap()
            } label: {
                AnytypeText(Loc.save, style: .previewTitle1Medium)
            }
        }
    }
    
    private var info: some View {
        VStack(spacing: 0) {
            Button {
                model.onChangeIconTap()
            } label: {
                VStack(spacing: 0) {
                    Spacer.fixedHeight(8)
                    IconView(icon: model.spaceIcon).frame(width: 112, height: 112)
                    Spacer.fixedHeight(8)
                    AnytypeText(Loc.Settings.editPicture, style: .caption1Medium).foregroundColor(.Text.secondary)
                }
            }
            
            Spacer.fixedHeight(24)
            
            VStack(alignment: .leading, spacing: 4) {
                AnytypeText(Loc.name, style: .calloutRegular).foregroundColor(.Text.secondary)
                AnytypeTextField(placeholder: Loc.Object.Title.placeholder, font: .bodySemibold, text: $model.spaceName)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .border(12, color: .Shape.primary, lineWidth: 0.5)
            
            Spacer.fixedHeight(12)
            
            VStack(alignment: .leading, spacing: 4) {
                AnytypeText(Loc.name, style: .calloutRegular).foregroundColor(.Text.secondary)
                AnytypeTextField(placeholder: Loc.description, font: .bodyRegular, text: $model.spaceDescription)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .border(12, color: .Shape.primary, lineWidth: 0.5)
            
            Spacer()
        }.padding(.horizontal, 16)
    }
}

