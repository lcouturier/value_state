import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  const myStr = 'My String';
  const myStrOrElse = 'My String orElse';

  group('when()', () {
    test('on a non null String', () {
      final result = myStr.toState().when(
            onWaiting: () => 'Waiting',
            onNoValue: () => 'No Value',
            onValue: (value) => value,
            onError: (error) => 'Error',
            orElse: () => 'Else',
          );

      expect(result, 'My String');
    });

    test('on null', () {
      const String? nullStr = null;

      final result = nullStr.toState().when(
            onWaiting: () => 'Waiting',
            onNoValue: () => 'No Value',
            onValue: (state) => 'Value',
            onError: (error) => 'Error',
            orElse: () => 'Else',
          );

      expect(result, 'No Value');
    });

    test('orElse', () {
      const String? nullStr = null;

      final result = nullStr.toState().when(
            onValue: (state) => 'Value',
            onError: (error) => 'Error',
            orElse: () => 'Else',
          );

      expect(result, 'Else');
    });
  });

  group('toState()', () {
    test('on a non null String', () {
      expect(myStr.toState(), const ValueState(myStr));
      expect(myStr.toState(refreshing: true), const ValueState(myStr, refreshing: true));
    });

    test('on null', () {
      const String? nullStr = null;

      expect(nullStr.toState(), const NoValueState<String>());
      expect(nullStr.toState(refreshing: true), const NoValueState<String>(refreshing: true));
    });
  });

  String? modifier(String value) => '$value modified';

  group('withValue', () {
    test('on a $ValueState', () {
      final result = myStr.toState().withValue(modifier);

      expect(result, modifier(myStr));
    });

    test('on a $ValueState with onlyValueState to true', () {
      final result = myStr.toState().withValue(modifier, onlyValueState: true);

      expect(result, modifier(myStr));
    });

    test('on a $InitState', () {
      final result = const InitState<String>().withValue(modifier);

      expect(result, isNull);
    });

    test('on a $InitState with onlyValueState to true', () {
      final result = const InitState<String>().withValue(modifier, onlyValueState: true);

      expect(result, isNull);
    });

    test('on a $ErrorState', () {
      final result = ErrorState<String>(error: 'Error', previousState: myStr.toState()).withValue(modifier);

      expect(result, modifier(myStr));
    });

    test('on a $ErrorState with onlyValueState to true', () {
      final result =
          ErrorState<String>(error: 'Error', previousState: myStr.toState()).withValue(modifier, onlyValueState: true);

      expect(result, isNull);
    });

    test('orElse on a $ValueState', () {
      final result = myStr.toState().withValue(modifier).orElse(() => myStrOrElse);

      expect(result, modifier(myStr));
    });

    test('orElse on a $InitState', () {
      final result = const InitState<String>().withValue(modifier).orElse(() => myStrOrElse);

      expect(result, myStrOrElse);
    });

    test('expression on a $ValueState', () {
      String? result;
      myStr.toState().withValue((value) {
        result = modifier(value);
      });

      expect(result, modifier(myStr));
    });
  });

  group('whenValue', () {
    test('on a $ValueState', () {
      final result = myStr.toState().whenValue(modifier);

      expect(result, modifier(myStr));
    });

    test('on a $ErrorState', () {
      final result = ErrorState<String>(error: 'Error', previousState: myStr.toState()).whenValue(modifier);

      expect(result, isNull);
    });
  });

  group('toValue', () {
    test('on a $ValueState', () {
      final result = myStr.toState().toValue();

      expect(result, myStr);
    });

    test('on a $ValueState with onlyValueState to true', () {
      final result = myStr.toState().toValue(onlyValueState: true);

      expect(result, myStr);
    });

    test('on a $InitState', () {
      final result = const InitState<String>().toValue();

      expect(result, isNull);
    });

    test('on a $InitState with onlyValueState to true', () {
      final result = const InitState<String>().toValue(onlyValueState: true);

      expect(result, isNull);
    });

    test('on a $ErrorState', () {
      final result = ErrorState<String>(error: 'Error', previousState: myStr.toState()).toValue();

      expect(result, myStr);
    });

    test('on a $ErrorState with onlyValueState to true', () {
      final result = ErrorState<String>(error: 'Error', previousState: myStr.toState()).toValue(onlyValueState: true);

      expect(result, isNull);
    });
  });

  test('toFutureState', () {
    const value = 'Result';

    expect(Future.value(value).toFutureState(), completion(value.toState()));
    expect(Future<String?>.value(null).toFutureState(), completion(const NoValueState<String>()));
  });

  test('toStates', () {
    const value = 'Result';

    expect(
        Future.value(value).toStates(),
        emitsInOrder([
          const PendingState<String>(),
          const ValueState(value),
          emitsDone,
        ]));
  });
}
