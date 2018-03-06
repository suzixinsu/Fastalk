//
//  MyTabBarController.swift
//  Fastalk
//
//  Created by Dan Xu on 3/3/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    var freshLaunch: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if freshLaunch == true {
            freshLaunch = false
            self.selectedIndex = 2 // settings tab
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
