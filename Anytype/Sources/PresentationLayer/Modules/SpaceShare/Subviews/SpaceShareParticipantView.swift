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
        case active(permission: String)
        case pending(message: String)
    }
    
    struct Action {
        let title: String?
        let action: () async throws -> Void
    }
    
    struct ContextAction: Identifiable {
        let id = UUID()
        let title: String
        let isSelected: Bool
        let destructive: Bool
        let enabled: Bool
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
                AnytypeText(participant.name, style: .uxTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .truncationMode(.middle)
                status
            }
            Spacer()
            if let action = participant.action, let title = action.title {
                AsyncStandardButton(title, style: .secondarySmall, action: action.action)
            }
            menu
        }
        .fixTappableArea()
        .onTapGesture {
            if let action = participant.action {
                UISelectionFeedbackGenerator().selectionChanged()
                Task { try await action.action() }
            }
        }
        .lineLimit(1)
        .padding(.vertical, 9)
        .frame(height: 72)
        .newDivider()
    }
    
    @ViewBuilder
    private var status: some View {
        switch participant.status {
        case .active(let permission):
            AnytypeText(permission, style: .relation3Regular)
                .foregroundColor(.Text.secondary)
        case .pending(let message):
            AnytypeText(message, style: .relation3Regular)
                .foregroundColor(.Text.inversion)
                .padding(.horizontal, 3)
                .background(Color.Control.button)
                .cornerRadius(3, style: .continuous)
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
                            AnytypeText(action.title, style: .uxCalloutRegular)
                                .foregroundColor(.Text.primary)
                            Spacer()
                            if action.isSelected {
                                Image(asset: .X24.tick)
                            }
                        }
                    }
                    .disabled(!action.enabled)
                }
                
            } label: {
                IconView(icon: .asset(.X24.more))
                    .frame(width: 24, height: 24)
            }
        }
    }
}
