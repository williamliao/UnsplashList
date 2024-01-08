//
//  UnsplashListTests.swift
//  UnsplashListTests
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import XCTest
@testable import UnsplashList
import SwiftUI
import Combine

final class UnsplashListTests: XCTestCase {
    
    var cancellable: AnyCancellable!
    
    private var unsplashModels: [UnsplashModel]!
    @State var navigationPath: [Route] = []
    private var networking: NetworkingMock!
    private var viewModel: GridViewModel!
    
    private var gridViewCoordinator: GridViewCoordinator!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let testBundle = Bundle(for: type(of: self))
        let filePath = testBundle.path(forResource: "unsplash", ofType: "json")
        
        guard let filePath = filePath else {
            return
        }
        
        let modelData = try Data(contentsOf: URL(fileURLWithPath: filePath))
        
        let decoder = JSONDecoder()
        unsplashModels = try decoder.decode([UnsplashModel].self, from: modelData)
        
        let response = HTTPURLResponse(url: URL(string: "TestUrl")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        networking = NetworkingMock(response)
        let imageService = ImagesService(withSession:networking)
        
       // navigationPath.append(.grid)
        let coordinator = HomeCoordinator(imagesService: imageService)
        gridViewCoordinator = GridViewCoordinator(imagesService: imageService, parent: coordinator)
        
        viewModel = GridViewModel(imagesService: imageService, coordinator:  gridViewCoordinator)
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGridViewModelData() throws {
        
        let model = unsplashModels.first
        
        let expectation = expectation(description: "testGridViewModelData")
        
        networking.result = .success(try JSONEncoder().encode(unsplashModels))

        viewModel.loadData()
        
        cancellable = viewModel.$items.sink(receiveValue: {
            
            if $0.count > 0 {
                XCTAssertNotNil($0)
                
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 3)

        let model2 = viewModel.items.first
       
        XCTAssertEqual(model2?.id, model?.id)
        XCTAssertNotNil(model2)
    }
    
    
    func testGridViewModelLoadDataFailed() throws {
        
        let endPoint: Endpoint = .random(with: "10")
        
        guard let request = endPoint.makeRequest(with: ()), let url = request.url else {
            return
        }
        
        let fakeResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)
        
        networking.result = .success(Data())
        networking.nextResponse = fakeResponse
        
        let expectation = expectation(description: "testGridViewModelLoadDataFailed")

        viewModel.loadData()
        
        cancellable = viewModel.$error.sink(receiveValue: {
            
            if $0 != nil {
                XCTAssertNotNil($0)
                
                expectation.fulfill()
            }
            
            
        })
        
        waitForExpectations(timeout: 3)
    
        guard let error = viewModel.error else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(error.localizedDescription, "Client Error With Status Code:\(400)")
    }

    func testGridViewTapImage() {
        guard let model = unsplashModels.first else { return  }
        viewModel.open(model: model)
        
        cancellable = gridViewCoordinator.$detailViewModel.sink(receiveValue: {
            
            XCTAssertNotNil($0)
            
            print("detailViewModel create, new value: \(String(describing: $0))")
        })
        
    }
    
    func testViewModelUpdate() {
        guard let model = unsplashModels.first else { return  }
        
        viewModel.items.append(model)
        
        cancellable = viewModel.$items.sink(receiveValue: {
            
            XCTAssertNotNil($0)
            
            print("ViewModel.alarm updated, new value: \($0)")
        })
        
//        viewModel.objectWillChange.sink(receiveValue: {
//            XCTAssertNotNil($0)
//            print("ViewModel updated: \($0)")
//        })
    }
}
