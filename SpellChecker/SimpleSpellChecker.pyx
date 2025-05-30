from random import randrange
import re

from Dictionary.TxtWord cimport TxtWord
from Language.TurkishLanguage cimport TurkishLanguage
from MorphologicalAnalysis.FsmParseList cimport FsmParseList

import pkg_resources
from SpellChecker.Candidate cimport Candidate
from SpellChecker.Operator import Operator

cdef class SimpleSpellChecker(SpellChecker):

    __shortcuts: list = ["cc", "cm2", "cm", "gb", "ghz", "gr", "gram", "hz", "inc", "inch", "inç", "kg", "kw", "kva",
                         "litre", "lt", "m2", "m3", "mah", "mb", "metre", "mg", "mhz", "ml", "mm", "mp", "ms",
                         "mt", "mv", "tb", "tl", "va", "volt", "watt", "ah", "hp", "oz", "rpm", "dpi", "ppm", "ohm",
                         "kwh", "kcal", "kbit", "mbit", "gbit", "bit", "byte", "mbps", "gbps", "cm3", "mm2", "mm3",
                         "khz", "ft", "db", "sn"]
    __conditionalShortcuts: list = ["g", "v", "m", "l", "w", "s"]
    __questionSuffixList: list = ["mi", "mı", "mu", "mü", "miyim", "misin", "miyiz", "midir", "miydi", "mıyım", "mısın",
                                  "mıyız", "mıdır", "mıydı", "muyum", "musun", "muyuz", "mudur", "muydu", "müyüm",
                                  "müsün", "müyüz", "müdür", "müydü", "miydim", "miydin", "miydik", "miymiş", "mıydım",
                                  "mıydın", "mıydık", "mıymış", "muydum", "muydun", "muyduk", "muymuş", "müydüm",
                                  "müydün", "müydük", "müymüş", "misiniz", "mısınız", "musunuz", "müsünüz", "miyimdir",
                                  "misindir", "miyizdir", "miydiniz", "miydiler", "miymişim", "miymişiz", "mıyımdır",
                                  "mısındır", "mıyızdır", "mıydınız", "mıydılar", "mıymışım", "mıymışız", "muyumdur",
                                  "musundur", "muyuzdur", "muydunuz", "muydular", "muymuşum", "muymuşuz", "müyümdür",
                                  "müsündür", "müyüzdür", "müydünüz", "müydüler", "müymüşüm", "müymüşüz", "miymişsin",
                                  "miymişler", "mıymışsın", "mıymışlar", "muymuşsun", "muymuşlar", "müymüşsün",
                                  "müymüşler", "misinizdir", "mısınızdır", "musunuzdur", "müsünüzdür"]

    def __init__(self, fsm: FsmMorphologicalAnalyzer, parameter: SpellCheckerParameter = None):
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
        if parameter is None:
            self.parameter = SpellCheckerParameter()
        else:
            self.parameter = parameter
        self.loadDictionaries()

    cpdef object getFile(self, str file_name):
        """
        Opens and returns a file reader of a given file name.
        :param file_name: File to read
        :return: File reader of the given file.
        """
        if len(self.parameter.getDomain()) == 0:
            return open(pkg_resources.resource_filename(__name__, 'data/' + file_name), "r", encoding="utf8")
        else:
            return open(pkg_resources.resource_filename(__name__, 'data/' + self.parameter.getDomain() + "_" + file_name), "r", encoding="utf8")

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

    cpdef list candidateList(self, Word word, Sentence sentence):
        """
        The candidateList method takes a Word as an input and creates a candidates list by calling generateCandidateList
        method with given word. Then, it loop i times where i ranges from 0 to size of candidates list and creates a
        FsmParseList by calling morphologicalAnalysis with each item of candidates list. If the size of FsmParseList is
        0, it then removes the ith item.

        PARAMETERS
        ----------
        word : Word
            Word input.
        sentence: Sentence
            Sentence input.

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
                    self.forcedBackwardMergeCheck(word, result, previous_word) or \
                    self.forcedSuffixMergeCheck(word, result, previous_word):
                i = i + 1
                continue
            if self.forcedForwardMergeCheck(word, result, next_word) or \
                    self.forcedHyphenMergeCheck(word, result, previous_word, next_word):
                i = i + 2
                continue
            if self.forcedSplitCheck(word, result) or self.forcedShortcutCheck(word, result) or \
                    self.forcedDeDaSplitCheck(word, result) or self.forcedQuestionSuffixSplitCheck(word, result)or \
                    self.forcedSuffixSplitCheck(word, result):
                i = i + 1
                continue
            fsm_parse_list = self.fsm.morphologicalAnalysis(word.getName())
            upper_case_fsm_parse_list = self.fsm.morphologicalAnalysis(Word.toCapital(word.getName()))
            if fsm_parse_list.size() == 0 and upper_case_fsm_parse_list.size() == 0:
                candidates = self.mergedCandidatesList(previous_word, word, next_word)
                if len(candidates) < 1:
                    candidates.extend(self.candidateList(word, sentence))
                if len(candidates) < 1:
                    candidates.extend(self.splitCandidatesList(word))
                if len(candidates) > 0:
                    random_candidate = randrange(len(candidates))
                    new_word = Word(candidates[random_candidate].getName())
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
        """
        Checks if the given word is a misspelled word according to the misspellings list, and if it is, then replaces
        it with its correct form in the given sentence.
        :param word: the {@link Word} to check for misspelling
        :param result: the {@link Sentence} that the word belongs to
        :return: true if the word was corrected, false otherwise
        """
        cdef str forced_replacement
        forced_replacement = self.fsm.getDictionary().getCorrectForm(word.getName())
        if forced_replacement != "":
            result.addWord(Word(forced_replacement))
            return True
        return False

    cpdef bint forcedBackwardMergeCheck(self,
                                 Word word,
                                 Sentence result,
                                 Word previousWord):
        """
        Checks if the given word and its preceding word need to be merged according to the merged list. If the merge
        is needed, the word and its preceding word are replaced with their merged form in the given sentence.
        :param word: the {@link Word} to check for merge
        :param result: the {@link Sentence} that the word belongs to
        :param previousWord: the preceding {@link Word} of the given {@link Word}
        :return: true if the word was merged, false otherwise
        """
        cdef str forced_replacement
        if previousWord is not None:
            forced_replacement = self.getCorrectForm(
                result.getWord(result.wordCount() - 1).getName() + " " + word.getName(),
                self.__merged_words)
            if forced_replacement != "":
                result.replaceWord(result.wordCount() - 1, Word(forced_replacement))
                return True
        return False

    cpdef bint forcedForwardMergeCheck(self,
                                Word word,
                                Sentence result,
                                Word nextWord):
        """
        Checks if the given word and its next word need to be merged according to the merged list. If the merge is
        needed, the word and its next word are replaced with their merged form in the given sentence.
        :param word: the {@link Word} to check for merge
        :param result: the {@link Sentence} that the word belongs to
        :param nextWord: the next {@link Word} of the given {@link Word}
        :return: true if the word was merged, false otherwise
        """
        cdef str forced_replacement
        if nextWord is not None:
            forced_replacement = self.getCorrectForm(word.getName() + " " + nextWord.getName(),
                                                     self.__merged_words)
            if forced_replacement != "":
                result.addWord(Word(forced_replacement))
                return True
        return False

    def addSplitWords(self,
                      multiWord: str,
                      result: Sentence):
        """
        Given a multiword form, splits it and adds it to the given sentence.
        :param multiWord: multiword form to split
        :param result: the {@link Sentence} to add the split words to
        """
        cdef str word
        cdef list words
        words = multiWord.split(" ")
        for word in words:
            result.addWord(Word(word))

    cpdef bint forcedSplitCheck(self,
                                Word word,
                                Sentence result):
        """
        Checks if the given word needs to be split according to the split list. If the split is needed, the word is
        replaced with its split form in the given sentence.
        :param word: the {@link Word} to check for split
        :param result: the {@link Sentence} that the word belongs to
        :return: true if the word was split, false otherwise
        """
        cdef str forced_replacement
        forced_replacement = self.getCorrectForm(word.getName(), self.__split_words)
        if forced_replacement != "":
            self.addSplitWords(forced_replacement, result)
            return True
        return False

    cpdef bint forcedShortcutCheck(self,
                                   Word word,
                                   Sentence result):
        """
        Checks if the given word is a shortcut form, such as "5kg" or "2.5km". If it is, it splits the word into its
        number and unit form and adds them to the given sentence.
        :param word: the {@link Word} to check for shortcut split
        :param result: the {@link Sentence} that the word belongs to
        :return: true if the word was split, false otherwise
        """
        cdef str shortcut_regex, conditional_shortcut_regex, forced_replacement
        cdef int i
        cdef tuple pair
        shortcut_regex = "(([1-9][0-9]*)|[0])(([.]|[,])[0-9]*)?(" + self.__shortcuts[0]
        for i in range(1, len(self.__shortcuts)):
            shortcut_regex = shortcut_regex + "|" + self.__shortcuts[i]
        shortcut_regex = shortcut_regex + ")"
        conditional_shortcut_regex = "(([1-9][0-9]{0,2})|[0])(([.]|[,])[0-9]*)?(" + self.__conditionalShortcuts[0]
        for i in range(1, len(self.__conditionalShortcuts)):
            conditional_shortcut_regex = conditional_shortcut_regex + "|" + self.__conditionalShortcuts[i]
        conditional_shortcut_regex = conditional_shortcut_regex + ")"
        compiled_expression1 = re.compile(shortcut_regex)
        compiled_expression2 = re.compile(conditional_shortcut_regex)
        if compiled_expression1.fullmatch(word.getName()) or compiled_expression2.fullmatch(word.getName()):
            pair = self.getSplitPair(word)
            forced_replacement = pair[0] + " " + pair[1]
            result.addWord(Word(forced_replacement))
            return True
        return False

    cpdef bint forcedDeDaSplitCheck(self,
                             Word word,
                             Sentence result):
        """
        Checks if the given word has a "da" or "de" suffix that needs to be split according to a predefined set of
        rules. If the split is needed, the word is replaced with its bare form and "da" or "de" in the given sentence.
        :param word: the {@link Word} to check for "da" or "de" split
        :param result: the {@link Sentence} that the word belongs to
        :return: true if the word was split, false otherwise
        """
        cdef str word_name, capitalized_word_name, new_word_name
        cdef TxtWord txt_word, txt_new_word
        cdef FsmParseList fsm_parse_list
        word_name = word.getName()
        capitalized_word_name = Word.toCapital(word_name)
        txt_word = None
        if word_name.endswith("da") or word_name.endswith("de"):
            if self.fsm.morphologicalAnalysis(word_name).size() == 0 and \
                    self.fsm.morphologicalAnalysis(capitalized_word_name).size() == 0:
                new_word_name = word_name[0:len(word_name) - 2]
                fsm_parse_list = self.fsm.morphologicalAnalysis(new_word_name)
                txt_new_word = self.fsm.getDictionary().getWord(Word.toLower(new_word_name))
                if txt_new_word is not None and isinstance(txt_new_word, TxtWord) and txt_new_word.isProperNoun():
                    new_word_name_capitalized = Word.toCapital(new_word_name)
                    if self.fsm.morphologicalAnalysis(new_word_name_capitalized + "'" + "da").size() > 0:
                        result.addWord(Word(new_word_name_capitalized + "'" + "da"))
                    else:
                        result.addWord(Word(new_word_name_capitalized + "'" + "de"))
                    return True
                if fsm_parse_list.size() > 0:
                    txt_word = self.fsm.getDictionary().getWord(
                        fsm_parse_list.getParseWithLongestRootWord().getWord().getName())
                if txt_word is not None and isinstance(txt_word, TxtWord) and not txt_word.isCode():
                    result.addWord(Word(new_word_name))
                    if TurkishLanguage.isBackVowel(Word.lastVowel(new_word_name)):
                        if txt_word.notObeysVowelHarmonyDuringAgglutination():
                            result.addWord(Word("de"))
                        else:
                            result.addWord(Word("da"))
                    else:
                        if txt_word.notObeysVowelHarmonyDuringAgglutination():
                            result.addWord(Word("da"))
                        else:
                            result.addWord(Word("de"))
                    return True
        return False

    cpdef bint forcedSuffixMergeCheck(self,
                               Word word,
                               Sentence result,
                               Word previousWord):
        """
        Checks if the given word is a suffix like 'li' or 'lik' that needs to be merged with its preceding word which
        is a number. If the merge is needed, the word and its preceding word are replaced with their merged form in
        the given sentence.
        :param word: the {@link Word} to check for merge
        :param result: the {@link Sentence} that the word belongs to
        :param previousWord: the preceding {@link Word} of the given {@link Word}
        :return: true if the word was merged, false otherwise
        """
        cdef list li_list, lik_list
        cdef str suffix
        li_list = ["li", "lı", "lu", "lü"]
        lik_list = ["lik", "lık", "luk", "lük"]
        compiled_expression = re.compile("[0-9]+")
        if word.getName() in li_list or word.getName() in lik_list:
            if previousWord is not None and compiled_expression.fullmatch(previousWord.getName()):
                for suffix in li_list:
                    if len(word.getName()) == 2 and self.fsm.morphologicalAnalysis(
                            previousWord.getName() + "'" + suffix).size() > 0:
                        result.replaceWord(result.wordCount() - 1, Word(previousWord.getName() + "'" + suffix))
                        return True
                for suffix in lik_list:
                    if len(word.getName()) == 3 and self.fsm.morphologicalAnalysis(
                            previousWord.getName() + "'" + suffix).size() > 0:
                        result.replaceWord(result.wordCount() - 1, Word(previousWord.getName() + "'" + suffix))
                        return True
        return False

    cpdef bint forcedHyphenMergeCheck(self,
                               Word word,
                               Sentence result,
                               Word previousWord,
                               Word nextWord):
        """
        Checks whether the next word and the previous word can be merged if the current word is a hyphen, an en-dash
        or an em-dash. If the previous word and the next word exist and they are valid words, it merges the previous
        word and the next word into a single word and add the new word to the sentence If the merge is valid, it
        returns true.
        :param word: current {@link Word}
        :param result: the {@link Sentence} that the word belongs to
        :param previousWord: the {@link Word} before current word
        :param nextWord: the {@link Word} after current word
        :return: true if merge is valid, false otherwise
        """
        cdef str new_word_name
        if word.getName() == "-" or word.getName() == "–" or word.getName() == "—":
            compiled_expression = re.compile("[a-zA-ZçöğüşıÇÖĞÜŞİ]+")
            if previousWord is not None and nextWord is not None and \
                    compiled_expression.fullmatch(previousWord.getName()) and \
                    compiled_expression.fullmatch(nextWord.getName()):
                new_word_name = previousWord.getName() + "-" + nextWord.getName()
                if self.fsm.morphologicalAnalysis(new_word_name).size() > 0:
                    result.replaceWord(result.wordCount() - 1, Word(new_word_name))
                    return True
        return False

    cpdef bint forcedSuffixSplitCheck(self,
                               Word word,
                               Sentence result):
        """
        Checks whether the given {@link Word} can be split into a proper noun and a suffix, with an apostrophe in
        between and adds the split result to the {@link Sentence} if it's valid.
        :param word: the {@link Word} to check for forced suffix split.
        :param result: the {@link Sentence} that the word belongs to
        :return: true if the split is successful, false otherwise.
        """
        cdef str word_name, probable_proper_noun, probable_suffix, apostrophe_word
        cdef TxtWord txt_word
        cdef int i
        word_name = word.getName()
        if self.fsm.morphologicalAnalysis(word_name).size() > 0:
            return False
        for i in range(1, len(word_name)):
            probable_proper_noun = Word.toCapital(word_name)[:i]
            probable_suffix = word_name[i:]
            apostrophe_word = probable_proper_noun + "'" + probable_suffix
            txt_word = self.fsm.getDictionary().getWord(Word.toLower(probable_proper_noun))
            if txt_word is not None and isinstance(txt_word, TxtWord) and txt_word.isProperNoun() \
                and self.fsm.morphologicalAnalysis(apostrophe_word).size() > 0:
                result.addWord(Word(apostrophe_word))
                return True
        return False

    cpdef bint forcedQuestionSuffixSplitCheck(self,
                                       Word word,
                                       Sentence result):
        """
        Checks whether the current word ends with a valid question suffix and split it if it does. It splits the word
        with the question suffix and adds the two new words to the sentence. If the split is valid, it returns true.
        :param word: current {@link Word}
        :param result: the {@link Sentence} that the word belongs to
        :return: true if split is valid, false otherwise
        """
        cdef str word_name, split_word_name, question_suffix
        cdef TxtWord split_word_root
        word_name = word.getName()
        if self.fsm.morphologicalAnalysis(word_name).size() > 0:
            return False
        for question_suffix in self.__questionSuffixList:
            if word_name.endswith(question_suffix):
                split_word_name = word_name[0:word_name.rindex(question_suffix)]
                if self.fsm.morphologicalAnalysis(split_word_name).size() < 1:
                    return False
                split_word_root = self.fsm.getDictionary().getWord(self.fsm.morphologicalAnalysis(split_word_name).getParseWithLongestRootWord().getWord().getName())
                if self.fsm.morphologicalAnalysis(split_word_name).size() > 0 and split_word_root is not None \
                        and isinstance(split_word_root, TxtWord) and not split_word_root.isCode():
                    result.addWord(Word(split_word_name))
                    result.addWord(Word(question_suffix))
                    return True
        return False

    cpdef loadDictionaries(self):
        """
        Loads the merged and split lists from the specified files.
        """
        cdef str line, word, split_word
        cdef list items, lines
        cdef int index
        input_file = self.getFile('merged.txt')
        lines = input_file.readlines()
        for line in lines:
            items = line.strip().split(" ")
            self.__merged_words[items[0] + " " + items[1]] = items[2]
        input_file.close()
        input_file = self.getFile('split.txt')
        lines = input_file.readlines()
        for line in lines:
            index = line.strip().index(' ')
            word = line.strip()[:index]
            split_word = line.strip()[index + 1:]
            self.__split_words[word] = split_word
        input_file.close()

    cpdef str getCorrectForm(self, str wordName, dict dictionary):
        """
        Returns the correct form of a given word by looking it up in the provided dictionary.
        :param wordName: the name of the word to look up in the dictionary
        :param dictionary: the dictionary to use for looking up the word
        :return: the correct form of the word, as stored in the dictionary, or null if the word is not found
        """
        if wordName in dictionary:
            return dictionary[wordName]
        return ""

    cpdef list mergedCandidatesList(self, Word previousWord, Word word, Word nextWord):
        """
        Generates a list of merged candidates for the word and previous and next words.
        :param previousWord: The previous {@link Word} in the sentence.
        :param word: The {@link Word} currently being checked.
        :param nextWord: The next {@link Word} in the sentence.
        :return: A list of merged candidates.
        """
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
        """
        Generates a list of split candidates for the given word.
        :param word: The {@link Word} currently being checked.
        :return: A list of split candidates.
        """
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
        """
        Splits a word into two parts, a key and a value, based on the first non-numeric/non-punctuation character.
        :param word: the {@link Word} object to split
        :return: an {@link AbstractMap.SimpleEntry} object containing the key (numeric/punctuation characters) and the
        value (remaining characters)
        """
        cdef str key, value
        cdef int j
        key = ""
        j = 0
        while j < len(word.getName()):
            if "0" <= word.getName()[j] <= "9" or word.getName()[j] == '.' or word.getName()[j] == ',':
                key = key + word.getName()[j]
            else:
                break
            j = j + 1
        value = word.getName()[j:]
        return key, value
