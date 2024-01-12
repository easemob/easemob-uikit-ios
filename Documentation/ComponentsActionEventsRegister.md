# 拦截单群聊UIKit中组件中的点击事件

注意：拦截后的业务逻辑与UI刷新逻辑用户需要完全自己去实现，建议使用注册继承即可更优雅的实现需求。

## 1.会话列表

- swipeAction 滑动事件
        
- longPressed 长按事件
        
- didSelected 点击事件

## 2.联系人列表

- didSelectedContact 点击联系人

- groupWithSelected 点击添加群成员或者创建群组选择成员

## 3.消息列表

- replyClicked 消息中引用消息气泡点击
        
- bubbleClicked 消息气泡点击
        
- bubbleLongPressed 消息气泡长按
        
- avatarClicked 头像点击
        
- avatarLongPressed 头像长按
        
