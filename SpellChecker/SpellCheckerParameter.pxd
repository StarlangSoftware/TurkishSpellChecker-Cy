cdef class SpellCheckerParameter:

    cdef float __threshold
    cdef bint __suffixCheck
    cdef bint __rootNGram
    cdef int __minWordLength
    cdef str __domain

    cpdef setThreshold(self, float threshold)
    cpdef setSuffixCheck(self, bint suffixCheck)
    cpdef setRootNGram(self, bint rootNGram)
    cpdef setDomain(self, str domain)
    cpdef setMinWordLength(self, int minWordLength)
    cpdef float getThreshold(self)
    cpdef bint isSuffixCheck(self)
    cpdef bint isRootNGram(self)
    cpdef int getMinWordLength(self)
    cpdef str getDomain(self)
