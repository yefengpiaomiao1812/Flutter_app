import 'package:flutter/material.dart';
import '../services/ScreenAdapter.dart';
import 'package:provider/provider.dart';
import '../provider/CheckOut.dart';
import '../provider/CartProvider.dart';
import '../services/UserServices.dart';
import '../services/SignServices.dart';
import '../services/CheckOutServices.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../config/Config.dart';
import 'package:dio/dio.dart';

import '../services/EventBus.dart';
import 'dart:convert';

// 结算页面
class CheckOutPage extends StatefulWidget {
  CheckOutPage({Key key}) : super(key: key);

  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  // 默认收货地址
  List _addressList = [];

  @override
  void initState() {
    super.initState();
    this._getDefaultAddress();

    //监听广播
    eventBus.on<CheckOutEvent>().listen((event) {
      print(event.str);
      this._getDefaultAddress();
    });
  }

  // 获取默认收货地址
  _getDefaultAddress() async {
    List userinfo = await UserServices.getUserInfo();

    // print('1234');
    var tempJson = {"uid": userinfo[0]["_id"], "salt": userinfo[0]["salt"]};

    var sign = SignServices.getSign(tempJson);

    var api =
        '${Config.oneAddressListApi}?uid=${userinfo[0]["_id"]}&sign=${sign}';
    var response = await Dio().get(api);

    print(response);
    setState(() {
      this._addressList = response.data['result'];
    });
  }

  // 立即下单
  _doOrder(checkOutProvider, cartProvider) async {

    // 判断是否有收货地址
    if (this._addressList.length <= 0) {
      Fluttertoast.showToast(
        msg: '请添加收货地址',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    // 获取用户信息
    List userinfo = await UserServices.getUserInfo();
    //注意：商品总价保留一位小数
    var allPrice =
        CheckOutServices.getAllPrice(checkOutProvider.checkOutListData)
            .toStringAsFixed(1);
    //获取签名
    var sign = SignServices.getSign({
      "uid": userinfo[0]["_id"],
      "phone": this._addressList[0]["phone"],
      "address": this._addressList[0]["address"],
      "name": this._addressList[0]["name"],
      "all_price": allPrice,
      "products": json.encode(checkOutProvider.checkOutListData),
      "salt": userinfo[0]["salt"] //私钥
    });

    //请求接口
    var api = '${Config.doOrderApi}';
    var response = await Dio().post(api, data: {
      "uid": userinfo[0]["_id"],
      "phone": this._addressList[0]["phone"],
      "address": this._addressList[0]["address"],
      "name": this._addressList[0]["name"],
      "all_price": allPrice,
      "products": json.encode(checkOutProvider.checkOutListData),
      "sign": sign
    });

    print(response);
    if (response.data["success"]) {
      //删除购物车选中的商品数据
      await CheckOutServices.removeUnSelectedCartItem();

      //调用CartProvider更新购物车数据
      cartProvider.updateCartList();

      //跳转到支付页面
      Navigator.pushNamed(context, '/pay');
    }
  }

  // 结算页面列表
  Widget _checkOutItem(item) {
    return Row(
      children: <Widget>[
        Container(
          width: ScreenAdapter.width(160),
          child: Image.network("${item["pic"]}", fit: BoxFit.cover),
        ),
        Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${item["title"]}", maxLines: 2),
                  Text("${item["selectedAttr"]}", maxLines: 2),
                  Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("￥${item["price"]}",
                            style: TextStyle(color: Colors.red)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("x${item["count"]}"),
                      )
                    ],
                  )
                ],
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var checkOutProvider = Provider.of<CheckOut>(context);

    var cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("结算"),
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    this._addressList.length > 0
                        ? ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    "${this._addressList[0]["name"]}  ${this._addressList[0]["phone"]}"),
                                SizedBox(height: 10),
                                Text("${this._addressList[0]["address"]}"),
                              ],
                            ),
                            trailing: Icon(Icons.navigate_next),
                            onTap: () {
                              Navigator.pushNamed(context, '/addressList');
                            },
                          )
                        : ListTile(
                            leading: Icon(Icons.add_location),
                            title: Center(
                              child: Text("请添加收货地址"),
                            ),
                            trailing: Icon(Icons.navigate_next),
                            onTap: () {
                              Navigator.pushNamed(context, '/addressAdd');
                            },
                          ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(ScreenAdapter.width(20)),
                child: Column(
                    children: checkOutProvider.checkOutListData.map((value) {
                  return Column(
                    children: <Widget>[_checkOutItem(value), Divider()],
                  );
                }).toList()),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(ScreenAdapter.width(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("商品总金额:￥100"),
                    Divider(),
                    Text("立减:￥5"),
                    Divider(),
                    Text("运费:￥0"),
                  ],
                ),
              )
            ],
          ),
          Positioned(
            bottom: 0,
            width: ScreenAdapter.width(750),
            height: ScreenAdapter.height(100),
            child: Container(
              padding: EdgeInsets.all(5),
              width: ScreenAdapter.width(750),
              height: ScreenAdapter.height(100),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(width: 1, color: Colors.black26))),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("总价:￥140", style: TextStyle(color: Colors.red)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: RaisedButton(
                      child:
                          Text('立即下单', style: TextStyle(color: Colors.white)),
                      color: Colors.red,
                      onPressed: () {
                        // 下单
                        _doOrder(checkOutProvider, cartProvider);
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
