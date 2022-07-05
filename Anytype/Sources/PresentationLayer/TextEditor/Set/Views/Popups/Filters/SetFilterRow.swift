import SwiftUI
import BlocksModels

struct SetFilterRow: View {
    
    @Environment(\.editMode) var editMode
    
    let configuration: SetFilterRowConfiguration
    
    var body: some View {
        Button {
            configuration.onTap()
        } label: {
            content
        }
        .disabled(editMode?.wrappedValue != .inactive)
    }
    
    private var content: some View {
        HStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.backgroundSelected)
                Image.createImage(configuration.iconName)
            }
            .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(configuration.title, style: .uxTitle2Medium, color: .textPrimary)
                filterConditionView
            }
            
            Spacer()
            
            if editMode?.wrappedValue == .inactive {
                Image.arrow
            }
        }
        .frame(height: 68)
    }
    
    private var filterConditionView: some View {
        Group {
            if let subtitle = configuration.subtitle,
                subtitle.isNotEmpty
            {
                HStack(spacing: 8) {
                    AnytypeText(subtitle, style: .relation1Regular, color: .textSecondary)
                    RelationValueView(
                        relation: RelationItemModel(relation: configuration.relation),
                        style: .filter,
                        action: nil
                    )
                }
            }
        }
    }
}
