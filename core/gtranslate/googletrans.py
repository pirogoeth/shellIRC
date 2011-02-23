#!/usr/bin/env python

import json as j
import argparse as ap
from urllib import urlopen as uo
from urllib import urlencode as ue
import sys as s
import re

apikey='AIzaSyDk-iXvgMG9SinQkk8TxmIEiwaSTwKdaPw'

class entities:
    def _callback(self, results):
        id = results.group(1)
        try: return unichr(int(id))
        except: return id
    def decode(self, data):
        return re.sub("&#(\d+)(;|(?=\s))", self._callback, data)
def prepParser():
    class parsed:
        pass
    store = parsed()
    parser = ap.ArgumentParser(description='Set source and target languages', add_help=True, prefix_chars='+-')
    parser.add_argument('+source', help='set the source language', default='en')
    parser.add_argument('+target', help='set the target language', default='fr')
    parser.add_argument('query', metavar='query', nargs='+', help='Query to translate')
    args = parser.parse_args(namespace=store)
    return store.source, store.target, store.query
def parseGTQuery(query, source='en', target='fr'):
    return parseGTResponse(uo('https://www.googleapis.com/language/translate/v2?%s' % (
        ue(
            (
                ('key', apikey),
                ('q', query),
                ('source', source),
                ('target', target)
            )
        )
    )))
def parseGTResponse(response):
    jdec=j.JSONDecoder()
    j.response=response.read()
    j.decoded_resp=jdec.decode(j.response)
    if 'error' in j.decoded_resp:
        results=[]
        results.append((str(j.decoded_resp['error']['code']), j.decoded_resp['error']['message']))
        return False, results
    elif 'data' in j.decoded_resp:
        a = j.decoded_resp
        b = a['data']['translations'][0]
        c = b['translatedText']
        return True, c
if __name__ == "__main__":
    source, target, query = prepParser()
    e = entities()
    query = " ".join(query)
    bool, response = parseGTQuery(query, source, target)
    if bool is True:
        try: print '\x02\x0310Google Translate: %s \x037-> \x0310%s: %s \x037->\x0310 %s' % (source, target, query, e.decode(response).encode('utf8'))
        except (UnicodeEncodeError): print '\x02\x034A WILD UnicodeEncodeException APPEARS!'
    elif bool is False:
        print '\x02\x0310Google Translate: \x034[FAILED]:\x0310 %s \x037->\x0310 %s: %s' % (source, target, query)
        for code, message in response:
          print '\x02\x034Error: [%s] %s' % (code, message)