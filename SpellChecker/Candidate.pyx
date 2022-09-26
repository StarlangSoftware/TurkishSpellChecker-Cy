from SpellChecker.Operator import Operator

cdef class Candidate(Word):

    def __init__(self,
                 candidate: str,
                 operator: Operator):
        super().__init__(candidate)
        self.__operator = operator

    cpdef object getOperator(self):
        return self.__operator
