import SwiftUI
import Services

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
                    .foregroundColor(Color.Background.highlightedOfSelected)
                Image(asset: configuration.iconAsset)
                    .foregroundColor(.Button.active)
            }
            .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(configuration.title, style: .uxTitle2Medium, color: .Text.primary)
                filterConditionView
            }
            
            Spacer()
            
            if editMode?.wrappedValue == .inactive {
                Image(asset: .arrowForward)
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
                    AnytypeText(subtitle, style: .relation1Regular, color: .Text.secondary)
                        .layoutPriority(1)
                    switch configuration.type {
                    case let .relation(relation):
                        relationValueView(for: relation)
                    case let .date(date):
                        AnytypeText(date, style: .relation1Regular, color: .Text.secondary)
                    }
                }
            }
        }
    }
    
    private func relationValueView(for relation: Relation?) -> some View {
        Group {
            if let relation = relation {
                RelationValueView(
                    relation: RelationItemModel(relation: relation),
                    style: .filter(hasValues: configuration.hasValues),
                    mode: .button(action: nil)
                )
            } else {
                EmptyView()
            }
        }
    }
}
