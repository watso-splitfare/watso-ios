import 'package:intl/intl.dart';

import '../../Auth/models/user_model.dart';

enum PostStatus { recruiting, closed, ordered, delivered, canceled }

//PostStatus to korean
extension PostStatusExtension on PostStatus {
  String get korName {
    switch (this) {
      case PostStatus.recruiting:
        return '모집중';
      case PostStatus.closed:
        return '모집마감';
      case PostStatus.ordered:
        return '주문완료';
      case PostStatus.delivered:
        return '배달완료';
      case PostStatus.canceled:
        return '취소';
      default:
        return '';
    }
  }
}

class Store {
  String id;
  String name;
  int minOrder;
  int fee;
  String phoneNumber;
  String logoImgUrl;
  List<String> note;

  Store(
      {required this.id,
      required this.name,
      required this.minOrder,
      required this.fee,
      required this.phoneNumber,
      required this.logoImgUrl,
      required this.note});

  Store.init()
      : id = '',
        name = '',
        minOrder = 1,
        fee = 0,
        phoneNumber = '',
        logoImgUrl = '',
        note = [];

  Store.fromJson(Map<String, dynamic> json)
      : id = json['_id'].toString(),
        name = json['name'].toString(),
        minOrder = int.tryParse(json['min_order'].toString()) ?? 0,
        fee = int.tryParse(json['fee'].toString()) ?? 0,
        phoneNumber = json['phone_number'].toString(),
        logoImgUrl = json['logo_img_url'].toString(),
        note = List<String>.from(json['note'].map((x) => x.toString()));

  Store.clone(Store store)
      : id = store.id,
        name = store.name,
        minOrder = store.minOrder,
        fee = store.fee,
        phoneNumber = store.phoneNumber,
        logoImgUrl = store.logoImgUrl,
        note = store.note;
}

class OrderOption {
  String place;
  DateTime orderTime;
  int minMember;
  int maxMember;
  Store store;
  String? postId;

  OrderOption(
      {required this.place,
      required this.orderTime,
      required this.minMember,
      required this.maxMember,
      required this.store,
      this.postId});

  OrderOption.fromJson(Map<String, dynamic> json)
      : place = json['place'],
        orderTime = DateTime.parse(json['order_time']),
        minMember = json['min_member'],
        maxMember = json['max_member'],
        store = Store.fromJson(json['store']),
        postId = json['post_id'];

  OrderOption.clone(OrderOption postOption)
      : place = postOption.place,
        orderTime = postOption.orderTime,
        minMember = postOption.minMember,
        maxMember = postOption.maxMember,
        store = Store.clone(postOption.store),
        postId = postOption.postId;

  factory OrderOption.init() {
    DateTime nowDate = DateTime.now();
    DateTime dateTime = DateTime(nowDate.year, nowDate.month, nowDate.day,
        nowDate.hour, nowDate.minute - nowDate.minute % 10 + 30);

    return OrderOption(
      place: '생자대',
      orderTime: dateTime,
      minMember: 2,
      maxMember: 4,
      store: Store.init(),
    );
  }

  toMap() => {
        'order_time': DateFormat('yyyy-MM-ddTHH:mm:ss').format(orderTime),
        'place': place,
        'min_member': minMember,
        'max_member': maxMember,
        'store': store.id,
        'post_id': postId ?? '',
      };

  get editableInfo => {
        'order_time': DateFormat('yyyy-MM-ddTHH:mm:ss').format(orderTime),
        'place': place,
        'min_member': minMember,
        'max_member': maxMember,
      };

  bool get isStoreSelected => store.id.isNotEmpty;

  bool get isMemberLogical => minMember <= maxMember;

  bool get isOrderTimeLogical =>
      orderTime.isAfter(DateTime.now().add(Duration(minutes: 10)));

  bool get isPlaceSelected => place.isNotEmpty;

  bool get isAbleToRecuit => orderTime.isAfter(DateTime.now());
}

class Order extends User {
  List<OrderMenu> orderLines;
  String requestComment;

  Order({
    required this.orderLines,
    required id,
    required nickname,
    this.requestComment = '',
  }) : super(id: id, nickname: nickname);

  Order.fromJson(Map<String, dynamic> json)
      : orderLines = List<OrderMenu>.from(
            json['order_lines'].map((x) => OrderMenu.fromJson(x))),
        requestComment = json['request_comment'] ?? '',
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'user_id': id,
        'nickname': nickname,
        'order_lines': orderLines.map((e) => e.toJson()).toList(),
        'request_comment': requestComment,
      };

  Order.clone(Order order)
      : orderLines = order.orderLines.map((e) => OrderMenu.clone(e)).toList(),
        requestComment = order.requestComment,
        super.clone(order);

  Order.init(User user)
      : orderLines = [],
        requestComment = '',
        super.clone(user);
}

class OrderMenu {
  int quantity;
  Menu menu;

  OrderMenu({required this.quantity, required this.menu});

  OrderMenu.fromJson(Map<String, dynamic> json)
      : quantity = json['quantity'],
        menu = Menu.fromJson(json['menu']);

  OrderMenu.fromMenu({required this.quantity, required this.menu});

  factory OrderMenu.clone(OrderMenu orderMenu) {
    return OrderMenu(
      quantity: orderMenu.quantity,
      menu: Menu.clone(orderMenu.menu),
    );
  }

  Map toJson() => {
        'quantity': quantity,
        'menu': menu.toJson(),
      };

  int get totalPrice {
    int totalPrice = menu.price * quantity;
    if (menu.optionGroups != null) {
      for (MenuOptionGroup group in menu.optionGroups!) {
        for (MenuOption option in group.options) {
          totalPrice += option.price * quantity;
        }
      }
    }
    return totalPrice;
  }
}

class Menu {
  String id;
  String name;
  int price;
  List<MenuOptionGroup>? optionGroups;

  Menu(
      {required this.id,
      required this.name,
      required this.price,
      this.optionGroups});

  Menu.fromJson(Map<String, dynamic> json)
      : id = json['_id'].toString(),
        name = json['name'].toString(),
        price = int.tryParse(json['price'].toString()) ?? 0,
        optionGroups = json['groups'] != null
            ? List<MenuOptionGroup>.from(
                json['groups'].map((x) => MenuOptionGroup.fromJson(x)))
            : null;

  factory Menu.clone(Menu menu) {
    return Menu(
      id: menu.id,
      name: menu.name,
      price: menu.price,
      optionGroups: menu.optionGroups != null
          ? menu.optionGroups!.map((e) => MenuOptionGroup.clone(e)).toList()
          : [],
    );
  }

  Map toJson() => {
        '_id': id,
        'price': price,
        'name': name,
        'groups': optionGroups != null
            ? optionGroups!.fold([], (previousValue, element) {
                if (element.options.isNotEmpty) {
                  previousValue.add(element.toJson());
                }
                return previousValue;
              })
            : null,
      };
}

class MenuSection {
  String section;
  List<Menu> menus;

  MenuSection({required this.section, required this.menus});

  MenuSection.fromJson(Map<String, dynamic> json)
      : section = json['section_name'].toString(),
        menus = List<Menu>.from(json['menus'].map((x) => Menu.fromJson(x)));
}

class MenuOptionGroup {
  String id;
  String name;
  int minOptionNum;
  int maxOptionNum;
  List<MenuOption> options;

  MenuOptionGroup(
      {required this.id,
      required this.name,
      required this.options,
      required this.minOptionNum,
      required this.maxOptionNum});

  MenuOptionGroup.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        name = json['name'],
        minOptionNum = json['min_order_quantity'],
        maxOptionNum = json['max_order_quantity'],
        options = List<MenuOption>.from(
            json['options'].map((x) => MenuOption.fromJson(x)));

  factory MenuOptionGroup.clone(MenuOptionGroup menuOptionGroup) {
    return MenuOptionGroup(
      id: menuOptionGroup.id,
      name: menuOptionGroup.name,
      minOptionNum: menuOptionGroup.minOptionNum,
      maxOptionNum: menuOptionGroup.maxOptionNum,
      options: menuOptionGroup.options.map((e) => MenuOption.clone(e)).toList(),
    );
  }

  Map toJson() => {
        '_id': id,
        'name': name,
        'min_order_quantity': minOptionNum,
        'max_order_quantity': maxOptionNum,
        'options': options.map((e) => e.toJson()).toList(),
      };
}

class MenuOption {
  String id;
  String name;
  int price;

  MenuOption({
    required this.id,
    required this.name,
    required this.price,
  });

  MenuOption.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        name = json['name'],
        price = json['price'];

  factory MenuOption.clone(MenuOption menuOption) {
    return MenuOption(
      id: menuOption.id,
      name: menuOption.name,
      price: menuOption.price,
    );
  }

  Map toJson() => {
        '_id': id,
        'name': name,
        'price': price,
      };
}
