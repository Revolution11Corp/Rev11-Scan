//
//  ShareViewController.swift
//  Rev11Scan-ShareExtension
//
//  Created by Sean's Macboo Pro on 9/3/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

  let suiteName = "group.deegeu.swift.share.extension"
  let redDefaultKey = "RedColorImage"
  let blueDefaultKey = "BlueColorImage"

  var selectedImage: UIImage?
  var selectedColorName = "Default"

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
      // This is called after the user selects Post.
      // Make sure we have a valid extension item
      if let content = extensionContext!.inputItems[0] as? NSExtensionItem {
        let contentType = kUTTypeImage as String
        // A couple kUTTypes that might work... kUTTypeJSON, kUTTypeCommaSeparatedText, kUTTypeSpreadsheet, kUTTypeFileURL

        // Verify the provider is valid
        if let contents = content.attachments as? [NSItemProvider] {

          // look for images
          for attachment in contents {
            if attachment.hasItemConformingToTypeIdentifier(contentType) {
              attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in

                let url = data as! NSURL
                if (!self.selectedColorName.isEmpty) {
                  if let imageData = NSData(contentsOf: url as URL) {
                    if (self.selectedColorName == "Default") {
                      self.saveImage(color: self.redDefaultKey, imageData: imageData)
                      self.saveImage(color: self.blueDefaultKey, imageData: imageData)
                    } else if (self.selectedColorName == "Red") {
                      self.saveImage(color: self.redDefaultKey, imageData: imageData)
                    } else {
                      // must be blue
                      self.saveImage(color: self.blueDefaultKey, imageData: imageData)
                    }
                  }
                }
              }
            }
          }
        }
      }

        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

// Need to convert "saveImage" to "saveFile" for .csv or .json.

  // Saves an image to user defaults.
  func saveImage(color: String, imageData: NSData) {
    if let prefs = UserDefaults(suiteName: suiteName) {
      prefs.removeObject(forKey: color)
      prefs.set(imageData, forKey: color)
    }
  }

}
