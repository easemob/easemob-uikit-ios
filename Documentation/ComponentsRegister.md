# 如何继承组件注册并自定义

所有的可继承组件都在ComponentsRegister.swift中，继承后替换原有的组件即可。


## 1.下面展示如何自定义位置消息cell。

```Swift
class CustomLocationMessageCell: LocationMessageCell {
    //创建返回你想展示的view即可，气泡会包裹住您的view
    @objc open override func createContent() -> UIView {
        UIView(frame: .zero).backgroundColor(.clear).tag(bubbleTag)
    }
}
//在EaseChatUIKit中注册继承原有类的自定义类来替换原来的类。
//在创建消息页面或使用其他UI组件之前调用此方法。
ComponentsRegister.shared.ChatLocationCell = CustomLocationMessageCell.self
```

## 2.下面展示如何继承注册基础的消息类型以及消息样式

```Swift
    ComponentsRegister.shared.registerCustomizeCellClass(cellType: YourMessageCell.self)
    class YourMessageCell: MessageCell {
        override func createAvatar() -> ImageView {
            ImageView(frame: .zero)
        }
    }
```

## 3.下面展示如何继承注册自定义MessageListViewModel

```Swift
    //继承原有的类型
    class CustomMessagesViewModel: MessageListViewModel {
        override func loadMessages() {
            //如果你想在之前已有的逻辑做改动需要调用super
            super.loadMessages()
            //如果不需要原有的逻辑则不需要调用super
        }
    }
    //注册要使用的类型        
    ComponentsRegister.shared.MessagesViewModel = CustomMessagesViewModel.self
```

## 4.下面展示如何继承注册自定义MessageListViewController

```Swift
    //继承原有的类型
    class CustomMessagesViewController: MessageListViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            //如果你想在之前已有的逻辑做改动需要调用super
            //如果不需要原有的逻辑则不需要调用super
        }
    }
    //注册要使用的类型        
    ComponentsRegister.shared.MessageViewController = CustomMessagesViewController.self
```

## 5.其他模块自定义示例请参考上述示例，原理一样
