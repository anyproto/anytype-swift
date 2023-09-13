import SwiftUI
import AnytypeCore

struct PersonalizationView: View {
    @ObservedObject var model: PersonalizationViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            AnytypeText(Loc.personalization, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            
            defaultType
            Spacer.fixedHeight(20)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsPersonal()
        }
    }

    private var defaultType: some View {
        AnytypeRow(
            action: model.onObjectTypeTap,
            title: Loc.defaultObjectType,
            description: model.objectType
        )
    }
}

struct AnytypeRow: View {
    let action: () -> Void
    let title: String
    let description: String
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                AnytypeText(title, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                AnytypeText(description, style: .uxBodyRegular, color: .Text.secondary)
                    .lineLimit(1)
                Spacer.fixedWidth(10)
                Image(asset: .arrowForward).foregroundColor(.Text.tertiary)
            }
            .padding(.vertical, 14)
            .divider()
            .padding(.horizontal, 20)
        }
    }
}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            PersonalizationView(model: PersonalizationViewModel(
                objectTypeProvider: DI.preview.serviceLocator.objectTypeProvider(),
                output: nil
            ))
        }
    }
}
