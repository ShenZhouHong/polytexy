#!/usr/bin/env python3

# This script is a Python pandoc filter that is designed to perform word
# substitutions according to CSV rulesets. These substitutions are currently
# used for ae, oe ligatures, as well as diaeresis. The rulesets are CSV files in
# the format of search,replace. Replacements are meant to be case-sensitive.

import panflute as pf
import string
import csv
import re
import os

base_path = os.path.dirname(os.path.abspath(__file__))

# List of word substitution rulesets, in the form of CSV files. These rulesets
# take the form of lines of search,replace strings, where search is the term
# that is being looked for, and replace is the substitution.
ruleset_files: list[str] = [
    base_path + '/ae-ligature.csv',
    base_path + '/oe-ligature.csv',
    base_path + '/diaeresis.csv',
    base_path + '/custom.csv'
]

# Initialise a ruleset dict containing "search":"replace" as key-value pairs
# NB: We use a dictionary instead of a list, because list lookups are in O(n),
# but dictionary lookups by key are in O(1) time.
ruleset: dict[str:str] = {}

# Load and append all rules from rulesets into one master dict
for file in ruleset_files:
    with open(file) as csv_file:
        for row in csv.reader(csv_file, delimiter=','):
            # Append lowercase strings to dict
            ruleset[row[0].lower()] = row[1].lower()

def preserve_case(original: str, substitution:str) -> str:
    """
    Auxiliary function which allows us to preserve case (i.e. capitalization) of
    the original string with the substituted string.
    """
    # First, take care of the trivial cases
    if original.isupper():
        # All uppercase e.g. UPPER
        return substitution.upper()
    elif original.islower():
        # All lowercase e.g. lower
        return substitution.lower()
    elif original[0].isupper and original[1:].islower():
        # Title case    e.g. Title
        return substitution[0].upper() + substitution[1:].lower()
    
    # Non-trivial case: e.g. SpOnGeCaSe
    else:
        # We generate a list of characters using a list comprehension. The case
        # logic is held within the list comprehension here. We essentially
        # iterate over the modulo of the original string (wrapping back to the)
        # start every time we exceed it, for cases when the substitute is longer
        # than the original, and copy the case from each letter of the original
        # to the substitution string.
        character_list: list[str] = [
            # Note that we use the modulo of the original's length, so that in
            # cases where len(original) != len(substitution), we do not end up
            # going out of bounds.
            letter.upper() if original[index % (len(original) - 1)].isupper()
            else letter.lower()
            for index, letter in enumerate(substitution)
        ]
        # Finally, we join all the letters in the character-list together, and
        # return it.
        return "".join(character_list)

def action(element, doc):
    """
    Python pandoc filter which performs case-aware string substitution, with the
    substitutions defined according to CSV rulesets.
    """
    # For every string element
    if isinstance(element, pf.Str):
        match: str = element.text.strip(string.punctuation)

        # We do some primitive lemmatizing by removing the plural 's'
        if len(match.lower()) > 0 and match.lower()[-1] == 's':
            key: str = match.lower()[:-1]
            plural: bool = True
        else:
            key = match.lower()
            plural: bool = False

        # If the word matches a rule in our ruleset
        if key in ruleset:
            # Build case-sensitive replacement and replace text
            replacement = preserve_case(match, ruleset[key])

            # If the word is plural, make sure to add the plural 's' back
            if plural:
                replacement += "s"

            # We reintroduce replacement w/ regex to preserve punctuation
            element.text = re.sub(match, replacement, element.text)

def main(doc=None):
    return pf.run_filter(action, doc=doc)

if __name__ == '__main__':
    main()