//
//  MovieModelTests.swift
//  MMDBTests
//
//  Unit tests for Movie model - Codable, formatting, and computed properties
//  Created by Tushar Chitnavis on 18/11/25.
//

import XCTest
@testable import Core

final class MovieModelTests: XCTestCase {
    
    // MARK: - Codable Tests
    
    func testMovieDecoding_WithValidJSON_Succeeds() throws {
        // Given
        let json = """
        {
            "id": 550,
            "title": "Fight Club",
            "overview": "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression.",
            "poster_path": "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            "backdrop_path": "/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg",
            "release_date": "1999-10-15",
            "vote_average": 8.4,
            "vote_count": 26000,
            "popularity": 61.416
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let movie = try JSONDecoder().decode(Movie.self, from: data)
        
        // Then
        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.title, "Fight Club")
        XCTAssertEqual(movie.overview, "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression.")
        XCTAssertEqual(movie.posterPath, "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
        XCTAssertEqual(movie.backdropPath, "/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg")
        XCTAssertEqual(movie.releaseDate, "1999-10-15")
        XCTAssertEqual(movie.voteAverage, 8.4, accuracy: 0.01)
        XCTAssertEqual(movie.voteCount, 26000)
        XCTAssertEqual(movie.popularity, 61.416, accuracy: 0.001)
    }
    
    func testMovieDecoding_WithMissingPosterPath_Succeeds() throws {
        // Given
        let json = """
        {
            "id": 550,
            "title": "Fight Club",
            "overview": "Test overview",
            "poster_path": null,
            "backdrop_path": null,
            "release_date": "1999-10-15",
            "vote_average": 8.4,
            "vote_count": 26000,
            "popularity": 61.416
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let movie = try JSONDecoder().decode(Movie.self, from: data)
        
        // Then
        XCTAssertNil(movie.posterPath, "Should handle null poster path")
        XCTAssertNil(movie.backdropPath, "Should handle null backdrop path")
    }
    
    func testMovieEncoding_RoundTrip_Succeeds() throws {
        // Given
        let originalMovie = Movie(
            id: 550,
            title: "Fight Club",
            overview: "Test overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            voteCount: 26000,
            popularity: 61.416
        )
        
        // When - Encode and decode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalMovie)
        let decoder = JSONDecoder()
        let decodedMovie = try decoder.decode(Movie.self, from: data)
        
        // Then
        XCTAssertEqual(originalMovie, decodedMovie, "Round trip encoding/decoding should preserve data")
    }
    
    // MARK: - URL Formatting Tests
    
    func testPosterURL_WithValidPath_ReturnsCorrectURL() {
        // Given
        let movie = createMockMovie(posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
        
        // When
        let posterURL = movie.posterURL
        
        // Then
        XCTAssertNotNil(posterURL)
        XCTAssertEqual(posterURL?.absoluteString, "https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
    }
    
    func testPosterURL_WithNilPath_ReturnsNil() {
        // Given
        let movie = createMockMovie(posterPath: nil)
        
        // When
        let posterURL = movie.posterURL
        
        // Then
        XCTAssertNil(posterURL, "Should return nil when poster path is nil")
    }
    
    func testBackdropURL_WithValidPath_ReturnsCorrectURL() {
        // Given
        let movie = createMockMovie(backdropPath: "/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg")
        
        // When
        let backdropURL = movie.backdropURL
        
        // Then
        XCTAssertNotNil(backdropURL)
        XCTAssertEqual(backdropURL?.absoluteString, "https://image.tmdb.org/t/p/w780/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg")
    }
    
    func testBackdropURL_WithNilPath_ReturnsNil() {
        // Given
        let movie = createMockMovie(backdropPath: nil)
        
        // When
        let backdropURL = movie.backdropURL
        
        // Then
        XCTAssertNil(backdropURL, "Should return nil when backdrop path is nil")
    }
    
    // MARK: - Date Formatting Tests
    
    func testFormattedReleaseDate_WithValidDate_ReturnsFormattedString() {
        // Given
        let movie = createMockMovie(releaseDate: "1999-10-15")
        
        // When
        let formatted = movie.formattedReleaseDate
        
        // Then
        XCTAssertEqual(formatted, "Oct 15, 1999")
    }
    
    func testFormattedReleaseDate_WithInvalidDate_ReturnsOriginalString() {
        // Given
        let movie = createMockMovie(releaseDate: "Invalid Date")
        
        // When
        let formatted = movie.formattedReleaseDate
        
        // Then
        XCTAssertEqual(formatted, "Invalid Date", "Should return original string if date parsing fails")
    }
    
    func testFormattedReleaseDate_WithDifferentYear_FormatsCorrectly() {
        // Given
        let movie = createMockMovie(releaseDate: "2024-12-25")
        
        // When
        let formatted = movie.formattedReleaseDate
        
        // Then
        XCTAssertEqual(formatted, "Dec 25, 2024")
    }
    
    // MARK: - Rating Percentage Tests
    
    func testRatingPercentage_ConvertsCorrectly() {
        // Given
        let movie = createMockMovie(voteAverage: 8.5)
        
        // When
        let percentage = movie.ratingPercentage
        
        // Then
        XCTAssertEqual(percentage, 85, "Should convert 8.5 to 85%")
    }
    
    func testRatingPercentage_WithZeroRating_ReturnsZero() {
        // Given
        let movie = createMockMovie(voteAverage: 0.0)
        
        // When
        let percentage = movie.ratingPercentage
        
        // Then
        XCTAssertEqual(percentage, 0)
    }
    
    func testRatingPercentage_WithMaxRating_Returns100() {
        // Given
        let movie = createMockMovie(voteAverage: 10.0)
        
        // When
        let percentage = movie.ratingPercentage
        
        // Then
        XCTAssertEqual(percentage, 100)
    }
    
    func testRatingPercentage_WithDecimalRating_RoundsDown() {
        // Given
        let movie = createMockMovie(voteAverage: 7.89)
        
        // When
        let percentage = movie.ratingPercentage
        
        // Then
        XCTAssertEqual(percentage, 78, "Should round down from 78.9")
    }
    
    // MARK: - Equatable Tests
    
    func testEquality_WithSameValues_ReturnsTrue() {
        // Given
        let movie1 = createMockMovie(id: 1, title: "Test")
        let movie2 = createMockMovie(id: 1, title: "Test")
        
        // Then
        XCTAssertEqual(movie1, movie2)
    }
    
    func testEquality_WithDifferentIds_ReturnsFalse() {
        // Given
        let movie1 = createMockMovie(id: 1, title: "Test")
        let movie2 = createMockMovie(id: 2, title: "Test")
        
        // Then
        XCTAssertNotEqual(movie1, movie2)
    }
    
    func testEquality_WithDifferentTitles_ReturnsFalse() {
        // Given
        let movie1 = createMockMovie(id: 1, title: "Test 1")
        let movie2 = createMockMovie(id: 1, title: "Test 2")
        
        // Then
        XCTAssertNotEqual(movie1, movie2)
    }
    
    // MARK: - Identifiable Tests
    
    func testIdentifiable_UsesIdProperty() {
        // Given
        let movie = createMockMovie(id: 550)
        
        // Then
        XCTAssertEqual(movie.id, 550)
    }
    
    // MARK: - Edge Cases
    
    func testMovie_WithEmptyStrings_HandlesGracefully() {
        // Given
        let movie = Movie(
            id: 1,
            title: "",
            overview: "",
            posterPath: "",
            backdropPath: "",
            releaseDate: "",
            voteAverage: 0,
            voteCount: 0,
            popularity: 0
        )
        
        // Then
        XCTAssertEqual(movie.title, "")
        XCTAssertEqual(movie.overview, "")
        XCTAssertNotNil(movie.posterURL) // Empty string still creates URL
    }
    
    func testMovie_WithVeryLongStrings_HandlesCorrectly() {
        // Given
        let longOverview = String(repeating: "A", count: 10000)
        let movie = createMockMovie(overview: longOverview)
        
        // Then
        XCTAssertEqual(movie.overview.count, 10000)
    }
    
    func testMovie_WithSpecialCharacters_DecodesCorrectly() throws {
        // Given
        let json = """
        {
            "id": 1,
            "title": "Movie with \\"quotes\\" & special <characters>",
            "overview": "Overview with émojis 🎬 and ñ",
            "poster_path": "/test.jpg",
            "backdrop_path": "/test.jpg",
            "release_date": "2024-01-01",
            "vote_average": 7.5,
            "vote_count": 100,
            "popularity": 50.0
        }
        """
        
        // When
        let data = json.data(using: .utf8)!
        let movie = try JSONDecoder().decode(Movie.self, from: data)
        
        // Then
        XCTAssertTrue(movie.title.contains("quotes"))
        XCTAssertTrue(movie.overview.contains("🎬"))
    }
    
    // MARK: - Helper Methods
    
    private func createMockMovie(
        id: Int = 1,
        title: String = "Test Movie",
        overview: String = "Test overview",
        posterPath: String? = "/test.jpg",
        backdropPath: String? = "/backdrop.jpg",
        releaseDate: String = "2024-01-01",
        voteAverage: Double = 7.5,
        voteCount: Int = 1000,
        popularity: Double = 100.0
    ) -> Movie {
        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity
        )
    }
}

