/// Support for doing something awesome.
///
/// More dartdocs go here.
library glina_generator;

import 'package:build/build.dart';
import 'package:glina_generator/src/glina_generator.dart';
import 'package:source_gen/source_gen.dart';

export 'src/glina_generator.dart';


Builder glina(BuilderOptions) =>
    SharedPartBuilder([GlinaGenerator()], "glina");


