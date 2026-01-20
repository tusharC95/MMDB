//
//  MovieListReducerTests.swift
//  MMDBTests
//
//  Unit tests for MovieListReducer - TCA pattern testing
//  Created by Tushar Chitnavis on 18/11/25.
//

import XCTest
@testable import MovieFeature

final class MovieListReducerTests: XCTestCase {
    
    var mockService: MockMovieService!
    var reducer: MovieListReducer!
    
    override func setUp() {
        super.setUp()
        mockService = MockMovieService()
        reducer = MovieListReducer(movieService: mockService)
    }
    
    override func tearDown() {
        mockService = nil
        reducer = nil
        super.tearDown()
    }
    
    // MARK: - Load Movies Tests
    
    func testLoadMovies_SetsLoadingState() {
        // Given
        var state = MovieListState()
        
        // When
        _ = reducer.reduce(state: &state, action: .loadMovies)
        
        // Then
        XCTAssertTrue(state.isLoading, "Loading state should be true when loading movies")
        XCTAssertNil(state.error, "Error should be nil when starting to load")
        XCTAssertEqual(state.currentPage, 1, "Should reset to page 1")
        XCTAssertTrue(state.movies.isEmpty, "Should clear movies when reloading")
    }
    
    func testLoadMovies_ReturnsEffect() {
        // Given
        var state = MovieListState()
        
        // When
        _ = reducer.reduce(state: &state, action: .loadMovies)
        
        // Then - Effect should trigger async operation
        // In production, we'd test the effect execution
        // For now, verify state was updated correctly
        XCTAssertTrue(state.isLoading, "Should set loading state when effect is created")
    }
    
    // MARK: - Movies Loaded Tests
    
    func testMoviesLoaded_UpdatesStateCorrectly() {
        // Given
        var state = MovieListState()
        state.isLoading = true
        let mockMovies = createMockMovies(count: 20)
        
        // When
        _ = reducer.reduce(state: &state, action: .moviesLoaded(mockMovies, totalPages: 5))
        
        // Then
        XCTAssertFalse(state.isLoading, "Loading should be false after movies loaded")
        XCTAssertEqual(state.movies.count, 20, "Should have 20 movies")
        XCTAssertEqual(state.currentPage, 2, "Should increment page to 2")
        XCTAssertTrue(state.hasMorePages, "Should have more pages when current < total")
    }
    
    func testMoviesLoaded_AppendsToExistingMovies() {
        // Given
        var state = MovieListState()
        state.movies = createMockMovies(count: 20)
        state.currentPage = 2
        let newMovies = createMockMovies(count: 20, startId: 21)
        
        // When
        _ = reducer.reduce(state: &state, action: .moviesLoaded(newMovies, totalPages: 5))
        
        // Then
        XCTAssertEqual(state.movies.count, 40, "Should append new movies to existing")
        XCTAssertEqual(state.currentPage, 3, "Should increment page to 3")
    }
    
    func testMoviesLoaded_SetsHasMorePagesCorrectly() {
        // Given
        var state = MovieListState()
        state.currentPage = 4
        let mockMovies = createMockMovies(count: 20)
        
        // When
        _ = reducer.reduce(state: &state, action: .moviesLoaded(mockMovies, totalPages: 5))
        
        // Then
        XCTAssertTrue(state.hasMorePages, "Should have more pages when 5 <= 5")
        
        // When on last page
        _ = reducer.reduce(state: &state, action: .moviesLoaded(mockMovies, totalPages: 5))
        
        // Then
        XCTAssertFalse(state.hasMorePages, "Should not have more pages when current > total")
    }
    
    // MARK: - Movies Failed Tests
    
    func testMoviesFailed_SetsErrorState() {
        // Given
        var state = MovieListState()
        state.isLoading = true
        let errorMessage = "Network connection failed"
        
        // When
        _ = reducer.reduce(state: &state, action: .moviesFailed(errorMessage))
        
        // Then
        XCTAssertFalse(state.isLoading, "Loading should be false after failure")
        XCTAssertEqual(state.error, errorMessage, "Should set error message")
    }
    
    func testMoviesFailed_PreservesExistingMovies() {
        // Given
        var state = MovieListState()
        state.movies = createMockMovies(count: 20)
        
        // When
        _ = reducer.reduce(state: &state, action: .moviesFailed("Error"))
        
        // Then
        XCTAssertEqual(state.movies.count, 20, "Should preserve existing movies on error")
    }
    
    // MARK: - Search Tests
    
    func testSearchQueryChanged_UpdatesQuery() {
        // Given
        var state = MovieListState()
        let query = "Avengers"
        
        // When
        _ = reducer.reduce(state: &state, action: .searchQueryChanged(query))
        
        // Then
        XCTAssertEqual(state.searchQuery, query, "Should update search query")
    }
    
    func testSearchMovies_SetsSearchingState() {
        // Given
        var state = MovieListState()
        state.searchQuery = "Avengers"
        
        // When
        _ = reducer.reduce(state: &state, action: .searchMovies)
        
        // Then
        XCTAssertTrue(state.isSearching, "Should set searching state")
        XCTAssertTrue(state.isLoading, "Should set loading state")
        XCTAssertEqual(state.currentPage, 1, "Should reset to page 1")
        XCTAssertTrue(state.movies.isEmpty, "Should clear movies when searching")
    }
    
    func testSearchMovies_WithEmptyQuery_ReturnsNone() {
        // Given
        var state = MovieListState()
        state.searchQuery = ""
        
        // When
        _ = reducer.reduce(state: &state, action: .searchMovies)
        
        // Then - Should not trigger search with empty query
        XCTAssertFalse(state.isLoading, "Should not start loading with empty query")
    }
    
    func testClearSearch_ResetsSearchState() {
        // Given
        var state = MovieListState()
        state.searchQuery = "Avengers"
        state.isSearching = true
        state.movies = createMockMovies(count: 10)
        
        // When
        _ = reducer.reduce(state: &state, action: .clearSearch)
        
        // Then
        XCTAssertEqual(state.searchQuery, "", "Should clear search query")
        XCTAssertFalse(state.isSearching, "Should clear searching state")
        XCTAssertTrue(state.movies.isEmpty, "Should clear movies")
        XCTAssertEqual(state.currentPage, 1, "Should reset to page 1")
    }
    
    // MARK: - Load More Tests
    
    func testLoadMoreMovies_WhileLoading_ReturnsNone() {
        // Given
        var state = MovieListState()
        state.isLoading = true
        
        // When
        _ = reducer.reduce(state: &state, action: .loadMoreMovies)
        
        // Then - Should not load more while already loading
        // Effect should be none (in real implementation)
    }
    
    func testLoadMoreMovies_WithNoMorePages_ReturnsNone() {
        // Given
        var state = MovieListState()
        state.hasMorePages = false
        
        // When
        _ = reducer.reduce(state: &state, action: .loadMoreMovies)
        
        // Then - Should not load more when no more pages
        XCTAssertFalse(state.isLoading, "Should not start loading when no more pages")
    }
    
    func testLoadMoreMovies_WithMorePages_SetsLoadingState() {
        // Given
        var state = MovieListState()
        state.hasMorePages = true
        state.isLoading = false
        state.currentPage = 1
        
        // When
        _ = reducer.reduce(state: &state, action: .loadMoreMovies)
        
        // Then
        XCTAssertTrue(state.isLoading, "Should set loading state")
    }
    
    // MARK: - Integration Tests
    
    func testCompleteFlow_LoadAndLoadMore() {
        // Given
        var state = MovieListState()
        
        // When - Initial load
        _ = reducer.reduce(state: &state, action: .loadMovies)
        XCTAssertTrue(state.isLoading)
        
        // Simulate successful load
        let firstBatch = createMockMovies(count: 20)
        _ = reducer.reduce(state: &state, action: .moviesLoaded(firstBatch, totalPages: 3))
        
        // Then
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.movies.count, 20)
        XCTAssertEqual(state.currentPage, 2)
        XCTAssertTrue(state.hasMorePages)
        
        // When - Load more
        _ = reducer.reduce(state: &state, action: .loadMoreMovies)
        XCTAssertTrue(state.isLoading)
        
        // Simulate second batch
        let secondBatch = createMockMovies(count: 20, startId: 21)
        _ = reducer.reduce(state: &state, action: .moviesLoaded(secondBatch, totalPages: 3))
        
        // Then
        XCTAssertEqual(state.movies.count, 40)
        XCTAssertEqual(state.currentPage, 3)
    }
    
    func testCompleteFlow_SearchAndClear() {
        // Given
        var state = MovieListState()
        state.movies = createMockMovies(count: 20)
        
        // When - Start search
        _ = reducer.reduce(state: &state, action: .searchQueryChanged("Avengers"))
        _ = reducer.reduce(state: &state, action: .searchMovies)
        
        // Then
        XCTAssertTrue(state.isSearching)
        XCTAssertTrue(state.movies.isEmpty, "Should clear movies when searching")
        
        // When - Search results come back
        let searchResults = createMockMovies(count: 5)
        _ = reducer.reduce(state: &state, action: .moviesLoaded(searchResults, totalPages: 1))
        
        // Then
        XCTAssertEqual(state.movies.count, 5)
        
        // When - Clear search
        _ = reducer.reduce(state: &state, action: .clearSearch)
        
        // Then
        XCTAssertFalse(state.isSearching)
        XCTAssertTrue(state.movies.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testMoviesLoaded_WithEmptyResults() {
        // Given
        var state = MovieListState()
        
        // When
        _ = reducer.reduce(state: &state, action: .moviesLoaded([], totalPages: 0))
        
        // Then
        XCTAssertTrue(state.movies.isEmpty, "Should handle empty results")
        XCTAssertFalse(state.hasMorePages, "Should have no more pages with 0 total")
    }
    
    func testMoviesFailed_WithEmptyMessage() {
        // Given
        var state = MovieListState()
        
        // When
        _ = reducer.reduce(state: &state, action: .moviesFailed(""))
        
        // Then
        XCTAssertEqual(state.error, "", "Should handle empty error message")
    }
    
    // MARK: - Helper Methods
    
    private func createMockMovies(count: Int, startId: Int = 1) -> [MovieFeature.Movie] {
        return (startId..<startId + count).map { id in
            MovieFeature.Movie(
                id: id,
                title: "Test Movie \(id)",
                overview: "Test overview for movie \(id)",
                posterPath: "/test\(id).jpg",
                backdropPath: "/backdrop\(id).jpg",
                releaseDate: "2024-01-01",
                voteAverage: 7.5,
                voteCount: 1000,
                popularity: 100.0
            )
        }
    }
}

// MARK: - Mock Movie Service

class MockMovieService: MovieServiceProtocol {
    var mockMovies: [MovieFeature.Movie] = []
    var mockError: Error?
    var shouldFail = false
    
    func fetchMoviesByPerson(personId: Int, page: Int) async throws -> MoviesResponse {
        if shouldFail, let error = mockError {
            throw error
        }
        
        return MoviesResponse(
            page: page,
            results: mockMovies,
            totalPages: 5,
            totalResults: 100
        )
    }
    
    func searchMovies(query: String, page: Int) async throws -> MoviesResponse {
        if shouldFail, let error = mockError {
            throw error
        }
        
        return MoviesResponse(
            page: page,
            results: mockMovies.filter { $0.title.contains(query) },
            totalPages: 1,
            totalResults: mockMovies.count
        )
    }
    
    func searchPerson(query: String) async throws -> PersonSearchResponse {
        if shouldFail, let error = mockError {
            throw error
        }
        
        return PersonSearchResponse(
            page: 1,
            results: [],
            totalPages: 1,
            totalResults: 0
        )
    }
    
    func fetchSimilarMovies(movieId: Int, page: Int) async throws -> MoviesResponse {
        if shouldFail, let error = mockError {
            throw error
        }
        
        return MoviesResponse(
            page: page,
            results: mockMovies,
            totalPages: 1,
            totalResults: mockMovies.count
        )
    }
}

