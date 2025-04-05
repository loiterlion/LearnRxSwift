//
//  ViewController.swift
//  RxSwift Example Chapter 3
//
//  Created by Bruce on 2025/4/2.
//

import UIKit
import RxSwift
import RxRelay

public func example(of description: String,
                    action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        example(of: "PublishSubject") {
            let subject = PublishSubject<String>()
            subject.on(.next("Is anyone listening"))
            
            let subscriptionOne = subject.subscribe(onNext: { string in
                print(string)
            })
            
            subject.on(.next("Hello 1"))
            subject.onNext("Hello 2")
            
            let subscriptionTwo = subject
                .subscribe { event in
                    print("2)", event.element ?? event)
                }
            subject.onNext("3")
            
            subscriptionOne.dispose()
            subject.onNext("4")
            
            // 1
            subject.onCompleted()
            // 2
            subject.onNext("5")
            // 3
            subscriptionTwo.dispose()
            let disposeBag = DisposeBag()
            // 4
            subject
                .subscribe {
                    print("3)", $0.element ?? $0)
                }
                .disposed(by: disposeBag)
            subject.onNext("?")
        }


        enum MyError: Error {
            case anError
        }
        
        func printmy<T: CustomStringConvertible>( label: String, event:
                                               Event<T>) {
                print(label, (event.element ?? event.error) ?? event)
        }
        
        example(of: "BehaviorSubject") {
            let subject = BehaviorSubject(value: "Initial value")
            let disposeBag = DisposeBag()
            
            subject.onNext("X")
            
            subject.subscribe {
                printmy(label: "1)", event: $0)
            }
            .disposed(by: disposeBag)
            
            subject.onError(MyError.anError)
            subject
                .subscribe {
                    printmy(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)
            
        }
        
        example(of: "RelaySubject") {
            let subject = ReplaySubject<String>.create(bufferSize: 2)
            let disposeBag = DisposeBag()
            
            subject.onNext("1")
            subject.onNext("2")
            subject.onNext("3")
            
            subject.subscribe {
                printmy(label: "1)", event: $0)
            }
            .disposed(by: disposeBag)
            
            subject.subscribe {
                printmy(label: "2)", event: $0)
            }
            .disposed(by: disposeBag)
            
            subject.onNext("4")

            subject.onError(MyError.anError)

            subject.subscribe {
                printmy(label: "3)", event: $0)
            }
            .disposed(by: disposeBag)
            
            // 1) 2
            // 1) 3
            // 2) 2
            // 2) 3
            // 1) 4
            // 2) 4
            // 1) anError
            // 2) anError
            // 3) 3
            // 3) 4
            // 3) anError
        }
        
        example(of: "PublishRelay") {
            let relay = PublishRelay<String>()
            
            let disposeBag = DisposeBag()
            
            relay.accept("Knock knock, anyone home?")
            
            relay
                .subscribe(onNext: {
                print($0)
                })
                .disposed(by: disposeBag)
            relay.accept("1")            
        }
        
        example(of: "BehaviorRelay") {
            let relay = BehaviorRelay(value: "Initial value")
            let disposeBag = DisposeBag()
            
            relay.accept("New initial value")
            
            relay
                .subscribe({
                    printmy(label: "1)", event: $0)
                })
                .disposed(by: disposeBag)
            
            relay.accept("1")
            
            relay
                .subscribe {
                    printmy(label: "2)", event: $0)
                }
                .disposed(by: disposeBag)
            
            relay.accept("2")
            
            // 1) New initial value
            // 1) 1
            // 2) 1
            // 1) 2
            // 2) 2
            
            print(relay.value)
        }
    }
}

