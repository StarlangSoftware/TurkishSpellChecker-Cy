cdef class TrieNode:

    cdef dict __children
    cdef bint __isWord

    cpdef TrieNode getChild(self, str ch)
    cpdef addChild(self, str ch, TrieNode child)
    cpdef str childrenToString(self)
    cpdef bint isWord(self)
    cpdef setIsWord(self, bint isWord)
