////
////  DatabaseAPI.swift
////  klask
////
////  Created by Joel Whitney on 1/9/18.
////  Copyright © 2018 JoelWhitney. All rights reserved.
////
//
//import UIKit
//
//typealias ServiceResponse = (Data?, NSError?) -> Void
//
//class DatabaseAPI: NSObject {
//    static let sharedInstance = DatabaseAPI()
//    let api_key = ""
//    let baseURL = "http://fryesleap.esri.com:3000/"
//    
//    // MARK: - GET methods
//    func getDatabase(onCompletion: @escaping (Data?) -> Void) {
//        let resource = "db"
//        makeHTTPGetRequest(url: baseURL + resource, onCompletion: { data, err in
//            onCompletion(data as Data?)
//        })
//    }
//    
//    // MARK: - POST methods
//    func addNewGame(game: Game, onCompletion: @escaping (Data, NSError?) -> Void) {
//        let resource = "current_games"
//        do {
//            let encoder = JSONEncoder()
//            let gameData = try encoder.encode(game)
//            makeHTTPPostRequest(url: baseURL + resource, postBody: gameData, onCompletion: { data, err in
//                onCompletion(data as! Data, err as NSError?)
//            })
//        } catch {
//            print(error)
//        }
//    }
//    
//    // MARK: - DELETE methods
//    func deleteGame(game: Game, onCompletion: @escaping (Data, NSError?) -> Void) {
//        let resource = "current_games/"
//        makeHTTPDeleteRequest(url: baseURL + resource, onCompletion: { data, err in
//            onCompletion(data as! Data, err as NSError?)
//        })
//    }
//    
//    // MARK: - PUT methods
//    func updateNickname(employee: KlaskUser, onCompletion: @escaping (Data, NSError?) -> Void) {
//        let resource = "employees/"
//        do {
//            let encoder = JSONEncoder()
//            let employeeData = try encoder.encode(employee)
//            makeHTTPPutRequest(url: baseURL + resource, putBody: employeeData, onCompletion: { data, err in
//                onCompletion(data as! Data, err as NSError?)
//            })
//        } catch {
//            print(error)
//        }
//    }
//    
//    // MARK: - GET REQUEST
//    private func makeHTTPGetRequest(url: String, parameters: [[String: String]]? = nil, onCompletion: @escaping ServiceResponse) {
//        var urlComponents = URLComponents(string: url)!
//        urlComponents.queryItems = []
//        if let parameters = parameters {
//            for parameter in parameters {
//                urlComponents.queryItems?.append(URLQueryItem(name: parameter["name"]!, value: parameter["value"]!))
//            }
//        }
//        let requestURL = urlComponents.url
//        var request = URLRequest(url: requestURL!)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        print("       API request: " + (request.url?.absoluteString)!)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
//            if let data = data {
//                onCompletion(data, error as NSError?)
//            } else {
//                onCompletion(nil, error as NSError?)
//            }
//        })
//        task.resume()
//    }
//    
//    // MARK: - DELETE REQUEST
//    private func makeHTTPDeleteRequest(url: String, onCompletion: @escaping ServiceResponse) {
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "DELETE"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        print("       API request: " + (request.url?.absoluteString)!)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
//            if let data = data {
//                onCompletion(data, error as NSError?)
//            } else {
//                onCompletion(data as Data?, error as NSError?)
//            }
//        })
//        task.resume()
//    }
//    
//    // MARK: - POST REQUEST
//    private func makeHTTPPostRequest(url: String, postBody: Data, onCompletion: @escaping ServiceResponse) {
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = postBody
//        print("       API request: " + (request.url?.absoluteString)!)
//        print(request.httpBody?.description)
//        let session = URLSession.shared
//        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
//            if let data = data {
//                onCompletion(data, error as NSError?)
//            } else {
//                onCompletion(data as Data?, error as NSError?)
//            }
//        })
//        task.resume()
//    }
//}
//
//// MARK: - PUT REQUEST
//private func makeHTTPPutRequest(url: String, putBody: Data, onCompletion: @escaping ServiceResponse) {
//    var request = URLRequest(url: URL(string: url)!)
//    request.httpMethod = "PUT"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.httpBody = putBody
//    print("       API request: " + (request.url?.absoluteString)!)
//    print(request.httpBody?.description)
//    let session = URLSession.shared
//    let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
//        if let data = data {
//            onCompletion(data, error as NSError?)
//        } else {
//            onCompletion(data as Data?, error as NSError?)
//        }
//    })
//    task.resume()
//}

