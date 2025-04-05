//
//  ViewController.swift
//  Challenge2 User Session Behavior Relay
//
//  Created by Bruce on 2025/4/5.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        example(of: "BehaviorRelay") {
            enum UserSession {
                case loggedIn, loggedOut
            }
            
            enum LoginError: Error {
                case invalidCredentials
            }
            
            let disposeBag = DisposeBag()
            
            // Create userSession BehaviorRelay of type UserSession with initial value of .loggedOut
            let userSessionRelay = BehaviorRelay<UserSession>(value: .loggedOut)
            
            // Subscribe to receive next events from userSession
            userSessionRelay.subscribe { event in
                print("event is :", event)
            }
            .disposed(by: disposeBag)
            
            func logInWith(username: String, password: String, completion: (Error?) -> Void) {
                guard username == "johnny@appleseed.com",
                      password == "appleseed" else {
                          completion(LoginError.invalidCredentials)
                          return
                      }
                
                // Update userSession
                userSessionRelay.accept(.loggedIn)
            }
            
            func logOut() {
                // Update userSession
                userSessionRelay.accept(.loggedOut)
            }
            
            func performActionRequiringLoggedInUser(_ action: () -> Void) {
                // Ensure that userSession is loggedIn and then execute action()
                guard userSessionRelay.value == .loggedIn else { return }
                action()
            }
            
            for i in 1...2 {
                let password = i % 2 == 0 ? "appleseed" : "password"
                
                logInWith(username: "johnny@appleseed.com", password: password) { error in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    
                    print("User logged in.")
                }
                
                performActionRequiringLoggedInUser {
                    print("Successfully did something only a logged in user can do.")
                }
            }
        }
    }
}



