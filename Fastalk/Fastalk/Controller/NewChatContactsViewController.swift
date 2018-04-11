//
//  NewChatContactsViewController.swift
//  Fastalk
//
//  Created by Xin Su on 4/11/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit

class NewChatContactsViewController: UIViewController, UIBarPositioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBack(_ sender: Any) {
        var parentVC = self.presentingViewController
        parentVC = parentVC?.presentingViewController
        parentVC?.dismiss(animated: true, completion: nil)
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
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
