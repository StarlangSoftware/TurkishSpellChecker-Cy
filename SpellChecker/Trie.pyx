cdef class Trie:

    def __init__(self):
        """
        A constructor of {@link Trie} class which constructs a new Trie with an empty root node
        """
        self.__root_node = TrieNode()

    cpdef insert(self, str word):
        """
        Inserts a new word into the Trie
        :param word: The word to be inserted
        """
        cdef int i
        cdef TrieNode current_node
        cdef str ch
        current_node = self.__root_node
        for i in range(len(word)):
            ch = word[i]
            if current_node.getChild(ch) is None:
                current_node.addChild(ch, TrieNode())
            current_node = current_node.getChild(ch)
        current_node.setIsWord(True)

    cpdef bint search(self, str word):
        """
        Checks if a word is in the Trie
        :param word: The word to be searched for
        :return: true if the word is in the Trie, false otherwise
        """
        cdef TrieNode node
        node = self.getTrieNode(word.lower())
        if node is None:
            return False
        else:
            return node.isWord()

    cpdef bint startsWith(self, str prefix):
        """
        Checks if a given prefix exists in the Trie
        :param prefix: The prefix to be searched for
        :return: true if the prefix exists, false otherwise
        """
        if self.getTrieNode(prefix.lower()) is None:
            return False
        else:
            return True

    cpdef TrieNode getTrieNode(self, str word):
        """
        Returns the TrieNode corresponding to the last character of a given word
        :param word: The word to be searched for
        :return: The TrieNode corresponding to the last character of the word
        """
        cdef int i
        cdef TrieNode current_node
        cdef str ch
        current_node = self.__root_node
        for i in range(len(word)):
            ch = word[i]
            if current_node.getChild(ch) is None:
                return None
            current_node = current_node.getChild(ch)
        return current_node
