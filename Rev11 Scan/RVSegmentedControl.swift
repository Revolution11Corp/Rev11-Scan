//
//  RVSegmentedControl.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 10/17/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RVSegmentedControl: UIControl {

  private var labels = [UILabel]()
  var thumbView = UIView()

  var items: [String] = ["UUID 1", "UUID 2", "UUID 3"] {
    didSet {
      setupLabels()
    }
  }

  var selectedIndex : Int = 0 {
    didSet {
      displayNewSelectedIndex()
    }
  }

  @IBInspectable var selectedLabelColor : UIColor = UIColor.black {
    didSet {
      setSelectedColors()
    }
  }

  @IBInspectable var unselectedLabelColor : UIColor = UIColor.white {
    didSet {
      setSelectedColors()
    }
  }

  @IBInspectable var thumbColor : UIColor = UIColor.white {
    didSet {
      setSelectedColors()
    }
  }

  @IBInspectable var borderColor : UIColor = UIColor.white {
    didSet {
      layer.borderColor = borderColor.cgColor
    }
  }

  @IBInspectable var font : UIFont! = UIFont.systemFont(ofSize: 12) {
    didSet {
      setFont()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }

  func setupView(){
    setupLabels()
    addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
    insertSubview(thumbView, at: 0)
  }

  func setupLabels(){

    for label in labels {
      label.removeFromSuperview()
    }

    labels.removeAll(keepingCapacity: true)

    for index in 1...items.count {

      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
      label.text = items[index - 1]
      label.backgroundColor = UIColor.clear
      label.textAlignment = .center
      label.font = UIFont(name: "AvenirNext-DemiBoldItalic", size: 12)
      label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
      label.translatesAutoresizingMaskIntoConstraints = false
      addSubview(label)
      labels.append(label)
    }

    addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    var selectFrame = bounds
    let newWidth = selectFrame.width / CGFloat(items.count)
    selectFrame.size.width = newWidth
    thumbView.frame = selectFrame
    thumbView.backgroundColor = thumbColor
    thumbView.layer.cornerRadius = thumbView.frame.height / 2

    layer.cornerRadius = bounds.height / 2
    layer.borderColor = Colors.blue.cgColor
    layer.borderWidth = 2
    backgroundColor = UIColor.clear

    displayNewSelectedIndex()
  }

  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)

    var calculatedIndex : Int?
    for (index, item) in labels.enumerated() {
      if item.frame.contains(location) {
        calculatedIndex = index
      }
    }


    if calculatedIndex != nil {
      selectedIndex = calculatedIndex!
      sendActions(for: .valueChanged)
    }

    return false
  }

  func displayNewSelectedIndex(){
    for (_, item) in labels.enumerated() {
      item.textColor = unselectedLabelColor
    }

    let label = labels[selectedIndex]
    label.textColor = selectedLabelColor

    UIView.animate(withDuration: 0.65, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 14.0, options: .curveEaseInOut, animations: {

      self.thumbView.frame = label.frame

      }, completion: nil)
  }

  func addIndividualItemConstraints(items: [UIView], mainView: UIView, padding: CGFloat) {

    for (index, button) in items.enumerated() {

      let topConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0)

      let bottomConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0)

      var rightConstraint : NSLayoutConstraint!

      if index == items.count - 1 {

        rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: -padding)

      }else{

        let nextButton = items[index+1]
        rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nextButton, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1.0, constant: -padding)
      }


      var leftConstraint : NSLayoutConstraint!

      if index == 0 {

        leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: mainView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1.0, constant: padding)

      }else{

        let prevButton = items[index-1]
        leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: prevButton, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: padding)
        let firstItem = items[0]
        let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: firstItem, attribute: .width, multiplier: 1.0  , constant: 0)

        mainView.addConstraint(widthConstraint)
      }

      mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
    }
  }

  func setSelectedColors(){
    for item in labels {
      item.textColor = unselectedLabelColor
    }

    if labels.count > 0 {
      labels[0].textColor = selectedLabelColor
    }

    thumbView.backgroundColor = thumbColor
  }

  func setFont(){
    for item in labels {
      item.font = font
    }
  }
}

