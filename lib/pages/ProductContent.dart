import 'package:flutter/material.dart';
import '../services/EventBus.dart';
import '../services/ScreenAdapter.dart';

import 'ProductContent/ProductContentFirst.dart';
import 'ProductContent/ProductContentSecond.dart';
import 'ProductContent/ProductContentThird.dart';

import '../widget/JdButton.dart';
import '../config/Config.dart';
import 'package:dio/dio.dart';
import '../model/ProductContentModel.dart';
import '../widget/LoadingWidget.dart';
import 'package:provider/provider.dart';
import '../provider/CartProvider.dart';
import '../services/CartServices.dart';
import 'package:fluttertoast/fluttertoast.dart';

// 商品详情
class ProductContentPage extends StatefulWidget {
  final Map arguments;

  ProductContentPage({Key key, this.arguments}) : super(key: key);

  _ProductContentPageState createState() => _ProductContentPageState();
}

class _ProductContentPageState extends State<ProductContentPage> {

  // 本页商品详情数据实体
  ProductContentModel productContentModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 详情数据请求
    this._getContentData();
  }

  // 获取商品详情数据
  _getContentData() async{

    var api ='${Config.pcontentApi}?id=${widget.arguments['id']}';
    //print(api);

    var result = await Dio().get(api);
    var productContent = new ProductContentModel.fromJson(result.data);
    //print(productContent.result);

    setState(() {
      this.productContentModel = productContent;
    });
  }

  @override
  Widget build(BuildContext context) {

    var cartProvider = Provider.of<CartProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenAdapter.width(400),
                child: TabBar(
                  indicatorColor: Colors.red,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: <Widget>[
                    Tab(
                      child: Text('商品'),
                    ),
                    Tab(
                      child: Text('详情'),
                    ),
                    Tab(
                      child: Text('评价'),
                    )
                  ],
                ),
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () {
                showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                        ScreenAdapter.width(600), 76, 10, 0),
                    items: [
                      PopupMenuItem(
                        child: Row(
                          children: <Widget>[Icon(Icons.home), Text("首页")],
                        ),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: <Widget>[Icon(Icons.search), Text("搜索")],
                        ),
                      )
                    ]);
              },
            )
          ],
        ),
        body: this.productContentModel != null?Stack(
          children: <Widget>[
            TabBarView(
              //禁止TabBarView滑动
              physics: NeverScrollableScrollPhysics(),

              children: <Widget>[
                ProductContentFirst(this.productContentModel),
                ProductContentSecond(this.productContentModel),
                ProductContentThird()
              ],
            ),
            Positioned(
              width: ScreenAdapter.width(750),
              height: ScreenAdapter.width(100),
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.black26, width: 1)),
                    color: Colors.white),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        // 跳转购物车页面
                        Navigator.pushNamed(context, '/cart');
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                        width: 100,
                        height: ScreenAdapter.height(100),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.shopping_cart),
                            Text("购物车")
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: JdButton(
                        color: Color.fromRGBO(253, 1, 0, 0.9),
                        text: "加入购物车",
                        cb: () async{
                          if(this.productContentModel.result.attr.length > 0){
                            //广播 弹出筛选
                            eventBus.fire(new ProductContentEvent('加入购物车'));
                          }else{
                            print("加入购物车操作");
                            await CartServices.addCart(this.productContentModel.result);
                            //调用Provider 更新数据
                            cartProvider.updateCartList();
                            Fluttertoast.showToast(
                                msg: "加入购物车成功",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: JdButton(
                        color: Color.fromRGBO(255, 165, 0, 0.9),
                        text: "立即购买",
                        cb: () {
                          if(this.productContentModel.result.attr.length > 0){
                            //广播 弹出筛选
                            eventBus.fire(new ProductContentEvent('立即购买'));
                          }else{
                            print("立即购买操作");
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ):LoadingWidget(),
      ),
    );
  }
}
