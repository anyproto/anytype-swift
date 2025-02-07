import SwiftUI
import Services

struct SpaceDetailsView: View {
    @StateObject private var model: SpaceDetailsViewModel
    
    init(info: AccountInfo, output: any SpaceSettingsModuleOutput) {
        _model = StateObject(wrappedValue: SpaceDetailsViewModel(info: info, output: output))
    }
    
    var body: some View {
        content
            .navigationBarHidden(true)
            .task { await model.setupSubscriptions() }
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
                AnytypeText(Loc.save, style: .bodyRegular)
            }
        }
    }
    
    private var info: some View {
        VStack(spacing: 0) {
            SettingsObjectHeader(name: $model.spaceName, nameTitle: Loc.Settings.spaceName, iconImage: model.spaceIcon, onTap: {
                model.onChangeIconTap()
            })
            Spacer()
        }.padding(.horizontal, 16)
    }
}

