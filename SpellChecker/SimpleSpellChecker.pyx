from random import randrange
import re

from Language.TurkishLanguage cimport TurkishLanguage
from MorphologicalAnalysis.FsmParseList cimport FsmParseList

import pkg_resources
from SpellChecker.Candidate cimport Candidate
from SpellChecker.Operator import Operator

cdef class SimpleSpellChecker(SpellChecker):

    __shortcuts: list = ["cc", "cm2", "cm", "gb", "ghz", "gr", "gram", "hz", "inc", "inch", "inç", "kg", "kw", "kva",
                         "litre", "lt", "m2", "m3", "mah", "mb", "metre", "mg", "mhz", "ml", "mm", "mp", "ms",
                         "mt", "mv", "tb", "tl", "va", "volt", "watt", "ah", "hp"]

    def __init__(self, fsm: FsmMorphologicalAnalyzer):
        """
        A constructor of SimpleSpellChecker class which takes a FsmMorphologicalAnalyzer as an input and
        assigns it to the fsm variable.

        PARAMETERS
        ----------
        fsm : FsmMorphologicalAnalyzer
            FsmMorphologicalAnalyzer type input.
        """
        self.fsm = fsm
        self.__merged_words = {}
        self.__split_words = {}
        self.loadDictionaries()

    cpdef list __generateCandidateList(self, str word):
        """
        The generateCandidateList method takes a String as an input. Firstly, it creates a String consists of lowercase
        Turkish letters and an list candidates. Then, it loops i times where i ranges from 0 to the length of given
        word. It gets substring from 0 to ith index and concatenates it with substring from i+1 to the last index as a
        new String called deleted. Then, adds this String to the candidates list. Secondly, it loops j times where j
        ranges from 0 to length of lowercase letters String and adds the jth character of this String between substring
        of given word from 0 to ith index and the substring from i+1 to the last index, then adds it to the candidates
        list. Thirdly, it loops j times where j ranges from 0 to length of lowercase letters String and adds the jth
        character of this String between substring of given word from 0 to ith index and the substring from i to the
        last index, then adds it to the candidates list.

        PARAMETERS
        ----------
        word : str
            String input.

        RETURNS
        -------
        list
            List candidates.
        """
        cdef str s, swapped, deleted, replaced, added
        cdef list candidates
        cdef int i, j
        s = TurkishLanguage.LOWERCASE_LETTERS
        candidates = []
        for i in range(len(word)):
            if i < len(word) - 1:
                swapped = word[:i] + word[i + 1] + word[i] + word[i + 2:]
                candidates.append(Candidate(swapped, Operator.SPELL_CHECK))
            if word[i] in TurkishLanguage.LETTERS or word[i] in "wqx":
                deleted = word[:i] + word[i + 1:]
                candidates.append(Candidate(deleted, Operator.SPELL_CHECK))
                for j in range(len(s)):
                    replaced = word[:i] + s[j] + word[i + 1:]
                    candidates.append(Candidate(replaced, Operator.SPELL_CHECK))
                for j in range(len(s)):
                    added = word[:i] + s[j] + word[i:]
                    candidates.append(Candidate(added, Operator.SPELL_CHECK))
        return candidates

    cpdef list candidateList(self, Word word):
        """
        The candidateList method takes a Word as an input and creates a candidates list by calling generateCandidateList
        method with given word. Then, it loop i times where i ranges from 0 to size of candidates list and creates a
        FsmParseList by calling morphologicalAnalysis with each item of candidates list. If the size of FsmParseList is
        0, it then removes the ith item.

        PARAMETERS
        ----------
        word : Word
            Word input.

        RETURNS
        -------
        list
            candidates list.
        """
        cdef list candidates
        cdef int i
        cdef FsmParseList fsm_parse_list
        cdef str new_candidate
        candidates = self.__generateCandidateList(word.getName())
        i = 0
        while i < len(candidates):
            fsm_parse_list = self.fsm.morphologicalAnalysis(candidates[i].getName())
            if fsm_parse_list.size() == 0:
                new_candidate = self.fsm.getDictionary().getCorrectForm(candidates[i].getName())
                if new_candidate != "" and self.fsm.morphologicalAnalysis(new_candidate).size() > 0:
                    candidates[i] = Candidate(new_candidate, Operator.MISSPELLED_REPLACE)
                else:
                    candidates.pop(i)
                    i = i - 1
            i = i + 1
        return candidates

    cpdef Sentence spellCheck(self, Sentence sentence):
        """
        The spellCheck method takes a Sentence as an input and loops i times where i ranges from 0 to size of words in
        given sentence. Then, it calls morphologicalAnalysis method with each word and assigns it to the FsmParseList,
        if the size of FsmParseList is equal to the 0, it adds current word to the candidateList and assigns it to the
        candidates list. If the size of candidates greater than 0, it generates a random number and selects an item from
        candidates list with this random number and assign it as newWord. If the size of candidates is not greater than
        0, it directly assigns the current word as newWord. At the end, it adds the newWord to the result Sentence.

        PARAMETERS
        ----------
        sentence : Sentence
            Sentence type input.

        RETURNS
        -------
        Sentence
            Sentence result.
        """
        cdef Sentence result
        cdef int i, repeat, random_candidate
        cdef Word word, new_word, next_word, previous_word
        cdef FsmParseList fsm_parse_list
        cdef list candidates
        result = Sentence()
        i = 0
        while i < sentence.wordCount():
            word = sentence.getWord(i)
            next_word = None
            previous_word = None
            if i > 0:
                previous_word = sentence.getWord(i - 1)
            if i < sentence.wordCount() - 1:
                next_word = sentence.getWord(i + 1)
            if self.forcedMisspellCheck(word, result) or \
                    self.forcedBackwardMergeCheck(word, result, previous_word):
                i = i + 1
                continue
            if self.forcedForwardMergeCheck(word, result, next_word):
                i = i + 2
                continue
            if self.forcedSplitCheck(word, result) or self.forcedShortcutCheck(word, result):
                i = i + 1
                continue
            fsm_parse_list = self.fsm.morphologicalAnalysis(word.getName())
            if fsm_parse_list.size() == 0:
                candidates = self.candidateList(word)
                if len(candidates) < 1:
                    candidates.extend(self.mergedCandidatesList(previous_word, word, next_word))
                if len(candidates) < 1:
                    candidates.extend(self.splitCandidatesList(word))
                if len(candidates) > 0:
                    random_candidate = randrange(len(candidates))
                    new_word = Word(candidates[random_candidate])
                    if candidates[random_candidate].getOperator() == Operator.BACKWARD_MERGE:
                        result.replaceWord(i - 1, new_word)
                        i = i + 1
                        continue
                    if candidates[random_candidate].getOperator() == Operator.FORWARD_MERGE:
                        i = i + 1
                    if candidates[random_candidate].getOperator() == Operator.SPLIT:
                        self.addSplitWords(candidates[random_candidate].getName(), result)
                        i = i + 1
                        continue
                else:
                    new_word = word
            else:
                new_word = word
            result.addWord(new_word)
            i = i + 1
        return result

    cpdef bint forcedMisspellCheck(self,
                                   Word word,
                                   Sentence result):
        cdef str forced_replacement
        forced_replacement = self.fsm.getDictionary().getCorrectForm(word.getName())
        if forced_replacement != "":
            result.addWord(Word(forced_replacement))
            return True
        return False

    cpdef bint forcedBackwardMergeCheck(self, Word word, Sentence result, Word previousWord):
        cdef str forced_replacement
        if previousWord is not None:
            forced_replacement = self.getCorrectForm(result.getWord(result.wordCount() - 1).getName() + " " + word.getName(),
                                                    self.__merged_words)
            if forced_replacement != "":
                result.replaceWord(result.wordCount() - 1, Word(forced_replacement))
                return True
        return False

    cpdef bint forcedForwardMergeCheck(self, Word word, Sentence result, Word nextWord):
        cdef str forced_replacement
        if nextWord is not None:
            forced_replacement = self.getCorrectForm(word.getName() + " " + nextWord.getName(),
                                                    self.__merged_words)
            if forced_replacement != "":
                result.addWord(Word(forced_replacement))
                return True
        return False

    def addSplitWords(self, multiWord: str, result: Sentence):
        words = multiWord.split(" ")
        result.addWord(Word(words[0]))
        result.addWord(Word(words[1]))

    cpdef bint forcedSplitCheck(self, Word word, Sentence result):
        cdef str forced_replacement
        forced_replacement = self.getCorrectForm(word.getName(), self.__split_words)
        if forced_replacement != "":
            self.addSplitWords(forced_replacement, result)
            return True
        return False

    cpdef bint forcedShortcutCheck(self, Word word, Sentence result):
        cdef str shortcut_regex, forced_replacement
        cdef int i
        shortcut_regex = "[0-9]+(" + self.__shortcuts[0]
        for i in range(1, len(self.__shortcuts)):
            shortcut_regex = shortcut_regex + "|" + self.__shortcuts[i]
        shortcut_regex = shortcut_regex + ")"
        compiled_expression = re.compile(shortcut_regex)
        if compiled_expression.fullmatch(word.getName()):
            pair = self.getSplitPair(word)
            forced_replacement = pair[0] + " " + pair[1]
            result.addWord(Word(forced_replacement))
            return True
        return False

    cpdef loadDictionaries(self):
        cdef str line
        cdef list items, lines
        input_file = open(pkg_resources.resource_filename(__name__, 'data/merged.txt'), "r", encoding="utf8")
        lines = input_file.readlines()
        for line in lines:
            items = line.strip().split(" ")
            self.__merged_words[items[0] + " " + items[1]] = items[2]
        input_file.close()
        input_file = open(pkg_resources.resource_filename(__name__, 'data/split.txt'), "r", encoding="utf8")
        lines = input_file.readlines()
        for line in lines:
            items = line.strip().split(" ")
            self.__split_words[items[0]] = items[1] + " " + items[2]
        input_file.close()

    cpdef str getCorrectForm(self, str wordName, dict dictionary):
        if wordName in dictionary:
            return dictionary[wordName]
        return ""

    cpdef list mergedCandidatesList(self, Word previousWord, Word word, Word nextWord):
        cdef list merged_candidates
        cdef Candidate backward_merge_candidate, forward_merge_candidate
        cdef FsmParseList fsm_parse_list
        merged_candidates = []
        backward_merge_candidate = None
        if previousWord is not None:
            backward_merge_candidate = Candidate(previousWord.getName() + word.getName(), Operator.BACKWARD_MERGE)
            fsm_parse_list = self.fsm.morphologicalAnalysis(backward_merge_candidate.getName())
            if fsm_parse_list.size() != 0:
                merged_candidates.append(backward_merge_candidate)
        if nextWord is not None:
            forward_merge_candidate = Candidate(word.getName() + nextWord.getName(), Operator.FORWARD_MERGE)
            if backward_merge_candidate is None or backward_merge_candidate.getName() != forward_merge_candidate.getName():
                fsm_parse_list = self.fsm.morphologicalAnalysis(forward_merge_candidate.getName())
                if fsm_parse_list.size() != 0:
                    merged_candidates.append(forward_merge_candidate)
        return merged_candidates

    cpdef list splitCandidatesList(self, Word word):
        cdef list split_candidates
        cdef int i
        cdef str first_part, second_part
        cdef FsmParseList fsm_parse_list_first, fsm_parse_list_second
        split_candidates = []
        for i in range(4, len(word.getName()) - 3):
            first_part = word.getName()[0:i]
            second_part = word.getName()[i:]
            fsm_parse_list_first = self.fsm.morphologicalAnalysis(first_part)
            fsm_parse_list_second = self.fsm.morphologicalAnalysis(second_part)
            if fsm_parse_list_first.size() > 0 and fsm_parse_list_second.size() > 0:
                split_candidates.append(Candidate(first_part + " " + second_part, Operator.SPLIT))
        return split_candidates

    cpdef tuple getSplitPair(self, Word word):
        cdef str key, value
        cdef int j
        key = ""
        j = 0
        while j < len(word.getName()):
            if "0" <= word.getName()[j] <= "9":
                key = key + word.getName()[j]
            else:
                break
            j = j + 1
        value = word.getName()[j:]
        return key, value
