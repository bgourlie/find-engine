// Copyright (c) 2015 W. Brian Gourlie
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:async';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:find_engine/find_engine.dart';

main() {
  test('should include all results that are not unranked', () {
    final tb = new _TestBed();
    final result1 = new Foo([new Term('one', TermType.NAME)]);
    final result2 = new Foo([new Term('two', TermType.NAME)]);
    final result3 = new Foo([new Term('three', TermType.NAME)]);

    when(tb.matcher.getMatch(any, any))
        .thenReturn(new FindEngineMatch(0, 0, 'test'));

    when(tb.fooSource.getStream())
        .thenReturn(new Stream.fromIterable([result1, result2, result3]));

    final findEngine = tb.newFindEngine();

    final resultStream = findEngine.streamResults('arbitrary');

    expect(resultStream.toList().then((List<FindResult<Foo>> l) {
      expect(l, hasLength(3));
      l.every((r) => ['one', 'two', 'three'].contains(r.matchedTerm.term));
      expect(
          l.every((r) => ['one', 'two', 'three'].contains(r.matchedTerm.term)),
          isTrue);
    }), completes);
  });

  test('should not return unranked results', () {
    final tb = new _TestBed();

    final result1 = new Foo([new Term('one', TermType.NAME)]);
    final result2 = new Foo([new Term('two', TermType.NAME)]);
    final result3 = new Foo([new Term('three', TermType.NAME)]);

    when(tb.matcher.getMatch(same(result1), any))
        .thenReturn(new FindEngineMatch.unranked());

    when(tb.matcher.getMatch(same(result2), any))
        .thenReturn(new FindEngineMatch(1, 1, 'two'));

    when(tb.matcher.getMatch(same(result3), any))
        .thenReturn(new FindEngineMatch(1, 1, 'three'));

    when(tb.fooSource.getStream())
        .thenReturn(new Stream.fromIterable([result1, result2, result3]));

    final findEngine = tb.newFindEngine();

    final resultStream = findEngine.streamResults('arbitrary');

    expect(resultStream.toList().then((List<FindResult<Foo>> l) {
      expect(l, hasLength(2));
      expect(l.every((r) => ['two', 'three'].contains(r.matchedTerm.term)),
          isTrue);
    }), completes);
  }, skip: 'TODO: Fix test');

  test('should only return results having specified term type', () {
    final tb = new _TestBed();

    when(tb.matcher.getMatch(any, any))
        .thenReturn(new FindEngineMatch(0, 0, 'on'));

    when(tb.fooSource.getStream()).thenReturn(new Stream.fromIterable([
      new Foo([new Term('one', TermType.NAME)]),
      new Foo([new Term('on', TermType.NAME)]),
      new Foo([new Term('one', TermType.TAG)])
    ]));

    final findEngine = tb.newFindEngine();

    final resultStream =
        findEngine.streamResults('arbitrary', matchOnTermType: TermType.NAME);

    expect(resultStream.toList().then((List<FindResult<Foo>> l) {
      expect(l, hasLength(2));
      expect(
          l.every((r) => ['one', 'on'].contains(r.matchedTerm.term)), isTrue);
    }), completes);
  }, skip: 'TODO: Fix test');

  test('should return results having all term types if none is specified', () {
    final tb = new _TestBed();
    when(tb.matcher.getMatch(any, any))
        .thenReturn(new FindEngineMatch(0, 0, 'test'));

    final findEngine = tb.newFindEngine();

    when(tb.fooSource.getStream()).thenReturn(new Stream.fromIterable([
      new Foo([new Term('one', TermType.NAME)]),
      new Foo([new Term('on', TermType.NAME)]),
      new Foo([new Term('ne', TermType.TAG)])
    ]));

    final resultStream = findEngine.streamResults('arbitrary');

    expect(resultStream.toList().then((List<FindResult<Foo>> l) {
      expect(l, hasLength(3));
      expect(l.every((r) => ['one', 'on', 'ne'].contains(r.matchedTerm.term)),
          isTrue);
    }), completes);
  });
}

class MockFooSource extends Mock implements FindableSource<Foo> {}
class MockMatcher extends Mock implements FindEngineMatcher {}

class Foo implements Findable {
  final List<Term> _terms;
  List<Term> get terms => _terms;
  Foo(this._terms);
}

class _TestBed {
  final fooSource = new MockFooSource();
  final matcher = new MockMatcher();
  FindEngine<Foo> newFindEngine() => new FindEngine<Foo>(matcher, fooSource);
}
