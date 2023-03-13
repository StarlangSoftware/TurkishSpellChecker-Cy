from Corpus.Sentence cimport Sentence
from Dictionary.Word cimport Word

from SpellChecker.NGramSpellChecker cimport NGramSpellChecker

cdef class ContextBasedSpellChecker(NGramSpellChecker):

    cdef dict __context_list

    cpdef loadContextDictionaries(self)
    cpdef list candidateList(self, Word word, Sentence sentence)
    cpdef int damerauLevenshteinDistance(self, str first, str second)
