//
//  ServiceHttp.swift
//  Prueba
//
//  Created by Jorge Tlahuechtl Juarez on 20/05/21.
//

import Foundation
import Alamofire

class ServiceHttp {
    
    static let shared = ServiceHttp()
    
    var requestManager = Alamofire.SessionManager.default
    
    func request(session:Session,uri:String,method:String,options:Dictionary<String,String>, data:Any,completion success: @escaping (Result<Dictionary<String,String>>) -> Void){
        putProxyRequest(session: session, contentType: options["content-type"] != nil ? options["content-type"]! :  "application/json")
        let methodHttp = MethodHttp(rawValue: method)
        
        switch methodHttp {
        case .get:
            get(uri: uri, options: options, data: data, completion:success)
        case .put:
            put(uri: uri, options: options, data: data, completion:success)
        case .post:
            post(uri: uri, options: options, data: data, completion:success)
        case .delete:
            delete(uri: uri, options: options, data: data, completion:success)
        default:
            break
        }
        
        
    }
    
    func getData(session:Session, uri:String,completion: @escaping (Result<Data>) -> Void){
        putProxyRequest(session: session, contentType:  "application/json")
        requestManager.request(uri).responseData { resposnse in
            switch(resposnse.result){
                case .success(let data):
                    completion(.Success(data))
                case .failure(_):
                    completion(.Error(resposnse.response?.statusCode ?? 999))
            }
        }
    }
//    Dictionary<String,Any>
    func get(uri:String,options:Dictionary<String,String>,data:Any,completion: @escaping (Result<Dictionary<String,String>>) -> Void){
//        requestManager.request(uri, method: .get, parameters: data, encoding: URLEncoding.default, headers: options).responseDATA { (response:DataResponse<Data>) in
            requestManager.request(uri, method: .get, parameters: [:], encoding: URLEncoding.default, headers: options).responseData{ (response:DataResponse<Data>) in
                
//                print("**************************** WHAT IS IT? ***********************************")
//                print("MAP: \(data as? Dictionary<String, Any>)")
//                print("String: \(data as? String)")
//                print("Array: \(data as? [Any])")
//                print("****************************************************************************");
                switch(response.result) {
                case .success(_):
                    let responseString: String? = String(data: response.data!, encoding: .utf8)
                    var res = Dictionary<String, String>()
                    res.updateValue(responseString ?? "", forKey: "data")
                    res.updateValue(String(response.response?.statusCode ?? 999), forKey: "status_code")
                    if let headers = response.response?.allHeaderFields{
                        
                        var h = Dictionary<String, String>()
                        headers.forEach { obj in
                            h.updateValue(obj.value as! String, forKey: obj.key.description)
                        }
                        res.updateValue(h.description, forKey: "headers")
                    }

                    completion(.Success(res))
                    break
                    
                case .failure(_):
                    print("Error get")
                    print(response.result.error as Any)
                    completion(.Error((response.response?.statusCode) ?? 999))
                    break
                }
        }

    }
    
    func post(uri:String,options:Dictionary<String,String>,data:Any,completion: @escaping (Result<Dictionary<String,String>>) -> Void){

        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        let jsonString = String(data: jsonData!, encoding: String.Encoding.utf8)!

//        requestManager.request(uri, method: .post, parameters: [:], encoding: JSONStringArrayEncoding.init(string: jsonString), headers: options).responseData { (response:DataResponse<Any>) in
            
        requestManager.request(uri, method: .post, parameters: [:], encoding: JSONStringArrayEncoding.init(string: jsonString), headers: options).responseData{ (response:DataResponse<Data>) in
                 
//                print("**************************** WHAT IS IT? ***********************************")
//                print("MAP: \(data as? Dictionary<String, Any>)")
//                print("String: \(data as? String)")
//                print("Array: \(data as? [Any])")
//                print("****************************************************************************");
                
            switch(response.result) {
                case .success(_):
                    let responseString: String? = String(data: response.data!, encoding: .utf8)
                    var res = Dictionary<String, String>()
                    res.updateValue(responseString ?? "", forKey: "data")
                    res.updateValue(String(response.response?.statusCode ?? 999), forKey:"status_code")
                    
                    if let headers = response.response?.allHeaderFields{
                        
                        var h = Dictionary<String, String>()
                        headers.forEach { obj in
                            h.updateValue(obj.value as! String, forKey: obj.key.description)
                        }
                        res.updateValue(h.description, forKey: "headers")
                    }
                    
 
                    completion(.Success(res))
                    break
                    
                case .failure(_):
                    print("Error post")
                    print(response.result.error as Any)
                    completion(.Error((response.response?.statusCode) ?? 999))
                    break
            }
        }


    }
    
    func delete(uri:String,options:Dictionary<String,String>,data:Any,completion: @escaping (Result<Dictionary<String,String>>) -> Void){
        requestManager.request(uri, method: .delete, parameters: [:], encoding: URLEncoding.default, headers: options).responseData{ (response:DataResponse<Data>) in
                
            switch(response.result) {
                case .success(_):
                    let responseString: String? = String(data: response.data!, encoding: .utf8)

                    var res = Dictionary<String, String>()
                    res.updateValue(responseString ?? "", forKey: "data")
                    res.updateValue(String(response.response?.statusCode ?? 999), forKey:"status_code")
                    if let headers = response.response?.allHeaderFields{
                        
                        var h = Dictionary<String, String>()
                        headers.forEach { obj in
                            h.updateValue(obj.value as! String, forKey: obj.key.description)
                        }
                        res.updateValue(h.description, forKey: "headers")
                    }
 
                    completion(.Success(res))
                    break
                    
                case .failure(_):
                    print("Error delete")
                    print(response.result.error as Any)
                    completion(.Error((response.response?.statusCode) ?? 999))
                    break
            }
        }

    }
    
    func put(uri:String,options:Dictionary<String,String>,data:Any,completion: @escaping (Result<Dictionary<String,String>>) -> Void){
        var jsonString:String
//        print("**************************** WHAT IS IT? ***********************************")
//        print("MAP: \(data as? Dictionary<String, Any>)")
//        print("String: \(data as? String)")
//        print("Array: \(data as? [Any])")
//        print("****************************************************************************");
        if(!(data is String)){
            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            jsonString = String(data: jsonData!, encoding: String.Encoding.utf8)!
        }else{
            jsonString = String(describing:data);
        }
       
        requestManager.request(uri, method: .put, parameters: [:], encoding: JSONStringArrayEncoding.init(string: jsonString), headers: options).responseData { (response:DataResponse<Data>) in
            
                
            switch(response.result) {
                case .success(_):
                    let responseString: String? = String(data: response.data!, encoding: .utf8)
                    var res = Dictionary<String, String>()
                    res.updateValue(responseString ?? "", forKey: "data")
                    res.updateValue(String(response.response?.statusCode ?? 999), forKey:"status_code")
                    if let headers = response.response?.allHeaderFields{
                        
                        var h = Dictionary<String, String>()
                        headers.forEach { obj in
                            h.updateValue(obj.value as! String, forKey: obj.key.description)
                        }
                        res.updateValue(h.description, forKey: "headers")
                    }
 
                    completion(.Success(res))
                    break
                    
                case .failure(_):
                    print("Error put")
                    print(response.result.error as Any)
                    completion(.Error((response.response?.statusCode) ?? 999))
                    break
            }
        }

    }
    
    
    
    /**
     Método que configura el proxy de WMC
     */
    func putProxyRequest(session:Session, contentType:String){
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        
        //configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        let loginData = String(format: "%@:%@", session.username!, session.password!).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        let headers = ["Proxy-Authorization" : "Basic \(base64LoginData)",
            "Content-Type": contentType,// "application/json",
            "sessionid": session.sessionid ]
        
        configuration.httpAdditionalHeaders = headers as [AnyHashable : Any]
        
        let urlProxyFull = session.gw?.deletingPrefix("https://").deletingPrefix("http://")
        
        let urlProxy = urlProxyFull!.split(separator: ":")[0]
        let portProxy = urlProxyFull!.split(separator: ":")[1]
        
        //print("token = \(token)")
        
        
        var proxyConfiguration = [String: AnyObject]()
        proxyConfiguration.updateValue(1 as AnyObject , forKey: "HTTPEnable")
        proxyConfiguration.updateValue(String(urlProxy) as String as AnyObject , forKey: "HTTPProxy")
        proxyConfiguration.updateValue(Int(portProxy) as AnyObject , forKey: "HTTPPort")
        proxyConfiguration.updateValue(1 as AnyObject , forKey: "HTTPSEnable")
        proxyConfiguration.updateValue(String(urlProxy) as String as AnyObject , forKey: "HTTPSProxy")
        proxyConfiguration.updateValue(Int(portProxy) as AnyObject , forKey: "HTTPSPort")
        
        configuration.connectionProxyDictionary = proxyConfiguration
    
        requestManager = Alamofire.SessionManager(configuration: configuration)
    }
}

enum Result<T> {
    case Success(T)
    case Error(Int)
}

enum MethodHttp: String{
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}








////
////  ServiceHttp.swift
////  Prueba
////
////  Created by Jorge Tlahuechtl Juarez on 20/05/21.
////
//
//import Foundation
//import Alamofire
//
//class ServiceHttp {
//
//    static let shared = ServiceHttp()
//
//    var requestManager = Alamofire.SessionManager.default
//
//    func request(session:Session,uri:String,method:String,options:Dictionary<String,String>,data:Dictionary<String,Any>,completion success: @escaping (Result<Dictionary<String,String>>) -> Void){
//        putProxyRequest(session: session)
//        let methodHttp = MethodHttp(rawValue: method)
//
//        switch methodHttp {
//        case .get:
//            get(uri: uri, options: options, data: data, completion:success)
//        case .put:
//            put(uri: uri, options: options, data: data, completion:success)
//        case .post:
//            post(uri: uri, options: options, data: data, completion:success)
//        case .delete:
//            delete(uri: uri, options: options, data: data, completion:success)
//        default:
//            break
//        }
//
//
//    }
//
//    func getData(session:Session, uri:String,completion: @escaping (Result<Data>) -> Void){
//        putProxyRequest(session: session)
//        requestManager.request(uri).responseData { resposnse in
//            switch(resposnse.result){
//                case .success(let data):
//                    completion(.Success(data))
//                case .failure(_):
//                    completion(.Error(resposnse.response?.statusCode ?? 999))
//            }
//        }
//    }
//
//    func get(uri:String,options:Dictionary<String,String>,data:Dictionary<String,Any>,completion: @escaping (Result<Dictionary<String,String>>) -> Void){
//        requestManager.request(uri, method: .get, parameters: data, encoding: URLEncoding.default, headers: options).responseJSON { (response:DataResponse<Any>) in
//
//                switch(response.result) {
//                case .success(_):
//                    let responseString: String? = String(data: response.data!, encoding: .utf8)
//                    var res = Dictionary<String, String>()
//                    res.updateValue(responseString ?? "", forKey: "data")
//                    res.updateValue(String(response.response?.statusCode ?? 999), forKey: "status_code")
//                    if let headers = response.response?.allHeaderFields{
//
//                        var h = Dictionary<String, String>()
//                        headers.forEach { obj in
//                            h.updateValue(obj.value as! String, forKey: obj.key.description)
//                        }
//                        res.updateValue(h.description, forKey: "headers")
//                    }
//
//                    completion(.Success(res))
//                    break
//
//                case .failure(_):
//                    print("Error get")
//                    print(response.result.error as Any)
//                    completion(.Error((response.response?.statusCode) ?? 999))
//                    break
//                }
//        }
//
//    }
//
//    func post(uri:String,options:Dictionary<String,String>,data:Dictionary<String,Any>,completion: @escaping (Result<Dictionary<String,String>>) -> Void){
//        var httpbody = ""
//        let encoder = JSONEncoder()
//        if let jsonData = try? encoder.encode(data) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                httpbody = jsonString
//            }
//        }
//        requestManager.request(uri, method: .post, parameters: [:], encoding: JSONStringArrayEncoding.init(string: httpbody), headers: options).responseJSON { (response:DataResponse<Any>) in
//
//            switch(response.result) {
//                case .success(_):
//                    let responseString: String? = String(data: response.data!, encoding: .utf8)
//                    var res = Dictionary<String, String>()
//                    res.updateValue(responseString ?? "", forKey: "data")
//                    res.updateValue(String(response.response?.statusCode ?? 999), forKey:"status_code")
//
//                    if let headers = response.response?.allHeaderFields{
//
//                        var h = Dictionary<String, String>()
//                        headers.forEach { obj in
//                            h.updateValue(obj.value as! String, forKey: obj.key.description)
//                        }
//                        res.updateValue(h.description, forKey: "headers")
//                    }
//
//
//                    completion(.Success(res))
//                    break
//
//                case .failure(_):
//                    print("Error post")
//                    print(response.result.error as Any)
//                    completion(.Error((response.response?.statusCode) ?? 999))
//                    break
//            }
//        }
//
//
//    }
//
//    func delete(uri:String,options:Dictionary<String,String>,data:Dictionary<String,Any>,completion: @escaping (Result<Dictionary<String,String>>) -> Void){
//        requestManager.request(uri, method: .delete, parameters: data, encoding: URLEncoding.default, headers: options).responseJSON { (response:DataResponse<Any>) in
//
//            switch(response.result) {
//                case .success(_):
//                    let responseString: String? = String(data: response.data!, encoding: .utf8)
//
//                    var res = Dictionary<String, String>()
//                    res.updateValue(responseString ?? "", forKey: "data")
//                    res.updateValue(String(response.response?.statusCode ?? 999), forKey:"status_code")
//                    if let headers = response.response?.allHeaderFields{
//
//                        var h = Dictionary<String, String>()
//                        headers.forEach { obj in
//                            h.updateValue(obj.value as! String, forKey: obj.key.description)
//                        }
//                        res.updateValue(h.description, forKey: "headers")
//                    }
//
//                    completion(.Success(res))
//                    break
//
//                case .failure(_):
//                    print("Error delete")
//                    print(response.result.error as Any)
//                    completion(.Error((response.response?.statusCode) ?? 999))
//                    break
//            }
//        }
//
//    }
//
//    func put(uri:String,options:Dictionary<String,String>,data:Dictionary<String,Any>,completion: @escaping (Result<Dictionary<String,String>>) -> Void){
//
//        var httpbody = ""
//        let encoder = JSONEncoder()
//        if let jsonData = try? encoder.encode(data) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                httpbody = jsonString
//            }
//        }
//
//        requestManager.request(uri, method: .put, parameters: [:], encoding: JSONStringArrayEncoding.init(string: httpbody), headers: options)
//            .validate(statusCode: 200..<300).responseJSON { (response:DataResponse<Any>) in
//
//            switch(response.result) {
//                case .success(_):
//                    let responseString: String? = String(data: response.data!, encoding: .utf8)
//                    var res = Dictionary<String, String>()
//                    res.updateValue(responseString ?? "", forKey: "data")
//                    res.updateValue(String(response.response?.statusCode ?? 999), forKey:"status_code")
//                    if let headers = response.response?.allHeaderFields{
//
//                        var h = Dictionary<String, String>()
//                        headers.forEach { obj in
//                            h.updateValue(obj.value as! String, forKey: obj.key.description)
//                        }
//                        res.updateValue(h.description, forKey: "headers")
//                    }
//
//                    completion(.Success(res))
//                    break
//
//                case .failure(_):
//                    print("Error put")
//                    print(response.result.error as Any)
//                    completion(.Error((response.response?.statusCode) ?? 999))
//                    break
//            }
//        }
//
//    }
//
//
//
//    /**
//     Método que configura el proxy de WMC
//     */
//    func putProxyRequest(session:Session){
//        let configuration = URLSessionConfiguration.default
//
//        configuration.timeoutIntervalForRequest = 10 // seconds
//        configuration.timeoutIntervalForResource = 10
//
//        //configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
//
//        let loginData = String(format: "%@:%@", session.username!, session.password!).data(using: String.Encoding.utf8)!
//        let base64LoginData = loginData.base64EncodedString()
//        let headers = ["Proxy-Authorization" : "Basic \(base64LoginData)",
//            "Content-Type": "application/json",
//            "sessionid": session.sessionid ]
//
//        configuration.httpAdditionalHeaders = headers as [AnyHashable : Any]
//
//        let urlProxyFull = session.gw?.deletingPrefix("https://").deletingPrefix("http://")
//
//        let urlProxy = urlProxyFull!.split(separator: ":")[0]
//        let portProxy = urlProxyFull!.split(separator: ":")[1]
//
//        //print("token = \(token)")
//
//
//        var proxyConfiguration = [String: AnyObject]()
//        proxyConfiguration.updateValue(1 as AnyObject , forKey: "HTTPEnable")
//        proxyConfiguration.updateValue(String(urlProxy) as String as AnyObject , forKey: "HTTPProxy")
//        proxyConfiguration.updateValue(Int(portProxy) as AnyObject , forKey: "HTTPPort")
//        proxyConfiguration.updateValue(1 as AnyObject , forKey: "HTTPSEnable")
//        proxyConfiguration.updateValue(String(urlProxy) as String as AnyObject , forKey: "HTTPSProxy")
//        proxyConfiguration.updateValue(Int(portProxy) as AnyObject , forKey: "HTTPSPort")
//
//        configuration.connectionProxyDictionary = proxyConfiguration
//
//        requestManager = Alamofire.SessionManager(configuration: configuration)
//    }
//}
//
//enum Result<T> {
//    case Success(T)
//    case Error(Int)
//}
//
//enum MethodHttp: String{
//    case post = "POST"
//    case get = "GET"
//    case put = "PUT"
//    case delete = "DELETE"
//}
//
