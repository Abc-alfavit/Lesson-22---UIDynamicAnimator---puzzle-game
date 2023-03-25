//
//  ViewController.swift
//  Lesson 22 -  UIDynamicAnimator - puzzle game
//
//  Created by Валентин Ремизов on 24.03.2023.
//

import UIKit

class ViewController: UIViewController {

    private let puzzleOneShadowIV = UIImageView(image: UIImage(named: "1"))
    private let puzzleTwoShadowIV = UIImageView(image: UIImage(named: "2"))
    private let puzzleThreeShadowIV = UIImageView(image: UIImage(named: "3"))
    private let puzzleFourShadowIV = UIImageView(image: UIImage(named: "4"))
    private let puzzleOneColorIV = UIImageView(image: UIImage(named: "1"))
    private let puzzleTwoColorIV = UIImageView(image: UIImage(named: "2"))
    private let puzzleThreeColorIV = UIImageView(image: UIImage(named: "3"))
    private let puzzleFourColorIV = UIImageView(image: UIImage(named: "4"))
    private var animator = UIDynamicAnimator()
    private var attachmentOne : UIAttachmentBehavior?
    private var attachmentTwo : UIAttachmentBehavior?
    private var attachmentThree : UIAttachmentBehavior?
    private var attachmentFour : UIAttachmentBehavior?
    private var pan = UIPanGestureRecognizer()
    private let winIV = UIImageView(image: UIImage(named: "Win"))

    override func viewDidAppear(_ animated: Bool) {
        createShadowPuzzles()
        createColorPuzzles()
        createAttachmentsAndCollision()
        createPanGestureRecognizer()
        createWin()
    }

    private func createShadowPuzzles() {
        puzzleOneShadowIV.frame = CGRect(x: view.frame.width / 2 - 90,
                                         y: 200,
                                         width: 80,
                                         height: 80)
        puzzleTwoShadowIV.frame = CGRect(x: view.frame.width / 2 + 10,
                                         y: 200,
                                         width: 80,
                                         height: 80)
        puzzleThreeShadowIV.frame = CGRect(x: view.frame.width / 2 - 90,
                                           y: 290,
                                           width: 80,
                                           height: 80)
        puzzleFourShadowIV.frame = CGRect(x: view.frame.width / 2 + 10,
                                          y: 290,
                                          width: 80,
                                          height: 80)

        [puzzleOneShadowIV, puzzleTwoShadowIV, puzzleThreeShadowIV, puzzleFourShadowIV].forEach{$0.alpha = 0.1
            $0.layer.shadowRadius = 20
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 1

//MARK: - Накладываем фильтр цветовой на фото, чтоб сделать их всех одного цвета.
                    guard let img = $0.image else {return}
                    guard let currentCGImage = img.cgImage else { return }
                        let currentCIImage = CIImage(cgImage: currentCGImage)
                        let context = CIContext(options: nil)
            //В этой строчке указывается какой фильтр будет применен, их много разных.
                        if let filter = CIFilter(name: "CIPhotoEffectMono") {
                            filter.setValue(currentCIImage, forKey: kCIInputImageKey)
                            if let output = filter.outputImage, let cgImage = context.createCGImage(output, from: output.extent) {
                                let processedImage = UIImage(cgImage: cgImage)
                                switch $0 {
                                case puzzleOneShadowIV: puzzleOneShadowIV.image = processedImage
                                case puzzleTwoShadowIV: puzzleTwoShadowIV.image = processedImage
                                case puzzleThreeShadowIV: puzzleThreeShadowIV.image = processedImage
                                case puzzleFourShadowIV: puzzleFourShadowIV.image = processedImage
                                default: return
                                }
                            }
                        }
            view.addSubview($0)
        }
    }



    private func createColorPuzzles() {
        puzzleOneColorIV.frame = CGRect(x: view.frame.width / 2 - 175,
                                        y: view.frame.height - 180,
                                        width: 80,
                                        height: 80)
        puzzleTwoColorIV.frame = CGRect(x: view.frame.width / 2 - 85,
                                        y: view.frame.height - 180,
                                        width: 80,
                                        height: 80)
        puzzleThreeColorIV.frame = CGRect(x: view.frame.width / 2 + 5,
                                        y: view.frame.height - 180,
                                        width: 80,
                                        height: 80)
        puzzleFourColorIV.frame = CGRect(x: view.frame.width / 2 + 95,
                                        y: view.frame.height - 180,
                                        width: 80,
                                        height: 80)

        [puzzleOneColorIV, puzzleTwoColorIV, puzzleThreeColorIV, puzzleFourColorIV].forEach{view.addSubview($0)}
    }

    private func createWin() {
        winIV.frame = CGRect(x: 0,
                             y: 0,
                             width: 30,
                             height: 20)
        winIV.center = view.center
        winIV.isHidden = true
        winIV.alpha = 0
        view.addSubview(winIV)
    }

    private func createAttachmentsAndCollision() {
        attachmentOne = UIAttachmentBehavior(item: puzzleOneColorIV,
                                             attachedToAnchor: puzzleOneColorIV.center)
        attachmentTwo = UIAttachmentBehavior(item: puzzleTwoColorIV,
                                             attachedToAnchor: puzzleTwoColorIV.center)
        attachmentThree = UIAttachmentBehavior(item: puzzleThreeColorIV,
                                               attachedToAnchor: puzzleThreeColorIV.center)
        attachmentFour = UIAttachmentBehavior(item: puzzleFourColorIV,
                                              attachedToAnchor: puzzleFourColorIV.center)
        guard let attachmentUnwrapOne = attachmentOne else {return}
        guard let attachmentUnwrapTwo = attachmentTwo else {return}
        guard let attachmentUnwrapThree = attachmentThree else {return}
        guard let attachmentUnwrapFour = attachmentFour else {return}
        [attachmentUnwrapOne, attachmentUnwrapTwo, attachmentUnwrapThree,
         attachmentUnwrapFour].forEach{animator.addBehavior($0)}
    }

    private func createPanGestureRecognizer() {
        pan = UIPanGestureRecognizer(target: self, action: #selector(workPanGesture(pan:)))
        pan.addTarget(self, action: #selector(winMethod))
        view.addGestureRecognizer(pan)
    }

    @objc private func workPanGesture(pan: UIPanGestureRecognizer) {
        let tapPoint = pan.location(in: view)
//MARK: - делаем логику - если нажал на первую картинку, то она и хватается и так со всеми.
        if tapPoint.x > puzzleOneColorIV.frame.minX && tapPoint.x < puzzleOneColorIV.frame.maxX && tapPoint.y > puzzleOneColorIV.frame.minY && tapPoint.y < puzzleOneColorIV.frame.maxY  {
            attachmentOne?.anchorPoint = tapPoint
            puzzleOneColorIV.center = tapPoint
        } else if tapPoint.x > puzzleTwoColorIV.frame.minX && tapPoint.x < puzzleTwoColorIV.frame.maxX && tapPoint.y > puzzleTwoColorIV.frame.minY && tapPoint.y < puzzleTwoColorIV.frame.maxY {
            attachmentTwo?.anchorPoint = tapPoint
            puzzleTwoColorIV.center = tapPoint
        } else if tapPoint.x > puzzleThreeColorIV.frame.minX && tapPoint.x < puzzleThreeColorIV.frame.maxX && tapPoint.y > puzzleThreeColorIV.frame.minY && tapPoint.y < puzzleThreeColorIV.frame.maxY {
            attachmentThree?.anchorPoint = tapPoint
            puzzleThreeColorIV.center = tapPoint
        } else if tapPoint.x > puzzleFourColorIV.frame.minX && tapPoint.x < puzzleFourColorIV.frame.maxX && tapPoint.y > puzzleFourColorIV.frame.minY && tapPoint.y < puzzleFourColorIV.frame.maxY {
            attachmentFour?.anchorPoint = tapPoint
            puzzleFourColorIV.center = tapPoint
        }

//MARK: - делаем логику - если палец убран и картинка на месте, то встает по размеру, если нет, то возвращается на место обратно.
        if pan.state == .ended {
//MARK: - Код для 1 картинки
            if tapPoint == puzzleOneColorIV.center {
                if tapPoint.x > puzzleOneShadowIV.frame.minX &&
                    tapPoint.x < puzzleOneShadowIV.frame.maxX &&
                    tapPoint.y > puzzleOneShadowIV.frame.minY &&
                    tapPoint.y < puzzleOneShadowIV.frame.maxY {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleOneColorIV.frame = self.puzzleOneShadowIV.frame
                        self.attachmentOne?.anchorPoint = self.puzzleOneColorIV.center
                    }
                } else {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleOneColorIV.frame = CGRect(x: self.view.frame.width / 2 - 175,
                                                             y: self.view.frame.height - 180,
                                                             width: 80,
                                                             height: 80)
                        self.attachmentOne?.anchorPoint = self.puzzleOneColorIV.center
                    }
                }
//MARK: - Код для 2 картинки
            } else if tapPoint == puzzleTwoColorIV.center {
                if tapPoint.x > puzzleTwoShadowIV.frame.minX &&
                    tapPoint.x < puzzleTwoShadowIV.frame.maxX &&
                    tapPoint.y > puzzleTwoShadowIV.frame.minY &&
                    tapPoint.y < puzzleTwoShadowIV.frame.maxY {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleTwoColorIV.frame = self.puzzleTwoShadowIV.frame
                        self.attachmentTwo?.anchorPoint = self.puzzleTwoColorIV.center
                    }
                } else {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleTwoColorIV.frame = CGRect(x: self.view.frame.width / 2 - 85,
                                                             y: self.view.frame.height - 180,
                                                             width: 80,
                                                             height: 80)
                        self.attachmentTwo?.anchorPoint = self.puzzleTwoColorIV.center
                    }
                }
//MARK: - Код для 3 картинки
            } else if tapPoint == puzzleThreeColorIV.center {
                if tapPoint.x > puzzleThreeShadowIV.frame.minX &&
                    tapPoint.x < puzzleThreeShadowIV.frame.maxX &&
                    tapPoint.y > puzzleThreeShadowIV.frame.minY &&
                    tapPoint.y < puzzleThreeShadowIV.frame.maxY {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleThreeColorIV.frame = self.puzzleThreeShadowIV.frame
                        self.attachmentThree?.anchorPoint = self.puzzleThreeColorIV.center
                    }
                } else {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleThreeColorIV.frame = CGRect(x: self.view.frame.width / 2 + 5,
                                                               y: self.view.frame.height - 180,
                                                               width: 80,
                                                               height: 80)
                        self.attachmentThree?.anchorPoint = self.puzzleThreeColorIV.center
                    }
                }
//MARK: - Код для 4 картинки
            } else if tapPoint == puzzleFourColorIV.center {
                if tapPoint.x > puzzleFourShadowIV.frame.minX &&
                    tapPoint.x < puzzleFourShadowIV.frame.maxX &&
                    tapPoint.y > puzzleFourShadowIV.frame.minY &&
                    tapPoint.y < puzzleFourShadowIV.frame.maxY {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleFourColorIV.frame = self.puzzleFourShadowIV.frame
                        self.attachmentFour?.anchorPoint = self.puzzleFourColorIV.center
                    }
                } else {
                    UIView.animate(withDuration: 0.7,
                                   delay: 0,
                                   usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.4) {
                        self.puzzleFourColorIV.frame = CGRect(x: self.view.frame.width / 2 + 95,
                                                              y: self.view.frame.height - 180,
                                                              width: 80,
                                                              height: 80)
                        self.attachmentFour?.anchorPoint = self.puzzleFourColorIV.center
                    }
                }
            }
        }
    }

    @objc private func winMethod() {
//MARK: - Почему-то если поставить через && все Color.frame картинки == Shadow.frame картинкам, то не срабатывает инструкция, но если через ||, то срабатывает.
        if puzzleFourColorIV.frame == puzzleFourShadowIV.frame {
            view.isUserInteractionEnabled = false
            winIV.isHidden = false
            UIView.animate(withDuration: 1.5,
                           delay: 0.2,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5) {
                self.winIV.frame = CGRect(x: 0,
                                          y: 0,
                                          width: 300,
                                          height: 200)
                self.winIV.center = self.view.center
                self.winIV.alpha = 1
            }
        }
    }
}


