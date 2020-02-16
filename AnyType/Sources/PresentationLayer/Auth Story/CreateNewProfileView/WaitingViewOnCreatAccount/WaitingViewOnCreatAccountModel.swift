//
//  WaitingViewOnCreatAccountModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 10.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


class WaitingViewOnCreatAccountModel: ObservableObject {
    private let storeService: SecureStoreServiceProtocol = KeychainStoreService()
    private var authService = AuthService()
    private var diskStorage = DiskStorage()
    var userName: String
    var image: UIImage?
    
    @Published var error: String?
    
    init(userName: String, image: UIImage?) {
        self.userName = userName
        self.image = image
    }
    
    func createAccount() {
        var avatar = ProfileModel.Avatar.color(UIColor.randomColor().toHexString())
        
        DispatchQueue.global().async { [weak self] in
            guard let stronSelf = self else { return }
            
            if let image = stronSelf.image,
                let path = stronSelf.diskStorage.saveImage(imageName: "avatar_\(stronSelf.userName)_\(UUID())", image: image) {
                avatar = ProfileModel.Avatar.imagePath(path)
            }
            let request = AuthModels.CreateAccount.Request(name: stronSelf.userName, avatar: avatar)
            
            stronSelf.authService.createAccount(profile: request) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        stronSelf.error = error.localizedDescription
                    case .success:
                        applicationCoordinator?.startNewRootView(content: stronSelf.obtainCompletionView())
                    }
                }
            }
        }
    }
    
    func showCongratsView() -> some View {
        obtainCompletionView()
    }
    
    // TODO: Move to coordinator
    private func obtainCompletionView() -> some View {
        let completionView = CompletionAuthViewCoordinator()
        return completionView.start()
    }
}
