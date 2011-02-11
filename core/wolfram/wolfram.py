#!/usr/bin/env python

from urllib import urlencode, urlopen
import xml.etree.cElementTree as xtree
import sys, traceback

appId = '395X7T-8JLXGEP8YH'

def search(query, format=('plaintext', )):
    return parseWolframAlphaResponse(urlopen('http://api.wolframalpha.com/v2/query?%s' % (
            urlencode(
                {
                    'appid': appId,
                    'input': query,
                    'format': ','.join(format)
                }
            )
        )
    ))
def parseWolframAlphaResponse(response, redirected = False, results = None):
    results = results if results is not None else []
    xmlTree = xtree.fromstring(response.read())
    recalculate = xmlTree.get('recalculate')
    success = xmlTree.get('success')
    if success == 'true':
        for pod in xmlTree.findall('pod'):
            title = pod.get('title')
            plaintext = pod.find('subpod/plaintext')
            if plaintext is not None and plaintext.text:
                results.append((title, plaintext.text.split('\n')))
        if recalculate:
            if not redirected:
                return parseWolframAlphaResponse(urlopen(recalculate), True, results)
            elif results:
                return True, results
            else:
                return error, 'Too many redirects.'
        elif success == 'true':
            return True, results
        else:
            return False, [tip.get('text') for tip in xmlTree.findall('tips/tip')]

if __name__ == "__main__":
    try:
        text = sys.stdin.readlines()
        print '\n\x02', 'Calculating...', '\n'
        result = search(" ".join(text))
        bool, response = result
        if bool == True:
            for title, poddle in response:
	        try: print '\x02', title, '\n\x0310,1', " ".join(poddle).encode('iso-8859-8'), '\n'
	        except (UnicodeEncodeError): 
	            print '\x02\x034,1', '  !!UnicodeEncodeException occurred here!!'
	            continue
        elif bool == False:
            if len(" ".join(response)) == 0:
                print '\x02\x034,1', 'No results found, try a different keyword.', '\n'
            elif len(" ".join(response)) != 0:
                print '\x02\x034,1', 'No results found, try a different keyword.', '\n', '\x02\x034,1', " ".join(response)

    except (SystemExit, KeyboardInterrupt):
        print 'exiting.'
    except (TypeError, AttributeError, IOError) as (errno, errstr):
        print '['+errno+'] ', errstr
    except: traceback.last()