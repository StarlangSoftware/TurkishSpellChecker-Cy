cdef class SpellCheckerParameter:

    def __init__(self):
        """
        Constructs a SpellCheckerParameter object with default values.
        The default threshold is 0.0, the De-Mi check is enabled, the root ngram is enabled and
        the minimum word length is 4.
        """
        self.__threshold = 0.0
        self.__deMiCheck = True
        self.__rootNGram = True
        self.__minWordLength = 4
        self.__domain = ""

    cpdef setThreshold(self, float threshold):
        """
        Sets the threshold value used in calculating the n-gram probabilities.
        :param threshold: the threshold for the spell checker
        """
        self.__threshold = threshold

    cpdef setDeMiCheck(self, bint deMiCheck):
        """
        Enables or disables De-Mi check for the spell checker.
        :param deMiCheck: a boolean indicating whether the De-Mi check should be enabled (true) or disabled (false)
        """
        self.__deMiCheck = deMiCheck

    cpdef setRootNGram(self, bint rootNGram):
        """
        Enables or disables the root n-gram for the spell checker.
        :param rootNGram: a boolean indicating whether the root n-gram should be enabled (true) or disabled (false)
        """
        self.__rootNGram = rootNGram

    cpdef setMinWordLength(self, int minWordLength):
        """
        Sets the minimum length of words viable for spell checking.
        :param minWordLength: the minimum word length for the spell checker
        """
        self.__minWordLength = minWordLength

    cpdef setDomain(self, str domain):
        """
        Sets the _domain name to the specified value.
        :param domain: the new domain name to set for this object
        """
        self.__domain = domain

    cpdef float getThreshold(self):
        """
        Returns the threshold value used in calculating the n-gram probabilities.
        :return: the threshold for the spell checker
        """
        return self.__threshold

    cpdef bint isDeMiCheck(self):
        """
        Returns whether De-Mi check is enabled for the spell checker.
        :return: a boolean indicating whether De-Mi check is enabled for the spell checker
        """
        return self.__deMiCheck

    cpdef bint isRootNGram(self):
        """
        Returns whether the root n-gram is enabled for the spell checker.
        :return: a boolean indicating whether the root n-gram is enabled for the spell checker
        """
        return self.__rootNGram

    cpdef int getMinWordLength(self):
        """
        Returns the minimum length of words viable for spell checking.
        :return: the minimum word length for the spell checker
        """
        return self.__minWordLength

    cpdef str getDomain(self):
        """
        Returns the domain name
        :return: the domain name
        """
        return self.__domain
