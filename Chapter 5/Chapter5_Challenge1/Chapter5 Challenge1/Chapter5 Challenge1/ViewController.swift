//
//  ViewController.swift
//  Chapter5 Challenge1
//
//  Created by Bruce on 2025/4/15.
//

import UIKit

public func example(of description: String,
                    action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

