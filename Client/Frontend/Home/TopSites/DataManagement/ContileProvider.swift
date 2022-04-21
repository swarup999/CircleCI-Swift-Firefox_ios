//// This Source Code Form is subject to the terms of the Mozilla Public
//// License, v. 2.0. If a copy of the MPL was not distributed with this
//// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared

typealias ContileResult = Swift.Result<[Contile], Error>

protocol ContileProviderInterface {

    /// Fetch contiles either from cache or backend
    /// - Parameters:
    ///   - timestamp: The timestamp to retrieve from cache, useful for tests. Default is Date.now()
    ///   - completion: Returns an array of Contile, can be empty
    func fetchContiles(timestamp: Timestamp, completion: @escaping (ContileResult) -> Void)
}

extension ContileProviderInterface {
    func fetchContiles(timestamp: Timestamp = Date.now(), completion: @escaping (ContileResult) -> Void) {
        fetchContiles(timestamp: timestamp, completion: completion)
    }
}

/// `Contile` is short for contextual tiles. This provider returns data that is used in Shortcuts (Top Sites) section on the Firefox home page.
class ContileProvider: ContileProviderInterface, Loggable, URLCaching {

    static let contileResourceEndpoint = "https://contile.services.mozilla.com/v1/tiles"

    lazy var urlSession = makeURLSession(userAgent: UserAgent.mobileUserAgent(),
                                         configuration: URLSessionConfiguration.default)

    enum Error: Swift.Error {
        case failure
    }

    func fetchContiles(timestamp: Timestamp = Date.now(), completion: @escaping (ContileResult) -> Void) {
        guard let resourceEndpoint = URL(string: ContileProvider.contileResourceEndpoint) else {
            browserLog.error("The Contile resource URL is invalid: \(ContileProvider.contileResourceEndpoint)")
            completion(.failure(Error.failure))
            return
        }

        let request = URLRequest(url: resourceEndpoint,
                                 cachePolicy: .reloadIgnoringCacheData,
                                 timeoutInterval: 5)

        if let cachedData = findCachedData(for: request, timestamp: timestamp) {
            decode(data: cachedData, completion: completion)
        } else {
            fetchContiles(request: request, completion: completion)
        }
    }

    private func fetchContiles(request: URLRequest, completion: @escaping (ContileResult) -> Void) {
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                self.browserLog.debug("An error occurred while fetching data: \(error)")
                completion(Result.failure(Error.failure))
                return
            }

            guard let response = validatedHTTPResponse(response, statusCode: 200..<300), let data = data else {
                completion(.failure(Error.failure))
                return
            }

            self.cache(response: response, for: request, with: data)
            self.decode(data: data, completion: completion)
        }.resume()
    }

    private func decode(data: Data, completion: @escaping (ContileResult) -> Void) {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let rootNote = try decoder.decode(Contiles.self, from: data)
            var contiles = rootNote.tiles
            contiles.sort { $0.position ?? 0 < $1.position ?? 0 }
            completion(.success(contiles))

        } catch let error {
            self.browserLog.error("Unable to parse with error: \(error)")
            completion(.failure(Error.failure))
        }
    }
}
