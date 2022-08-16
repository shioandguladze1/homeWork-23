//
//  NetworkManager.swift
//  HomeWork23 (shio andghuladze)
//
//  Created by shio andghuladze on 16.08.22.
//

import Foundation
import UIKit


let apiKey = "4d3ec680a0d9e9167e276f5571bae754"
let imagePath = "https://image.tmdb.org/t/p/w500/"
let baseUrl = "https://api.themoviedb.org/3"
let tvShowsPath = "/tv/top_rated"
let tvShowDetailsPath = "/tv/" // need to add id
let similarShowsPath = "/similar" // should be followed with tvShowDetailsPath
let createGuestSessionPath = "/authentication/guest_session/new"
let apiKeyQueryItem = URLQueryItem(name: "api_key", value: apiKey)

class NetworkManager{
    private let config = URLSessionConfiguration.default
    private let session: URLSession
    private let decoder = JSONDecoder()
    static let shared = NetworkManager()
    
    init() {
        session = URLSession(configuration: self.config)
    }

    func fetchData<T: Decodable>(url: String, dataType: T.Type, queryItems: [URLQueryItem] = [apiKeyQueryItem], onResult: @escaping (Result)-> Void){
        
        guard var components = URLComponents(string: url) else {
            onResult(ErrorResult(errorMessage: "Invalid url \(url)"))
            return
        }
        
        components.queryItems = queryItems
        
        guard let componentsUrl = components.url else {
            onResult(ErrorResult(errorMessage: "Invalid url \(String(describing: components.url?.absoluteString))"))
            return
        }
        
        session.dataTask(with: URLRequest(url: componentsUrl)) { data, response, error in

            return self.generateResult(dataType: dataType, data: data, error: error, onResult: onResult)
            
        }.resume()
        
    }

    func getImage(imageUrl: String, onResult: @escaping (Result)-> Void){
        
        guard let url = URL(string: imageUrl) else {
            onResult(ErrorResult(errorMessage: "invalid url \(imageUrl)"))
            return
        }
        
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                onResult(ErrorResult(errorMessage: error.localizedDescription))
                return
            }
            
            guard let data = data else {
                onResult(ErrorResult(errorMessage: "Invalid data \(String(describing: data))"))
                return
            }
            
            if let image = UIImage(data: data) {
                onResult(SuccessResult(data: image))
                return
            }
            
            onResult(ErrorResult(errorMessage: "Unknown Error"))
            
        }.resume()
        
    }

    func generateResult<T: Decodable>(dataType: T.Type, data: Data?, error: Error?, onResult: (Result)-> Void){
        
        if let e = error {
            let result = ErrorResult(errorMessage: e.localizedDescription)
            onResult(result)
            return
        }
        
        if let d = data {
            guard let decodedData = try? decoder.decode(dataType, from: d) else {
                print(dataType)
                let result = ErrorResult(errorMessage: "Could not parse data)" + d.toString())
                onResult(result)
                return
            }
            let result = SuccessResult(data: decodedData)
            onResult(result)
            return
        }
        
        let result = ErrorResult(errorMessage: "Unknown error")
        onResult(result)
        
    }

    struct SuccessResult<T>: Result{
        let data: T
    }

    struct ErrorResult: Result{
        let errorMessage: String
    }

    
}

func parseResult<T>(result: Result, onError: (String)-> Void = { print($0) }, onSuccess: (T)-> Void){
    
    if let successResult = result as? NetworkManager.SuccessResult<T> {
        onSuccess(successResult.data)
        return
    }
    
    if let errorResult = result as? NetworkManager.ErrorResult {
        onError(errorResult.errorMessage)
    }
    
}


protocol Result { }

extension Data{
    
    func toString()-> String{
        
        return String(data: self, encoding: .utf8) ?? ""
        
    }
    
}
