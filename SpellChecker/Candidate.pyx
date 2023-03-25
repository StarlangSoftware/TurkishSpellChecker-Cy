from SpellChecker.Operator import Operator

cdef class Candidate(Word):

    def __init__(self,
                 candidate: str,
                 operator: Operator):
        """
        Constructs a new Candidate object with the specified candidate and operator.
        :param candidate: The word candidate to be checked for spelling.
        :param operator: The operator to be applied to the candidate in the spell checking process.
        """
        super().__init__(candidate)
        self.__operator = operator

    cpdef object getOperator(self):
        """
        Returns the operator associated with this candidate.
        :return: The operator associated with this candidate.
        """
        return self.__operator
