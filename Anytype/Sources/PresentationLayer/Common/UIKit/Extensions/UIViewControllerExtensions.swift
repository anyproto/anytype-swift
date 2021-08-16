//
//  UIViewControllerExtensions.swift
//  UIViewControllerExtensions
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setupBackBarButtonItem(_ item: UIBarButtonItem) {
        navigationItem.hidesBackButton = true
        
        navigationItem.leftBarButtonItem = item
        
        // This trick enables screen edge pan gesture after setting left bar button.
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
}
