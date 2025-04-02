//
//  ViewController.swift
//  RxExample
//
//  Created by Bruce on 2025/4/1.
//

import UIKit
import RxSwift

public func example(of description: String, action: () -> Void)
{
    print("\n--- Example of:", description, "---")
    action()
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        example2()
    }
    
    func example1() {
        example(of: "just, of, from") {
            // 1
            let one = 1
            let two = 2
            let three = 3
            // 2
            let observable = Observable<Int>.just(one)
            let observable2 = Observable.of(one, two, three)
            let observable3 = Observable.of([one, two, three])
            let observable4 = Observable.from([one, two, three])
        }
        
        let sequence = 1...3
        var iterator = sequence.makeIterator()
        while let n = iterator.next() {
            print("\(n)")
        }
    }
    
    
    func example2() {
        example(of: "subscribe") {
            let one = 1
            let two = 2
            let three = 3
            let observable = Observable.of(one, two, three)
//            observable.subscribe { event in
//                if let element = event.element {
//                    print(element)
//                }
//            }
            
            observable.subscribe(onNext: {element in
                print(element)
            })
        }
        
        print("=============")
        
        example(of: "empty") {
            let observable = Observable<Void>.empty()
            observable.subscribe(
                // 1
                onNext: { element in
                    print(element)
                },
                // 2
                onCompleted: {
                    print("Completed")
                }
            )
        }
        
        example(of: "never") {
            let disposeBag = DisposeBag()
            let observable = Observable<Void>.never()
            observable.subscribe(
                onNext: { element in
                    print(element)
                },
                onCompleted: {
                    print("Completed")
                },
                onDisposed: {print("never disposed!")}
                
            ).disposed(by: disposeBag)
        }
        
        example(of: "dispose") {
            // 1
            let observable = Observable.of("A", "B", "C")
            // 2
            let subscription = observable.subscribe { event in
                // 3
                print(event)
            }
            
            subscription.dispose()
        }
        
        example(of: "DisposeBag") {
            // 1
            let disposeBag = DisposeBag()
            // 2
            Observable.of("A", "B", "C")
                .subscribe { // 3
                    print($0) }
                .disposed(by: disposeBag) // 4
        }
        
        example(of: "create") {
            enum MyError: Error {
                case anError
            }
            
            let disposeBag = DisposeBag()
            Observable<String>.create { observer in
                // 1
                observer.onNext("1")
//                observer.onError(MyError.anError)
                // 2
                observer.onCompleted()
                // 3
                observer.onNext("?")
                // 4
                return Disposables.create()
            }
            .subscribe(
                onNext: { print($0) },
                onError: { print($0) },
                onCompleted: { print("Completed") },
                onDisposed: { print("Disposed") }
            )
            .disposed(by: disposeBag)
        }
        
        example(of: "Deferred") {
            let disposeBag = DisposeBag()
            
            var flag = false
            let factory = Observable<Int>.deferred {
                
                flag.toggle()
                if flag {
                    return Observable.of(1, 2, 3)
                } else {
                    return Observable.of(4, 5, 6)
                }
            }
            
            factory.subscribe(onNext: {n in print(n)}).disposed(by: disposeBag)

            factory.subscribe(onNext: {n in print(n)}).disposed(by: disposeBag)

        }
        
        example(of: "Single") {
            enum FileReadError: Error {
                case fileNotFound, unreadable, encodingFailed
            }
            
            let disposeBag = DisposeBag()
            
            func loadText(name: String) -> Single<String> {
                return Single.create { single in
                    let disposable = Disposables.create()
                    
                    guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                        single(.error(FileReadError.fileNotFound))
                        return disposable
                    }
                    
                    guard let data = FileManager.default.contents(atPath: path) else {
                        single(.error(FileReadError.unreadable))
                        return disposable
                    }
                    
                    guard let contents = String(data: data, encoding: .utf8) else {
                        single(.error(FileReadError.encodingFailed))
                        return disposable
                    }
                    
                    single(.success(contents))
                    return disposable
                }
            }
            
            loadText(name: "Copyright").subscribe { single in
                switch single {
                case .error(let error):
                    print(error)
                case .success(let string):
                    print(string)
                }
            }
            .disposed(by: disposeBag)
        }
    }


}

