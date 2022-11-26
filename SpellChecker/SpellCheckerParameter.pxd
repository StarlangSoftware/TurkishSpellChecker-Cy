cdef class SpellCheckerParameter:

    cdef float __threshold
    cdef bint __deMiCheck
    cdef bint __rootNGram

    cpdef setThreshold(self, float threshold)
    cpdef setDeMiCheck(self, bint deMiCheck)
    cpdef setRootNGram(self, bint rootNGram)
    cpdef float getThreshold(self)
    cpdef bint isDeMiCheck(self)
    cpdef bint isRootNGram(self)
