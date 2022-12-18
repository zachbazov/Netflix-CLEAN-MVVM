//
//  SearchViewModel.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import Foundation

struct MediaPage: Equatable {
    let page: Int
    let totalPages: Int
    let media: [Media]
}

struct MediaQuery: Equatable {
    let query: String
}




enum SVMLoading {
    case fullscreen
    case nextPage
}

struct SearchMediaUseCaseRequestValue {
    let query: MediaQuery
    let page: Int
}
protocol SearchMediaUseCase {
    func execute(requestValue: SearchMediaUseCaseRequestValue,
                 cached: @escaping (MediaPage) -> Void,
                 completion: @escaping (Result<MediaPage, Error>) -> Void) -> Cancellable?
}
final class DefaultSearchMediaUseCase: SearchMediaUseCase {
    private let mediaRepository: MediaRepository
    
    init(mediaRepository: MediaRepository) {
        self.mediaRepository = mediaRepository
    }
    
    func execute(
        requestValue: SearchMediaUseCaseRequestValue,
        cached: @escaping (MediaPage) -> Void,
        completion: @escaping (Result<MediaPage, Error>) -> Void) -> Cancellable? {
            return fetchMediaList(query: requestValue.query, page: requestValue.page) { mediaPage in
                print("cached", mediaPage)
            } completion: { result in
                if case let .success(mediaPage) = result {
                    completion(.success(mediaPage))
                }
            }
        }
    
    func fetchMediaList(
        query: MediaQuery,
        page: Int,
        cached: @escaping (MediaPage) -> Void,
        completion: @escaping (Result<MediaPage, Error>) -> Void) -> Cancellable? {
            let requestDTO = SearchMediaRequestDTO(slug: query.query, page: nil) //, page: page
            let task = RepositoryTask()
            
            guard !task.isCancelled else { return nil }
            
            let endpoint = getMedia(with: requestDTO)
            task.networkTask = Application.current.dataTransferService.request(with: endpoint, completion: { result in
                if case let .success(responseDTO) = result {
                    completion(.success(MediaPage(page: 0, totalPages: 1, media: responseDTO.data.map { $0.toDomain() } )))
                } else if case let .failure(error) = result {
                    completion(.failure(error))
                }
            })
            
            return task
        }
    
    func getMedia(with mediaRequestDTO: SearchMediaRequestDTO) -> Endpoint<SearchMediaResponseDTO> {
        return Endpoint(path: "api/v1/media",
                        method: .get,
                        queryParametersEncodable: mediaRequestDTO)
    }
}
struct SearchMediaRequestDTO: Encodable {
    let slug: String
    let page: Int?
}
struct SearchMediaResponseDTO: Decodable {
    let status: String
    let data: [MediaDTO]
}

final class SearchViewModel: ViewModel {
    var coordinator: SearchViewCoordinator?
    
    var useCase: DefaultSearchMediaUseCase
    
    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    
    var pages: [MediaPage] = []
    var mediaLoadTask: Cancellable? {
        willSet { mediaLoadTask?.cancel() }
    }
    
    let items: Observable<[MediaListItemViewModel]> = Observable([])
    let loading: Observable<SVMLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    
    init() {
        let dataTransferService = Application.current.dataTransferService
        let mediaResponseCache = Application.current.mediaResponseCache
        let mediaRepository = MediaRepository(dataTransferService: dataTransferService, cache: mediaResponseCache)
        self.useCase = DefaultSearchMediaUseCase(mediaRepository: mediaRepository)
    }
    
    func transform(input: Void) {}
}

extension SearchViewModel {
    private func appendPage(_ mediaPage: MediaPage) {
        currentPage = mediaPage.page
        totalPageCount = mediaPage.totalPages
        
        pages = pages.filter { $0.page != mediaPage.page } + [mediaPage]
        
        items.value = pages.media.map(MediaListItemViewModel.init)
        print(123, items.value.first!)
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func load(mediaQuery: MediaQuery, loading: SVMLoading) {
        self.loading.value = loading
        query.value = mediaQuery.query
        
        mediaLoadTask = useCase.execute(requestValue: .init(query: mediaQuery, page: nextPage), cached: appendPage, completion: { result in
            if case let .success(page) = result {
                print(1, page)
                self.appendPage(page)
            } else if case let .failure(error) = result {
                print(0, error)
            }
            self.loading.value = .none
        })
    }
    
    private func update(mediaQuery: MediaQuery) {
        resetPages()
        load(mediaQuery: mediaQuery, loading: .fullscreen)
    }
}
extension SearchViewModel {
    func viewDidLoad() {
        
    }
    
    func didLoadNextPage() {
        guard hasMorePages, loading.value == .none else { return }
        load(mediaQuery: .init(query: query.value), loading: .nextPage)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(mediaQuery: MediaQuery(query: query))
    }
    
    func didCancelSearch() {
        mediaLoadTask?.cancel()
    }
    
    func didSelectItem(at index: Int) {
        
    }
}

private extension Array where Element == MediaPage {
    var media: [Media] { flatMap { $0.media } }
}



import UIKit

final class MediaListItemCell: UICollectionViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var posterImageView: UIImageView!
    
    var viewModel: MediaListItemViewModel!
    var task: Cancellable? {
        willSet { task?.cancel() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("fromnib")
    }
    
    func fill(with viewModel: MediaListItemViewModel) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        titleLabel.textColor = .white
    }
    
    private func updatePosterImage(width: Int) {
        posterImageView.image = nil
        guard let posterImagePath = viewModel.posterImagePath else { return }
        
        task = fetchImage(with: posterImagePath, width: width, completion: { [weak self] result in
            guard let self = self else { return }
            guard self.viewModel.posterImagePath == posterImagePath else { return }
            if case let .success(data) = result {
                print("im", data)
                let image = UIImage(data: data)
                self.posterImageView.image = image
                print("im", image)
            }
            self.task = nil
        })
    }
    
    func fetchImage(with imagePath: String, width: Int, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        let endpoint = getMediaPoster(path: imagePath, width: width)
        let task = RepositoryTask()
        task.networkTask = Application.current.dataTransferService.request(with: endpoint, completion: { (result: Result<Data, DataTransferError>) in
            let result = result.mapError { $0 as Error }
            DispatchQueue.main.async { completion(result) }
        })
        return task
    }
    
    func getMediaPoster(path: String, width: Int) -> Endpoint<Data> {
        let sizes = [92, 154, 185, 342, 500, 780]
        let closestWidth = sizes.enumerated().min {
            abs($0.1 - width) < abs($1.1 - width) }?.element ?? sizes.first!
        
        return Endpoint(path: "t/p/w\(closestWidth)\(path)",
                        method: .get,
                        responseDecoder: RawDataResponseDecoder())
    }
}

struct MediaListItemViewModel: Equatable {
    let title: String
    let posterImagePath: String?
}
extension MediaListItemViewModel {
    init(with media: Media) {
        self.title = media.title
        self.posterImagePath = media.resources.posters.first
    }
}

public class RawDataResponseDecoder: ResponseDecoder {
    public init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
