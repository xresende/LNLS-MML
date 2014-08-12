#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import pywikibot
import storage_ring
import booster


bot_default_comment = ('Automatically generated by ' + os.path.basename(__file__))


def check_deps(parameters):
    names = [parameter.name for parameter in parameters]
    for parameter in parameters:
        msg = ''
        deps = parameter.deps
        for dep in deps:
            if dep not in names:
                if msg is '':
                    msg = str(parameter.name) + ': ' + str(dep)
                else:
                    msg += ', ' + str(dep)

        if msg is not '':
            print(msg)


def generate_parameter_name_list_page(label, parameters):
    #return
    wiki = []
    for parameter in parameters:
        name = parameter.name.replace(label+' ', '')
        name_capitalized = name[0].upper() + name[1:]
        line = '#[[Parameter:' + parameter.name + '|' + name_capitalized + ']]'
        wiki.append(line)
    
    site = pywikibot.Site('en', 'siriuswiki')
    page = pywikibot.Page(site, 'Machine:' + label + ' parameter name list')
    page.text = '\n'.join(wiki)
    page.save(bot_default_comment)
    
    
def generate_parameter_pages(parameters):
    #return
    site = pywikibot.Site('en', 'siriuswiki')  
    for parameter in parameters:
        page = pywikibot.Page(site, 'Parameter:'+parameter.name)
        page.text = parameter.create_wiki_page()
        page.save(bot_default_comment)
        #print(page.text)

def update_submachine(submachine, parameters_list = None):
    if parameters_list is None:
        generate_parameter_pages(submachine.parameter_list)
    if len(parameters_list) == 0:
        return
    print('<'+submachine.label+'>')
    parm_names = [p.name for p in submachine.parameter_list]
    parameter_updated = False
    for parameter in parameters_list:
        try:
            parameter_full_name = submachine.label + ' ' + parameter
            idx = parm_names.index(parameter_full_name)
            parm = submachine.parameter_list[idx]
            generate_parameter_pages([parm])
            #print(parm.name + ' updated.')
            parameter_updated = True
        except ValueError:
            print(parameter + ' not defined!')
    if parameter_updated:
        generate_parameter_name_list_page(submachine.label, submachine.parameter_list)
        #print('"Machine:'+submachine.label+' parameter name list" page updated.')
    

    
def update_all():
    update_submachine(submachine = storage_ring)
    update_submachine(submachine = booster)
    
def print_help():
    print('NAME')
    print('      ' + sys.argv[0] + ' - updates Sirius wiki pages' )
    print('')
    print('SYNOPSIS')
    print('      ' + sys.argv[0] + ' [STRING1] [STRING2] [STRING3]...')
    print('')
    print('EXAMPLES')
    print('      ' + '1. updates all parameters in Sirius wiki:')
    print('      ' + sys.argv[0])
    print('')
    print('      ' + '2. updates all storage ring parameters:')
    print('      ' + sys.argv[0] + ' sr')
    print('')
    print('      ' + '3. updates all booster parameters:')
    print('      ' + sys.argv[0] + ' booster')
    print('')
    print('      ' + '4. updates two storage ring parameters and one booster parameter:')
    print('      ' + sys.argv[0] + ' sr "beam energy" circumference booster "horizontal tune"')
    print('')
    
if __name__ == "__main__":
    
    if len(sys.argv) < 2:
        update_all()
    elif len(sys.argv) == 2:
        arg1 = sys.argv[1].lower()
        if arg1 == 'sr':
            update_submachine(submachine = storage_ring)
        elif arg1 == 'booster':
            update_submachine(submachine = booster)
        elif arg1 == 'deps':
            pass
        else:
            print_help()
    else:
        submachine  = None
        parms_lists = {'sr':[], 'booster':[]}
        bo_list = []
        '''builds lists with parameters'''
        for arg in sys.argv[1:]:
            arg = arg.lower();
            if arg == 'sr':
                submachine = 'sr'
            elif arg == 'booster':
                submachine = 'booster'
            else:
                if submachine is None:
                    print_help()
                else:
                    parms_lists[submachine].append(arg)
        update_submachine(storage_ring, parms_lists['sr'])
        update_submachine(booster, parms_lists['booster'])
                    
                
            
                 
#storage_ring.parameter_list.sort()
#generate_parameter_pages(storage_ring.parameter_list)
#generate_parameter_name_list_page(storage_ring.label, storage_ring.parameter_list)
#booster.parameter_list.sort()
#generate_parameter_pages(booster.parameter_list)
#generate_parameter_name_list_page(booster.label, booster.parameter_list)
