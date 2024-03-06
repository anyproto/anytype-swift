import SwiftUI


@MainActor
protocol EmailVerificationAssemblyProtocol {
    func make(onSuccessfulValidation: @escaping () -> ()) -> AnyView
}

final class EmailVerificationAssembly: EmailVerificationAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(onSuccessfulValidation: @escaping () -> ()) -> AnyView {
        EmailVerificationView(
            model: EmailVerificationViewModel(
                membershipService: self.serviceLocator.membershipService(),
                onSuccessfulValidation: onSuccessfulValidation
            )
        ).eraseToAnyView()
    }
}
