import 'package:flutter/material.dart';
import '../../services/ScreenAdapter.dart';
import 'CartNum.dart';
import 'package:provider/provider.dart';
import '../../provider/CartProvider.dart';

class CartItem extends StatefulWidget {
  Map _itemData;

  CartItem(this._itemData, {Key key}) : super(key: key);

  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  Map _itemData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 注意  多次赋值需要放在这里
    this._itemData = widget._itemData;

    var cartProvider = Provider.of<CartProvider>(context);

    return Container(
      height: ScreenAdapter.height(220),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenAdapter.width(60),
            child: Checkbox(
              value: _itemData["checked"],
              onChanged: (val) {
                setState(() {
                  _itemData["checked"]  = !_itemData["checked"];
                  // 监听每一项的选中事件
                  cartProvider.itemChage();
                });
              },
              activeColor: Colors.pink,
            ),
          ),
          Container(
            width: ScreenAdapter.width(160),
            child: Image.network(
              "${_itemData["pic"]}",
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("${_itemData["title"]}",
                      maxLines: 2),
                  Text("${_itemData["selectedAttr"]}",
                      maxLines: 2),
                  Stack(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "￥${_itemData["price"]}",
                            style: TextStyle(color: Colors.red),
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CartNum(_itemData),
                      )
                    ],
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
