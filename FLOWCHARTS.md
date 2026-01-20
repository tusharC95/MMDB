# MMDB App Flowcharts

This document contains comprehensive flowcharts showing the architecture and user flows of the MMDB app.

---

## 1. App Launch & Configuration Flow

```mermaid
flowchart TD
    Start([App Launch]) --> SceneDelegate[SceneDelegate.scene]
    SceneDelegate --> CreateWindow[Create UIWindow & UINavigationController]
    CreateWindow --> CreateCoordinator[Create AppCoordinator]
    CreateCoordinator --> CoordinatorStart[AppCoordinator.start]
    
    CoordinatorStart --> TryLoadConfig{Try Load Config.plist}
    TryLoadConfig -->|Success| ValidateKey{Validate API Key}
    TryLoadConfig -->|File Not Found| ShowError[Show Configuration Error Alert]
    
    ValidateKey -->|Valid Key| SetupDependencies[Setup Dependencies]
    ValidateKey -->|Invalid/Placeholder| ShowError
    
    ShowError --> AlertChoice{User Choice}
    AlertChoice -->|Exit| ExitApp([Exit App])
    AlertChoice -->|Get API Key| OpenSafari[Open Safari: TMDB API Settings]
    OpenSafari --> DelayExit[Wait 0.5s]
    DelayExit --> ExitApp
    
    SetupDependencies --> CreateAPIClient[Create NetworkingAPIClient]
    CreateAPIClient --> CreateMovieService[Create NetworkingMovieService with API Key]
    CreateMovieService --> CreateAdapter[Create MovieServiceAdapter]
    CreateAdapter --> CreateMovieCoordinator[Create MovieFeatureCoordinator]
    CreateMovieCoordinator --> StartMovieFlow[movieCoordinator.start]
    StartMovieFlow --> ShowMovieList([Display Movie List Screen])
```

---

## 2. Architecture Overview

```mermaid
flowchart TB
    subgraph App ["MMDB App Target"]
        AppDelegate[AppDelegate]
        SceneDelegate[SceneDelegate]
        AppCoordinator[AppCoordinator]
        Configuration[Configuration.swift]
        ConfigPlist[(Config.plist)]
    end
    
    subgraph MovieFeature ["MovieFeature Package"]
        MovieCoordinator[MovieCoordinator]
        MovieListVC[MovieListViewController]
        MovieListStore[Store<MovieListState>]
        MovieListReducer[MovieListReducer]
        MovieDetailView[MovieDetailView SwiftUI]
        MovieDetailVM[MovieDetailViewModel]
    end
    
    subgraph Networking ["Networking Package"]
        APIClient[APIClient]
        MovieService[MovieService]
        Endpoints[Endpoints: TMDB API]
    end
    
    subgraph Core ["Core Package"]
        Models[Movie Model]
        ImageCache[ImageCache Singleton]
        CoordinatorProtocol[Coordinator Protocol]
    end
    
    subgraph External ["External Services"]
        TMDB[TMDB API]
        TMDBImages[TMDB Image CDN]
    end
    
    SceneDelegate --> AppCoordinator
    AppCoordinator --> Configuration
    Configuration --> ConfigPlist
    AppCoordinator --> MovieCoordinator
    AppCoordinator --> MovieService
    
    MovieCoordinator --> MovieListVC
    MovieCoordinator --> MovieDetailView
    MovieListVC --> MovieListStore
    MovieListStore --> MovieListReducer
    MovieListReducer --> MovieService
    MovieDetailView --> MovieDetailVM
    MovieDetailVM --> MovieService
    
    MovieService --> APIClient
    APIClient --> TMDB
    MovieListVC --> ImageCache
    MovieDetailView --> ImageCache
    ImageCache --> TMDBImages
    
    MovieFeature -.uses.-> Core
    MovieFeature -.uses.-> Networking
    App -.uses.-> MovieFeature
    App -.uses.-> Networking
```

---

## 3. Main User Journey Flow

```mermaid
flowchart TD
    Start([App Opens]) --> MovieListScreen[Movie List Screen: Benedict Cumberbatch Movies]
    
    MovieListScreen --> UserAction{User Action}
    
    UserAction -->|Scroll Down| CheckPagination{More Pages Available?}
    CheckPagination -->|Yes| LoadMore[Load More Movies API Call]
    CheckPagination -->|No| MovieListScreen
    LoadMore --> AppendMovies[Append Movies to List]
    AppendMovies --> MovieListScreen
    
    UserAction -->|Search Movies| SearchBar[Type Movie Name in Search Bar]
    SearchBar --> SearchAPI[Search Movies API Call]
    SearchAPI --> DisplaySearchResults[Display Search Results]
    DisplaySearchResults --> UserAction
    
    UserAction -->|Clear Search| ClearSearch[Clear Search Query]
    ClearSearch --> ReloadActorMovies[Reload Benedict's Movies]
    ReloadActorMovies --> MovieListScreen
    
    UserAction -->|Tap Movie Cell| NavigateDetail[Navigate to Movie Detail]
    NavigateDetail --> MovieDetailScreen[Movie Detail Screen]
    
    MovieDetailScreen --> DetailAction{User Action}
    
    DetailAction -->|View Similar Movies| LoadSimilar[Load Similar Movies API Call]
    LoadSimilar --> DisplaySimilar[Display Similar Movies Horizontal Scroll]
    DisplaySimilar --> DetailAction
    
    DetailAction -->|Tap Similar Movie| NavigateDetail2[Navigate to New Movie Detail]
    NavigateDetail2 --> MovieDetailScreen2[Movie Detail Screen - New Movie]
    MovieDetailScreen2 --> CanGoDeeper{User Continues?}
    CanGoDeeper -->|Tap Another Similar| NavigateDetail2
    CanGoDeeper -->|Back Button| PopBack[Navigate Back]
    
    DetailAction -->|Back Button| PopToList[Navigate Back to List]
    PopToList --> MovieListScreen
    PopBack --> PreviousDetail[Previous Detail Screen]
    PreviousDetail --> DetailAction
```

---

## 4. Actor Search Flow

```mermaid
flowchart TD
    Start([Movie List Screen]) --> OpenSearch[User Taps Search Bar]
    OpenSearch --> SearchScope{Search Scope Selector}
    
    SearchScope -->|Movies Selected| MovieSearch[Search for Movies]
    SearchScope -->|Actors Selected| ActorSearch[Switch to Actor Search]
    
    ActorSearch --> TypeActor[User Types Actor Name]
    TypeActor --> DispatchSearch[Dispatch: actorSearchQueryChanged]
    DispatchSearch --> TriggerAPI[User Submits Search]
    TriggerAPI --> DispatchSearchAction[Dispatch: searchActor]
    
    DispatchSearchAction --> CallAPI[API: /search/person]
    CallAPI --> FilterActors{Filter Results}
    FilterActors -->|Known For: Acting| KeepResult[Keep Person]
    FilterActors -->|Other Department| DiscardResult[Discard]
    
    KeepResult --> LimitResults[Limit to Top 5]
    LimitResults --> DispatchCompleted[Dispatch: actorSearchCompleted]
    DispatchCompleted --> ShowResults[Show Actor Search Results]
    
    ShowResults --> UserSelects{User Action}
    UserSelects -->|Tap Actor| SelectActor[Dispatch: actorSelected]
    UserSelects -->|Cancel| CancelSearch[Close Search]
    
    SelectActor --> UpdateState[Update personId & actorName in State]
    UpdateState --> ClearSearchState[Clear Search Query]
    ClearSearchState --> LoadNewMovies[Dispatch: loadMovies]
    LoadNewMovies --> FetchActorMovies[API: /discover/person/ID/movie_credits]
    FetchActorMovies --> RenderNewList[Render New Actor's Movies]
    RenderNewList --> UpdateTitle[Update Custom Title Label]
    UpdateTitle --> UpdateAccessibility[Update VoiceOver Labels]
    UpdateAccessibility --> End([Display New Actor's Movies])
    
    CancelSearch --> RestoreList[Return to Current List]
```

---

## 5. Movie Detail & Similar Movies Flow

```mermaid
flowchart TD
    Start([User Taps Movie]) --> Coordinator[MovieCoordinator.showMovieDetail]
    Coordinator --> CreateVM[Create MovieDetailViewModel]
    CreateVM --> CreateView[Create MovieDetailView SwiftUI]
    CreateView --> WrapHosting[Wrap in MovieDetailHostingController]
    WrapHosting --> PushNav[Push onto NavigationController]
    
    PushNav --> OnAppear[SwiftUI .onAppear]
    OnAppear --> LoadSimilar[viewModel.loadSimilarMovies]
    LoadSimilar --> CancelPrevious{Previous Task Running?}
    CancelPrevious -->|Yes| CancelTask[Cancel Previous Task]
    CancelPrevious -->|No| CreateTask[Create New Task]
    CancelTask --> CreateTask
    
    CreateTask --> CallAPI[API: /movie/ID/similar]
    CallAPI --> CheckCancelled{Task Cancelled?}
    CheckCancelled -->|Yes| Abort[Abort Update]
    CheckCancelled -->|No| UpdateState[Update similarMovies in ViewModel]
    
    UpdateState --> RenderView[Render Similar Movies Section]
    RenderView --> DisplayScroll[Horizontal ScrollView with Cards]
    
    DisplayScroll --> UserAction{User Action}
    
    UserAction -->|Scroll Similar Movies| PrefetchImages[Prefetch Images via ImageCache]
    PrefetchImages --> DisplayScroll
    
    UserAction -->|Tap Similar Movie| TapSimilar[onMovieSelected Callback]
    TapSimilar --> NewDetail[coordinator.showMovieDetail]
    NewDetail --> CreateVM
    
    UserAction -->|Scroll Content| TrackOffset[GeometryReader Tracks Scroll Offset]
    TrackOffset --> UpdateNavTitle{Scroll Direction & Position}
    UpdateNavTitle -->|Scrolling Up & Not at Top| ShowTitle[Show Navigation Bar Title]
    UpdateNavTitle -->|Scrolling Down or At Top| HideTitle[Hide Navigation Bar Title]
    ShowTitle --> DisplayScroll
    HideTitle --> DisplayScroll
    
    UserAction -->|Back Button| OnDisappear[SwiftUI .onDisappear]
    OnDisappear --> SetInactive[Set isViewActive = false]
    SetInactive --> CancelLoading[viewModel.cancelLoading]
    CancelLoading --> ViewDidDisappear[viewDidDisappear Lifecycle]
    ViewDidDisappear --> CheckMoving{isMovingFromParent?}
    CheckMoving -->|Yes| NilCoordinator[coordinator = nil]
    CheckMoving -->|No| KeepCoordinator[Keep Coordinator Reference]
    NilCoordinator --> Deinit[Deinit MovieDetailHostingController]
    Deinit --> ViewModelDeinit[Deinit MovieDetailViewModel]
    ViewModelDeinit --> PopNav[Pop Navigation Stack]
    PopNav --> End([Return to Previous Screen])
```

---

## 6. TCA-Inspired State Management Flow

```mermaid
flowchart TD
    Start([User Interaction]) --> Dispatch[Dispatch Action to Store]
    Dispatch --> StoreReceive[Store.dispatch(action)]
    StoreReceive --> CallReducer[Reducer.reduce(state, action)]
    
    CallReducer --> UpdateState[Update State]
    UpdateState --> CreateEffect{Effect Needed?}
    
    CreateEffect -->|Effect.none| PublishState[Publish State to Subscribers]
    CreateEffect -->|Effect.task| ExecuteTask[Execute Async Task]
    
    ExecuteTask --> RunAsync[Run Async Operation]
    RunAsync --> APICall{API Call Type}
    
    APICall -->|Fetch Movies| FetchMovies[MovieService.fetchMoviesByPerson]
    APICall -->|Search Movies| SearchMovies[MovieService.searchMovies]
    APICall -->|Search Actor| SearchActor[MovieService.searchPerson]
    APICall -->|Similar Movies| SimilarMovies[MovieService.fetchSimilarMovies]
    
    FetchMovies --> NetworkLayer[Networking Layer]
    SearchMovies --> NetworkLayer
    SearchActor --> NetworkLayer
    SimilarMovies --> NetworkLayer
    
    NetworkLayer --> HTTPRequest[APIClient.request]
    HTTPRequest --> TMDBAPI[TMDB API Server]
    TMDBAPI --> ParseResponse{Response Status}
    
    ParseResponse -->|Success| DecodeJSON[Decode JSON Response]
    ParseResponse -->|Error| CreateErrorAction[Create Error Action]
    
    DecodeJSON --> CreateSuccessAction[Create Success Action]
    CreateSuccessAction --> DispatchResult[Dispatch Result Action to Store]
    CreateErrorAction --> DispatchResult
    
    DispatchResult --> CallReducer
    PublishState --> UpdateUI[UI Components Observe State]
    UpdateUI --> RenderView[Re-render View]
    RenderView --> End([Updated UI Displayed])
```

---

## 7. Image Caching & Loading Flow

```mermaid
flowchart TD
    Start([Need to Load Image]) --> CheckSource{Image Source}
    
    CheckSource -->|MovieCell UIKit| CellLoad[MovieCell.configure]
    CheckSource -->|DetailView SwiftUI| SwiftUILoad[CachedAsyncImage]
    CheckSource -->|Prefetch| PrefetchLoad[UICollectionViewDataSourcePrefetching]
    
    CellLoad --> CreateCacheKey[cacheKey = posterURL.absoluteString]
    SwiftUILoad --> CreateCacheKey
    PrefetchLoad --> CreateCacheKey
    
    CreateCacheKey --> CheckMemoryCache{Check Memory Cache}
    CheckMemoryCache -->|Hit| ReturnCached[Return Cached UIImage]
    ReturnCached --> DisplayImage[Display Image Immediately]
    
    CheckMemoryCache -->|Miss| CheckDiskCache{Check Disk Cache}
    CheckDiskCache -->|Hit| LoadFromDisk[Load Image from Disk]
    LoadFromDisk --> SaveToMemory[Save to Memory Cache with Cost]
    SaveToMemory --> DisplayImage
    
    CheckDiskCache -->|Miss| CreateTask[Create Task for Download]
    CreateTask --> DownloadImage[URLSession.shared.data]
    DownloadImage --> CheckCancelled{Task Cancelled?}
    CheckCancelled -->|Yes| Abort([Abort Loading])
    CheckCancelled -->|No| CreateUIImage[Create UIImage from Data]
    
    CreateUIImage --> CacheImage[Cache Image]
    CacheImage --> SaveMemory[Memory: NSCache with Cost]
    SaveMemory --> SaveDisk[Disk: Async Write to FileManager]
    SaveDisk --> UpdateUI[Update UI on MainActor]
    UpdateUI --> DisplayImage
    
    DisplayImage --> LifecycleEvent{Lifecycle Event}
    LifecycleEvent -->|Cell Reuse| CancelTask[Cancel Image Task]
    LifecycleEvent -->|View Disappear| CancelTask
    LifecycleEvent -->|Memory Warning| ClearCache[Clear Memory Cache]
    LifecycleEvent -->|App Background| ClearMemory[Clear Memory Cache]
    
    CancelTask --> NilTask[Task = nil]
    ClearCache --> RemoveAll[cache.removeAllObjects]
    ClearMemory --> RemoveAll
```

---

## 8. Memory Management Flow (VoiceOver & Deep Navigation)

```mermaid
flowchart TD
    Start([Navigate to Detail Screen]) --> CreateHosting[Create MovieDetailHostingController]
    CreateHosting --> StoreWeakRef[Store weak var coordinator]
    StoreWeakRef --> CreateViewModel[Create MovieDetailViewModel]
    CreateViewModel --> StoreTask[Store Task Reference in ViewModel]
    StoreTask --> PushNav[Push onto Navigation Stack]
    
    PushNav --> OnAppear[.onAppear Triggered]
    OnAppear --> SetActive[isViewActive = true]
    SetActive --> LoadData[Start Loading Similar Movies]
    LoadData --> CheckActive{View Still Active?}
    CheckActive -->|No| AbortLoad[Cancel Task]
    CheckActive -->|Yes| ContinueLoad[Complete Load]
    
    ContinueLoad --> UserNavigates{User Action}
    UserNavigates -->|Navigate to Similar Movie| DeepNav[Create New Detail Screen]
    DeepNav --> CreateHosting
    
    UserNavigates -->|Back Button| OnDisappear[.onDisappear Triggered]
    OnDisappear --> SetInactive[isViewActive = false]
    SetInactive --> CancelViewModelTask[viewModel.cancelLoading]
    CancelViewModelTask --> ViewDidDisappear[viewDidDisappear Called]
    
    ViewDidDisappear --> CheckMoving{isMovingFromParent?}
    CheckMoving -->|Yes| CleanupCoordinator[coordinator = nil]
    CheckMoving -->|No| SkipCleanup[Keep References]
    
    CleanupCoordinator --> HostingDeinit[MovieDetailHostingController.deinit]
    HostingDeinit --> ViewModelDeinit[MovieDetailViewModel.deinit]
    ViewModelDeinit --> CancelTasks[loadTask?.cancel]
    CancelTasks --> RemoveCombine[cancellables.removeAll]
    RemoveCombine --> LogDeinit[Print Debug Log]
    LogDeinit --> ReleaseMemory[Memory Released]
    
    ReleaseMemory --> CheckMemoryPressure{Memory Pressure?}
    CheckMemoryPressure -->|Yes| MemoryWarning[didReceiveMemoryWarning]
    CheckMemoryPressure -->|No| Normal[Normal Operation]
    
    MemoryWarning --> ClearImageCache[ImageCache.clearMemoryCache]
    ClearImageCache --> Normal
    
    Normal --> End([Memory Managed Properly])
```

---

## 9. Accessibility (VoiceOver) Flow

```mermaid
flowchart TD
    Start([App Launches]) --> CheckVO{VoiceOver Enabled?}
    CheckVO -->|No| NormalMode[Normal Visual UI]
    CheckVO -->|Yes| VOMode[VoiceOver Mode Active]
    
    VOMode --> MovieListScreen[Movie List Screen]
    MovieListScreen --> SetLabels[Set Accessibility Labels]
    SetLabels --> CheckState{Current State}
    
    CheckState -->|Normal Mode| SetActorLabel["accessibilityLabel = '[Actor Name] movies collection'"]
    CheckState -->|Search Mode| SetSearchLabel["accessibilityLabel = 'Search results for [query]'"]
    
    SetActorLabel --> SetHint["accessibilityHint = 'Scrollable list...'"]
    SetSearchLabel --> SetHint
    
    SetHint --> VONavigate{User Navigates}
    VONavigate -->|Swipe Right| NextElement[Focus Next Element]
    VONavigate -->|Swipe Left| PrevElement[Focus Previous Element]
    VONavigate -->|Double Tap| SelectElement[Activate Element]
    
    SelectElement --> CheckElement{Element Type}
    CheckElement -->|Movie Cell| ReadMovie["Announce: '[Title], [Year], Rating [X]%'"]
    CheckElement -->|Search Bar| ActivateSearch[Activate Search Field]
    
    ReadMovie --> VODetailNav{User Action}
    VODetailNav -->|Double Tap| NavigateDetail[Navigate to Detail Screen]
    VODetailNav -->|Back Swipe| ReturnList[Return to List]
    
    NavigateDetail --> DetailScreen[Movie Detail Screen]
    DetailScreen --> DetailLabels[Set Detail Accessibility Labels]
    DetailLabels --> ReadTitle[Announce Movie Title]
    ReadTitle --> ReadInfo[Read Rating, Release Date]
    ReadInfo --> ReadOverview[Read Overview Text]
    
    ReadOverview --> SimilarSection{Similar Movies Visible?}
    SimilarSection -->|Yes| ReadSimilar["Announce: 'Similar Movies'"]
    SimilarSection -->|No| EndDetail
    
    ReadSimilar --> VOSimilarNav{User Navigates Similar}
    VOSimilarNav -->|Swipe| FocusSimilar[Focus Similar Movie Card]
    VOSimilarNav -->|Double Tap| SelectSimilar[Navigate to Similar Movie]
    
    SelectSimilar --> NavigateDetail
    
    VOSimilarNav -->|Back Button| OnDisappearVO[Trigger Cleanup]
    OnDisappearVO --> CheckDepth{Navigation Depth}
    CheckDepth -->|Deep Stack| ReleaseMemory[Cancel Tasks & Release Memory]
    CheckDepth -->|Shallow| NormalBack[Standard Back Navigation]
    
    ReleaseMemory --> PreventHang[Prevent App Hang]
    PreventHang --> EndDetail[Return to Previous Screen]
    NormalBack --> EndDetail
    
    EndDetail --> UpdateLabels[Update List Labels Dynamically]
    UpdateLabels --> MovieListScreen
```

---

## 10. Testing Flow

```mermaid
flowchart TD
    Start([Run Tests]) --> TestSuite{Test Suite Type}
    
    TestSuite -->|Unit Tests| UnitTests[Unit Test Suites]
    TestSuite -->|Integration Tests| IntegrationTests[MMDBTests]
    
    UnitTests --> APITests[APIClientTests]
    UnitTests --> ReducerTests[MovieListReducerTests]
    UnitTests --> ModelTests[MovieModelTests]
    
    APITests --> MockAPIClient[Use MockAPIClient Protocol]
    MockAPIClient --> TestAPIScenarios{Test Scenarios}
    TestAPIScenarios --> TestSuccess[Test Valid Response]
    TestAPIScenarios --> TestHTTPError[Test HTTP Errors]
    TestAPIScenarios --> TestDecoding[Test Decoding Errors]
    TestAPIScenarios --> TestNetwork[Test Network Errors]
    
    ReducerTests --> MockService[Use MockMovieService]
    MockService --> TestReducerScenarios{Test Scenarios}
    TestReducerScenarios --> TestLoadMovies[Test Load Movies Action]
    TestReducerScenarios --> TestSearch[Test Search Action]
    TestReducerScenarios --> TestPagination[Test Load More Action]
    TestReducerScenarios --> TestError[Test Error Handling]
    
    ModelTests --> TestJSON[Test JSON Decoding]
    TestJSON --> TestModelScenarios{Test Scenarios}
    TestModelScenarios --> TestValid[Test Valid JSON]
    TestModelScenarios --> TestSpecial[Test Special Characters]
    TestModelScenarios --> TestProperties[Test Computed Properties]
    
    IntegrationTests --> ConfigTests[Configuration Tests]
    IntegrationTests --> CoordinatorTests[Coordinator Tests]
    IntegrationTests --> MemoryTests[Memory Management Tests]
    
    ConfigTests --> TestConfigScenarios{Test Scenarios}
    TestConfigScenarios --> TestValidKey[Test Valid API Key]
    TestConfigScenarios --> TestPlaceholder[Test Placeholder Detection]
    TestConfigScenarios --> TestMissingFile[Test Missing Config File]
    
    CoordinatorTests --> TestCoordScenarios{Test Scenarios}
    TestCoordScenarios --> TestInit[Test Initialization]
    TestCoordScenarios --> TestNav[Test Navigation Setup]
    TestCoordScenarios --> TestDependencies[Test Dependency Chain]
    
    MemoryTests --> TestMemScenarios{Test Scenarios}
    TestMemScenarios --> TestDealloc[Test Proper Deallocation]
    TestMemScenarios --> TestPerf[Test Performance]
    
    TestSuccess --> AssertResult[Assert Expected Result]
    TestHTTPError --> AssertResult
    TestDecoding --> AssertResult
    TestNetwork --> AssertResult
    TestLoadMovies --> AssertResult
    TestSearch --> AssertResult
    TestPagination --> AssertResult
    TestError --> AssertResult
    TestValid --> AssertResult
    TestSpecial --> AssertResult
    TestProperties --> AssertResult
    TestValidKey --> AssertResult
    TestPlaceholder --> AssertResult
    TestMissingFile --> AssertResult
    TestInit --> AssertResult
    TestNav --> AssertResult
    TestDependencies --> AssertResult
    TestDealloc --> AssertResult
    TestPerf --> AssertResult
    
    AssertResult --> TestPassed{Test Result}
    TestPassed -->|Pass| NextTest[Continue to Next Test]
    TestPassed -->|Fail| ReportFailure[Report Failure]
    NextTest --> AllDone{More Tests?}
    AllDone -->|Yes| TestSuite
    AllDone -->|No| End([All Tests Complete])
    ReportFailure --> End
```

---

## Legend

### Shapes
- **Rounded Rectangle**: Process/Action
- **Diamond**: Decision Point
- **Circle**: Start/End Point
- **Rectangle with Double Lines**: Subroutine/Module
- **Cylinder**: Data Storage

### Colors (if rendered)
- **Blue**: UI Layer
- **Green**: Business Logic
- **Orange**: Network Layer
- **Purple**: Data/Cache Layer
- **Red**: Error/Alert Flow

---

## Key Architectural Patterns

1. **Coordinator Pattern**: Navigation and flow control
2. **TCA-Inspired**: Unidirectional data flow with State/Action/Reducer
3. **Protocol-Oriented**: Dependency injection and testability
4. **Async/Await**: Modern Swift concurrency
5. **Memory Safety**: Weak references, task cancellation, lifecycle management
6. **Accessibility-First**: Comprehensive VoiceOver support

---

## Author
Tushar Chitnavis

