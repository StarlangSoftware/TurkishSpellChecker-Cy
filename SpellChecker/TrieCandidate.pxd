from SpellChecker.Candidate cimport Candidate

cdef class TrieCandidate(Candidate):

    cdef int __current_index
    cdef float __current_penalty

    cpdef int getCurrentIndex(self)
    cpdef float getCurrentPenalty(self)
    cpdef nextIndex(self)
