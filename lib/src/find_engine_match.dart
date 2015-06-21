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

part of find_engine;

/// Contains metadata regarding a matched [Term].
///
/// [rank] and [subRank] determines a match's relevance.
/// [rank] must be a value between 0 and 255.  [subRank] is arbitrary, and
/// determines the position of a match within a particular rank.  If you were
/// to order matches by relevance, you would sort by [rank], then by [subRank].
class FindEngineMatch {
  static const UNRANKED = 256;

  final int rank;
  final int subRank;
  final String matchedFragment;

  FindEngineMatch(this.rank, this.subRank, this.matchedFragment);

  FindEngineMatch.unranked()
      : this.rank = UNRANKED,
        this.subRank = UNRANKED,
        this.matchedFragment = '';

  String toString() => '"$matchedFragment" [rank: $rank] [subRank: $subRank]';
}
