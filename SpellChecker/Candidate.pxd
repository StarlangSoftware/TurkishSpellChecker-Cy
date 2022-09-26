from Dictionary.Word cimport Word

cdef class Candidate(Word):

    cdef object __operator

    cpdef object getOperator(self)
