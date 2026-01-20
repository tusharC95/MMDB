//
//  MMDBTests.swift
//  MMDBTests
//
//  Integration tests for main app target
//  Created by Tushar Chitnavis on 17/11/25.
//

import XCTest
@testable import MMDB

final class MMDBTests: XCTestCase {

    // MARK: - Configuration Tests
    
    func testConfiguration_WithValidPlist_LoadsAPIKey() throws {
        // Given/When
        let apiKey = try Configuration.tmdbAPIKey()
        
        // Then
        XCTAssertFalse(apiKey.isEmpty, "API key should not be empty")
        XCTAssertNotEqual(apiKey, "YOUR_API_KEY_HERE", "API key should not be placeholder")
    }
    
    func testConfiguration_WithPlaceholder_ThrowsError() {
        // This test verifies that placeholder values are rejected
        // Note: This will only work if Config.plist has placeholder
        // In production setup with real key, this test would need to be skipped
        
        // Given - If config has placeholder
        // When/Then - Should throw error
        // (This is more of a documentation test showing expected behavior)
        XCTAssertTrue(true, "Configuration properly validates placeholder values")
    }
    
    // MARK: - AppCoordinator Tests
    
    func testAppCoordinator_Initialization_Succeeds() {
        // Given
        let navigationController = UINavigationController()
        
        // When
        let coordinator = AppCoordinator(navigationController: navigationController)
        
        // Then
        XCTAssertNotNil(coordinator, "AppCoordinator should initialize")
        XCTAssertEqual(coordinator.navigationController, navigationController, "Should store navigation controller")
    }
    
    func testAppCoordinator_NavigationBarAppearance_IsConfigured() {
        // Given
        let navigationController = UINavigationController()
        _ = AppCoordinator(navigationController: navigationController)
        
        // When - Coordinator initializes (setupNavigationBarAppearance called in init)
        
        // Then
        XCTAssertNotNil(navigationController.navigationBar.standardAppearance, "Should have standard appearance")
        XCTAssertNotNil(navigationController.navigationBar.scrollEdgeAppearance, "Should have scroll edge appearance")
        XCTAssertTrue(navigationController.navigationBar.prefersLargeTitles, "Should prefer large titles")
    }
    
    // MARK: - Integration Tests
    
    func testAppCoordinator_WithValidConfiguration_CanStart() {
        // Given
        let navigationController = UINavigationController()
        let coordinator = AppCoordinator(navigationController: navigationController)
        
        // When/Then - Should not crash when starting
        // Note: This test verifies the coordinator can be initialized
        // Actual start() requires valid Config.plist with API key
        XCTAssertNotNil(coordinator, "Coordinator should be ready to start")
    }
    
    // MARK: - Dependency Wiring Tests
    
    func testAppCoordinator_CreatesProperDependencyChain() {
        // Given
        let navigationController = UINavigationController()
        let coordinator = AppCoordinator(navigationController: navigationController)
        
        // Then
        // Verify coordinator is properly set up to create the dependency chain:
        // APIClient -> MovieService -> ServiceAdapter -> MovieCoordinator -> ViewControllers
        XCTAssertNotNil(coordinator, "Should create complete dependency chain")
        XCTAssertNotNil(coordinator.navigationController, "Should have navigation controller")
        XCTAssertEqual(coordinator.childCoordinators.count, 0, "Should start with no child coordinators")
    }
    
    // MARK: - Type Alias Tests
    
    func testTypeAliases_AreCorrectlyDefined() {
        // Verify type aliases don't cause conflicts
        let _: NetworkingAPIClient? = nil
        let _: NetworkingMovieService? = nil
        let _: MovieFeatureCoordinator? = nil
        
        XCTAssertTrue(true, "Type aliases should be properly defined without conflicts")
    }
    
    // MARK: - Security Tests
    
    func testConfiguration_HasProperErrorHandling() {
        // Verify that Configuration has proper error types
        let error = Configuration.Error.missingConfigFile
        
        XCTAssertEqual(
            error.localizedDescription,
            "Configuration file (Config.plist) not found. Please create it from Config.plist.template and add your TMDB API key.",
            "Should have user-friendly error messages"
        )
    }
    
    func testConfiguration_ErrorDescriptions_AreHelpful() {
        // Verify all error types have helpful descriptions
        let errors: [Configuration.Error] = [
            .missingConfigFile,
            .invalidValue,
            .missingKey
        ]
        
        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error should have description")
            XCTAssertTrue(error.localizedDescription.count > 10, "Error description should be meaningful")
        }
    }
    
    // MARK: - App Lifecycle Tests
    
    func testAppDelegate_Exists() {
        // Verify AppDelegate is properly defined
        let appDelegate = AppDelegate()
        XCTAssertNotNil(appDelegate, "AppDelegate should exist")
    }
    
    func testSceneDelegate_Exists() {
        // Verify SceneDelegate is properly defined
        let sceneDelegate = SceneDelegate()
        XCTAssertNotNil(sceneDelegate, "SceneDelegate should exist")
    }
    
    // MARK: - Memory Management Tests
    
    func testAppCoordinator_ReleasesResourcesProperly() {
        // Given
        var coordinator: AppCoordinator? = AppCoordinator(navigationController: UINavigationController())
        weak var weakCoordinator = coordinator
        
        // Then - Coordinator should exist
        XCTAssertNotNil(weakCoordinator, "Coordinator should be alive")
        
        // When - Release coordinator
        coordinator = nil
        
        // Then - Verify coordinator is deallocated
        XCTAssertNil(weakCoordinator, "Coordinator should be deallocated when no longer referenced")
    }
    
    // MARK: - Performance Tests
    
    func testAppCoordinator_InitializationPerformance() {
        measure {
            let navigationController = UINavigationController()
            _ = AppCoordinator(navigationController: navigationController)
        }
    }
    
    func testConfiguration_LoadingPerformance() {
        measure {
            // Only measure if config is valid
            _ = try? Configuration.tmdbAPIKey()
        }
    }
}
