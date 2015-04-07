#!/usr/bin/env python
# Copyright (C) 2015  Matt Borgerson
# 
# This file is part of TrayPlay.
# 
# TrayPlay is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# TrayPlay is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with TrayPlay.  If not, see <http://www.gnu.org/licenses/>.
"""A simple tool for managing Sparkle Appcast XML files.

For more information about Appcasts see the page from the Sparkle project at:

  https://github.com/sparkle-project/Sparkle/wiki/Publishing-An-Update
"""

# Sample Appcast
#-------------------------------------------------------------------------------
# <?xml version="1.0" encoding="utf-8"?>
# <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
#     <channel>
#         <title>Your Great App's Changelog</title>
#         <link>http://you.com/app/appcast.xml</link>
#         <description>Most recent changes with links to updates.</description>
#         <language>en</language>
#         <item>
#             <title>Version 2.0 (2 bugs fixed; 3 new features)</title>
#             <sparkle:releaseNotesLink>
#                 http://you.com/app/2.0.html
#             </sparkle:releaseNotesLink>
#             <pubDate>Wed, 09 Jan 2006 19:20:11 +0000</pubDate>
#             <enclosure url="http://you.com/app/Your%20Great%20App%202.0.zip" sparkle:version="2.0" length="1623481" type="application/octet-stream" sparkle:dsaSignature="BAFJW4B6B1K1JyW30nbkBwainOzrN6EQuAh" />
#             <sparkle:minimumSystemVersion>10.7</sparkle:minimumSystemVersion>
#         </item>
#
#         <item>
#             <title>Version 1.5 (8 bugs fixed; 2 new features)</title>
#             <sparkle:releaseNotesLink>
#                 http://you.com/app/1.5.html
#             </sparkle:releaseNotesLink>
#             <pubDate>Wed, 01 Jan 2006 12:20:11 +0000</pubDate>
#             <enclosure url="http://you.com/app/Your%20Great%20App%201.5.zip" sparkle:version="1.5" length="1472893" type="application/octet-stream" sparkle:dsaSignature="234818feCa1JyW30nbkBwainOzrN6EQuAh" />
#             <sparkle:minimumSystemVersion>10.7</sparkle:minimumSystemVersion>
#         </item>
#
#         <!-- Now here's an example of a version with a weird internal version number (like an SVN revision) but a human-readable external one. -->
#         <item>
#             <title>Version 1.4 (5 bugs fixed; 2 new features)</title>
#             <sparkle:releaseNotesLink>
#                 http://you.com/app/1.4.html
#             </sparkle:releaseNotesLink>
#             <pubDate>Wed, 25 Dec 2005 12:20:11 +0000</pubDate>
#             <enclosure url="http://you.com/app/Your%20Great%20App%201.4.zip" sparkle:version="241" sparkle:shortVersionString="1.4" sparkle:dsaSignature="MC0CFBfeCa1JyW30nbkBwainOzrN6EQuAh=" length="1472349" type="application/octet-stream" />
#             <sparkle:minimumSystemVersion>10.7</sparkle:minimumSystemVersion>
#         </item>
#     </channel>
# </rss>
#-------------------------------------------------------------------------------

import argparse
from lxml import etree

NS_MAP = {
    'sparkle': 'http://www.andymatuschak.org/xml-namespaces/sparkle',
    'dc':      'http://purl.org/dc/elements/1.1/'
}

class Appcast(object):
    def __init__(self, channels=None):
        self._channels = channels or []

    @property
    def channels(self):
        return self._channels
    @channels.setter
    def channels(self, value):
        self._channels = value

    def to_xml(self):
        rss = etree.Element('rss', version='2.0', nsmap=NS_MAP)
        for ch in self._channels:
            rss.append(ch.to_xml())
        return rss

    @classmethod
    def from_xml(self, element):
        channels = []

        for channel in element.findall('channel'):
            channels.append(Channel.from_xml(channel))

        return Appcast(channels=channels)

    @classmethod
    def load(cls, path):
        return cls.from_xml(etree.parse(path))

    def save(self, path):
        doc = etree.ElementTree(self.to_xml())
        doc.write(open(path, 'wb'), xml_declaration=True, encoding='utf-8', pretty_print=True)

class Channel(object):
    def __init__(self, title, link, description, language, items=None):
        self._title       = title
        self._link        = link
        self._description = description
        self._language    = language
        self._items       = items or []

    @property
    def items(self):
        return self._items
    @items.setter
    def items(self, value):
        self._items = value

    def to_xml(self):
        # Channel
        channel = etree.Element('channel')

        # Title
        title = etree.SubElement(channel, 'title')
        title.text = self._title

        # Link
        link = etree.SubElement(channel, 'link')
        link.text = self._link

        # Description
        description = etree.SubElement(channel, 'description')
        description.text = self._description

        # Language
        language = etree.SubElement(channel, 'language')
        language.text = self._language

        # Items
        for item in self._items:
            channel.append(item.to_xml())

        return channel

    @classmethod
    def from_xml(self, element):
        title       = element.find('title')
        link        = element.find('link')
        description = element.find('description')
        language    = element.find('language')
        items       = []

        for item in element.findall('item'):
            items.append(Item.from_xml(item))

        return Channel(title=title.text,
                       link=link.text,
                       description=description.text,
                       language=language.text,
                       items=items)

class Item(object):
    def __init__(self,
                 title,
                 release_notes_link,
                 pubdate,
                 url,
                 version,
                 short_version,
                 dsa_signature,
                 length,
                 type,
                 minimum_system_version):
        self._title                  = title
        self._release_notes_link     = release_notes_link
        self._pubdate                = pubdate
        self._url                    = url
        self._version                = version
        self._short_version          = short_version
        self._dsa_signature          = dsa_signature
        self._length                 = length
        self._type                   = type
        self._minimum_system_version = minimum_system_version

    def to_xml(self):
        # Item
        item = etree.Element('item')

        # Title
        title = etree.SubElement(item, 'title')
        title.text = self._title

        # Release Notes Link
        release_notes_link = etree.SubElement(item, etree.QName(NS_MAP['sparkle'], 'releaseNotesLink'))
        release_notes_link.text = self._release_notes_link

        # Pub Date
        pubdate = etree.SubElement(item, 'pubDate')
        pubdate.text = self._pubdate

        # Enclosure
        enclosure = etree.SubElement(item, 'enclosure')

        # URL
        enclosure.set('url', self._url)

        # Length
        enclosure.set('length', self._length)

        # Type
        enclosure.set('type', self._type)

        # Version
        enclosure.set(etree.QName(NS_MAP['sparkle'], 'version'), self._version)

        # Short Version String
        enclosure.set(etree.QName(NS_MAP['sparkle'], 'shortVersionString'), self._short_version)

        # DSA Signature
        enclosure.set(etree.QName(NS_MAP['sparkle'], 'dsaSignature'), self._dsa_signature)

        # Minimum System Version
        minimum_system_version = etree.SubElement(item, etree.QName(NS_MAP['sparkle'], 'minimumSystemVersion'))
        minimum_system_version.text = self._minimum_system_version

        return item

    @classmethod
    def from_xml(self, element):
        title                  = element.find('title')
        release_notes          = element.find(etree.QName(NS_MAP['sparkle'], 'releaseNotesLink'))
        pubdate                = element.find('pubDate')
        enclosure              = element.find('enclosure')
        minimum_system_version = element.find(etree.QName(NS_MAP['sparkle'], 'minimumSystemVersion'))

        return Item(title=title.text,
                    release_notes_link=release_notes.text,
                    pubdate=pubdate.text,
                    url=enclosure.get('url'),
                    version=enclosure.get(etree.QName(NS_MAP['sparkle'], 'version')),
                    short_version=enclosure.get(etree.QName(NS_MAP['sparkle'], 'shortVersionString')),
                    dsa_signature=enclosure.get(etree.QName(NS_MAP['sparkle'], 'dsaSignature')),
                    length=enclosure.get('length'),
                    type=enclosure.get('type'),
                    minimum_system_version=minimum_system_version.text)

def create(args):
    appcast = Appcast()
    appcast.save(args.appcast)

def add_channel(args):
    appcast = Appcast.load(args.appcast)
    channel = Channel(title=args.title,
                      link=args.link,
                      description=args.description,
                      language=args.language)
    appcast.channels.append(channel)
    appcast.save(args.appcast)

def add_item(args):
    appcast = Appcast.load(args.appcast)
    item = Item(title=args.title,
                release_notes_link=args.releaseNotesLink,
                pubdate=args.pubDate,
                url=args.url,
                version=args.version,
                short_version=args.shortVersionString,
                dsa_signature=args.dsaSignature,
                length=args.length,
                type=args.type,
                minimum_system_version=args.minimumSystemVersion)
    appcast.channels[args.channel].items.append(item)
    appcast.save(args.appcast)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--appcast', default='appcast.xml', help='The appcast file to manage (appcast.xml).')

    subparsers = parser.add_subparsers()

    # "create" command
    sub_parser = subparsers.add_parser('create', help='Create a new appcast.')
    sub_parser.set_defaults(func=create)

    # "add_channel" command
    sub_parser = subparsers.add_parser('add_channel', help='Add a new channel to an Appcast.')
    sub_parser.set_defaults(func=add_channel)
    sub_parser.add_argument('title')
    sub_parser.add_argument('link')
    sub_parser.add_argument('description')
    sub_parser.add_argument('language')

    # "add_item" command
    sub_parser = subparsers.add_parser('add_item', help='Add a new item to a channel.')
    sub_parser.set_defaults(func=add_item)
    sub_parser.add_argument('--channel', type=int, default=0, help='Which channel to add the item to.')
    sub_parser.add_argument('title')
    sub_parser.add_argument('releaseNotesLink')
    sub_parser.add_argument('pubDate')
    sub_parser.add_argument('url')
    sub_parser.add_argument('version')
    sub_parser.add_argument('shortVersionString')
    sub_parser.add_argument('dsaSignature')
    sub_parser.add_argument('length')
    sub_parser.add_argument('type')
    sub_parser.add_argument('minimumSystemVersion')

    args = parser.parse_args()
    args.func(args)

if __name__ == '__main__':
    main()