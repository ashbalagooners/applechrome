//
//  HTTPRequestForChrome.swift
//  applechrome
//
//  Created by Ashwin Balachandran on 18/02/17.
//  Copyright © 2017 Ashwin Balachandran. All rights reserved.
//  The class below covers Part 1 and 2 of excercise and partly covers part 3 by adding the apple id to iCloud login page
//

import Foundation
import AppKit

class HTTPRequestForChrome {
    
    var sessionId = ""
    
    /*
     Method to trigger various http requests
    */
    func HTTPstartChromeDriverSession(callback: (String, String?) -> Void) {
        
        let scriptUrl = "http://localhost:4444/wd/hub"
        let urlWithParams = scriptUrl + "/session"
        let iClouldProdURL = "https://www.icloud.com"
        let appleId = "ashwin.gunners@gmail.com" //choose an apple id of your choice
    
        // Create NSURL Object to start a webdriver session
        let myUrl = NSURL(string: urlWithParams);
    
        // Create POST request to start the chrome driver
        let request = NSMutableURLRequest(url:myUrl! as URL);
        let params:NSMutableDictionary? = ["desiredCapabilities" : ["browserName" : "chrome"]]
        let updatedRequest = createPostBody(request: request,params: params!)
        HTTPPost(request: updatedRequest, session : false, callback: callback)
        
        // Create POST request to navigate to icloud.com
        let iClouldURLWithParams = scriptUrl + "/session/" + sessionId + "/url"
        // Create NSURL Object
        let myiCloudUrl = NSURL(string: iClouldURLWithParams);
        let iClouldRequest = NSMutableURLRequest(url:myiCloudUrl! as URL);
        let iClouldParams:NSMutableDictionary? = ["url" : iClouldProdURL]
        let iClouldUpdatedRequest = createPostBody(request: iClouldRequest,params: iClouldParams!)
        HTTPPost(request: iClouldUpdatedRequest, session : true, callback: callback)
        
        // Enter apple id and password
        let iClouldEnterLoginURL = scriptUrl + "/session/" + sessionId + "/keys"
        // Create NSURL Object
        let myiCloudLoginUrl = NSURL(string: iClouldEnterLoginURL);
        let iClouldLoginRequest = NSMutableURLRequest(url:myiCloudLoginUrl! as URL);
        let iClouldLoginParams:NSMutableDictionary? = ["value" : [appleId]]
        let iClouldUpdatedLoginRequest = createPostBody(request: iClouldLoginRequest,params: iClouldLoginParams!)
        HTTPPost(request: iClouldUpdatedLoginRequest, session : true, callback: callback)

    }
    
    /*
     Method to trigger http get request
     */
    func HTTPGet(request: NSMutableURLRequest, callback: (String, String?) -> Void) {
        
        request.httpMethod = "GET"
        HTTPsendRequest(request: request, currentSession : true, callback: callback)
    }
    
    /*
     Method to trigger http post request
     */
    func HTTPPost(request: NSMutableURLRequest, session : Bool, callback: (String, String?) -> Void) {
            
        request.httpMethod = "POST"
        HTTPsendRequest(request: request, currentSession: session, callback: callback)

    }
    
    /*
     Method to create payload or body for POST request
     */
    func createPostBody(request: NSMutableURLRequest, params: NSMutableDictionary) -> NSMutableURLRequest{
        
        let data = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        if let json = json {
            print(json)
        }
        request.httpBody = json!.data(using: String.Encoding.utf8.rawValue)
        return request
    }
    
    /*
     Method to trigger http request based on request type and also checks if the a current session is active
     */
    func HTTPsendRequest(request: NSMutableURLRequest,currentSession : Bool,callback: (String, String?) -> Void) {
    
        // Execute HTTP Request
        print(request)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            if (currentSession == false) {
                self.convertJsonResponseToDict(data: data!)
            }
        }
        task.resume()
            
        sleep(10);  //hard code sleep is added for simplicity to make sure the program is not terminated and the browser can be opened. This can be improved upon by adding a implicit wait
    
    }
    
    /*
     Method to convert json response to a dict so that its key/value pair can be looked up
     */
    func convertJsonResponseToDict(data : Data?) -> Void {
    
    
        // Convert server json response to NSDictionary
        do {
            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
    
                // Print out dictionary
                print(convertedJsonIntoDict)
                getDictKeyValue(jsonDict: convertedJsonIntoDict, key: "sessionId")
            }
        } catch let error as NSError {
        print(error.localizedDescription)
        }
    
    }
    
    /*
     Get the appropriate value for corresponding dict key
    */
    func getDictKeyValue(jsonDict: NSDictionary, key : String?) -> Void {
    
        // Get value by key
        let jsonKey = jsonDict[key!] as? String
        print(jsonKey!)
        sessionId = jsonKey!
        
    }
    
}
