
import 'package:built_collection/built_collection.dart';
import 'package:glina/glina.dart';

import 'customer.dart';

part 'invoice.g.dart';

@record
abstract class Invoice extends _$Invoice {

  int get id;
  Customer get customer;

  factory Invoice.fromMap(Map<String, Object> data) = _$$Invoice.fromMap;

}
