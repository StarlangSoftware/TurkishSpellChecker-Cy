from Corpus.Sentence cimport Sentence
from Dictionary.Word cimport Word
from NGram.NGram cimport NGram
from SpellChecker.SimpleSpellChecker cimport SimpleSpellChecker
from SpellChecker.SpellCheckerParameter cimport SpellCheckerParameter

cdef class NGramSpellChecker(SimpleSpellChecker):

    cdef NGram __nGram
    cdef SpellCheckerParameter __parameter

    cpdef Word checkAnalysisAndSetRootForWordAtIndex(self, Sentence sentence, int index)
    cpdef Word checkAnalysisAndSetRoot(self, str word)
    cpdef setThreshold(self, float threshold)
    cpdef float getProbability(self, str word1, str word2)
    cpdef Sentence spellCheck(self, Sentence sentence)
