cdef class TrieNode:

    def __init__(self):
        """
        A constructor of {@link TrieNode} class which constructs a new TrieNode with an empty children HashMap
        """
        self.__children = {}
        self.__isWord = False

    cpdef TrieNode getChild(self, str ch):
        """
        Returns the child TrieNode with the given character as its value.
        :param ch: The character value of the child TrieNode.
        :return: TrieNode with the given character value.
        """
        return self.__children.get(ch)

    cpdef addChild(self, str ch, TrieNode child):
        self.__children[ch] = child

    cpdef str childrenToString(self):
        cdef str result
        result = ""
        for ch in self.__children:
            result = result + ch
        return result

    cpdef bint isWord(self):
        """
        Returns whether the current TrieNode represents the end of a word.
        :return: true if the current TrieNode represents the end of a word, false otherwise.
        """
        return self.__isWord

    cpdef setIsWord(self, bint isWord):
        """
        Sets whether the current TrieNode represents the end of a word.
        :param isWord: true if the current TrieNode represents the end of a word, false otherwise.
        """
        self.__isWord = isWord
