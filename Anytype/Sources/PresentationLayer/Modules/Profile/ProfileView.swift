import SwiftUI
import Services
import AnytypeCore


struct ProfileView: View {
    @StateObject private var model: ProfileViewModel
    
    init(info: ObjectInfo) {
        _model = StateObject(wrappedValue: ProfileViewModel(info: info))
    }
    
    var body: some View {
        Group {
            if let details = model.details {
                content(details)
            } else {
                emptyView
            }
        }
        
        .task { await model.setupSubscriptions() }
        .sheet(isPresented: $model.showSettings) {
            if FeatureFlags.newSettings {
                NewSettingsCoordinatorView()  // TODO: Open profile settings
            } else {
                SettingsCoordinatorView()
            }
        }
    }
    
    private var emptyView: some View {
        Spacer.fixedHeight(300)
            .background(Color.Background.secondary)
    }
    
    private func content(_ details: ObjectDetails) -> some View {
        VStack(spacing: 0) {
            DragIndicator()
            actionRow
            
            if details.description.isNotEmpty {
                viewWithDescription(details)
            } else {
                viewWithoutDescription(details)
            }
            
        }
        .padding(.horizontal, 16)
        .background(Color.Background.secondary)
    }
    
    private var actionRow: some View {
        Group {
            if model.isOwner {
                HStack(spacing: 12) {
                    Spacer()
                    Button {
                        model.showSettings.toggle()
                    } label: {
                        IconView(asset: .X32.edit).frame(width: 32, height: 32)
                    }
                }
            } else {
                Spacer.fixedHeight(32)
            }
        }
    }
    
    private func viewWithDescription(_ details: ObjectDetails) -> some View {
        Group {
            Spacer.fixedHeight(30)
            IconView(icon: details.objectIconImage).frame(width: 112, height: 112)
            Spacer.fixedHeight(12)
            AnytypeText(details.name, style: .heading).lineLimit(1)
            Spacer.fixedHeight(4)
            AnytypeText(details.identity, style: .caption1Regular).foregroundColor(.Text.secondary).lineLimit(1)
            Spacer.fixedHeight(4)
            AnytypeText(details.description, style: .previewTitle2Regular)
            Spacer.fixedHeight(78)
        }
    }
    
    private func viewWithoutDescription(_ details: ObjectDetails) -> some View {
        Group {
            Spacer.fixedHeight(30)
            IconView(icon: details.objectIconImage).frame(width: 184, height: 184)
            Spacer.fixedHeight(12)
            AnytypeText(details.name, style: .heading).lineLimit(1)
            Spacer.fixedHeight(4)
            AnytypeText(details.identity, style: .caption1Regular).foregroundColor(.Text.secondary).lineLimit(1)
            Spacer.fixedHeight(84)
        }
    }
}

#Preview {
    ProfileView(info: ObjectInfo(objectId: "", spaceId: ""))
}
