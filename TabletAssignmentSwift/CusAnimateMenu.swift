//
//  CusAnimateMenu.swift
//  TabletAssignmentSwift
//
//  Created by hongjian lin on 2/21/16.
//  Copyright © 2016 Tablet. All rights reserved.
//

import UIKit

let SCREEN_WIDTH_RATIO = UIScreen.mainScreen().bounds.size.width/320

@objc protocol CusAnimateMenuDelegate {
    func MenuDidClosed (menuShow: Bool)
    func SetsOfElementNeedForCusAnimateMenuDelegate () -> NSArray
    optional func MenuItemDidSelected ( indexPath: NSIndexPath )
}

class CusAnimateMenu: UIView, UITableViewDelegate, UITableViewDataSource {
    var menuItems:NSArray?
    var viewForMenu: UIView?
    var viewForTable:UITableView?
    weak var delegate: CusAnimateMenuDelegate?
    var scrollView: UIScrollView?
    var BlurView: UIView?
    var contentView: UIView?
    var showMenu = false
    var zoomIn = false
    
    deinit {
        delegate = nil
    }
    
    func buildMenu()
    {
        self.userInteractionEnabled = true
        self.menuItems = delegate?.SetsOfElementNeedForCusAnimateMenuDelegate();
        self.alpha = 0
        addBlurView()
        addScropeView()
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    func addBlurView()
    {
        self.BlurView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        self.BlurView!.backgroundColor = UIColor.blackColor()
        self.BlurView!.alpha = 0.6;
        self.addSubview(self.BlurView!)
    }
    
    func setupMenuView() {
        
        self.viewForMenu = UIView(frame: CGRectMake(300.0*SCREEN_WIDTH_RATIO,0,0,0))
        self.viewForMenu!.backgroundColor = UIColor.clearColor()
        self.viewForTable = UITableView(frame: CGRectMake(0, 0,320*SCREEN_WIDTH_RATIO,200*SCREEN_WIDTH_RATIO ), style: UITableViewStyle.Plain)
        self.viewForTable!.backgroundColor = UIColor.whiteColor()
        self.viewForTable!.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
        self.viewForTable!.alpha = 1.0
        self.viewForTable!.tableFooterView = UIView()
        self.viewForTable!.scrollEnabled = false
        self.viewForTable!.delegate = self
        self.viewForTable!.dataSource = self
        self.viewForTable!.layer.cornerRadius = 3
        self.viewForTable!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.viewForMenu!.clipsToBounds = true
        
        self.viewForMenu!.addSubview(self.viewForTable!)
        
    }
    
    func resetScorllView() {
        
        self.scrollView!.maximumZoomScale = 1.6
        self.scrollView!.minimumZoomScale = 0.4
        self.scrollView!.zoomScale = 1
        self.scrollView!.delegate = self
        self.scrollView!.showsHorizontalScrollIndicator = false
        self.scrollView!.showsVerticalScrollIndicator = false
        centerScrollViewContents()
    }

    
    // MARK: - Implementation UIScrollView
    func addScropeView() {
        
        if self.scrollView == nil
        {
            self.scrollView = UIScrollView(frame: CGRectMake(0, 55*SCREEN_WIDTH_RATIO, self.frame.size.width, self.frame.size.height))
            setupMenuView();
            
            
            self.contentView = UIView(frame: CGRectMake(0,0,320*SCREEN_WIDTH_RATIO,568*SCREEN_WIDTH_RATIO))
            self.contentView!.addSubview(self.viewForMenu!);
            
            resetScorllView();
            
            self.scrollView!.addSubview(self.contentView!)
            self.scrollView!.contentSize = self.contentView!.frame.size
            self.addSubview(self.scrollView!)
            
            let panRecognizer = UIPanGestureRecognizer(target: self, action: "scrollViewOneFingerDragged:")
            panRecognizer.minimumNumberOfTouches = 1
            panRecognizer.maximumNumberOfTouches = 1
            self.viewForMenu!.addGestureRecognizer(panRecognizer)
            
        }
        
        
    }
    
    func scrollViewOneFingerDragged(recognizer : UIPanGestureRecognizer)
    {
        
        let velocity = recognizer.velocityInView(self.contentView)
        
        if velocity.y > 0 && velocity.x < 0
        {
            let newZoomScale = ( 1 + velocity.y / 15000) * self.scrollView!.zoomScale
            zoomIn = true
            self.scrollView!.setZoomScale(newZoomScale, animated: true)
        }else if velocity.y < 0 && velocity.x > 0
        {
            let newZoomScale = ( 1 + velocity.y / 15000)*self.scrollView!.zoomScale
            zoomIn=false;
            if newZoomScale<=0.40 {
                showMenu=false;
                showMenu(showMenu)
            }else
            {
                self.scrollView!.setZoomScale(newZoomScale, animated: true)
            }
            
        }
        
        switch recognizer.state
        {
        case .Ended:
            self.scrollView!.setZoomScale(1, animated: true)
            break
            
        default:
            break
        }
        
    }
    
    func showMenu (yesNo : Bool)
    {
        showMenu = yesNo
        var regularFrame: CGRect?
        
        if showMenu
        {
            self.alpha = 1
            regularFrame = CGRectMake(0, 0,320*SCREEN_WIDTH_RATIO,200*SCREEN_WIDTH_RATIO )
        }else
        {
            regularFrame=CGRectMake(300.0*SCREEN_WIDTH_RATIO,0,0,0 )
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: .TransitionNone, animations: {
            self.viewForMenu!.frame = regularFrame!
            self.viewForTable!.frame = self.viewForMenu!.bounds;
            if self.showMenu {
                self.zoomIn=true;
                self.scrollView!.setZoomScale(1.03, animated: true)
            }
            }, completion: { finished in
                if self.showMenu==false {
                    UIView.animateWithDuration(0.4, delay: 0, options: .TransitionNone, animations: {
                        self.alpha = 0
                        }, completion: { finished in
                            self.delegate?.MenuDidClosed(self.showMenu)
                    })
                }else{
                    self.zoomIn=false
                    self.scrollView!.setZoomScale(1, animated: true)
                }
                
        })
    }

    
    func centerScrollViewContents()
    {
        let boundsSize = self.scrollView!.bounds.size
        let contentsFrame = self.contentView!.frame
        
        if contentsFrame.size.width > boundsSize.width && zoomIn == true
        {
            self.scrollView!.contentOffset = CGPointMake(contentsFrame.size.width-boundsSize.width, 0)
        }else if contentsFrame.size.width < boundsSize.width && zoomIn == false
        {
            self.scrollView!.contentOffset = CGPointMake(-abs(contentsFrame.size.width-boundsSize.width), 0)
        }else if contentsFrame.size.width < boundsSize.width && zoomIn == true
        {
            self.scrollView!.contentOffset = CGPointMake(-abs(boundsSize.width-contentsFrame.size.width), 0)
        }
        
        
    }
    
    override func hitTest(point: CGPoint, withEvent e: UIEvent?) -> UIView? {
        let result = super.hitTest(point, withEvent: e)
        if (result==self.contentView) {
            showMenu(false)
        }
        return result ;
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView)
    {
        centerScrollViewContents()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.menuItems?.count)!;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        
        let menuOptionText = self.menuItems?.objectAtIndex(indexPath.row) as! NSString
        cell.textLabel!.text = menuOptionText as String
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.textLabel!.textColor = UIColor.blackColor()
        cell.textLabel!.font = UIFont(name: "Futura", size: 15.0)
        cell.backgroundColor = UIColor.clearColor()
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated:false)
        self.delegate?.MenuItemDidSelected!(indexPath)
    }
    
    
}
