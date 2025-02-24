//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation

class TodosVM {
    
    //API를 통해 불러온 데이터들
    var todos:[Todo] = [] {
        didSet {
            self.notifyTodosChanged?(todos)
        }
    }
    //데이터들이 변경되었을 때 호출됨
    var notifyTodosChanged: (([Todo]) ->Void)? = nil
    
    //현재 페이지 값
    var currentPage:Int = 1 {
        didSet {
            self.notifyCurrentPage?(currentPage)
        }
    }
    //페이지 값이 변경될 때 호출됨
    var notifyCurrentPage: ((Int) -> Void)? = nil
    
    //데이터를 불러오는 중인지 아닌지
    var isLoading = false {
        didSet {
            self.notifyIsLoading?(isLoading)
        }
    }
    //데이터를 불러오거나 끝났을 때 호출됨
    var notifyIsLoading: ((Bool) -> Void)? = nil
    
    
    
    var notifyRefresh: (() -> Void)? = nil
    
    //MARK: - sangjin 검색 결과 유무 변수
    var notifyNotFoundSearchResult: ((Bool) -> Void)? = nil
    
    
    //search word
    var searchTerm: String = "" {
        didSet {
            
            //MARK: - sangjin change
            if searchTerm.count > 0 {
                self.searchTodos(searchTerm: searchTerm)
            } else {
                self.fetchTodos()
            }
        }
    }
    
    
    //마지막 페인지 확인하기 위한 변수
    var beforePageCount = 0
    var afterPageCount = 0
    
    
    
    init(){
        fetchTodos()
    }// init
    
    
    func searchTodos(searchTerm: String, page: Int = 1) {
        
        if searchTerm.count < 0 {
            print("검색어가 없습니다.")
            return
        }
        
        
        if isLoading {
            return
        }
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            TodosAPI.searchTodos(searchTerm: searchTerm, completion: { result in
                switch result {
                case .success(let response):
                    self.currentPage = page
                    if let fetchedTodos:[Todo] = response.data {
                        
                        if page == 1 {
                            //MARK: - sangjin
//                            if fetchedTodos.isEmpty {
//                                print("검색 결과가 없습니다. 차상진")
//                            }
                            
                            self.todos = fetchedTodos.shuffled()
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        
                    } else {
                        print("데이터 없다니까 상진")
                    }
                    
                case .failure(let fail):
                    print("failure: \(fail)")
                    
                    //MARK: - sangjin
                    self.todos = []
                }
                
                //MARK: - sangjin
                if self.todos.isEmpty && searchTerm.count > 0 {
                    print(#file, #function, #line, "- 검색 결과가 없습니다. 차상진")
                    self.notifyNotFoundSearchResult?(true)
                } else {
                    self.notifyNotFoundSearchResult?(false)
                }
                
                self.notifyRefresh?()
                self.isLoading = false
                
            })
            
        })
        
        
    }
    
    func fetchRefresh() {
        fetchTodos(page: 1)
    }
    
    
    func fetchMore() {
        if self.currentPage < 3 {
            fetchTodos(page: currentPage + 1)
        }
    }
    
    
    func fetchTodos(page: Int = 1) {
        
        if isLoading {
            return
        }
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            TodosAPI.fetchTodos(completion: { result in
                switch result {
                case .success(let response):
                    self.currentPage = page
                    if let fetchedTodos:[Todo] = response.data {
                        
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                           
                        }
                        
                    } else {
                        print("데이터 없다니까 상진")
                    }
                    
                case .failure(let fail):
                    print("failure: \(fail)")
                }
                self.notifyRefresh?()
                self.isLoading = false
                
            })
            
        })
        
        
    }
    
    
    
    
    /// API 에러처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        if err is TodosAPI.ApiError {
            let apiError = err as! TodosAPI.ApiError
            
            print("handleError : err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음")
            case .unauthorized:
                print("인증안됨")
            case .decodingError:
                print("디코딩 에러입니당ㅇㅇ")
            default:
                print("default")
            }
        }
        
    }// handleError
    
}
