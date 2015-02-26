#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import sys
import pywikibot
from parameter import Parameter
import sirius_si
import sirius_bo


def generate_parameter_page(parameter):
    bot_default_comment = ('Automatically generated by ' + os.path.basename(__file__))
    site = pywikibot.Site('en', 'siriuswiki')  
    page = pywikibot.Page(site, 'Parameter:'+parameter.name)
    page.text = parameter.create_wiki_page()
    #page.save(bot_default_comment)
    try:
        page.save(bot_default_comment)
    except pywikibot.PageNotSaved:
        print('problem saving parameter "' + parameter.name + '"')

def print_help(argv):
    print('NAME')
    print('      ' + 'updatewiki' + ' - updates Sirius wiki pages' )
    print('')
    print('SYNOPSIS')
    print('      ' + 'updatewiki' + ' [STRING1] [STRING2] [STRING3] ...')
    print('')
    print('EXAMPLES')
    print('      ' + '01. lists all parameters in Sirius wiki:')
    print('      ' + 'updatewiki ".*" --just-print')
    print('')
    print('      ' + '02. updates all parameters in Sirius wiki:')
    print('      ' + 'updatewiki ".*"')
    print('')
    print('      ' + '03. lists all parameters in the storage ring:')
    print('      ' + 'updatewiki "SI .*" --just-print')
    print('')
    print('      ' + '04. updates all parameters in the storage ring:')
    print('      ' + 'updatewiki "SI .*"')
    print('')
    print('      ' + '05. updates all booster to storage ring transport line parameters:')
    print('      ' + 'updatewiki "TS .*"')
    print('')
    print('      ' + '06. updates all booster parameters:')
    print('      ' + 'updatewiki "BO .*"')
    print('')
    print('      ' + '07. updates all linac to booster transport line parameters:')
    print('      ' + 'updatewiki "TS .*"')
    print('')
    print('      ' + '08. updates all linac parameters:')
    print('      ' + 'updatewiki "LI .*"')
    print('')
    print('      ' + '09. prints this help:')
    print('      ' + 'updatewiki --help')
    print('')


def process_input(regexp, list_flag):

    parameters = sirius_si.parameter_list + sirius_bo.parameter_list

    malformed_regexp = False
    for parameter in parameters:
        try:
            searchobj =re.search(regexp, parameter.name)
            if searchobj:
               if list_flag:
                    print(parameter.name)
               else:
                    generate_parameter_page(parameter)
        except:
            malformed_regexp = True
            break
    if malformed_regexp:
        print('Malformed regular expression!')

def process_arguments(argv):
    list_flag, regexp = False, None
    for arg in argv[1:]:
        if arg == '--help':
            print_help(argv)
        elif arg == '--just-print':
            list_flag = True
        else:
            regexp = arg
    if regexp is not None:
        process_input(regexp, list_flag)
    else:
        if not list_flag:
            print_help(argv)

if __name__ == "__main__":
    argv = sys.argv
    #print(argv)
    #argv = ['updatewiki.py', '--just-print', '--si', 'beam']
    process_arguments(argv)
    
