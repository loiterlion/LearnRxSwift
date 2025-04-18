/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!

  private let bag = DisposeBag()
  private let images = BehaviorRelay<[UIImage]>(value: [])
  
  private var imageCache = [Int]()
  
  var myClosure = {}
  
  func testEscp(closure: @escaping () -> Void) {
    myClosure = closure
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    testEscp {
      print("Hello World!")
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.myClosure()
    }
    
    let sharedImages = images.share()
    sharedImages
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak imagePreview] photos in
        guard let preview = imagePreview else { return }
        
        preview.image = photos.collage(size: preview.frame.size)
      })
      .disposed(by: bag)
    
    sharedImages
      .subscribe(onNext: { [weak self] photos in
        self?.updateUI(photos: photos)
      })
      .disposed(by: bag)
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
  
  @IBAction func actionClear() {
    images.accept([])
    imageCache = []
    navigationItem.leftBarButtonItem?.image = nil
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }
    PhotoWriter.save(image)
      .subscribe(onSuccess: { [weak self] id in
        self?.showMessage("Saved with id: \(id)")
        self?.actionClear()
      }, onError:{ [weak self] error in
        self?.showMessage("Error", description: error.localizedDescription)
      })
      .disposed(by: bag)
  }

  @IBAction func actionAdd() {
//    let newImages = images.value
//    + [UIImage(named: "IMG_1907.jpg")!]
//    images.accept(newImages)
    
    let photosVC = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    
    let newPhotos = photosVC.selectedPhotos
    
    
    newPhotos
      // only allows 6 images in total 
      .takeWhile({ [weak self] image in
        let count = self?.images.value.count ?? 0
        return count < 6
      })
      // filter only landscape images
      .filter({ $0.size.width > $0.size.height })
      // filter existing images by comparing byte size
      .filter({ [weak self] newImage in
        let len = newImage.pngData()?.count ?? 0
        guard self?.imageCache.contains(len) == false else { return false }
        
        self?.imageCache.append(len)
        return true
      })
      .subscribe(onNext: { [weak self] newImage in
        guard let images = self?.images else { return }
        images.accept(images.value + [newImage])
      },onDisposed: {
        print("Completed photo selection")
      })
      .disposed(by: bag)
    
    navigationController!.pushViewController(photosVC, animated: true)
        
    newPhotos
      .ignoreElements()
      .subscribe(onCompleted: { [weak self] in
        self?.updateNavigationIcon()
      })
      .disposed(by: bag)
  }
  
  private func updateNavigationIcon() {
    let icon = imagePreview.image?
      .scaled(CGSize(width: 22, height: 22))
      .withRenderingMode(.alwaysOriginal)
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
  }

  func showMessage(_ title: String, description: String? = nil) {
    alert(title: title, text: description)
      .subscribe {
      } onError: {_ in
      }
      .disposed(by: bag)
  }
}

//extension UIViewController {
//  func showAlert(title: String, description: String? = nil) -> Completable {
//    return Completable.create { observer in
//      let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
//      alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in
//        self?.dismiss(animated: true, completion: nil)
//        observer(.completed)
//      }))
//      self.present(alert, animated: true, completion: nil)
//
//      return Disposables.create()
//    }
//  }
//}

// Official solution
extension UIViewController {
  func alert(title: String, text: String?) -> Completable {
    return Completable.create { [weak self] completable in
      let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
      alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
        // 1 当这里触发之后，就代表subscription结束了，之后就会触发2 里的代码
        completable(.completed)
      }))
      self?.present(alertVC, animated: true, completion: nil)
      return Disposables.create {
        print("disposed")
        // 2 之所以这里写是因为，在1的地方执行完之后，
        self?.dismiss(animated: true, completion: nil)
      }
    }
  }
}
