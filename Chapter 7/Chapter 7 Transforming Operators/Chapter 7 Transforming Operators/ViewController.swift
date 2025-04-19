//
//  ViewController.swift
//  Chapter 7 Transforming Operators
//
//  Created by Bruce on 2025/4/18.
//

import UIKit
import RxSwift

public func example(of description: String, action: () -> Void)
{
    print("\n--- Example of:", description, "---")
    action()
}

struct Student {
    let score: BehaviorSubject<Int>
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        test()
    }

    func test() {
        example(of: "toArray") {
            let bag = DisposeBag()
            let observable = Observable.of(1, 2, 3)
            observable
                .toArray()
                .subscribe{
                    print($0)
                }
                .disposed(by: bag)
        }
        
        example(of: "map") {
            let bag = DisposeBag()
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            
            Observable<Int>.of(123, 4, 567)
                .map {
                    formatter.string(for: $0) ?? ""
                }
                .subscribe(onNext: {
                    print($0)
                }, onError: {
                    print($0)
                })
                .disposed(by: bag)
        }
        
        example(of: "Enumerated and map") {
            let bag = DisposeBag()
            
            Observable<Int>.of(1, 2, 3, 4, 5, 6)
                .enumerated()
                .map { (index, num) in
                    index > 2 ? num * 2 : num
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: bag)
        }
        
        example(of: "compactMap") {
          let disposeBag = DisposeBag()
        // 1
          Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
            // 2
            .compactMap { $0 }
            // 3
            .toArray()
            // 4
            .map { $0.joined(separator: " ") }
            // 5
            .subscribe(onSuccess: {
        print($0) })
            .disposed(by: disposeBag)
        }
        
        example(of: "flatMap") {
            let bag = DisposeBag()
            
            let laura = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 90))
            
            let student = PublishSubject<Student>()
            
            student
                .flatMap{ $0.score }
                .subscribe(onNext: { print($0)})
                .disposed(by: bag)
            
            student.onNext(laura)
            laura.score.onNext(85)
            student.onNext(charlotte)
            laura.score.onNext(95)
            charlotte.score.onNext(100)
        }
        
        example(of: "flatMapLatest") {
            let bag = DisposeBag()
            
            let laura = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 90))
            
            let student = PublishSubject<Student>()
            
            student
                .flatMapLatest { $0.score
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: bag)
            
            student.onNext(laura)
            laura.score.onNext(85)
            student.onNext(charlotte)
            laura.score.onNext(95) // 对比flatmap，flatMapLatest只订阅最新的一特
            charlotte.score.onNext(100)
        }
        
        example(of: "materlize and dematerialize") {
            enum MyError: Error {
                case anError
            }
            
            let disposeBag = DisposeBag()
            
            let laura = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 100))
            
            let student = BehaviorSubject(value: laura)
            
            let studentScore = student
                .flatMapLatest {
//                    $0.score
                    $0.score.materialize()
                }
            
            studentScore
                .filter {
                    guard $0.error == nil else {
                        print($0.error!)
                        return false
                    }
                    return true
                }
                .dematerialize()
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            laura.score.onNext(85)
            laura.score.onError(MyError.anError)
            laura.score.onNext(90)
            student.onNext(charlotte)
        }
    }
}

