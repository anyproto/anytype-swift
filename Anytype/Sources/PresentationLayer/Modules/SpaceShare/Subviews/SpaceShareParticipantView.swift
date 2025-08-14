import Foundation
import SwiftUI

struct SpaceShareParticipantViewModel: Identifiable {
    let id: String
    let icon: Icon?
    let name: String
    let globalName: String
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
        let action: () async throws -> Void
    }
}

struct SpaceShareParticipantView: View {
    
    let participant: SpaceShareParticipantViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: participant.icon)
                .frame(width: 48, height: 48)
                .overlay(alignment: .topTrailing) {
                    if case .pending = participant.status  {
                        attentionDotView
                            .padding(.trailing, 2)
                            .padding(.top, 2)
                    }
                }
            
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(participant.name, style: .uxTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .truncationMode(.middle)
                AnytypeText(participant.globalName, style: .caption1Regular)
                    .foregroundColor(.Text.secondary)
                    .truncationMode(.tail)
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
            HStack(spacing: 4) {
                AnytypeText(permission, style: .uxTitle2Regular)
                    .foregroundColor(.Text.primary)
                if participant.contextActions.isNotEmpty {
                    Image(asset: .X18.Disclosure.down)
                }
            }
        case .pending(let message):
            HStack(spacing: 4) {
                AnytypeText(message, style: .uxTitle2Regular)
                    .foregroundColor(.Text.secondary)
                if participant.contextActions.isNotEmpty {
                    Image(asset: .X18.Disclosure.down)
                }
            }
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var menu: some View {
        if participant.contextActions.isEmpty {
            status
        } else if participant.contextActions.count == 1, let action = participant.contextActions.first  {
            AsyncButton {
                try await action.action()
            } label: {
                status.padding()
            }
        } else {
            Menu {
                ForEach(participant.contextActions) { action in
                    AsyncButton(role: action.destructive ? .destructive : nil) {
                        try await action.action()
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
                status.padding()
            }
        }
    }
    
    private var attentionDotView: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color.Control.accent100)
                .frame(width: 8, height: 8)

            Circle()
                .strokeBorder(Color.Background.primary, lineWidth: 2)
                .frame(width: 10, height: 10)
        }
    }
}
