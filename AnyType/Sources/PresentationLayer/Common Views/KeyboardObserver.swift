//
//  KeyboardObserver.swift
//  AnyType
//
//  Created by Denis Batvinkin on 09.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine


struct KeyboardInfo {
    var keyboardRect: CGRect = .zero
    var duration: TimeInterval = 0
    
    public static var zero = KeyboardInfo()
}


final class KeyboardObserver: ObservableObject {
    @Published public var kInfo = KeyboardInfo()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        addObserver()
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration =  notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            kInfo = KeyboardInfo(keyboardRect: rect, duration: duration)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let duration =  notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            kInfo = .zero
            return
        }
        kInfo = KeyboardInfo(keyboardRect: .zero, duration: duration)
    }
}
