


import 'customer.dart';

void main() {
  Customer c = Customer.fromMap({"id": 15});
  print(c.id);          //15
  // print(c.name);        //error - can't be null
  print(c.description); //null
}