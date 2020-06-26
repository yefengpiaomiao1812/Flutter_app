import 'package:event_bus/event_bus.dart';

//Bus 初始化
EventBus eventBus = EventBus();

// 加入购物车广播
class ProductContentEvent {
  String str;

  ProductContentEvent(String str) {
    this.str = str;
  }
}

//用户中心广播
class UserEvent {
  String str;

  UserEvent(String str) {
    this.str = str;
  }
}

// 新增地址广播
class AddressEvent {
  String str;

  AddressEvent(String str) {
    this.str = str;
  }
}

//结算页面
class CheckOutEvent{
  String str;
  CheckOutEvent(String str){
    this.str=str;
  }
}
