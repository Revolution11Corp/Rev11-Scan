//
//  AddBeaconScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation

class AddBeaconScreen: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var saveBarButton: UIBarButtonItem!

  @IBOutlet weak var beaconTypeSwitch: UISwitch!
  @IBOutlet weak var eddystoneLabel: UILabel!
  @IBOutlet weak var iBeaconLabel: UILabel!
  
  @IBOutlet weak var nameTextField: UITextField!

  // iBeacon Labels & Text Fields
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var uuidTextField: UITextField!
  @IBOutlet weak var majorLabel: UILabel!
  @IBOutlet weak var majorTextField: UITextField!
  @IBOutlet weak var minorLabel: UILabel!
  @IBOutlet weak var minorTextField: UITextField!

  @IBOutlet var iBeaconViews: [UIView]!

  // Eddystone Labels & Text Fields
  @IBOutlet weak var namespaceLabel: UILabel!
  @IBOutlet weak var namespaceTextField: UITextField!
  @IBOutlet weak var instanceLabel: UILabel!
  @IBOutlet weak var instanceTextField: UITextField!
  @IBOutlet weak var urlLabel: UILabel!
  @IBOutlet weak var urlTextField: UITextField!

  @IBOutlet var eddystoneViews: [UIView]!

  var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
  var nameFieldValid = false
  var majorFieldValid = false
  var minorFieldValid = false
  var UUIDFieldValid = false

  var switchIsOn = true
  var newBeacon: iBeaconItem?
//  var newEddystone: BeaconInfo?


  override func viewDidLoad() {
    super.viewDidLoad()
    enableDismissKeyboardOnTap()
    checkIfTextInputValid()
    beaconTypeSwitch.addTarget(self, action: #selector(AddBeaconScreen.stateChanged(_:)), for: UIControlEvents.valueChanged)
    saveBarButton.isEnabled = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    for view in eddystoneViews {
      view.alpha = 0.0
    }
  }

  @objc func stateChanged(_ switchState: UISwitch) {

    if switchState.isOn {
      switchViews(viewsToHide: eddystoneViews, viewsToShow: iBeaconViews)
      switchIsOn = true

    } else {
      switchViews(viewsToHide: iBeaconViews, viewsToShow: eddystoneViews)
      switchIsOn = false
    }
  }

  func switchViews(viewsToHide: [UIView], viewsToShow: [UIView]) {

    for view in viewsToHide {
      UIView.animate(withDuration: 0.3, animations: {
        view.alpha = 0.0
      })
    }

    for view in viewsToShow {
      UIView.animate(withDuration: 0.3, animations: {
        view.alpha = 1.0
      })
    }
  }

  @objc func nameTextFieldChanged(_ textField: UITextField) {
    nameFieldValid = (textField.text!.characters.count > 0)
    updateSaveButton()
  }

  @objc func majorTextFieldChanged(_ textField: UITextField) {
    majorFieldValid = (textField.text!.characters.count > 0)
    updateSaveButton()
  }

  @objc func minorTextFieldChanged(_ textField: UITextField) {
    minorFieldValid = (textField.text!.characters.count > 0)
    updateSaveButton()
  }

  @objc func uuidTextFieldChanged(_ textField: UITextField) {
    let numberOfMatches = uuidRegex.numberOfMatches(in: textField.text!, options: [], range: NSMakeRange(0, textField.text!.characters.count))
    UUIDFieldValid = (numberOfMatches > 0)
    updateSaveButton()
  }

  func checkIfTextInputValid() {
    nameTextField.addTarget(self, action: #selector(AddBeaconScreen.nameTextFieldChanged(_:)), for: .editingChanged)
    majorTextField.addTarget(self, action: #selector(AddBeaconScreen.majorTextFieldChanged(_:)), for: .editingChanged)
    minorTextField.addTarget(self, action: #selector(AddBeaconScreen.minorTextFieldChanged(_:)), for: .editingChanged)
    uuidTextField.addTarget(self, action: #selector(AddBeaconScreen.uuidTextFieldChanged(_:)), for: .editingChanged)
  }

  func updateSaveButton() {

    if UUIDFieldValid && nameFieldValid && majorFieldValid && minorFieldValid {
      saveBarButton.isEnabled = true
    } else {
      saveBarButton.isEnabled = false
    }
  }

//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    if segue.identifier == "SaveBeacon" {
//
//      if switchIsOn == true {
//        let uuid = UUID(uuidString: uuidTextField.text!)
//
//        let major: CLBeaconMajorValue = UInt16(Int(majorTextField.text!)!)
//        let minor: CLBeaconMinorValue = UInt16(Int(minorTextField.text!)!)
//        newBeacon = iBeaconItem(name: nameTextField.text!, uuid: (uuid! as NSUUID) as UUID, majorValue: major, minorValue: minor, color: Colors.white)
//
//      } else {
//
//
//      }
//    }
//  }


  // MARK: - Keyboard Functions

  func enableDismissKeyboardOnTap() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddBeaconScreen.dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }

  
  
  
  
  
  
  
}
