import UIKit
import Combine

class TaskCollectionViewListCell: UICollectionViewListCell, UITextFieldDelegate {
    private var cancellables = Set<AnyCancellable>()

    private var viewModel: TaskCellViewModel? = nil
    private var stack: UIStackView? = nil
    private let taskStateButton = UIButton()
    private let textField = UITextField()

    var onCommit: (Result<Task, InputError>) -> Void = { _ in }

    func update(with item: TasksViewController.Item) {
        guard viewModel != item else { return }

        cancellables = Set<AnyCancellable>()
        textField.text = item.task.title
        item.$taskStateIconName
            .sink { [taskStateButton] taskStateIconName in
                taskStateButton.setImage(
                    UIImage(systemName: taskStateIconName)?.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
            }
            .store(in: &cancellables)
        viewModel = item

        setNeedsUpdateConfiguration()
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        setupViewsIfNeeded()
    }

    @objc func onTaskStateButtonTapped() {
        viewModel?.onTaskStateIconTapped()
    }

    @objc private func onTextFieldDidChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }

        viewModel?.task.title = text
    }

    @objc private func onTextFieldDidEndEditting(_ textField: UITextField) {
        guard let text = textField.text else { return onCommit(.failure(.empty)) }

        onCommit(.success(.init(title: text)))
    }

    private func setupViewsIfNeeded() {
        guard stack == nil else { return }

        taskStateButton.addTarget(self, action: #selector(TaskCollectionViewListCell.onTaskStateButtonTapped), for: .touchUpInside)
        taskStateButton.tintColor = .label
        textField.textColor = .label
        textField.placeholder = "Enter task title"
        textField.addTarget(self, action: #selector(TaskCollectionViewListCell.onTextFieldDidChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(TaskCollectionViewListCell.onTextFieldDidEndEditting), for: .editingDidEndOnExit)

        let stack = UIStackView(arrangedSubviews: [
            taskStateButton,
            textField
        ])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            taskStateButton.heightAnchor.constraint(equalToConstant: 20),
            taskStateButton.widthAnchor.constraint(equalToConstant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        self.stack = stack
    }
}
