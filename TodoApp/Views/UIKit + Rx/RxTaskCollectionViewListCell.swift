import UIKit
import RxSwift

class RxTaskCollectionViewListCell: UICollectionViewListCell, UITextFieldDelegate {
    private var bag = DisposeBag()

    private var viewModel: RxTaskCellViewModel? = nil
    private var stack: UIStackView? = nil
    private let taskStateButton = UIButton()
    private let textField = UITextField()

    var onCommit: (Result<Task, InputError>) -> Void = { _ in }

    func update(with item: RxTasksViewController.Item) {
        guard viewModel != item else { return }

        bag = DisposeBag()
        textField.text = item.task.value.title
        item.taskStateIconName
            .subscribe(onNext: { [taskStateButton] taskStateIconName in
                taskStateButton.setImage(
                    UIImage(systemName: taskStateIconName)?.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
            })
            .disposed(by: bag)
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
        guard
            let text = textField.text,
            let viewModel = viewModel
        else { return }

        let current = viewModel.task.value
        viewModel.task.accept(Task(id: current.id, title: text, hasDone: current.hasDone))
    }

    @objc private func onTextFieldDidEndEditting(_ textField: UITextField) {
        guard let text = textField.text else { return onCommit(.failure(.empty)) }

        onCommit(.success(.init(title: text)))
    }

    private func setupViewsIfNeeded() {
        guard stack == nil else { return }

        taskStateButton.addTarget(self, action: #selector(RxTaskCollectionViewListCell.onTaskStateButtonTapped), for: .touchUpInside)
        taskStateButton.tintColor = .label
        textField.textColor = .label
        textField.placeholder = "Enter task title"
        textField.addTarget(self, action: #selector(RxTaskCollectionViewListCell.onTextFieldDidChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(RxTaskCollectionViewListCell.onTextFieldDidEndEditting), for: .editingDidEndOnExit)

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
