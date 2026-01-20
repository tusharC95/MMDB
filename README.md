# MMDB - Modern Movie Database

A modern iOS application showcasing all movies starring **Benedict Cumberbatch**. Built with hybrid UIKit/SwiftUI architecture, TCA-inspired state management, and modular design patterns.

## Architecture Overview

This project showcases a production-ready iOS app structure with:

### **Hybrid UIKit + SwiftUI**
- **Movie List Screen**: UIKit with programmatic layout (no storyboards)
- **Movie Detail Screen**: SwiftUI with modern declarative UI
- Seamless integration between UIKit and SwiftUI using `UIHostingController`

### **Design Patterns**

#### 1. **Coordinator Pattern**
Navigation is managed through coordinators, separating navigation logic from view controllers:
- `AppCoordinator`: Main app coordinator handling dependency injection
- `MovieCoordinator`: Feature-specific coordinator managing movie flows
- Benefits: Testable navigation, loose coupling, reusable components

#### 2. **TCA-Inspired Architecture (The Composable Architecture)**
Unidirectional data flow with:
- **State**: Single source of truth for UI state
- **Actions**: Events that can occur (user actions, API responses)
- **Reducer**: Pure function: `(State, Action) -> (State, Effect)`
- **Store**: Manages state and dispatches actions
- **Effects**: Handle side effects (API calls, async operations)

#### 3. **Local Swift Packages**
Modular architecture with three packages:

##### **Core Package**
- Shared models (Movie, MoviesResponse)
- Coordinator base protocol
- Image caching utilities
- Common extensions

##### **Networking Package**
- API client with protocol-oriented design
- Movie service for TMDB API integration
- Network error handling
- Codable models

##### **MovieFeature Package**
- Movie list (UIKit) and detail (SwiftUI) screens
- TCA-inspired state management (Store, Reducer, Effects)
- Feature-specific coordinator
- Service adapter pattern

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0 or later
- Swift 5.9+

### Step 1: Add Local Packages

1. Open `MMDB.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select the MMDB target
4. Go to **General** → **Frameworks, Libraries, and Embedded Content**
5. Click **+** → **Add Other** → **Add Package Dependency**
6. For each package, click **Add Local...** and select:
   - `Packages/Core`
   - `Packages/Networking`
   - `Packages/MovieFeature`

### Alternative: Using File → Add Package Dependencies

1. In Xcode, go to **File** → **Add Package Dependencies...**
2. Click **Add Local...** at the bottom
3. Navigate to and select `Packages/Core`, then click **Add Package**
4. Repeat for `Packages/Networking` and `Packages/MovieFeature`

### Step 2: Import Packages in AppCoordinator

Ensure these imports are at the top of `AppCoordinator.swift`:

```swift
import Core
import Networking
import MovieFeature
```

### Step 3: Configure API Key (Required)

**IMPORTANT**: The app requires a TMDB API key to function. No fallback keys are provided for security reasons.

**Setup Steps:**

1. Get your API key from [TMDB](https://www.themoviedb.org/settings/api) (free registration required)

2. Copy the template file:
   ```bash
   cp MMDB/Config.plist.template MMDB/Config.plist
   ```

3. Open `MMDB/Config.plist` and replace `YOUR_API_KEY_HERE` with your actual API key:
   ```xml
   <key>TMDB_API_KEY</key>
   <string>your_actual_api_key_here</string>
   ```

4. Add `Config.plist` to Xcode project (if not already added):
   - Right-click on `MMDB` folder in Xcode
   - Select "Add Files to MMDB"
   - Select `Config.plist`
   - Ensure "Copy items if needed" is checked
   - Ensure target membership includes `MMDB`

5. Build and run the app

**What Happens Without Config:**
- App will show an alert: "Configuration Required"
- Alert provides setup instructions
- "Get API Key" button opens https://www.themoviedb.org/settings/api in Safari
- App exits after Safari opens to allow user to get their key
- No fallback keys or hardcoded secrets in code

**Security Note**: 
- `Config.plist` is in `.gitignore` and will NOT be committed to version control
- Only `Config.plist.template` (with placeholder) is tracked in git
- No API keys exist in source code
- This follows production security best practices

### Step 4: Build and Run

1. Select a simulator or device (iPhone 15 or later recommended)
2. Press `Cmd + R` to build and run
3. Wait for the project to build (first build may take a few minutes due to Swift Package compilation)

## Features

### User Story 1: Browse Benedict Cumberbatch Movies
**Home Screen (UIKit)**
- Shows all movies starring Benedict Cumberbatch
- Each movie displays:
  - Movie poster thumbnail
  - Movie title
  - Rating
- Grid layout (2 columns) with compositional layout
- Infinite scrolling with pagination
- Sorted by popularity (most popular first)
- Loading states with activity indicator
- Network error handling with user-friendly messages
- Empty state handling

### User Story 2: View Movie Synopsis  
**Movie Detail Screen (SwiftUI)**
- Tap any movie and navigate to detail screen
- Shows:
  - Movie title
  - Movie poster (large backdrop)
  - Movie synopsis (overview)
- **Bonus features:**
  - User rating with circular progress
  - Release date (formatted)
  - Vote count and popularity
  - Details section
  - Similar movies horizontal scroll
  - Recursive navigation through similar movies
  - Dynamic navigation title (appears/disappears on scroll)
- Native SwiftUI components
- Smooth navigation with native back button
- Proper memory management for deep navigation hierarchies

### User Story 3: Similar Movies
**Movie Detail Screen - Similar Movies Section**
- Horizontal scrollable list of similar movies
- Tap to navigate to another movie detail screen
- Recursive navigation (can go multiple levels deep)
- Optimized image loading with prefetching
- Smooth scrolling with cached images

### Search Functionality
- **Movie Search**: Search bar to find specific movies
  - Search within all TMDB movies
  - Clear button to return to Benedict Cumberbatch list
  - Live search with debouncing
  - Dynamic title updates based on search state
- **Actor Search**: Search for different actors
  - Button in navigation bar to search for actors
  - Shows all movies by selected actor
  - Dynamic accessibility labels update with actor name

## Project Structure

```
MMDB/
├── MMDB/                          # Main app target
│   ├── AppDelegate.swift          # App lifecycle
│   ├── SceneDelegate.swift        # Scene lifecycle & window setup
│   └── AppCoordinator.swift       # Dependency injection & coordination
│
├── Packages/                      # Local Swift Packages
│   ├── Core/                      # Shared utilities & models
│   │   ├── Package.swift
│   │   └── Sources/Core/
│   │       ├── Coordinator.swift
│   │       ├── Models/Movie.swift
│   │       └── Utils/ImageCache.swift
│   │
│   ├── Networking/                # API layer
│   │   ├── Package.swift
│   │   └── Sources/Networking/
│   │       ├── APIClient.swift
│   │       └── MovieService.swift
│   │
│   └── MovieFeature/              # Movie feature module
│       ├── Package.swift
│       └── Sources/MovieFeature/
│           ├── Architecture/      # TCA-inspired components
│           │   └── Store.swift
│           ├── MovieList/         # UIKit list screen
│           │   ├── MovieListViewController.swift
│           │   ├── MovieListState.swift
│           │   └── MovieCell.swift
│           ├── MovieDetail/       # SwiftUI detail screen
│           │   └── MovieDetailView.swift
│           ├── Coordinator/
│           │   └── MovieCoordinator.swift
│           └── Services/
│               └── MovieServiceAdapter.swift
│
└── README.md                      # This file
```

## Key Architectural Decisions

### Why Coordinator Pattern?
- **Separation of Concerns**: VCs don't know about navigation
- **Testability**: Navigation logic can be tested independently
- **Reusability**: VCs become more reusable across different flows
- **Deep Linking**: Easier to implement complex navigation

### Why TCA-Inspired Architecture?
- **Predictable State**: Single source of truth
- **Testable Logic**: Pure reducers are easy to test
- **Side Effect Management**: Effects are explicit and composable
- **Time Travel Debugging**: State changes are trackable
- **No External Dependencies**: Implemented from scratch

### Why Local Swift Packages?
- **Build Time**: Parallel compilation of modules
- **Modularity**: Clear boundaries between features
- **Reusability**: Packages can be shared across apps
- **Testing**: Isolated unit tests per module
- **Code Organization**: Better than folder structure

### Why Hybrid UIKit/SwiftUI?
- **Real-World Scenario**: Most production apps are hybrid
- **Gradual Migration**: Shows migration strategy
- **Best of Both Worlds**: UIKit performance, SwiftUI simplicity
- **Team Skills**: Demonstrates proficiency in both frameworks

## Technical Highlights

### Programmatic UI (No Storyboards)
```swift
// Auto Layout with anchors
NSLayoutConstraint.activate([
    collectionView.topAnchor.constraint(equalTo: view.topAnchor),
    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    // ...
])
```

### UICollectionView Compositional Layout
```swift
let itemSize = NSCollectionLayoutSize(
    widthDimension: .fractionalWidth(1.0),
    heightDimension: .estimated(200)
)
let group = NSCollectionLayoutGroup.horizontal(
    layoutSize: groupSize, 
    subitem: item, 
    count: 2
)
```

### TCA State Management
```swift
public func reduce(state: inout MovieListState, action: MovieListAction) -> Effect<MovieListAction> {
    switch action {
    case .loadMovies:
        state.isLoading = true
        return .task {
            let response = try await movieService.fetchPopularMovies(page: 1)
            return .moviesLoaded(response.results)
        }
    // ...
    }
}
```

### SwiftUI Integration
```swift
let detailView = MovieDetailView(movie: movie)
let hostingController = UIHostingController(rootView: detailView)
navigationController.pushViewController(hostingController, animated: true)
```

## Testing Strategy

### Unit Tests
- Reducer logic testing (pure functions)
- Model transformations
- Service layer with mocked dependencies

### Integration Tests
- Coordinator navigation flows
- API integration with mock responses

### UI Tests
- Critical user journeys
- Search and detail navigation

## Performance Optimizations

1. **Advanced Image Caching**
   - Custom NSCache-based memory cache (30MB limit, 50 items)
   - Disk cache with async writes to avoid blocking
   - Cost-based eviction (images weighted by pixel size)
   - Memory warning observer for automatic cleanup
   - Background cleanup when app enters background
   
2. **Image Prefetching**
   - UICollectionViewDataSourcePrefetching for upcoming cells
   - Task tracking to cancel abandoned prefetch operations
   - Thread-safe prefetch queue
   - Avoids re-downloading cached images

3. **Memory Management**
   - Custom UIHostingController with proper cleanup
   - Task cancellation on view disappear
   - Weak references in navigation closures
   - View lifecycle protection (isViewActive guards)
   - No retain cycles (verified with Instruments)
   - Optimized for deep navigation hierarchies

4. **Pagination**: Infinite scrolling with efficient loading
5. **Cell Reuse**: Proper cell reuse with cancellable tasks
6. **Async/Await**: Modern concurrency for better performance
7. **Compositional Layout**: Efficient UICollectionView layout
8. **SwiftUI Optimizations**: LazyVStack/LazyHStack for on-demand rendering

## UI/UX Features

- Dark mode support
- Dynamic type support
- Smooth animations
- Pull to refresh
- Search with debouncing
- Loading states
- Error handling
- Empty states

## API Used

This app uses [The Movie Database (TMDB) API](https://www.themoviedb.org/documentation/api):
- **Discover movies endpoint** (`/discover/movie?with_people={personId}`) - Movies by actor
- **Search movies endpoint** (`/search/movie`) - Movie search functionality
- **Search person endpoint** (`/search/person`) - Actor search functionality
- **Similar movies endpoint** (`/movie/{movieId}/similar`) - Similar movie recommendations
- **Image URLs** - Posters and backdrops with various sizes (w500, w780, original)
- **Person ID**: 71580 (Benedict Cumberbatch) - Default actor

## Best Practices Demonstrated

- Protocol-oriented programming
- Dependency injection
- SOLID principles
- Separation of concerns
- Unidirectional data flow
- Composition over inheritance
- Value types over reference types where appropriate
- Modern Swift concurrency (async/await)
- Comprehensive error handling
- Type-safe networking layer

## Future Enhancements

- [ ] Add movie favorites with local persistence
- [ ] Implement genre filtering
- [ ] Add movie trailers using AVKit
- [ ] Share movie functionality
- [ ] Localization support
- [ ] UI test coverage for critical user flows
- [ ] CI/CD pipeline with automated testing

## Libraries & Dependencies

### External Libraries Used: NONE

**Why No External Dependencies?**

This project intentionally uses **zero external dependencies** (third-party libraries) to demonstrate:

1. **Deep iOS Platform Knowledge**
   - Complete implementation of TCA pattern from scratch (~200 lines)
   - Custom networking layer with protocol-oriented design
   - Native URLSession with modern async/await
   - Custom image caching with memory management
   - No third-party state management or UI libraries

2. **Production Considerations**
   - Smaller app binary size (no dependency bloat)
   - No supply chain security risks
   - No version conflicts or breaking changes during iOS updates
   - Complete control over implementation and debugging
   - Easier long-term maintenance
   - Faster compile times (no external dependencies to build)

3. **What Was NOT Used & Why**

| Library | Why Not Used | Our Approach |
|---------|-------------|--------------|
| **Alamofire** | URLSession + async/await is native, powerful, and sufficient | Custom APIClient with protocol-oriented design, error handling, and async/await |
| **TCA (Point-Free)** | Large dependency (~200KB), steep learning curve, complex setup | Custom TCA-inspired implementation with State, Actions, Reducer, Effects, Store |
| **Kingfisher/SDWebImage** | Modern async/await makes image loading simple | Custom CachedAsyncImage with NSCache, disk persistence, prefetching, memory warnings |
| **SnapKit** | Native Auto Layout is clear, performant, and well-understood | NSLayoutConstraint with layout anchors and programmatic UI |
| **SwiftLint** | Adds build time, can be overly opinionated | Manual code reviews, consistent coding patterns, Swift API guidelines |
| **PromiseKit/ReactiveSwift** | Modern Swift concurrency makes promises unnecessary | async/await, Task, TaskGroup for structured concurrency |

4. **Native iOS SDKs & Frameworks Used**
   - **UIKit**: Programmatic UI for movie list (no storyboards)
   - **SwiftUI**: Declarative UI for movie detail screen
   - **Combine**: Reactive state updates with @Published properties
   - **Foundation**: URLSession, Codable, Date formatting, FileManager
   - **XCTest**: Unit testing framework
   - **Swift Concurrency**: async/await, Task, MainActor, Task cancellation
   - **Core Graphics**: Image rendering and caching

5. **Local Swift Packages (Not External Dependencies)**
   - **Core**: Shared models, utilities, protocols (our own code)
   - **Networking**: API client, service protocols (our own code)
   - **MovieFeature**: Feature module with UI and logic (our own code)
   
   These are **local packages**, not external dependencies. They're part of the project codebase.

**Benefits Demonstrated:**
- Zero dependency vulnerabilities
- Full understanding of every line of code
- No "magic" from external libraries
- Direct control over performance characteristics
- Can optimize for specific use cases
- No licensing concerns
- Works with any iOS version we support

**Trade-off**: More code to write initially, but demonstrates deeper platform understanding and provides full control. For a production app at scale, carefully selected dependencies might be appropriate, but this project showcases ability to implement core functionality from first principles.

---

## What I Would Improve With More Time

### Short Term (1-2 days)

1. **Enhanced Test Coverage** - PARTIALLY COMPLETED
   - Unit tests for all packages (Core, Networking, MovieFeature)
   - Integration tests for app initialization and security
   - Protocol-based mocking for better testability
   - Special character and edge case handling
   - Memory and performance benchmarks
   - Still TODO: UI tests for critical user flows, 80%+ code coverage goal

2. **Enhanced Error Handling**
   - Retry mechanism for failed requests
   - Offline mode with cached data
   - Better error messages with recovery suggestions
   - Network reachability monitoring

3. **Accessibility Enhancements** - COMPLETED
   - Comprehensive VoiceOver testing with deep navigation
   - Dynamic accessibility labels that update with state
   - Memory management for VoiceOver scenarios
   - Full Dynamic Type support testing
   - Accessibility audit with Xcode tools
   - Contrast ratio validation
   - Reduce motion support

4. **Performance Optimizations** - PARTIALLY COMPLETED
   - Prefetching images for upcoming cells (UICollectionViewDataSourcePrefetching)
   - Sophisticated image cache eviction (cost-based, memory warnings)
   - Background thread optimization (async disk writes)
   - Request deduplication
   - Response caching with ETags

### Medium Term (1 week)

1. **Feature Additions**
   - **Favorites/Watchlist**: Core Data persistence
   - **Movie Filters**: By genre, year, rating
   - **Movie Trailers**: AVKit video player
   - **Share Functionality**: Share movie details
   - **Deep Linking**: Open specific movies from URLs

2. **Architecture Improvements**
   - **Error Recovery Store**: Centralized error handling
   - **Analytics Layer**: Track user interactions
   - **Logging**: Structured logging with OSLog
   - **Configuration**: Environment-based configs (dev/prod)

3. **UI/UX Enhancements**
   - **Skeleton Loading**: Better loading states
   - **Pull to Refresh**: On list screen
   - **Empty States**: Better empty/no results UI
   - **Animations**: Smooth transitions, hero animations
   - **iPad Support**: Adaptive layout for larger screens

4. **Developer Experience**
   - **SwiftGen**: Type-safe assets and strings
   - **CI/CD**: GitHub Actions for automated testing
   - **Fastlane**: Automated builds and releases
   - **Documentation**: DocC documentation

### Long Term (2+ weeks)

1. **Advanced Features**
   - **User Authentication**: Firebase/Auth0 integration
   - **Social Features**: Share ratings, comments
   - **Recommendations**: ML-based suggestions
   - **Widgets**: iOS Home Screen widget
   - **Watch App**: Companion Apple Watch app

2. **Technical Debt**
   - **Full SwiftUI Migration**: When performance is ready
   - **GraphQL**: Replace REST with GraphQL
   - **Server-Driven UI**: Dynamic layouts
   - **Modularization**: Extract more packages

3. **Production Readiness**
   - **Crash Reporting**: Crashlytics/Sentry
   - **Remote Config**: Firebase Remote Config
   - **A/B Testing**: Experiment framework
   - **App Store Optimization**: Screenshots, localization

---

## Challenges Encountered & Solutions

### Challenge 1: Module Boundaries with Type Conflicts

**Problem**: Movie model exists in multiple packages (Core, Networking, MovieFeature), causing naming conflicts.

**Solution**: 
- Used type aliases in AppCoordinator: `NetworkingMovie`, `MovieFeatureMovie`
- Created adapter pattern to convert between types
- Kept packages truly independent

**Learning**: Module boundaries need careful planning. In retrospect, could have shared Core.Movie across all packages.

### Challenge 2: TCA Implementation Without Library

**Problem**: Implementing TCA pattern from scratch while maintaining simplicity.

**Solution**:
- Studied Point-Free's TCA architecture
- Created minimal viable implementation (~70 lines)
- Focused on core concepts: State, Actions, Reducer, Effects, Store
- Used Swift's modern concurrency (async/await) instead of Combine for effects

**Trade-off**: Less features than full TCA, but demonstrates deep understanding.

### Challenge 3: UIKit ↔ SwiftUI Navigation

**Problem**: Seamless navigation between UIKit list and SwiftUI detail while maintaining native feel.

**Solution**:
- UIHostingController for embedding SwiftUI in UIKit navigation
- Shared UINavigationController for consistent navigation stack
- Native back button works automatically
- Coordinator pattern handles the integration cleanly

**Result**: Users can't tell where UIKit ends and SwiftUI begins.

### Challenge 4: Memory Management in Async Image Loading

**Problem**: Potential retain cycles with async tasks in table view cells, memory leaks from ongoing downloads.

**Solution**:
- Store `Task` reference in cell: `var imageLoadTask: Task<Void, Never>?`
- Cancel task in `prepareForReuse()`
- Use `[weak self]` in closures when needed
- Proper cleanup on cell deallocation

**Verification**: Tested with Instruments - no leaks detected.

### Challenge 5: State Management Complexity

**Problem**: Managing multiple states (loading, error, pagination, search) without state explosion.

**Solution**:
- Single State struct with clear properties
- Reducer handles all state transitions
- Effects for side effects only
- No derived state - computed properties where needed

**Result**: Predictable, testable state management.

### Challenge 6: Accessibility Without Compromising Design

**Problem**: Adding comprehensive VoiceOver support while keeping UI clean.

**Solution**:
- Cell becomes single accessibility element with comprehensive label
- Descriptive hints for actions
- Headers marked appropriately  
- Tested with VoiceOver on device
- Added identifiers for UI testing

**Result**: App is fully usable with VoiceOver while maintaining visual design.

### Challenge 7: Testing Without Mocking Framework

**Problem**: Writing unit tests without libraries like Quick/Nimble or OCMock.

**Solution**:
- Protocol-oriented design makes mocking easy
- Simple mock classes implementing protocols
- Pure functions (reducers) are trivial to test
- XCTest is sufficient for quality tests

**Result**: Clean, readable tests without dependencies.

### Challenge 8: Package Setup Complexity

**Problem**: Local Swift Packages aren't in Git by default, need manual setup in Xcode.

**Solution**:
- Created comprehensive setup instructions in README
- Clear step-by-step instructions
- Multiple setup methods documented
- API key configuration guidance

**Trade-off**: Extra setup step, but demonstrates modular architecture understanding.

### Challenge 9: Memory Leaks with VoiceOver and Deep Navigation

**Problem**: Memory usage kept rising when VoiceOver was enabled and navigating through multiple detail screens (detail → similar movie → another similar movie, 3-4 levels deep). App would hang when navigating back. VoiceOver made the issue worse because iOS keeps additional accessibility references to UI elements.

**Root Causes Identified**:
1. Retain cycles in recursive navigation closures
2. Tasks not being cancelled when views disappeared
3. UIHostingController lifecycle issues with SwiftUI views
4. Image loading tasks continuing after cells were reused
5. GeometryReader callbacks firing during navigation pop animations
6. VoiceOver keeping extra references to deallocated views

**Solutions Implemented**:

1. **Custom UIHostingController**
   ```swift
   private class MovieDetailHostingController: UIHostingController<MovieDetailView> {
       weak var coordinator: MovieCoordinator?  // Weak reference
       
       override func viewDidDisappear(_ animated: Bool) {
           if isMovingFromParent {
               coordinator = nil  // Explicit cleanup
           }
       }
   }
   ```

2. **Task Lifecycle Management**
   - Added `private var loadTask: Task<Void, Never>?` to track all async operations
   - Cancel tasks in `deinit` and `onDisappear`
   - Check `Task.isCancelled` before updating state
   - Explicit `cancelLoading()` methods for cleanup

3. **View Lifecycle Protection**
   - Added `@State private var isViewActive = true` to guard callbacks
   - Prevents scroll events from firing during navigation transitions
   - Only process GeometryReader callbacks when view is active

4. **Image Cache Memory Management**
   - Reduced cache limits (30MB instead of 50MB)
   - Added memory warning observer to clear cache
   - Background cleanup when app enters background
   - Cost-based eviction by pixel size
   - Async disk writes to avoid blocking

5. **Prefetch Task Tracking**
   - Thread-safe dictionary of prefetch tasks
   - Cancel abandoned prefetch operations
   - Proper cleanup in cell `prepareForReuse()`

**Verification**:
- Tested with 4-5 levels of navigation depth with VoiceOver enabled
- Monitored with Xcode Memory Graph Debugger
- Added debug logging to verify deallocation
- No retain cycles found with Instruments
- Memory properly decreases when navigating back

**Result**: App handles deep navigation smoothly, even with VoiceOver enabled. Memory is properly managed and views are deallocated correctly.

**Learning**: VoiceOver exposes memory management issues that might not be obvious in normal usage. Proper lifecycle management and task cancellation are critical for production apps.

### Challenge 10: API Key Security

**Problem**: API keys should never be hardcoded in source code or committed to version control. Need a secure, production-ready approach with no exposed secrets.

**Solution**:

1. **Configuration File Approach (Zero Secrets in Code)**
   - Created `Config.plist` to store API keys separately
   - Added `Config.plist` to `.gitignore` to exclude from version control
   - Created `Config.plist.template` (tracked in git) with placeholder
   - Removed ALL hardcoded keys from source code

2. **Configuration Helper with Error Handling**
   ```swift
   enum Configuration {
       enum Error: Swift.Error {
           case missingConfigFile
           case invalidValue
           case missingKey
       }
       
       static func tmdbAPIKey() throws -> String {
           let key: String = try value(for: "TMDB_API_KEY")
           
           // Validate key is not placeholder
           guard !key.isEmpty, key != "YOUR_API_KEY_HERE" else {
               throw Error.missingKey
           }
           
           return key
       }
   }
   ```

3. **User-Friendly Error Handling in AppCoordinator**
   ```swift
   do {
       let apiKey = try Configuration.tmdbAPIKey()
       // Setup app...
   } catch {
       showConfigurationError(error.localizedDescription)
       // Shows alert with setup instructions
   }
   ```

4. **Alert with Guidance**
   - Title: "Configuration Required"
   - Message: Detailed setup instructions
   - Actions: "Get API Key" (opens TMDB website in Safari with completion handler), "Exit"
   - Uses async completion handler to ensure URL opens before app exits
   - No way to proceed without valid configuration

**Benefits**:
- Zero API keys in source code (truly secure)
- Zero secrets committed to version control
- Production-ready security approach
- User-friendly error messages guide setup
- Can add multiple keys/environments easily
- Forces proper configuration (no insecure fallbacks)

**Why No Fallback Key?**
- Fallback keys in code defeat the purpose of security
- Forces developers to use their own keys
- Prevents accidental exposure of demo keys
- Follows industry security best practices
- Clear separation between code and configuration

**Alternative Approaches Considered**:
- Fallback key: Rejected - exposes secrets in code
- Environment variables: Complex for iOS, not persistent
- Keychain: Overkill for API keys, better for user credentials
- Build configurations: Still requires some hardcoding
- Secrets manager: Too complex for this use case

**Result**: Production-grade security with zero secrets in code. App fails gracefully with clear guidance if misconfigured.

### Challenge 11: Test Suite Refinement

**Problem**: Initial test suite had several issues that needed fixing:
1. `Movie` model tests were looking in wrong package (MovieFeature instead of Core)
2. JSON test data with special characters failed due to unescaped quotes
3. Deprecated URLSession mocking approach
4. Mock services missing required protocol methods
5. No integration tests for app initialization and security features

**Solutions Implemented**:

1. **Fixed Package References**
   ```swift
   // Changed from:
   @testable import MovieFeature
   let movie = MovieFeature.Movie(...)
   
   // To:
   @testable import Core
   let movie = Movie(...)
   ```

2. **Fixed JSON Test Data**
   ```swift
   // Escaped special characters properly:
   "title": "Movie with \\"quotes\\" & special <characters>"
   ```

3. **Protocol-Based Mocking**
   - Replaced deprecated `MockURLSession` with `MockAPIClient` conforming to `APIClientProtocol`
   - Better testability through protocol-oriented design
   - No reliance on internal URLSession APIs

4. **Complete Mock Implementations**
   ```swift
   class MockMovieService: MovieServiceProtocol {
       func fetchMoviesByPerson(personId: Int, page: Int) async throws -> MoviesResponse
       func searchMovies(query: String, page: Int) async throws -> MoviesResponse
       func searchPerson(query: String) async throws -> PersonSearchResponse  // Added
       func fetchSimilarMovies(movieId: Int, page: Int) async throws -> MoviesResponse  // Added
   }
   ```

5. **Comprehensive Integration Tests (14 new tests)**
   - Configuration loading and validation
   - Error handling for missing/invalid API keys
   - AppCoordinator initialization
   - Dependency chain verification
   - Type alias definitions
   - Security checks
   - Memory management
   - Performance benchmarks

**Result**: Comprehensive test suite with 55+ tests covering unit, integration, security, memory, and performance aspects. All tests pass reliably with proper mocking and error handling.

**Learning**: Test maintenance is crucial. As code evolves (packages refactored, protocols updated), tests need to evolve too. Protocol-oriented design makes testing significantly easier than concrete implementations.

---

## Testing Strategy

### Unit Tests Implemented

**MovieListReducerTests** (18 tests)
- State transitions
- Action handling  
- Effect creation
- Edge cases
- Integration flows
- Mock service includes all protocol methods (searchPerson, fetchSimilarMovies)

**MovieModelTests** (15 tests)
- JSON encoding/decoding (including special characters)
- URL formatting
- Date formatting
- Computed properties
- Edge cases
- Now tests Core.Movie (moved from MovieFeature)

**APIClientTests** (8 tests)
- Success responses
- HTTP errors (404, 500)
- Network errors (no connection, timeout)
- Decoding errors
- Invalid responses
- Protocol-based MockAPIClient (replacing deprecated URL mocking)

**MMDBTests** (Integration Tests - 14 tests)
- Configuration loading and error handling
- API key validation (missing file, invalid value, placeholder detection)
- AppCoordinator initialization and setup
- Dependency chain creation (APIClient → MovieService → Adapter → Coordinator)
- Type alias verification for module imports
- Security validation (Config.plist in .gitignore)
- AppDelegate and SceneDelegate existence
- Memory management (coordinator deallocation)
- Performance benchmarks (coordinator initialization, configuration loading)

**Total**: 55+ high-quality unit and integration tests covering critical paths

### What Tests Demonstrate

- **Quality Over Quantity**: Focused, meaningful tests
- **Edge Cases**: Empty data, nil values, errors, special characters
- **Integration**: Complete user flows and app initialization
- **Mocking**: Protocol-based mocks (no external frameworks)
- **Async Testing**: Modern async/await patterns
- **Security Testing**: Configuration validation and error handling
- **Memory Testing**: Proper deallocation verification
- **Performance Testing**: Benchmark critical initialization paths

---

## Production-Ready Features

### Error Handling
- Network failures handled gracefully
- User-friendly error messages
- Empty states for no results
- Loading states throughout
- No force unwraps in production code

### Memory Management
- No retain cycles (verified with Instruments)
- Proper task cancellation
- Weak self in closures where needed
- Efficient image caching with automatic eviction

### Security
- API keys stored in Config.plist (excluded from version control via .gitignore)
- Configuration.swift provides secure key loading with error handling
- No fallback keys - app shows alert if configuration is missing
- Template file (Config.plist.template) tracked in git for easy setup
- Zero hardcoded secrets in source code
- Production-ready security best practices for API key management
- User-friendly error messages guide setup process

### Accessibility (VoiceOver Support)

**Comprehensive VoiceOver Implementation:**

1. **Movie List Screen**
   - Each cell is a single accessibility element with comprehensive label
   - Dynamic labels that update based on actor/search state
   - Example: "Benedict Cumberbatch movies collection" or "Tom Cruise movies collection"
   - Cell labels include: movie title, rating, release date
   - Hint: "Double tap to view movie details"
   - Search bar with descriptive labels
   - Actor search button with label and hint

2. **Movie Detail Screen**
   - Backdrop images with descriptive labels
   - Title marked as header with `.isHeader` trait
   - Rating with value announcements ("Rating: 85 percent, 8.5 out of 10")
   - User score section with vote count
   - Overview section with proper heading
   - Similar movies with tap hints
   - Loading states announced ("Loading similar movies")
   - Error states announced with messages

3. **Memory Management for VoiceOver**
   - VoiceOver keeps additional references to UI elements
   - Proper task cancellation prevents memory leaks
   - Custom UIHostingController with weak references
   - View lifecycle protection prevents crashes
   - Tested with 4-5 levels of navigation depth

4. **Dynamic Updates**
   - Accessibility labels update when actor changes
   - Search state reflected in labels
   - Scroll position doesn't trigger unnecessary announcements
   - Smooth navigation even with VoiceOver enabled

**Testing:**
- All features tested with VoiceOver enabled on physical device
- No hangs or crashes during deep navigation
- Memory usage properly managed
- Smooth back button navigation

### Code Quality
- Clean, readable code
- Appropriate comments
- Consistent naming conventions
- SOLID principles
- Protocol-oriented design

---

## License

This project is for demonstration purposes.

## Author

Tushar Chitnavis

---

**Note**: This is a production-ready showcase project demonstrating modern iOS development practices, hybrid architecture, advanced design patterns, comprehensive testing, and accessibility support. Built with zero external dependencies to demonstrate deep iOS platform knowledge.

