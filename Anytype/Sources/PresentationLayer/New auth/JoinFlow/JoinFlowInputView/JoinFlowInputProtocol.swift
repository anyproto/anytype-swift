import SwiftUI

@MainActor
protocol JoinFlowInputProtocol: ObservableObject {
    var title: String { get }
    var description: String { get }
    var placeholder: String { get }
    var inProgress: Bool { get }
    var inputText: String { get set }
    
    func onNextAction()
    func onAppear()
}
