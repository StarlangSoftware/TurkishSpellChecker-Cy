from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from SpellChecker.SpellChecker cimport SpellChecker
from Dictionary.Word cimport Word
from Corpus.Sentence cimport Sentence
from SpellChecker.SpellCheckerParameter cimport SpellCheckerParameter

cdef class SimpleSpellChecker(SpellChecker):

    cdef FsmMorphologicalAnalyzer fsm
    cdef dict __merged_words
    cdef dict __split_words
    cdef SpellCheckerParameter parameter

    cpdef list __generateCandidateList(self, str word)
    cpdef object getFile(self, str file_name)
    cpdef list candidateList(self, Word word, Sentence sentence)
    cpdef Sentence spellCheck(self, Sentence sentence)
    cpdef bint forcedMisspellCheck(self, Word word, Sentence result)
    cpdef bint forcedBackwardMergeCheck(self, Word word, Sentence result, Word previousWord)
    cpdef bint forcedForwardMergeCheck(self, Word word, Sentence result, Word nextWord)
    cpdef bint forcedSplitCheck(self, Word word, Sentence result)
    cpdef bint forcedShortcutCheck(self, Word word, Sentence result)
    cpdef bint forcedDeDaSplitCheck(self, Word word, Sentence result)
    cpdef bint forcedSuffixMergeCheck(self, Word word, Sentence result, Word previousWord)
    cpdef bint forcedHyphenMergeCheck(self, Word word, Sentence result, Word previousWord, Word nextWord)
    cpdef bint forcedQuestionSuffixSplitCheck(self, Word word, Sentence result)
    cpdef loadDictionaries(self)
    cpdef str getCorrectForm(self, str wordName, dict dictionary)
    cpdef list mergedCandidatesList(self, Word previousWord, Word word, Word nextWord)
    cpdef list splitCandidatesList(self, Word word)
    cpdef tuple getSplitPair(self, Word word)
