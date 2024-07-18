import Foundation
import Services

// Temporary model. Waiting middleware
struct MessageBlock {
    let text: String
    let id: String
    let author: Participant
    let createDate: Date
    let isYourMessage: Bool
}
