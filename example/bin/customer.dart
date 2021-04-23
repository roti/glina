
import 'package:built_collection/built_collection.dart';
import 'package:glina/glina.dart';

part 'customer.g.dart';

@record
abstract class Customer extends _$Customer {

  int get id;
  String get name;
  String? get description;

  factory Customer(BuiltMap<String, Object> data) = _$CustomerImpl;
  factory Customer.fromMap(Map<String, Object> data) = _$CustomerImpl.fromMap;

}
