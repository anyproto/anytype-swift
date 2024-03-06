import SwiftUI


@MainActor
protocol EmailVerificationAssemblyProtocol {
    func make() -> AnyView
}

final class EmailVerificationAssembly: EmailVerificationAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make() -> AnyView {
        EmailVerificationView(
            model: EmailVerificationViewModel(
                membershipService: self.serviceLocator.membershipService()
            )
        ).eraseToAnyView()
    }
}
