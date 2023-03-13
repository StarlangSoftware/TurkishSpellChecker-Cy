from Corpus.Sentence cimport Sentence
from Dictionary.Word cimport Word

from SpellChecker.NGramSpellChecker cimport NGramSpellChecker
from SpellChecker.Trie cimport Trie
from SpellChecker.TrieCandidate cimport TrieCandidate

cdef class TrieBasedSpellChecker(NGramSpellChecker):

    cdef list __generated_words
    cdef Trie __trie

    cpdef loadTrieDictionaries(self)
    cpdef prepareTrie(self)
    cpdef list candidateList(self, Word word, Sentence sentence)
    cpdef int searchCandidates(self, list result, TrieCandidate candidate)
    cpdef list generateTrieCandidates(self, TrieCandidate candidate)