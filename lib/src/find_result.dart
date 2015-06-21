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

class FindResult<T extends Findable> {

  /// The matched [Findable].
  final T item;

  final FindEngineMatch match;

  /// The [Term] that resulted in the match.
  final Term matchedTerm;

  /// A value only set on special instances of FindResult to indicate that no
  /// terms matched.
  final bool _noMatch;

  FindResult(this.item, this.match, this.matchedTerm) : _noMatch = false;

  FindResult.noMatch()
      : item = null,
        matchedTerm = null,
        match = null,
        _noMatch = true;

  String toString() => _noMatch ? '[No Match]' : matchedTerm.toString();
}
