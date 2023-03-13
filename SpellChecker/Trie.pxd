from SpellChecker.TrieNode cimport TrieNode


cdef class Trie:

    cdef TrieNode __root_node

    cpdef insert(self, str word)
    cpdef bint search(self, str word)
    cpdef bint startsWith(self, str prefix)
    cpdef TrieNode getTrieNode(self, str word)
