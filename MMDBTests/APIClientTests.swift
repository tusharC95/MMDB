//
//  APIClientTests.swift
//  MMDBTests
//
//  Unit tests for APIClient - Network layer testing
//  Created by Tushar Chitnavis on 18/11/25.
//

import XCTest
@testable import Networking

final class APIClientTests: XCTestCase {
    
    var mockAPIClient: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
    }
    
    override func tearDown() {
        mockAPIClient = nil
        super.tearDown()
    }
    
    // MARK: - Successful Response Tests
    
    func testRequest_WithValidResponse_ReturnsDecodedData() async throws {
        // Given
        let expectedMovie = TestMovie(id: 1, title: "Test Movie")
        mockAPIClient.mockResult = expectedMovie
        
        let endpoint = TestEndpoint()
        
        // When
        let result: TestMovie = try await mockAPIClient.request(endpoint)
        
        // Then
        XCTAssertEqual(result.id, expectedMovie.id)
        XCTAssertEqual(result.title, expectedMovie.title)
    }
    
    // MARK: - HTTP Error Tests
    
    func testRequest_With404Response_ThrowsHTTPError() async {
        // Given
        mockAPIClient.mockError = NetworkError.httpError(statusCode: 404)
        let endpoint = TestEndpoint()
        
        // When/Then
        do {
            let _: TestMovie = try await mockAPIClient.request(endpoint)
            XCTFail("Should throw HTTP error")
        } catch let error as NetworkError {
            if case .httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRequest_With500Response_ThrowsHTTPError() async {
        // Given
        mockAPIClient.mockError = NetworkError.httpError(statusCode: 500)
        let endpoint = TestEndpoint()
        
        // When/Then
        do {
            let _: TestMovie = try await mockAPIClient.request(endpoint)
            XCTFail("Should throw HTTP error")
        } catch let error as NetworkError {
            if case .httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Decoding Error Tests
    
    func testRequest_WithInvalidJSON_ThrowsDecodingError() async {
        // Given
        let decodingError = NSError(domain: "DecodingError", code: -1)
        mockAPIClient.mockError = NetworkError.decodingError(decodingError)
        let endpoint = TestEndpoint()
        
        // When/Then
        do {
            let _: TestMovie = try await mockAPIClient.request(endpoint)
            XCTFail("Should throw decoding error")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Success - correct error type
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRequest_WithMissingRequiredField_ThrowsDecodingError() async {
        // Given
        let decodingError = NSError(domain: "DecodingError", code: -2)
        mockAPIClient.mockError = NetworkError.decodingError(decodingError)
        let endpoint = TestEndpoint()
        
        // When/Then
        do {
            let _: TestMovie = try await mockAPIClient.request(endpoint)
            XCTFail("Should throw decoding error for missing field")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Success
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Invalid Response Tests
    
    func testRequest_WithNonHTTPResponse_ThrowsInvalidResponseError() async {
        // Given
        mockAPIClient.mockError = NetworkError.invalidResponse
        let endpoint = TestEndpoint()
        
        // When/Then
        do {
            let _: TestMovie = try await mockAPIClient.request(endpoint)
            XCTFail("Should throw invalid response error")
        } catch let error as NetworkError {
            if case .invalidResponse = error {
                // Success
            } else {
                XCTFail("Wrong error type")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testRequest_WithEmptyData_ButValidJSON_Succeeds() async throws {
        // Given - Empty array is valid JSON
        let emptyArray: [TestMovie] = []
        mockAPIClient.mockResult = emptyArray
        
        let endpoint = TestEndpoint()
        
        // When
        let result: [TestMovie] = try await mockAPIClient.request(endpoint)
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
}

// MARK: - Test Helpers

struct TestMovie: Codable, Equatable {
    let id: Int
    let title: String
}

struct TestEndpoint: Endpoint {
    var baseURL: String { "https://api.test.com" }
    var path: String { "/movies" }
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String : String]? { nil }
}

class MockAPIClient: APIClientProtocol {
    var mockResult: Any?
    var mockError: Error?
    
    func request<T>(_ endpoint: Endpoint) async throws -> T where T : Decodable {
        if let error = mockError {
            throw error
        }
        
        guard let result = mockResult as? T else {
            throw NetworkError.invalidResponse
        }
        
        return result
    }
}
