cdef class SpellCheckerParameter:

    cdef float __threshold
    cdef bint __deMiCheck
    cdef bint __rootNGram
    cdef int __minWordLength
    cdef str __domain

    cpdef setThreshold(self, float threshold)
    cpdef setDeMiCheck(self, bint deMiCheck)
    cpdef setRootNGram(self, bint rootNGram)
    cpdef setDomain(self, str domain)
    cpdef setMinWordLength(self, int minWordLength)
    cpdef float getThreshold(self)
    cpdef bint isDeMiCheck(self)
    cpdef bint isRootNGram(self)
    cpdef int getMinWordLength(self)
    cpdef str getDomain(self)
