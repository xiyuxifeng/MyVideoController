//
//  ThirdViewController.swift
//  MyVideoController
//
//  Created by WangHui on 16/6/12.
//  Copyright © 2016年 WangHui. All rights reserved.
//

import UIKit

class ThirdViewController: MyVideoViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        releasePlayer()

        dismissViewControllerAnimated(true) {
            
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MasterViewController")
        go_vc(vc)
    }

    func go_vc(vc:UIViewController) {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            let window = UIApplication.sharedApplication().keyWindow
            window?.rootViewController = vc
            window?.makeKeyWindow()
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
