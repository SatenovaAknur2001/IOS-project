//
//  TableViewController.swift
//  Project-1
//
//  Created by Акнур on 4/12/20.
//  Copyright © 2020 Акнур. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    
      private var movies = [String: [Movie]]() // коллекция ключ страница, значение массив фильмов
      private let searchController = UISearchController(searchResultsController: nil) // строка поиска
      private var lastSearch = "" //последний текст поиска
      
      override init(style: UITableView.Style) {
          super.init(style: style)
          tableView.register(UITableViewCell.self,
                             forCellReuseIdentifier: "reuseIdentifier")
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
      override func viewDidLoad() {
          super.viewDidLoad()
          setupTheSearchController()
      }
      func setupTheSearchController() {
          searchController.searchResultsUpdater = self //
          searchController.obscuresBackgroundDuringPresentation = false
          searchController.searchBar.placeholder = "Search"
          navigationItem.searchController = searchController
          definesPresentationContext = true
      }
      
      // MARK: - Table view data source
      override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          return "Page \(section + 1)" // название заголовка
      }
      override func numberOfSections(in tableView: UITableView) -> Int {
          return movies.count // количество секций т.е. страниц с фильмами
      }

      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          let moviesCount = movies[String(section)]?.count // количество фильмов на каждой странице
          return moviesCount ?? 1 // если количество фильмов nil тогда делаем его количество 1
      }
      
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
          let movie = movies[String(indexPath.section)]?[indexPath.row] // получаем фильм
          cell.textLabel?.text = movie?.title ?? "данные страницы \(indexPath.section + 1) не пришли" // присваиваем его титл лейблу ячейки, если такого фильма нет пишем что данные не пришли
          return cell
      }
      
      override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          guard let movie = movies[String(indexPath.section)]?[indexPath.row] else { return } // пытаемся получить фильм
          let vc = MovieViewController(movie: movie) //инициализируем вью контроллер
          self.navigationController?.pushViewController(vc, // переходим на вьюконтроллер
                                                        animated: true)
      }

  }
  extension TableViewController: UISearchResultsUpdating {
      // MARK: Results Updating
      func updateSearchResults(for searchController: UISearchController) {
          guard let searchText = searchController.searchBar.text, // получаем текст
              searchText != lastSearch else { return } // текст не должен быть равен последнему запросу
          lastSearch = searchText // последний запрос равен теперь новому запросу
          movies.removeAll() // удаляем старую коллекцию
          tableView.reloadData() // перезагружаем таблицу
          
          var page = 0 // счетчик страниц
          var canSearch = true // можно искать хначит
          while canSearch { // пока canSearch == true будет выполняться цикл while
              page += 1 // прибавляем 1 к счетчику т.е. какая страница загружается
              guard page <= 100, // страница должна быть меньше либо равной 100
                  searchController.searchBar.text == searchText, // проверка текст совпадает или нет
                  searchText == self.lastSearch else { // проверка текст совпадает или нет
                  canSearch = false // если условия нарушились тогда делаем чтоб не мог дальше повторяться цикл while
                  return // выход
              }
              let key = String(page) //ключ для сохранения массива фильмов в коллекцию
              let parameters: [String : String] = [ // коллекция параметров
                  "apikey": "7385a326", // ключ - апикей, значение - 7385a326  //// c7d5811
                  "s": searchText, // ключ - s, значение - введенный текст
                  "page": "\(page)" //ключ - page, значение - номер страницы
              ]
              NetworkManager.sendRequest("http://www.omdbapi.com/", parameters: parameters) { responseObject, error in
                  guard let responseObject = responseObject, //пришел ответ сервера и мы его закастили
                      error == nil, // нет ошибок
                      let search = responseObject["Search"] as? [[String: Any]] else { // по значеник серч получилось закастить массив коллекций
                      return // выход
                  }
                  
                  var movies = [Movie]() // массив фильмов
                  for movieDict in search { // проходимся по массиву коллекций
                      let movie = Movie(poster: movieDict["Poster"] as? String ?? "error",
                                        title: movieDict["Title"] as? String ?? "error",
                                        type: movieDict["Type"] as? String ?? "error",
                                        year: movieDict["Year"] as? String ?? "error",
                                        imdbID: movieDict["imdbID"] as? String ?? "error")
                      // по ключу Poster Title и тд получаем их значения текстовые либо по умолчанию еррор присваиваем
                      movies.append(movie) // добавляем фильм в массив фильмов
                  }
                  DispatchQueue.main.async {
                      self.movies[key] = movies // по ключу страницы в коллекцию добавляем массив фильмов
                      self.tableView.reloadData() // перезагружаем таблицу
                  }
              }
          }
      }
  }


