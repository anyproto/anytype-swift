import Foundation
import SwiftUI

struct SpaceShareParticipantViewModel: Identifiable {
    let id: String
    let icon: Icon?
    let name: String
    let status: Status?
    let action: Action?
    let contextActions: [ContextAction]
    
    enum Status {
        case normal(permission: String)
        case joining
        case declined
    }
    
    struct Action {
        let title: String
        let action: () -> Void
    }
    
    struct ContextAction: Identifiable {
        let id = UUID()
        let title: String
        let isSelected: Bool
        let destructive: Bool
        let action: () -> Void
    }
}

struct SpaceShareParticipantView: View {
    
    let participant: SpaceShareParticipantViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: participant.icon)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(participant.name, style: .uxTitle2Medium, color: .Text.primary)
                status
            }
            Spacer()
            if let action = participant.action {
                StandardButton(.text(action.title), style: .secondarySmall, action: action.action)
            }
            menu
        }
        .lineLimit(1)
        .padding(.vertical, 9)
        .frame(height: 72)
    }
    
    @ViewBuilder
    private var status: some View {
        switch participant.status {
        case .normal(let permission):
            AnytypeText(permission, style: .relation3Regular, color: .Text.secondary)
        case .joining:
            AnytypeText(Loc.SpaceShare.Status.joining, style: .relation3Regular, color: .Dark.pink)
                .padding(.horizontal, 3)
                .background(Color.Light.pink)
                .cornerRadius(3, style: .continuous)
        case .declined:
            AnytypeText(Loc.SpaceShare.Status.declined, style: .relation3Regular, color: .Text.secondary)
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var menu: some View {
        if participant.contextActions.isEmpty {
            EmptyView()
        } else {
            Menu {
                ForEach(participant.contextActions) { action in
                    Button(role: action.destructive ? .destructive : nil) {
                        action.action()
                    } label: {
                        HStack {
                            AnytypeText(action.title, style: .uxCalloutRegular, color: .Text.primary)
                            Spacer()
                            if action.isSelected {
                                Image(asset: .X24.tick)
                            }
                        }
                    }
                }
                
            } label: {
                IconView(icon: .asset(.X24.more))
                    .frame(width: 24, height: 24)
            }
        }
    }
}
