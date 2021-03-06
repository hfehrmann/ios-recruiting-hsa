//
//  ListMovieViewController.swift
//  ios-recruiting-hsa
//
//  Created by Hans Fehrmann on 5/28/19.
//  Copyright © 2019 Hans Fehrmann. All rights reserved.
//

import Foundation
import UIKit

class ListMovieViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var searchBar: CustomSearchBar!
    @IBOutlet private weak var activity: UIActivityIndicatorView!

    private weak var navigationBar: UINavigationBar?
    private lazy var emptySearch = EmptySearch()
    private lazy var errorSearch = ErrorSearch()

    private var viewModel: ListMovieViewModel
    private let movieCellIdentifier = "MovieCellIdentifier"
    private let cellsPerRow: CGFloat = 2
    private let interspace: CGFloat = 5

    init(navigationBar: UINavigationBar? = nil, viewModel: ListMovieViewModel) {
        self.viewModel = viewModel
        self.navigationBar = navigationBar
        super.init(nibName: "ListMovie", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("This view should not be instantiaded by storyboard")
    }

    override func viewDidLoad() {
        tabBarItem.title = viewModel.title
        tabBarItem.image = .list

        activity.hidesWhenStopped = true
        activity.stopAnimating()

        searchBar.backgroundColor = .app
        searchBar.searchBackgroundColor = .darkApp
        searchBar.placeholder = "Search"
        searchBar.delegate = self

        collectionView.register(
            MovieCollectionCellImpl.self,
            forCellWithReuseIdentifier: movieCellIdentifier
        )

        collectionView.dataSource = self
        collectionView.delegate = self

        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.shadowImage = UIImage()

        viewModel.startLoading = { [weak self] in
            self?.activity.startAnimating()
        }
        viewModel.stopLoading = { [weak self] in
            self?.activity.stopAnimating()
        }
        viewModel.onError = { [weak self] in
            self?.collectionView.backgroundView = self?.errorSearch
        }
        viewModel.onUpdate = { [unowned self] in
            if self.viewModel.count == 0 {
                self.emptySearch.set(text: self.viewModel.filterTextEmptySearch)
                self.collectionView.backgroundView = self.emptySearch
            } else {
                self.collectionView.backgroundView = nil
            }
            self.collectionView.reloadData()
        }
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.title = viewModel.title

        collectionView.reloadData()
    }
}

extension ListMovieViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width
        let edges = 2 * interspace
        let interspaceCell = interspace * (cellsPerRow - 1)
        let availableWidth = width - (edges + interspaceCell)

        let cellWidth = availableWidth / cellsPerRow
        let cellHeight = 1.4 * cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let edge = UIEdgeInsets(
            top: interspace,
            left: interspace,
            bottom: interspace,
            right: interspace
        )
        return edge
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return interspace
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return interspace
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(atIndex: indexPath)
    }
}

extension ListMovieViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let count = viewModel.count
        return count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let dequedCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: movieCellIdentifier,
            for: indexPath
        )
        guard let cell = dequedCell as? MovieCollectionCell else {
            return UICollectionViewCell()
        }
        let cellViewModel = viewModel.itemViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension ListMovieViewController: CustomSearchBarDelegate {

    func customSearchBar(_ customSearchBar: CustomSearchBar, currentText text: String) {
        viewModel.setCurrent(filterText: text)
    }
}
