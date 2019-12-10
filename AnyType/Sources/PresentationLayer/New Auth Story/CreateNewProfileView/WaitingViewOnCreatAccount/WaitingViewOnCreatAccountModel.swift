//
//  WaitingViewOnCreatAccountModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 10.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


class WaitingViewOnCreatAccountModel: ObservableObject {
    private var authService = AnytypeAuthService()
    private var diskStorage = DiskStorage()
    var userName: String
    var image: UIImage?
    
    @Published var error: String?
    
    init(userName: String, image: UIImage?) {
        self.userName = userName
        self.image = image
    }
    
    func createAccount() {
        var avatar = ProfileModels.Avatar.color(UIColor.randomColor().toHexString())
        
        DispatchQueue.global().async { [weak self] in
            guard let stronSelf = self else { return }
            
            if let image = stronSelf.image,
                let path = stronSelf.diskStorage.saveImage(imageName: "avatar_\(stronSelf.userName)_\(UUID())", image: image) {
                avatar = ProfileModels.Avatar.imagePath(path)
            }
            let request = AuthModels.CreateAccount.Request(name: stronSelf.userName, avatar: avatar)
            
            stronSelf.authService.createAccount(profile: request) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        stronSelf.error = error.localizedDescription
                    case .success(let id):
                        applicationCoordinator?.startNewRootView(content: CompletionAuthView())
                    }
                }
            }
        }
    }
    
    func showCongratsView() -> some View {
        CompletionAuthView()
    }
}
