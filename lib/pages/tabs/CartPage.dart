import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pages/Cart/CartItem.dart';
import '../../services/ScreenAdapter.dart';
import '../../provider/CartProvider.dart';
import '../../services/CartServices.dart';
import '../../services/UserServices.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../provider/CheckOut.dart';

// 购物车页面
class CartPage extends StatefulWidget {
  CartPage({Key key}) : super(key: key);

  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  var checkOutProvider;

  // 删除按钮与结算按钮状态切换
  bool _isEdit = false;

  // 去结算
  doCheckOut() async {
    //1、获取购物车选中的数据
    List checkOutData = await CartServices.getCheckOutData();
    //2、保存购物车选中的数据
    this.checkOutProvider.changeCheckOutListData(checkOutData);
    //3、购物车有没有选中的数据
    if (checkOutData.length > 0) {
      //4、判断用户有没有登录
      var loginState = await UserServices.getUserLoginState();
      if (loginState) {
        Navigator.pushNamed(context, '/checkOut');
      } else {
        Fluttertoast.showToast(
          msg: '您还没有登录，请登录以后再去结算',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        Navigator.pushNamed(context, '/login');
      }
    } else {
      Fluttertoast.showToast(
        msg: '购物车没有选中的数据',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初始化获取屏幕长宽类
    ScreenAdapter.init(context);
    // 初始化Provider
    var cartProvider = Provider.of<CartProvider>(context);
    checkOutProvider = Provider.of<CheckOut>(context);

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("购物车"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.launch),
            onPressed: () {
              setState(() {
                this._isEdit = !this._isEdit;
              });
            },
          )
        ],
      ),
      body: cartProvider.cartList.length > 0
          ? Stack(
              children: <Widget>[
                // 列表
                ListView(
                  children: <Widget>[
                    Column(
                      children: cartProvider.cartList.map((value) {
                        return CartItem(value);
                      }).toList(),
                    ),
                    SizedBox(height: ScreenAdapter.height(100)),
                  ],
                ),

                //底部全选 和 按钮
                Positioned(
                  bottom: 0,
                  width: ScreenAdapter.width(750),
                  height: ScreenAdapter.height(78),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 1, color: Colors.black12)),
                        color: Colors.white),
                    width: ScreenAdapter.width(750),
                    height: ScreenAdapter.height(78),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: ScreenAdapter.width(60),
                                child: Checkbox(
                                  value: cartProvider.isCheckedAll,
                                  activeColor: Colors.pink,
                                  onChanged: (val) {
                                    //实现全选或者反选
                                    cartProvider.checkAll(val);
                                  },
                                ),
                              ),
                              Text("全选"),
                              SizedBox(width: 20),
                              this._isEdit==false?Text("合计:"):Text(""),
                              this._isEdit==false?Text("${cartProvider.allPrice}",style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.red
                              )):Text("")
                            ],
                          ),
                        ),
                        this._isEdit == false
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: RaisedButton(
                                  child: Text("结算",
                                      style: TextStyle(color: Colors.white)),
                                  color: Colors.blue,
                                  onPressed: doCheckOut,
                                ),
                              )
                            : Align(
                                alignment: Alignment.centerRight,
                                child: RaisedButton(
                                  child: Text("删除",
                                      style: TextStyle(color: Colors.white)),
                                  color: Colors.red,
                                  onPressed: () {
                                    cartProvider.removeItem();
                                  },
                                ),
                              )
                      ],
                    ),
                  ),
                )
              ],
            )
          : Center(
              child: Text("购物车空空的..."),
            ),
    );
  }
}
