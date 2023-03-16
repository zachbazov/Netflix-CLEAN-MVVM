//
//  APIEndpoint.swift
//  netflix
//
//  Created by Zach Bazov on 01/09/2022.
//

import Foundation

// MARK: - APIEndpoint Type

struct APIEndpoint {}

// MARK: - AuthRepositoryEndpoints Implementation

extension APIEndpoint: AuthRepositoryEndpoints {
    static func signUp(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response> {
        return Endpoint(path: "api/v1/users/signup",
                        method: .post,
                        headerParameters: ["content-type": "application/json"],
                        bodyParameters: ["name": request.user.name ?? "Undefined",
                                         "email": request.user.email!,
                                         "password": request.user.password!,
                                         "passwordConfirm": request.user.passwordConfirm!],
                        bodyEncoding: .jsonSerializationData)
    }
    
    static func signIn(with request: UserHTTPDTO.Request) -> Endpoint<UserHTTPDTO.Response> {
        return Endpoint(path: "api/v1/users/signin",
                        method: .post,
                        headerParameters: ["content-type": "application/json"],
                        bodyParameters: ["email": request.user.email!,
                                         "password": request.user.password!],
                        bodyEncoding: .jsonSerializationData)
    }
    
    static func signOut(with request: UserHTTPDTO.Request) -> Endpoint<Void>? {
        let authService = Application.app.services.authentication
        guard authService.user?._id == request.user._id else { return nil }
        return Endpoint(path: "api/v1/users/signout",
                        method: .get,
                        headerParameters: ["content-type": "application/json"])
    }
    
    
    
    
    
    static func getMyUserProfiles(with request: UserProfileHTTPDTO.GET.Request) -> Endpoint<UserProfileHTTPDTO.GET.Response> {
        return Endpoint(path: "api/v1/users/profiles",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["user": request.user._id ?? ""])
    }
    
    static func createUserProfile(with request: UserProfileHTTPDTO.POST.Request) -> Endpoint<UserProfileHTTPDTO.POST.Response> {
        return Endpoint(path: "api/v1/users/profiles",
                        method: .post,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["user": request.user._id ?? ""],
                        bodyParameters: ["name": request.profile.name])
    }
}

// MARK: - SectionsRepositoryEndpoints Implementation

extension APIEndpoint: SectionsRepositoryEndpoints {
    static func getAllSections() -> Endpoint<SectionHTTPDTO.Response> {
        return Endpoint(path: "api/v1/sections",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["sort": "id"])
    }
}

// MARK: - MediaRepositoryEndpoints Implementation

extension APIEndpoint: MediaRepositoryEndpoints {
    static func getAllMedia() -> Endpoint<MediaHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"])
    }
    
    static func getMedia(with request: MediaHTTPDTO.Request) -> Endpoint<MediaHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: request.slug != nil ? ["slug": request.slug ?? ""] : ["id": request.id ?? ""])
    }
    
    static func getUpcomingMedia(with request: NewsHTTPDTO.Request) -> Endpoint<NewsHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: request.queryParams)
    }
    
    static func getTopSearchedMedia() -> Endpoint<SearchHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["timesSearched": 1, "limit": 20])
    }
    
    static func searchMedia(with request: SearchHTTPDTO.Request) -> Endpoint<SearchHTTPDTO.Response> {
        return Endpoint(path: "api/v1/media/search",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["slug": request.regex, "title": request.regex])
    }
}

// MARK: - SeasonRepositoryEndpoints Implementation

extension APIEndpoint: SeasonRepositoryEndpoints {
    static func getSeason(with request: SeasonHTTPDTO.Request) -> Endpoint<SeasonHTTPDTO.Response> {
        return Endpoint(path: "api/v1/seasons",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["slug": request.slug ?? "", "season": request.season ?? 1])
    }
}

// MARK: - ListRepositoryEndpoints Implementation

extension APIEndpoint: ListRepositoryEndpoints {
    static func getMyList(with request: ListHTTPDTO.GET.Request) -> Endpoint<ListHTTPDTO.GET.Response> {
        return Endpoint(path: "api/v1/mylists",
                        method: .get,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["user": request.user._id ?? ""])
    }
    
    static func updateMyList(with request: ListHTTPDTO.PATCH.Request) -> Endpoint<ListHTTPDTO.PATCH.Response> {
        return Endpoint(path: "api/v1/mylists",
                        method: .patch,
                        headerParameters: ["content-type": "application/json"],
                        queryParameters: ["user": request.user],
                        bodyParameters: ["user": request.user,
                                         "media": request.media],
                        bodyEncoding: .jsonSerializationData)
    }
}
