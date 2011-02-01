#!/usr/bin/env python

from urllib import urlencode, urlopen
from xml.etree.cElementTree import fromstring
import sys

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
    ).read())
def parseWolframAlphaResponse(response, redirected = False):
    xmlTree = fromstring(response)
    recalculate = xmlTree.get('recalculate')
    if recalculate:
        if not redirected:
            return parseWolframAlphaResponse(urlopen(recalculate).read(), True)
        else:
            return 'Error', 'Too many redirects.'
    else:
        success = xmlTree.get('success')
        if success == 'true':
            out = []
            for pod in xmlTree.findall('pod'):
                title = pod.get('title')
                plaintext = pod.find('subpod/plaintext')
                if plaintext is not None and plaintext.text:
                    out.append((title, plaintext.text.split('\n')))
                    
            return True, out
        else:
            return False, [tip.get('text') for tip in xmlTree.findall('tips/tip')]

if __name__ == "__main__":
    try:
        text = sys.stdin.readlines()
        result = search(" ".join(text))
        bool, response = result
        if bool == True:
            for title, poddle in response:
	        try: print '\x02', title, '\n', " ".join(poddle).encode('iso-8859-8'), '\n'
	        except (UnicodeEncodeError): 
	            print '\x02', '  !!UnicodeEncodeException occurred here!!'
	            continue
        elif bool == False:
            print '\x02', 'No results found, try a different keyword.', '\n', '\x02', " ".join(response)
    except (IndexError, TypeError, SystemExit, KeyboardInterrupt):
        print "lolwut."