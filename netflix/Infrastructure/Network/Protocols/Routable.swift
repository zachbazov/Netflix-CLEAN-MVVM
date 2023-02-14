//
//  Routable.swift
//  netflix
//
//  Created by Zach Bazov on 14/02/2023.
//

import Foundation

protocol Routable {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable?
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable?
    
    func request<T>(for response: T.Type,
                    request: SeasonHTTPDTO.Request,
                    completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable?
    func request(requestDTO: SearchHTTPDTO.Request,
                 cached: @escaping ([Media]) -> Void,
                 completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable?
    func request(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable?
}

extension Routable {
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, DataTransferError>) -> Void)?) -> Cancellable? {return nil}
    func request<T, U>(for response: T.Type,
                       request: U?,
                       cached: ((T?) -> Void)?,
                       completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {return nil}
    
    func request<T>(for response: T.Type,
                    request: SeasonHTTPDTO.Request,
                    completion: @escaping (Result<SeasonHTTPDTO.Response, Error>) -> Void) -> Cancellable? {return nil}
    func request(requestDTO: SearchHTTPDTO.Request,
                 cached: @escaping ([Media]) -> Void,
                 completion: @escaping (Result<[Media], Error>) -> Void) -> Cancellable? {return nil}
    func request(completion: @escaping (Result<NewsHTTPDTO.Response, Error>) -> Void) -> Cancellable? {return nil}
}
