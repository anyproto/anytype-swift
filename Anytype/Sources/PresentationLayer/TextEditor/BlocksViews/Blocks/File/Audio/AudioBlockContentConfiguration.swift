import Services
import UIKit
import AVFoundation


struct AudioBlockContentConfiguration: BlockConfiguration {
    typealias View = AudioBlockContentView

    let file: BlockFile
    let trackId: String
    let documentId: String
    weak var audioPlayerViewDelegate: (any AudioPlayerViewDelegate)?

    static func == (lhs: AudioBlockContentConfiguration, rhs: AudioBlockContentConfiguration) -> Bool {
        lhs.trackId == rhs.trackId &&
        lhs.audioPlayerViewDelegate === rhs.audioPlayerViewDelegate &&
        lhs.documentId == rhs.documentId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackId)
        hasher.combine(documentId)
    }
}

extension AudioBlockContentConfiguration {
    var contentInsets: UIEdgeInsets { .init(top: 10, left: 20, bottom: 10, right: 20) }
}
