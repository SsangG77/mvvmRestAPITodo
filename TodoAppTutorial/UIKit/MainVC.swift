//
//  MainVC.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/09.
//

import Foundation
import UIKit
import SwiftUI


class MainVC: UIViewController {
    
    //MARK: - outlet
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet var currentPageLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var addTodoButton: UIButton!
    
    
    var searchTermInputWorkItem: DispatchWorkItem? = nil
    
    
    //MARK: - view 모음
    
    lazy var bottomIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: self.myTableView.bounds.width, height: 100))
        return indicator
    }()
    
    lazy var refreshControl: UIRefreshControl = {
       let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "당겨버리기...")
        refresh.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        return refresh
    }()
    
    
    //검색 결과가 없을때 나타날 뷰
    lazy var searchDataNotFoundView: UIView = {
        let notDataFoundView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 300))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        notDataFoundView.addSubview(label)
        label.text = "검색 결과를 찾을 수 없습니다.🗑️"
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: notDataFoundView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: notDataFoundView.centerYAnchor)
        ])
        return notDataFoundView
    }()
    
    //마지막 페이지 뷰
    lazy var lastPageView: UIView = {
        let lastPageView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 100))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        lastPageView.addSubview(label)
        label.text = "더 이상 가져올 데이터가 없습니다."
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: lastPageView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: lastPageView.centerYAnchor)
        ])
        return lastPageView
    }()
    
    
    //할일 추가 알림창
    lazy var addTodoAlert: UIAlertController = {
        let alert = UIAlertController(title: "할일 추가", message: "할일을 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "할일 추가"
        }
        alert.addAction(UIAlertAction(title: "닫기", style: .destructive))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            if let txt = alert.textFields?.first?.text {
                self.todosVM.todoText = txt
            }
        }))
        return alert
    }()
    
    //MARK: - sangjin 알림 추가 에러 알림창
    lazy var addTodoAlertError: UIAlertController = {
        let alert = UIAlertController(title: "할일 추가 오류", message: "할일이 추가되지 않았습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        
        return alert
    }()
    
    
    
    
    //MARK: - sangjin
    //검색결과 변수
    var notFoundSearchResult: Bool = false
    
    var todos: [Todo] = []

    var todosVM = TodosVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(#fileID, #function, #line, "- ")
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.refreshControl = self.refreshControl
        
        
        
        //서치바 설정
        self.searchBar.searchTextField.addTarget(self, action: #selector(searchTermChanged(_:)), for: .editingChanged)
        
        
        self.addTodoButton.addTarget(self, action: #selector(appearAddTodoAlert(_:)), for: .touchUpInside)
        
        
        
        self.todosVM.notifyIsLoading = { isLoading in
            DispatchQueue.main.async {
                if isLoading {
                        self.myTableView.tableFooterView = self.bottomIndicatorView
                } else {
                    self.myTableView.tableFooterView = self.lastPageView
                }
            }
        }
        
        
        self.todosVM.notifyTodosChanged = { todos in
            self.todos = todos
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        
        self.todosVM.notifyCurrentPage = { page in
            DispatchQueue.main.async {
                self.currentPageLabel.text = "페이지: \(page)"
            }
        }
        
        self.todosVM.notifyRefresh = {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
        
        //MARK: - sangjin
        self.todosVM.notifyNotFoundSearchResult = { [weak self] result in
            //내가 한거
//            self.notFoundSearchResult = result
            
            
            //강의
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.myTableView.backgroundView = result ? self.searchDataNotFoundView : nil
            }
        }
        
        
        //MARK: - sangjin 서버로부터 에러가 응답되었을때 실행할 클로저
        self.todosVM.addTodoError = {
            DispatchQueue.main.async {
                self.present(self.addTodoAlertError, animated: true)
            }
        }
        
        
        
        
        self.todosVM.addTodoSuccess = {
            DispatchQueue.main.async {
                self.myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        
        
        
        
        
        
    }// viewDidLoad
}


//MARK: - extention 액션 설정들
extension MainVC {
    @objc fileprivate func refresh(_ sender:UIRefreshControl) {
        self.todosVM.fetchRefresh()
    }
    
    
    //검색창에 입력할때마다 호출됨.
    @objc func searchTermChanged(_ sender: UITextField) {
        
        //검색어를 입력할때마다 기존 작업을 취소
        searchTermInputWorkItem?.cancel()
        
        let dispatchWorkItem = DispatchWorkItem(block: {
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async { [weak self] in
                    guard let userInput = sender.text,
                          let self = self
                    else { return }
                    self.todosVM.searchTerm = userInput
                }
            }
        })
        //작업 재실행
        self.searchTermInputWorkItem = dispatchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
    }// - searchTermChanged
    
    
    // 할일 추가 알림창 띄우기
    @objc func appearAddTodoAlert(_ sender:UIButton) {
        self.present(addTodoAlert, animated: true)
    }
    
    
    
}


//MARK: - extention TableView 스크롤 설정
extension MainVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.contentSize.height
        let contentYOffset = scrollView.contentOffset.y
        let distance = scrollView.contentSize.height - contentYOffset
        
        if distance < height {
            self.todosVM.fetchMore()
            
        }
        
    }
}



extension MainVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let cellData = self.todos[indexPath.row]
        
        cell.updateUI(cellData)
        
        return cell
    }
}



extension MainVC {
    
    private struct VCRepresentable : UIViewControllerRepresentable {
        
        let mainVC : MainVC
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return mainVC
        }
    }
    
    func getRepresentable() -> some View {
        VCRepresentable(mainVC: self)
    }
}




//extension MainVC: UITableViewDelegate {
//    func tableView(
//        _ tableView: UITableView,
//        willDisplay cell: UITableViewCell,
//        forRowAt indexPath: IndexPath
//    ) {
//        let isLastCursor = indexPath.row == todos.count - 1
//        guard isLastCursor else { return }
//        print("load more")
//        tableView.reloadData()
//    }
//}
