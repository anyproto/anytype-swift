//
//  EditorNavigationBarHelperProtocol.swift
//  EditorNavigationBarHelperProtocol
//
//  Created by Konstantin Mordan on 19.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import BlocksModels

protocol EditorNavigationBarHelperProtocol {
    
    func addFakeNavigationBarBackgroundView(to view: UIView)
    
    func handleViewWillAppear(_ vc: UIViewController?, _ scrollView: UIScrollView)
    func handleViewWillDisappear()
    
    func configureNavigationBar(using header: ObjectHeader, details: ObjectDetails?)
    
}
