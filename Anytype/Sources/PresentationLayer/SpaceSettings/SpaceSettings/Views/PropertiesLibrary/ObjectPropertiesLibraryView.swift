import SwiftUI
import Services
import Loc

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
                if !model.userProperties.isEmpty {
                    Section {
                        ForEach(model.userProperties) { row in
                            Button {
                                model.onRowTap(row)
                            } label: {
                                rowView(data: row)
                            }
                        }
                    } header: {
                        SectionHeaderView(title: Loc.myProperties)
                            .padding(.horizontal, 16)
                    }
                }
                
                if !model.systemProperties.isEmpty {
                    Section {
                        ForEach(model.systemProperties) { row in
                            Button {
                                model.onRowTap(row)
                            } label: {
                                rowView(data: row)
                            }
                        }
                    } header: {
                        SectionHeaderView(title: Loc.systemProperties)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
    
    private func rowView(data: PropertyDetails) -> some View {
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
