from SpellChecker.Candidate cimport Candidate
from SpellChecker.Operator import Operator


cdef class TrieCandidate(Candidate):

    def __init__(self,
                 word: str,
                 current_index: int,
                 current_penalty: float):
        """
        Constructs a TrieCandidate object.
        :param word: the candidate word
        :param current_index: the current index of the candidate word
        :param current_penalty: the currentPenalty associated with the candidate word
        """
        super().__init__(word, Operator.TRIE_BASED)
        self.__current_index = current_index
        self.__current_penalty = current_penalty

    cpdef int getCurrentIndex(self):
        """
        Returns the current index of the candidate word.
        :return: the current index of the candidate word
        """
        return self.__current_index

    cpdef float getCurrentPenalty(self):
        """
        Returns the currentPenalty value associated with the candidate word.
        :return: the currentPenalty value associated with the candidate word
        """
        return self.__current_penalty

    cpdef nextIndex(self):
        """
        Increments the current index of the candidate word by 1.
        """
        self.__current_index = self.__current_index + 1
