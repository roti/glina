
import 'dart:mirrors';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:glina/glina.dart';
import 'package:source_gen/source_gen.dart';

class GlinaGenerator extends GeneratorForAnnotation<Record> {


  @override
  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {

    if (element is ClassElement) {

      var implClassName = _implClassName(element);

      var abstractGetters = element.accessors.where((method) => method.isAbstract && method.isGetter);

      if (abstractGetters.length == 0)
        throw InvalidGenerationSourceError("Class ${element.name} needs to have at least one abstract getter");

      var methodImpls = abstractGetters.map((g) => _generateGetter(element, g));

      var withMethods = abstractGetters.map((g) => _generateWithMethods(element, g, false));
      var abstractWithMethods = abstractGetters.map((g) => _generateWithMethods(element, g, true));

      return """

      class $implClassName implements _\$\$${element.name} {
        BuiltMap<String, Object> _data;
        
        $implClassName(this._data);
        $implClassName.fromMap(Map<String, Object> data): _data = BuiltMap.of(data);
        
        
        ${methodImpls.join("\n")}
        
        ${withMethods.join("\n")}
        
      }
      
      abstract class _\$${element.name} {
        ${abstractWithMethods.join("\n")}
      }
      
      abstract class _\$\$${element.name} implements ${element.name} {
        factory _\$\$${element.name}() => $implClassName(BuiltMap());
        factory _\$\$${element.name}.fromMap(Map<String, Object> data) = $implClassName.fromMap;
      }
      

    """;
    } else {
      throw InvalidGenerationSourceError("@record supported only on classes");
    }

  }

  static final annotationType = reflectType(Record);

  String _generateGetter(ClassElement clazz, PropertyAccessorElement getter) {
    var isRecord = getter.returnType.element?.metadata.any((element) =>
      //TODO need a more consistent way to compare annotation types
      element.computeConstantValue()?.type.toString() == "Record"
    );
    if (isRecord != null && isRecord) {
      return """
      @override
      ${getter} {
        return ${getter.returnType}(_data["${getter.name}"] as BuiltMap<String, Object>);
      }
      """;
    } else {
      return """
      @override
      ${getter} {
        return _data["${getter.name}"] as ${getter.returnType};
      }
      """;
    }
  }

  String _generateWithMethods(ClassElement clazz, PropertyAccessorElement getter, bool abstract) {
    var methodName = "with${getter.name[0].toUpperCase()}${getter.name.substring(1)}";
    var methodSignature = "${clazz.name} $methodName(${getter.returnType} ${getter.name})";
    if (abstract) {
      return "$methodSignature;";
    } else {
      if (getter.returnType.nullabilitySuffix == NullabilitySuffix.none) {
        return """
        $methodSignature {
          return ${_implClassName(clazz)}(_data.rebuild((b) => b["${getter.name}"] = ${getter.name}));
        }
        """;
      } else {
        return """
        $methodSignature {
          return ${_implClassName(clazz)}(_data.rebuild((b) => (${getter.name} == null) ? b.remove("${getter.name}") : b["${getter.name}"] = ${getter.name}));
        }
        """;
      }
    }
  }


  String _implClassName(ClassElement clazz) => "_\$${clazz.name}Impl";

}
