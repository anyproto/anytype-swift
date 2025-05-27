import SwiftUI
import AnytypeCore

struct SetPropertiesView: View {
    @StateObject private var model: SetPropertiesViewModel
    @State private var editMode = EditMode.inactive
    
    init(setDocument: some SetDocumentProtocol, viewId: String, output: (any SetPropertiesCoordinatorOutput)?) {
        _model = StateObject(wrappedValue: SetPropertiesViewModel(setDocument: setDocument, viewId: viewId, output: output))
    }
    
    var body: some View {
        DragIndicator()
        NavigationView {
            content
        }
        .background(Color.Background.secondary)
        .navigationViewStyle(.stack)
    }
    
    private var content: some View {
        PlainList {
            propertiesSection
                .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
        .environment(\.editMode, $editMode)
        
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
        
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color.Control.active)
                    .environment(\.editMode, $editMode)
            }
            ToolbarItem(placement: .principal) {
                AnytypeText(Loc.fields, style: .uxTitle1Semibold)
                    .foregroundColor(.Text.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation { editMode = .inactive }
                    model.showAddRelationInfoView()
                }) {
                    Image(asset: .X32.plus).foregroundColor(.Control.active)
                }
            }
        }
    }
    
    private var propertiesSection: some View {
        ForEach(model.relations) { property in
            propertyRow(property)
                .divider()
                .deleteDisabled(!property.canBeRemoved)
        }
        .onDelete { indexes in
            model.deleteProperties(indexes: indexes)
        }
        .onMove { from, to in
            model.moveProperty(from: from, to: to)
        }
    }
    
    private func propertyRow(_ property: SetViewSettingsProperty) -> some View {
        HStack(spacing: 0) {
            Image(asset: property.image)
                .foregroundColor(.Control.active)
            Spacer.fixedWidth(10)
            AnytypeToggle(
                title: property.title,
                isOn: property.isOn
            ) {
                property.onChange($0)
            }
        }
        .frame(height: 52)
    }
}
