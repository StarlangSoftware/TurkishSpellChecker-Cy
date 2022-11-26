cdef class SpellCheckerParameter:

    def __init__(self):
        self.__threshold = 0.0
        self.__deMiCheck = True
        self.__rootNGram = True

    cpdef setThreshold(self, float threshold):
        self.__threshold = threshold

    cpdef setDeMiCheck(self, bint deMiCheck):
        self.__deMiCheck = deMiCheck

    cpdef setRootNGram(self, bint rootNGram):
        self.__rootNGram = rootNGram

    cpdef float getThreshold(self):
        return self.__threshold

    cpdef bint isDeMiCheck(self):
        return self.__deMiCheck

    cpdef bint isRootNGram(self):
        return self.__rootNGram
