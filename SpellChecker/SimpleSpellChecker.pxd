from MorphologicalAnalysis.FsmMorphologicalAnalyzer cimport FsmMorphologicalAnalyzer
from SpellChecker.SpellChecker cimport SpellChecker
from Dictionary.Word cimport Word
from Corpus.Sentence cimport Sentence


cdef class SimpleSpellChecker(SpellChecker):

    cdef FsmMorphologicalAnalyzer fsm

    cpdef list __generateCandidateList(self, str word)
    cpdef list candidateList(self, Word word)
    cpdef Sentence spellCheck(self, Sentence sentence)
