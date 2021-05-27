//
//  TabBarViewController.swift
//  QRCard
//
//  Created by Дмитрий on 5/25/21.
//  Copyright © 2021 DK. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.barTintColor = UIColor.tabBarColor
    }
}

// MARK: -
// MARK: - Configure
private extension TabBarController {
    func configure() {
        configureTabBar()
    }
    
    func configureTabBar() {
        let cardVC = UIStoryboard(name: "Card", bundle: nil).instantiateInitialViewController() as! UINavigationController
        cardVC.navigationController?.title = "Визитка"
        let firstTabBarItem = UITabBarItem()
        firstTabBarItem.title = "Визитка"
        firstTabBarItem.image = UIImage(named: "card")?.withRenderingMode(.alwaysOriginal)
        firstTabBarItem.selectedImage = UIImage(named: "cardSelected")?.withRenderingMode(.alwaysOriginal)
        firstTabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tabBarSelectedColor], for:.selected)
        cardVC.tabBarItem = firstTabBarItem
        let websiteVC = UIStoryboard(name: "Website", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let secondTabBarItem = UITabBarItem()
        secondTabBarItem.title = "Вебсайт"
        secondTabBarItem.image = UIImage(named: "website")?.withRenderingMode(.alwaysOriginal)
        secondTabBarItem.selectedImage = UIImage(named: "websiteSelected")?.withRenderingMode(.alwaysOriginal)
        secondTabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.tabBarSelectedColor], for:.selected)
        websiteVC.tabBarItem = secondTabBarItem
        viewControllers = [cardVC, websiteVC]
    }
}
