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

library find_engine;

import 'dart:async';
import 'package:quiver/iterables.dart' as q;
import 'package:logging/logging.dart';

part 'src/find_result.dart';
part 'src/findable.dart';
part 'src/findable_source.dart';
part 'src/term.dart';
part 'src/invalid_term_type_error.dart';
part 'src/find_engine_matcher.dart';
part 'src/find_engine_match.dart';

class FindEngine<T extends Findable> {
  static final _logger = new Logger('find_engine');
  final FindEngineMatcher _matcher;
  final FindableSource<T> _source;

  FindEngine(this._matcher, this._source);

  /// Returns a [Stream] of [FindResult] whose [Term]s satisfy [searchTerm].
  ///
  /// Whether or not a [Findable] satisfies [searchTerm] is determined by the
  /// injected [FindEngineMatcher].
  ///
  /// [matchOnTermType] determines the type of term that [searchTerm] will
  /// be compared to.  If unspecified, it will compare against all term types.
  Stream<FindResult<T>> streamResults(String searchTerm,
      {TermType matchOnTermType: TermType.UNSPECIFIED}) {
    return _source
        .getStream()
        .map((r) => _match(r, searchTerm, matchOnTermType))
        .where((r) => !r._noMatch);
  }

  FindResult<T> _match(
      Findable findable, String searchTerm, TermType matchOnTermType) {
    final terms = matchOnTermType == TermType.UNSPECIFIED
        ? findable.terms
        : findable.terms.where((t) => t.termType == matchOnTermType);

    final matchedTerms = terms.map((Term t) {
      final match = _matcher.getMatch(t, searchTerm);

      return match.rank == FindEngineMatch.UNRANKED
          ? new FindResult.noMatch()
          : new FindResult(findable, match, t);
    });

    // TODO(blocked): write test to verify that we actually return the
    // highest ranked match. See:
    // https://code.google.com/p/dart/issues/detail?id=21945
    final bestMatch = q.max(matchedTerms, (FindResult a, FindResult b) {
      if (!a._noMatch && b._noMatch) return 1;
      if (a._noMatch && !b._noMatch) return -1;
      if (a._noMatch && b._noMatch) return 0;

      // A lower rank is a better match
      if (a.match.rank < b.match.rank) return 1;
      if (a.match.rank > b.match.rank) return -1;

      // if we get here, ranks are safely assumed to be equal
      if (a.match.subRank > b.match.subRank) return -1;
      if (a.match.subRank < b.match.subRank) return 1;

      // rank and subRank are safely assumed to be equal
      return 0;
    });

    return bestMatch;
  }
}
