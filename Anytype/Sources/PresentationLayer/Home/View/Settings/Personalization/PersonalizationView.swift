import SwiftUI
import AnytypeCore

struct PersonalizationView: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    
    init(newSearchModuleAssembly: NewSearchModuleAssemblyProtocol) {
        self.newSearchModuleAssembly = newSearchModuleAssembly
    }

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            
            Spacer.fixedHeight(12)
            AnytypeText(Loc.personalization, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            
            defaultType
            Spacer.fixedHeight(20)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.personalizationSettingsShow)
        }
    }

    private var defaultType: some View {
        Button(action: { model.defaultType = true }) {
            HStack(spacing: 0) {
                AnytypeText(Loc.defaultObjectType, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                AnytypeText(ObjectTypeProvider.shared.defaultObjectType.name, style: .uxBodyRegular, color: .Text.secondary)
                Spacer.fixedWidth(10)
                Image(asset: .arrowForward).foregroundColor(.Text.tertiary)
            }
            .padding(.vertical, 14)
            .divider()
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $model.defaultType) {
            DefaultTypePicker(newSearchModuleAssembly: newSearchModuleAssembly)
                .environmentObject(model)
        }
    }
}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            PersonalizationView(newSearchModuleAssembly: DI.preview.modulesDI.newSearch())
        }
    }
}
