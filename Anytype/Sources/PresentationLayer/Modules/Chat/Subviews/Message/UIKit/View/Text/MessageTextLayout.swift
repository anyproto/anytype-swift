import Foundation

struct MessageTextLayout: Equatable, Hashable {
    let size: CGSize
    let textFrame: CGRect
    let infoFrame: CGRect
    let syncIconFrame: CGRect?
}
