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
    @IBOutlet weak var myTableView:                 UITableView!
    @IBOutlet var      currentPageLabel:            UILabel!
    @IBOutlet var      searchBar:                   UISearchBar!
    @IBOutlet var      addTodoButton:               UIButton!
    @IBOutlet var      selectedTodosDeleteButton:   UIButton!
    @IBOutlet var      selectedTodos:               UILabel!
    
    
    var searchTermInputWorkItem: DispatchWorkItem? = nil
    
    
    //MARK: - view 모음
    
    //밑에서 데이터가 로딩될 때 나타나는 인디케이터
    lazy var bottomIndicatorView:    UIActivityIndicatorView = getBottomIndicatorView()
    
    // 테이블뷰 위에서 당길때 나타나는 인디케이터
    lazy var refreshControl:         UIRefreshControl        = getRefreshControl()
    
    //검색 결과가 없을때 나타날 뷰
    lazy var searchDataNotFoundView: UIView                  = getSearchDataNotFoundView()
    
    //마지막 페이지 뷰
    lazy var lastPageView:           UIView                  = getLastPageView()
    
    //할일 추가 알림창
    lazy var addTodoAlert:           UIAlertController       = getAddTodoAlert()
    
    //알림 추가 에러 알림창
    lazy var addTodoAlertError:      UIAlertController       = getAddTodoAlertError()
    
   
    
    
    
    
    
    //MARK: - sangjin
    //검색결과 변수
    var notFoundSearchResult: Bool = false
    
    var todos: [Todo] = []
    var todosVM = TodosVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemYellow
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        self.myTableView.refreshControl = self.refreshControl
        
        
        
        //서치바 설정
        self.searchBar.searchTextField.addTarget(self, action: #selector(searchTermChanged(_:)), for: .editingChanged)
        
        
        self.addTodoButton.addTarget(self, action: #selector(appearAddTodoAlert(_:)), for: .touchUpInside)
        
        self.selectedTodosDeleteButton.addTarget(self, action: #selector(deleteTodosAction(_:)), for: .touchUpInside)
        
        
        
        
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
        
        self.todosVM.notifySelectedTodosChanged = { [weak self] selectedTodos in
            guard let self = self else { return }
            DispatchQueue.main.async {
                
                
                let selectedTodosString = selectedTodos.map{ "\($0)" }.joined(separator: ", ")
                self.selectedTodos.text = "선택된 할일들: [\(selectedTodosString)]"
            }
        }
        
        
        
    }// viewDidLoad
}



//MARK: - View 반환 함수들
extension MainVC {
    
//인디케이터
    // 위에서 당기면 나타나는 인디케이터
    fileprivate func getRefreshControl() -> UIRefreshControl {
        let refresh = UIRefreshControl()
         refresh.attributedTitle = NSAttributedString(string: "당겨버리기...")
         refresh.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
         return refresh
    } // getRefreshControl
    
 
    // 밑에 데이터가 로딩될 때 나타나는 인디케이터
    fileprivate func getBottomIndicatorView() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        indicator.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: self.myTableView.bounds.width, height: 100))
        return indicator
    } // getBottomIndicatorView
    
    
    
//알림창
    //알림 추가 에러 알림창
    fileprivate func getAddTodoAlertError() -> UIAlertController {
        let alert = UIAlertController(title: "할일 추가 오류", message: "할일이 추가되지 않았습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        
        return alert
    } // getAddTodoAlertError
    
    //할일 추가 알림창
    fileprivate func getAddTodoAlert() -> UIAlertController {
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
    } // getAddTodoAlert
    
    
    //할일 삭제 알림창
    fileprivate func getDeleteTodoAlert(_ id: Int) -> UIAlertController {
        let alert = UIAlertController(title: "할일 삭제", message: "'\(id)' 를 삭제하시겠습니까?", preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "닫기", style: .cancel)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: {_ in 
            self.todosVM.deleteTodo(id)
        })
        
        alert.addAction(closeAction)
        alert.addAction(deleteAction)
        
        return alert
    }
    
    
    //할일 편집 알림창
    fileprivate func getEditTodoAlert(_ id: Int, _ beforeEditText: String) -> UIAlertController {
        let alert = UIAlertController(title: "할일 편집", message: "내용을 입력해주세요.", preferredStyle: .alert)
        
        var afterEditText = ""
        alert.addTextField { (textField) in
            textField.placeholder = "할일 추가"
            textField.text = beforeEditText /*beforeText*/
        }
        alert.addAction(UIAlertAction(title: "닫기", style: .destructive))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            if let txt = alert.textFields?.last?.text {
                self.todosVM.editTodo(id, txt)
            }
        }))
        return alert
    } // getAddTodoAlert
    
    
    
//뷰
    //마지막 페이지 뷰
    fileprivate func getLastPageView() -> UIView {
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
    } // getLastPageView
    
    
    //검색 결과가 없을때 나타날 뷰
    fileprivate func getSearchDataNotFoundView() -> UIView {
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
    } // getSearchDataNotFoundView
    
 
    
    
    
    
    
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
    
    @objc func deleteTodosAction(_ sender: UIButton) {
        self.todosVM.deleteTodos()
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
        
        cell.updateUI(cellData, self.todosVM.selectedTodosId)
        
        cell.deletedActionEvent = {
            let alert = self.getDeleteTodoAlert($0)
            self.present(alert, animated: true)
        }
        
        cell.editActionEvent = { id, title in
            let alert = self.getEditTodoAlert(id, title)
            self.present(alert, animated: true)
        }
        
        //MARK: - sangjin delete todo
//           cell.parentVC = self
        
        
        cell.selectedActionEvent = { id, isOn in
            self.todosVM.handleTodoSelection(id, isOn)
        }
        
        
        
        
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
