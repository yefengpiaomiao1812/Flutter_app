
// 配置文件
class Config{

  // 域名地址
  static String doMainApi = "http://jd.itying.com/";

  // 轮播图地址
  static String focusApi = doMainApi + "api/focus";

  // 猜你喜欢地址
  static String hotProductApi = doMainApi + "api/plist?is_hot=1";

  // 热门推荐地址
  static String bestProductApi = doMainApi + "api/plist?is_best=1";

  // 分类页面栏目地址
  static String pcateApi = doMainApi + "api/pcate";

  // 商品列表地址
  static String plistApi = doMainApi + "api/plist";

  // 商品详情地址
  static String pcontentApi = doMainApi + "api/pcontent";

  // 获取手机验证码地址
  static String sendCodeApi = doMainApi + "api/sendCode";

  // 验证码验证地址
  static String validateCodeApi = doMainApi + "api/validateCode";

  // 注册地址
  static String registerApi = doMainApi + "api/register";

  // 登录地址
  static String doLoginApi = doMainApi + "api/doLogin";

  // 增加收货地址
  static String addAddressApi = doMainApi + "api/addAddress";

  // 获取用户全部地址
  static String addressListApi = doMainApi + "api/addressList";

  // 获取默认收货地址
  static String oneAddressListApi = doMainApi + "api/oneAddressList";

  // 修改默认收货地址
  static String changeDefaultAddressApi = doMainApi + "api/changeDefaultAddress";

  // 编辑收货地址
  static String editAddressApi = doMainApi + "api/editAddress";

  // 删除收货地址
  static String deleteAddressApi = doMainApi + "api/deleteAddress";

  // 立即下单地址
  static String doOrderApi = doMainApi + "api/doOrder";

  // 订单列表详情地址
  static String orderListApi = doMainApi + "api/orderList";


}