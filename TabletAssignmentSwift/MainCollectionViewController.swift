//
//  MainCollectionViewController.swift
//  TabletAssignmentSwift
//
//  Created by Yee Peng Chia on 2/19/16.
//  Copyright © 2016 Tablet. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainCollectionViewController: UICollectionViewController, CusAnimateMenuDelegate {
    var showMenu = false
    let reuseIdentifier = "Cell"
    var menu: CusAnimateMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dotsImage = UIImage(named: "dots")
        let barButtonItem = UIBarButtonItem(image: dotsImage, style: UIBarButtonItemStyle.Plain, target: self, action: "barButtonTapped:")
        navigationItem.rightBarButtonItem = barButtonItem
        
        BuildMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CusAnimateMenuDelegate
    func MenuDidClosed (menuShow: Bool)
    {
        showMenu = menuShow
    }
    func SetsOfElementNeedForCusAnimateMenuDelegate () -> NSArray
    {
        return ["Menu Item 1", "Menu Item 2", "Menu Item 3", "Menu Item 4"]
    }
    func MenuItemDidSelected ( indexPath: NSIndexPath )
    {
        NSLog("Selected")
    }
    
    // MARK: - Implementation
    
    func BuildMenu()
    {
        self.menu = CusAnimateMenu(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.menu!.delegate = self
        self.menu!.buildMenu()
        self.view.addSubview(self.menu!)
    }
    
    func barButtonTapped(sender: AnyObject) {
        showMenu = !showMenu
        self.menu?.showMenu(showMenu)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        if let c = cell as? MyCollectionViewCell {
            let imageName = "photo_\(indexPath.row)"
            let image = UIImage(named: imageName)
            c.imageView.image = image
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let bounds = UIScreen.mainScreen().bounds
        return CGSize(width: bounds.size.width, height: bounds.size.width)
    }

}
