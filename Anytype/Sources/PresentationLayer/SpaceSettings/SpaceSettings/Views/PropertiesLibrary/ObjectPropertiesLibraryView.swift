import SwiftUI
import Services

struct ObjectPropertiesLibraryView: View {
    
    @StateObject private var model: ObjectPropertiesLibraryViewModel
    
    init(spaceId: String) {
        _model = StateObject(wrappedValue: ObjectPropertiesLibraryViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        content
            .homeBottomPanelHidden(true)
            .task { await model.startSubscriptions() }
        
            .sheet(item: $model.propertyInfo) {
                PropertyInfoCoordinatorView(data: $0, output: model)
                    .mediumPresentationDetents()
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            navBar
            propertiesList
        }
    }
    
    private var navBar: some View {
        PageNavigationHeader(title: Loc.properties) {
            Button {
                model.onNewPropertyTap()
            } label: {
                Image(asset: .X32.plus)
                    .frame(width: 32, height: 32)
            }
        }
    }
    
    private var propertiesList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.rows) { row in
                    Button {
                        model.onRowTap(row)
                    } label: {
                        rowView(data: row)
                    }
                }
            }
        }
    }
    
    private func rowView(data: RelationDetails) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if let iconImage = data.iconImage {
                    IconView(icon: iconImage)
                        .frame(width: 24, height: 24)
                        .allowsHitTesting(false)
                    Spacer.fixedWidth(10)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                AnytypeText(data.title, style: data.isMinimal ? .uxBodyRegular : .previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                    .frame(height: 20)
                    
                Spacer()
            }
            
            Spacer()
            Image(asset: .RightAttribute.disclosure)
        }
        .frame(height: data.isMinimal ? 52 : 68)
        .newDivider()
        .padding(.horizontal, 16)
    }
}
