//
//  ViewController.swift
//  Chapter 3 Challenge 1
//
//  Created by Bruce on 2025/4/5.
//

import RxSwift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发牌", style:.plain, target: self, action: #selector(dealCards))
        
        dealCards()
    }
    
    
    @objc func dealCards() {
        example(of: "PublishSubject") {
            
            let disposeBag = DisposeBag()
            
            let dealtHand = PublishSubject<[(String, Int)]>()
            
            func deal(_ cardCount: UInt) {
                var deck = cards
                var cardsRemaining = deck.count
                var hand = [(String, Int)]()
                
                for _ in 0..<cardCount {
                    let randomIndex = Int.random(in: 0..<cardsRemaining)
                    hand.append(deck[randomIndex])
                    deck.remove(at: randomIndex)
                    cardsRemaining -= 1
                }
                
                // Add code to update dealtHand here
                let points = points(for: hand)
                if points > 21 {
                    dealtHand.onError(HandError.busted(points: points))
                } else {
                    dealtHand.onNext(hand)
                }
                
            }
            
            // Add subscription to dealtHand here
            dealtHand.subscribe { hand in
                print(cardString(for: hand) + "\(points(for: hand))")
            } onError: { error in
                if case let .busted(points: point) = error as? HandError {
                    print("Busted with the points being: \(point)")
                }
                print("==" + String(describing: error).capitalized + "==")
            }
            .disposed(by: disposeBag)
            
            
            deal(3)
        }
    }

}

