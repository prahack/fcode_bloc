import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/specification.dart';

class ComplexSpecification implements SpecificationI {
  List<ComplexOperation> _complexWhere;

  ComplexSpecification(this._complexWhere) : assert(_complexWhere != null);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    if (_complexWhere == null) {
      return Stream<List<DocumentSnapshot>>.empty();
    }
    Query query = collection;
    for (final cw in _complexWhere) {
      query = cw.perform(query);
    }
    return query
        .snapshots()
        .map<List<DocumentSnapshot>>((data) => data.documents);
  }

  @override
  Future<List<DocumentSnapshot>> specifySingle(
    CollectionReference collection,
  ) async {
    if (_complexWhere == null) {
      return [];
    }
    Query query = collection;
    for (final cw in _complexWhere) {
      query = cw.perform(query);
    }
    return (await query.getDocuments()).documents;
  }
}

abstract class ComplexOperation {
  Query perform(Query query);
}

class Limit implements ComplexOperation {
  final int _length;

  Limit(this._length);

  @override
  Query perform(Query query) {
    return query.limit(_length);
  }
}

class OrderBy implements ComplexOperation {
  final String _field;
  final bool descending;

  OrderBy(this._field, {this.descending = false});

  @override
  Query perform(Query query) {
    return query.orderBy(_field, descending: descending);
  }
}

class ComplexWhere implements ComplexOperation {
  final String _field;
  final dynamic isEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List arrayContainsAny;
  final List whereIn;
  bool isNull;

  ComplexWhere(
    this._field, {
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    bool isNull = false,
  }) {
    if (isNull) {
      this.isNull = true;
    }
  }

  @override
  Query perform(Query query) {
    return query.where(
      _field,
      isEqualTo: isEqualTo,
      isLessThan: isLessThan,
      isLessThanOrEqualTo: isLessThanOrEqualTo,
      isGreaterThan: isGreaterThan,
      isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      arrayContains: arrayContains,
      arrayContainsAny: arrayContainsAny,
      whereIn: whereIn,
      isNull: isNull,
    );
  }
}
