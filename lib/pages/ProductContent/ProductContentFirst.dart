import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/config/Config.dart';
import '../../services/CartServices.dart';
import '../../services/ScreenAdapter.dart';
import '../../widget/JdButton.dart';
import '../../model/ProductContentModel.dart';
import '../ProductContent/CartNum.dart';
import 'package:provider/provider.dart';
import '../../provider/CartProvider.dart';
import 'package:fluttertoast/fluttertoast.dart';
//广播
import '../../services/EventBus.dart';



class ProductContentFirst extends StatefulWidget {
  final ProductContentModel productContentModel;

  ProductContentFirst(this.productContentModel, {Key key}) : super(key: key);

  _ProductContentFirstState createState() => _ProductContentFirstState();
}

class _ProductContentFirstState extends State<ProductContentFirst>
    with AutomaticKeepAliveClientMixin {
  // 事件监听
  var actionEventBus;

  // 商品
  ProductContentitem _productContent;

  // 选择分类
  List _attr = [];

  // 选中的描述
  String _selectedValue;

  // 保存当前页面状态
  bool get wantKeepAlive => true;

  // 数据共享Provider
  var cartProvider;

  @override
  void initState() {
    super.initState();
    this._productContent = widget.productContentModel.result;

    this._attr = this._productContent.attr;

    // print(this._attr);
    //[{"cate":"鞋面材料","list":["牛皮 "]},{"cate":"闭合方式","list":["系带"]},{"cate":"颜色","list":["红色","白色","黄色"]}]

    // list":["系带","非系带"]

    /*
   [
      {
       "cate":"尺寸",
       list":[{
            "title":"xl",
            "checked":false
          },
          {
            "title":"xxxl",
            "checked":true
          },
        ]
      },
      {
       "cate":"颜色",
       list":[{
            "title":"黑色",
            "checked":false
          },
          {
            "title":"白色",
            "checked":true
          },
        ]
      }
  ]
   */
    // 初始化选中
    _initAttr();

    //监听广播
    //监听所有广播
    // eventBus.on().listen((event) {
    //   print(event);
    //   this._attrBottomSheet();
    // });
    this.actionEventBus = eventBus.on<ProductContentEvent>().listen((str) {
      print(str);
      this._attrBottomSheet();
    });
  }

  // EventBus销毁
  void dispose() {
    super.dispose();
    this.actionEventBus.cancel(); //取消事件监听
  }

  // 初始化选中
  _initAttr() {
    var attr = this._attr;
    for (var i = 0; i < attr.length; i++) {

      //清空数组里面的数据
      attr[i].attrList.clear();

      for (var j = 0; j < attr[i].list.length; j++) {
        // 设置第一个被选中
        if (j == 0) {
          attr[i].attrList.add({"title": attr[i].list[j], "checked": true});
        } else {
          attr[i].attrList.add({"title": attr[i].list[j], "checked": false});
        }
      }
    }

    // 获取选中的值
    _getSelectedAttrValue();
  }

  //获取选中的值
  _getSelectedAttrValue() {
    var _list = this._attr;
    List tempArr = [];
    for (var i = 0; i < _list.length; i++) {
      for (var j = 0; j < _list[i].attrList.length; j++) {
        if (_list[i].attrList[j]['checked'] == true) {
          tempArr.add(_list[i].attrList[j]["title"]);
        }
      }
    }
    // print(tempArr.join(','));
    // 设置选中的值
    setState(() {
      this._selectedValue = tempArr.join(',');
      //给筛选属性赋值
      this._productContent.selectedAttr=this._selectedValue;
    });
  }

  //改变属性值
  _changeAttr(cate, title, setBottomState) {
    var attr = this._attr;
    for (var i = 0; i < attr.length; i++) {
      if (attr[i].cate == cate) {
        for (var j = 0; j < attr[i].attrList.length; j++) {
          attr[i].attrList[j]["checked"] = false;
          if (title == attr[i].attrList[j]["title"]) {
            attr[i].attrList[j]["checked"] = true;
          }
        }
      }
    }
    setBottomState(() {
      //注意  改变showModalBottomSheet里面的数据 来源于StatefulBuilder
      this._attr = attr;
    });
    _getSelectedAttrValue();
  }

  // 底部筛选框
  _attrBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, setBottomState) {
              return GestureDetector(
                //解决showModalBottomSheet点击消失的问题
                onTap: () {
                  return false;
                },
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(ScreenAdapter.width(20)),
                      child: ListView(
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _getAttrWidget(setBottomState)),
                          Divider(),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            height: ScreenAdapter.height(80),
                            child: Row(
                              children: <Widget>[
                                Text("数量: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 10),
                                CartNum(this._productContent)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      width: ScreenAdapter.width(750),
                      height: ScreenAdapter.height(100),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: JdButton(
                                color: Color.fromRGBO(253, 1, 0, 0.9),
                                text: "加入购物车",
                                cb: () async{
                                  print('加入购物车');
                                  await CartServices.addCart(this._productContent);
                                  //关闭底部筛选属性
                                  Navigator.of(context).pop();
                                  //调用Provider 更新数据
                                  this.cartProvider.updateCartList();
                                  Fluttertoast.showToast(
                                      msg: "加入购物车成功",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1);
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: JdButton(
                                  color: Color.fromRGBO(255, 165, 0, 0.9),
                                  text: "立即购买",
                                  cb: () {
                                    print('立即购买');
                                  },
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  //封装一个组件 渲染attr ---1
  List<Widget> _getAttrWidget(setBottomState) {
    List<Widget> attrList = [];
    this._attr.forEach((attrItem) {
      attrList.add(Wrap(
        children: <Widget>[
          Container(
            width: ScreenAdapter.width(130),
            child: Padding(
              padding: EdgeInsets.only(top: ScreenAdapter.height(30)),
              child: Text("${attrItem.cate}: ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
            width: ScreenAdapter.width(580),
            child: Wrap(
              children: _getAttrItemWidget(attrItem, setBottomState),
            ),
          )
        ],
      ));
    });

    return attrList;
  }

  //封装一个组件 渲染attr ---2
  List<Widget> _getAttrItemWidget(attrItem, setBottomState) {
    List<Widget> attrItemList = [];
    attrItem.attrList.forEach((item) {
      attrItemList.add(Container(
        margin: EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            _changeAttr(attrItem.cate, item["title"], setBottomState);
          },
          child: Chip(
            label: Text("${item["title"]}",style: TextStyle(
              color: item["checked"] ? Colors.white : Colors.black54
            ),),
            padding: EdgeInsets.all(10),
            backgroundColor: item["checked"] ? Colors.red : Colors.black26,
          ),
        ),
      ));
    });
    return attrItemList;
  }

  @override
  Widget build(BuildContext context) {

    // 初始化Provider
    this.cartProvider = Provider.of<CartProvider>(context);

    // 处理图片
    String pic = Config.doMainApi + this._productContent.pic;
    pic = pic.replaceAll('\\', '/');

    return Container(
      padding: EdgeInsets.all(10),
      child: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 12,
            child: Image.network("${pic}", fit: BoxFit.cover),
          ),
          //标题
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text("${this._productContent.title}",
                style: TextStyle(
                    color: Colors.black87, fontSize: ScreenAdapter.size(36))),
          ),
          Container(
              padding: EdgeInsets.only(top: 10),
              child: Text("${this._productContent.subTitle}",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: ScreenAdapter.size(28)))),
          //价格
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      Text("特价: "),
                      Text("¥${this._productContent.price}",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: ScreenAdapter.size(40))),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("原价: "),
                      Text("¥${this._productContent.oldPrice}",
                          style: TextStyle(
                              color: Colors.black38,
                              fontSize: ScreenAdapter.size(28),
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                )
              ],
            ),
          ),
          //筛选
          this._attr.length > 0
              ? Container(
                  margin: EdgeInsets.only(top: 10),
                  height: ScreenAdapter.height(80),
                  child: InkWell(
                    onTap: () {
                      // 弹出筛选
                      _attrBottomSheet();
                    },
                    child: Row(
                      children: <Widget>[
                        Text("已选: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("${this._selectedValue}")
                      ],
                    ),
                  ),
                )
              : Text(""),
          Divider(),
          Container(
            height: ScreenAdapter.height(80),
            child: Row(
              children: <Widget>[
                Text("运费: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("免运费")
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
