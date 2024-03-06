import SwiftUI
import Services


@MainActor
protocol EmailVerificationAssemblyProtocol {
    func make(data: EmailVerificationData, onSuccessfulValidation: @escaping () -> ()) -> AnyView
}

final class EmailVerificationAssembly: EmailVerificationAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(data: EmailVerificationData, onSuccessfulValidation: @escaping () -> ()) -> AnyView {
        EmailVerificationView(
            model: EmailVerificationViewModel(
                data: data,
                membershipService: self.serviceLocator.membershipService(),
                onSuccessfulValidation: onSuccessfulValidation
            )
        ).eraseToAnyView()
    }
}
