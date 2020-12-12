import SwiftUI
import UIKit
import RxSwift

final class RxTasksViewController: UIViewController {
    enum Section {
        case main
    }

    typealias Item = RxTaskCellViewModel

    private let bag = DisposeBag()

    let viewModel: RxTasksViewModel = .init(taskRepository: Factory.create())

    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil

    let newTaskButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureNewTaskButton()

        let stack = UIStackView(arrangedSubviews: [
            collectionView,
            newTaskButton
        ])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            collectionView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            newTaskButton.heightAnchor.constraint(equalToConstant: 40),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])

        viewModel.onAppear()
        viewModel.taskCellViewModels
            .subscribe(onNext: { [unowned self] cellViewModels in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(cellViewModels)
                self.dataSource.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: bag)
    }

    private func configureNewTaskButton() {
        newTaskButton.setImage(
            UIImage(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        newTaskButton.setTitle("New Task", for: .normal)
        newTaskButton.tintColor = .systemBlue
        newTaskButton.setTitleColor(.systemBlue, for: .normal)
        newTaskButton.contentEdgeInsets = UIEdgeInsets(
            top: newTaskButton.imageEdgeInsets.top,
            left: newTaskButton.imageEdgeInsets.left,
            bottom: newTaskButton.imageEdgeInsets.bottom,
            right: newTaskButton.imageEdgeInsets.right + 6
        )
        newTaskButton.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 6,
            bottom: 0,
            right: -6
        )
        newTaskButton.addTarget(self, action: #selector(onNewTaskButtonTapped), for: .touchUpInside)
    }

    private func configureCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            let delete = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
                self.viewModel.onTaskDeleted(atOffsets: .init(integer: indexPath.row))
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        collectionView.backgroundColor = .clear

        let cellRegistration = UICollectionView.CellRegistration<RxTaskCollectionViewListCell, Item> { (cell, indexPath, item) in
            cell.onCommit = { [unowned self] result in
                if case .success(let task) = result {
                    self.viewModel.onTaskAdded(task: task)
                }
            }
            cell.update(with: item)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }

    @objc private func onNewTaskButtonTapped() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        let newItem = Item(task: .init(), taskRepository: Factory.create())
        snapshot.appendItems(viewModel.taskCellViewModels.value + [newItem])
        dataSource!.apply(snapshot, animatingDifferences: true)
    }
}

extension RxTasksViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RxTasksViewController {
        RxTasksViewController()
    }

    func updateUIViewController(_ uiViewController: RxTasksViewController, context: Context) {}
}

extension RxTaskCellViewModel: Hashable {
    static func == (lhs: RxTaskCellViewModel, rhs: RxTaskCellViewModel) -> Bool {
        lhs.task.value.id == rhs.task.value.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(task.value.id)
    }
}
