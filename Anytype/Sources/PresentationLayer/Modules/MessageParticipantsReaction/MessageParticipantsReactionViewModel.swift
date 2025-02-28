import Foundation
import Services

struct MessageParticipantsReactionData: Identifiable, Hashable {
    let spaceId: String
    let emoji: String
    let participantsIds: [String]
    
    var id: Int { hashValue }
}

enum MessageParticipantsReactionState {
    case data([ObjectCellData])
    case empty
}

@MainActor
final class MessageParticipantsReactionViewModel: ObservableObject {
    
    @Published var state: MessageParticipantsReactionState? = nil
    @Published var title: String?
    
    private let data: MessageParticipantsReactionData
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    private lazy var participantSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(data.spaceId)
    
    init(data: MessageParticipantsReactionData) {
        self.data = data
    }
    
    func subscribeOnParticipants() async {
        for await participants in participantSubscription.participantsPublisher.values {
            updateList(with: participants)
        }
    }
    
    private func updateList(with participants: [Participant]) {
        let reactedParticipants = data.participantsIds.compactMap { participantId in
            participants.first { $0.identity == participantId }
        }

        let participantsData = reactedParticipants.map { participant in
            let type = try? objectTypeProvider.objectType(id: participant.type).name
            return ObjectCellData(
                id: participant.id,
                icon: .object(participant.icon),
                title: participant.localName.withPlaceholder,
                type: type ?? "",
                canArchive: false,
                onTap: {}
            )
        }
        
        title = data.emoji + " \(participantsData.count)"
        state = participantsData.isEmpty ? .empty : .data(participantsData)
    }
}
