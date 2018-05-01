//
//  MyTabBarController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/3/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FasTalk"
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.barTintColor = UIColor.white
        colorChange(Config.colorScheme())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func AddClickedAction(_ sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "popoverViewController")
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.preferredContentSize = CGSize(width: 150, height: 240)
        let popover = vc.popoverPresentationController!
        popover.barButtonItem = sender
        popover.delegate = self
        present(vc, animated: true, completion:nil)
    }
    
    func colorChange( _ colorIdx:Int){
        self.navigationController?.navigationBar.barTintColor = UIColor(named: navColor[colorIdx])
        self.tabBar.tintColor = UIColor(named: tabTintColor[colorIdx])
    }
    
}

extension MyTabBarController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

