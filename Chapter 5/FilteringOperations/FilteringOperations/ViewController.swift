//
//  ViewController.swift
//  FilteringOperations
//
//  Created by Bruce on 2025/4/14.
//

import RxSwift
import UIKit

public func example(of description: String, action: () -> Void)
{
    print("\n--- Example of:", description, "---")
    action()
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test1()
    }
    
    func test1() {
        example(of: "ignoreElements") {
            let strikes = PublishSubject<String>()
            let disposeBag = DisposeBag()
            
            strikes
                .ignoreElements()
                .subscribe{ event in
                    print(event)
                    print("You're out!")
                }
                .disposed(by: disposeBag)
            
            strikes.onNext("hello")
            strikes.onCompleted()
        }
        
        example(of: "skip") {
          let disposeBag = DisposeBag()
          Observable.of("A", "B", "C", "D", "E", "F")
            .skip(3)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        }
        
        example(of: "skipWhile") {
          let disposeBag = DisposeBag()
        // 1
          Observable.of(2, 2, 3, 4, 3, 4, 4)
            // 2
            .skipWhile { $0.isMultiple(of: 2) }
            .subscribe(onNext: {
        print($0) })
            .disposed(by: disposeBag)
        }
        
        example(of: "skipUntil") {
          let disposeBag = DisposeBag()
        // 1
          let subject = PublishSubject<String>()
          let trigger = PublishSubject<String>()
        // 2
          subject
            .skipUntil(trigger)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
            
            subject.onNext("a")
            subject.onNext("b")
            
            trigger.onNext("X")
            
            subject.onNext("c")
            subject.onNext("d")
        }
        
        // take 和 skip 刚好相反
        example(of: "take") {
            let disposeBag = DisposeBag()
            
            Observable.of(1, 2, 3, 4, 5, 6)
                .take(3)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(of: "takeWhile") {
            let disposeBag = DisposeBag()
            
            Observable.of(2, 2, 4, 4, 6, 6)
                .enumerated()
                .takeWhile { (index, i) in
                    i.isMultiple(of: 2) && index < 3
                }
                .map(\.element)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(of: "takeUntil") {
            let disposeBag = DisposeBag()
            
            Observable.of(1, 2, 3, 4, 5)
                .takeUntil(.inclusive) { $0.isMultiple(of: 4) }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(of: "takeUntil trigger") {
            let disposeBag = DisposeBag()
            
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            
            subject
                .takeUntil(trigger)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            subject.onNext("1")
            subject.onNext("2")
            trigger.onNext("x")
            subject.onNext("3")
        }
        
        example(of: "distinctUntilChanged") {
            let disposeBag = DisposeBag()
            
            Observable.of("A", "A", "B", "B", "A")
                .distinctUntilChanged()
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(of: "distinctUntilChanged(_:)") {
            let disposeBag = DisposeBag()
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            
            Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
                .distinctUntilChanged { a, b in
                    guard let aWords = formatter.string(from: a)?
                            .components(separatedBy: " "),
                          let bWords = formatter.string(from: b)?
                            .components(separatedBy: " ")
                    else {
                        return false
                    }
                    
                    var containsMatch = false
                    for aword in aWords where bWords.contains(aword) {
                        containsMatch = true
                        break
                    }
                    
                    return containsMatch
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
    }
}

