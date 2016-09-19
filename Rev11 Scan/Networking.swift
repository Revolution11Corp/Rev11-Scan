//
//  Networking.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 9/18/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation

class Networking {

  lazy var configuration: URLSessionConfiguration = .default
  lazy var session: URLSession = URLSession(configuration: self.configuration)

  let url: NSURL

  init(url: NSURL) {
    self.url = url
  }

  func downloadImage(completion: @escaping ((Data) -> Void)) {

    let request = NSURLRequest(url: self.url as URL)
    let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in

      if error == nil {

        if let httpResponse = response as? HTTPURLResponse {

          switch (httpResponse.statusCode) {

          case 200:
            if let data = data {
              completion(data)
            }

          default:
            print("Status Code = \(httpResponse.statusCode)")
          }
        }

      } else {

        //handle download error - Maybe show placeholder image
        print("Error downloading data: \(error?.localizedDescription)")
      }
    }

    dataTask.resume()
  }

}
