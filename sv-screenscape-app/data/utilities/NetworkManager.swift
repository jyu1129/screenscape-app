//
//  NetworkManager.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import Alamofire
import RxSwift

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    /// Sends a GET request to the specified URL with optional headers and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - url: The URL to which the GET request will be sent.
    ///   - headers: Optional headers to be included in the request.
    ///   - responseType: The type into which the response data will be decoded.
    /// - Returns: An observable sequence emitting a single element of the decoded response type.
    func responseDecodable<T: Decodable>(url: URL, headers: HTTPHeaders? = nil, responseType: T.Type) -> Observable<T> {
        return Observable.create { observer in
            AF.request(url, headers: headers).responseDecodable(of: T.self) { response in
                switch response.result {
                case let .success(value):
                    observer.onNext(value)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }



    /// Sends a POST request to the specified URL with the given parameters and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - url: The URL to which the POST request will be sent.
    ///   - parameters: The parameters to be included in the POST request.
    ///   - responseType: The type into which the response data will be decoded.
    /// - Returns: An observable sequence emitting a single element of the decoded response type.
    func postData<T: Decodable>(url: URL, parameters: [String: Any], responseType: T.Type) -> Observable<T> {
        return Observable.create { observer in
            AF.request(url, method: .post, parameters: parameters).responseDecodable(of: T.self) { response in
                switch response.result {
                case let .success(value):
                    observer.onNext(value)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
