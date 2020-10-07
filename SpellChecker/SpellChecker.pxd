from Corpus.Sentence cimport Sentence


cdef class SpellChecker:

    cpdef Sentence spellCheck(self, Sentence sentence)
