//
//
//   applechrome
//
//  Created by Ashwin Balachandran on 17/02/17.
//  Copyright © 2017 Ashwin Balachandran. All rights reserved.
//

import AppKit

let httpChromeRequest = HTTPRequestForChrome()
httpChromeRequest.HTTPstartChromeDriverSession() {
    (data: String, error: String?) -> Void in
    if error != nil {
        print("There is probabably some error in the request : ", error)
    } else {
        print("data is : \n\n\n")
        print(data)
    }
}
