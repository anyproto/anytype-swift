import SwiftUI
import Services


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
    }
    
    private var emptyView: some View {
        Spacer.fixedHeight(300)
            .background(Color.Background.secondary)
    }
    
    private func content(_ details: ObjectDetails) -> some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(35)
            
            if details.description.isNotEmpty {
                viewWithDescription(details)
            } else {
                viewWithoutDescription(details)
            }
            
            Spacer.fixedHeight(35)
            StandardButton(Loc.editProfile, style: .secondaryLarge) { }
            Spacer.fixedHeight(24)
        }
        .padding(.horizontal, 32)
        .background(Color.Background.secondary)
    }
    
    private func viewWithDescription(_ details: ObjectDetails) -> some View {
        Group {
            IconView(icon: details.objectIconImage).frame(width: 112, height: 112)
            AnytypeText(details.name, style: .heading)
            AnytypeText(details.identity, style: .caption1Regular).foregroundColor(.Text.secondary).lineLimit(1)
            AnytypeText(details.description, style: .previewTitle2Regular)
        }
    }
    
    private func viewWithoutDescription(_ details: ObjectDetails) -> some View {
        Group {
            IconView(icon: details.objectIconImage).frame(width: 184, height: 184)
            AnytypeText(details.name, style: .heading)
            AnytypeText(details.identity, style: .caption1Regular).foregroundColor(.Text.secondary).lineLimit(1)
        }
    }
}

#Preview {
    ProfileView(info: ObjectInfo(objectId: "", spaceId: ""))
}
