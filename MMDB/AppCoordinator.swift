//
//  AppCoordinator.swift
//  MMDB
//
//  Main app coordinator that wires together all dependencies
//  Created by Tushar Chitnavis on 18/11/25.
//

import UIKit
import Core
import Networking
import MovieFeature

final class AppCoordinator: @MainActor Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        setupNavigationBarAppearance()
    }
    
    @MainActor func start() {
        do {
            // Try to load API key from Config.plist
            let apiKey = try Configuration.tmdbAPIKey()
            
            // Setup dependencies
            let networkingAPIClient = NetworkingAPIClient()
            let networkMovieService = NetworkingMovieService(
                apiClient: networkingAPIClient,
                apiKey: apiKey
            )
            
            // Create adapter to bridge networking and feature layers
            let movieService = MovieFeatureServiceAdapter(networkMovieService: networkMovieService)
            
            // Create and start movie coordinator
            let movieCoordinator = MovieFeatureCoordinator(
                navigationController: navigationController,
                movieService: movieService
            )
            
            // Add as child coordinator to manage lifecycle
            addChildCoordinator(movieCoordinator)
            movieCoordinator.start()
            
        } catch let error as Configuration.Error {
            // Show error alert for missing/invalid configuration
            showConfigurationError(error.localizedDescription)
        } catch {
            // Show generic error
            showConfigurationError("An unexpected error occurred while loading configuration.")
        }
    }
    
    @MainActor private func showConfigurationError(_ message: String) {
        let alert = UIAlertController(
            title: "Configuration Required",
            message: "\(message)\n\nSetup Instructions:\n1. Copy Config.plist.template to Config.plist\n2. Add your TMDB API key from themoviedb.org\n3. Rebuild and run the app",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { _ in
            exit(0)
        })
        
        alert.addAction(UIAlertAction(title: "Get API Key", style: .default) { _ in
            if let url = URL(string: "https://www.themoviedb.org/settings/api") {
                UIApplication.shared.open(url) { _ in
                    // Exit after URL opens (or fails to open)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
            } else {
                exit(0)
            }
        })
        
        // Present alert on the window's root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            // Create a temporary view controller to present the alert
            let tempVC = UIViewController()
            tempVC.view.backgroundColor = .systemBackground
            window.rootViewController = tempVC
            window.makeKeyAndVisible()
            
            DispatchQueue.main.async {
                tempVC.present(alert, animated: true)
            }
        }
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .systemBlue
    }
}

// MARK: - Dependency Adapters

/// Adapter to bridge Networking module with MovieFeature module
final class MovieFeatureServiceAdapter: MovieFeatureServiceProtocol {
    private let networkMovieService: NetworkingMovieServiceProtocol
    
    init(networkMovieService: NetworkingMovieServiceProtocol) {
        self.networkMovieService = networkMovieService
    }
    
    func fetchMoviesByPerson(personId: Int, page: Int) async throws -> MovieFeatureMoviesResponse {
        let networkResponse = try await networkMovieService.fetchMoviesByPerson(personId: personId, page: page)
        return MovieFeatureMoviesResponse(
            page: networkResponse.page,
            results: networkResponse.results.map { networkMovie in
                MovieFeatureMovie(
                    id: networkMovie.id,
                    title: networkMovie.title,
                    overview: networkMovie.overview,
                    posterPath: networkMovie.posterPath,
                    backdropPath: networkMovie.backdropPath,
                    releaseDate: networkMovie.releaseDate,
                    voteAverage: networkMovie.voteAverage,
                    voteCount: networkMovie.voteCount,
                    popularity: networkMovie.popularity
                )
            },
            totalPages: networkResponse.totalPages,
            totalResults: networkResponse.totalResults
        )
    }
    
    func searchMovies(query: String, page: Int) async throws -> MovieFeatureMoviesResponse {
        let networkResponse = try await networkMovieService.searchMovies(query: query, page: page)
        return MovieFeatureMoviesResponse(
            page: networkResponse.page,
            results: networkResponse.results.map { networkMovie in
                MovieFeatureMovie(
                    id: networkMovie.id,
                    title: networkMovie.title,
                    overview: networkMovie.overview,
                    posterPath: networkMovie.posterPath,
                    backdropPath: networkMovie.backdropPath,
                    releaseDate: networkMovie.releaseDate,
                    voteAverage: networkMovie.voteAverage,
                    voteCount: networkMovie.voteCount,
                    popularity: networkMovie.popularity
                )
            },
            totalPages: networkResponse.totalPages,
            totalResults: networkResponse.totalResults
        )
    }
    
    func searchPerson(query: String) async throws -> MovieFeaturePersonSearchResponse {
        let networkResponse = try await networkMovieService.searchPerson(query: query)
        return MovieFeaturePersonSearchResponse(
            page: networkResponse.page,
            results: networkResponse.results.map { networkPerson in
                MovieFeatureNetworkPerson(
                    id: networkPerson.id,
                    name: networkPerson.name,
                    knownForDepartment: networkPerson.knownForDepartment
                )
            },
            totalPages: networkResponse.totalPages,
            totalResults: networkResponse.totalResults
        )
    }
    
    func fetchSimilarMovies(movieId: Int, page: Int) async throws -> MovieFeatureMoviesResponse {
        let networkResponse = try await networkMovieService.fetchSimilarMovies(movieId: movieId, page: page)
        return MovieFeatureMoviesResponse(
            page: networkResponse.page,
            results: networkResponse.results.map { networkMovie in
                MovieFeatureMovie(
                    id: networkMovie.id,
                    title: networkMovie.title,
                    overview: networkMovie.overview,
                    posterPath: networkMovie.posterPath,
                    backdropPath: networkMovie.backdropPath,
                    releaseDate: networkMovie.releaseDate,
                    voteAverage: networkMovie.voteAverage,
                    voteCount: networkMovie.voteCount,
                    popularity: networkMovie.popularity
                )
            },
            totalPages: networkResponse.totalPages,
            totalResults: networkResponse.totalResults
        )
    }
}

// MARK: - Type Aliases for Module Imports

// Networking module types
typealias NetworkingAPIClient = Networking.APIClient
typealias NetworkingMovieService = Networking.MovieService
typealias NetworkingMovieServiceProtocol = Networking.MovieServiceProtocol
typealias NetworkingMovie = Networking.Movie
typealias NetworkingMoviesResponse = Networking.MoviesResponse
typealias NetworkingPerson = Networking.Person
typealias NetworkingPersonSearchResponse = Networking.PersonSearchResponse

// MovieFeature module types
typealias MovieFeatureCoordinator = MovieFeature.MovieCoordinator
typealias MovieFeatureServiceProtocol = MovieFeature.MovieServiceProtocol
typealias MovieFeatureMovie = MovieFeature.Movie
typealias MovieFeatureMoviesResponse = MovieFeature.MoviesResponse
typealias MovieFeaturePersonSearchResponse = MovieFeature.PersonSearchResponse
typealias MovieFeatureNetworkPerson = MovieFeature.NetworkPerson

