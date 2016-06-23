//
//  Request.swift
//  CallbackURLKit
/*
The MIT License (MIT)
Copyright (c) 2015 Eric Marchand (phimage)
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

typealias RequestID = String

struct Request {

    let ID: RequestID
    let client: Client
    let action: Action
    let parameters: Parameters
    let successCallback: SuccessCallback?
    let failureCallback: FailureCallback?
    let cancelCallback: CancelCallback?

    // [scheme]://[host]/[action]?[x-callback parameters]&[action parameters]
    func URLComponents(query: Parameters) -> NSURLComponents {
        let components = NSURLComponents()
        components.scheme = self.client.URLScheme
        components.host = kXCUHost
        components.path = "/\(self.action)"
        components.query = (parameters + query).query
        return components
    }

    var hasCallback: Bool {
        return successCallback != nil || failureCallback != nil || cancelCallback != nil
    }

}

enum ResponseType: String {
    case success
    case error
    case cancel
}