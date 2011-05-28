#!/usr/bin/env python

import fnmatch
import os
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-r", "--remove-files", dest="remove", action='store_true',
        default=False, help="If there is file in place of link to be created, remove it")

(options, args) = parser.parse_args()

matches = []
for root, dirnames, filenames in os.walk('/home/rs/projects/dotfiles'):
    if root.find('.git') > 0: 
        continue
    for filename in filenames:
        if filename == '.git':
            continue
        if not os.path.exists(root):
            print 'Path: %s for file %s doesn\'t exist, skipping' % (root, filename)
        real_fn = os.path.join(root, filename)
        rp = root.split('dotfiles/')
        part_path = ''
        if len(rp) == 2:
            part_path = rp[1]
        if len(rp) > 2:
            print 'Check this path: %s' % (root)
            continue
        link_fn = os.path.join(os.path.join('/home/rs', part_path), filename)
        if os.path.islink(link_fn):
            print 'Removing link (will install new)'
            os.unlink(link_fn)
        if os.path.isfile(link_fn):
            if options.remove:
                print 'Removing file (will install link)'
                os.unlink(link_fn)
            else:
                print '%s is file blocking our operation (try --remove-files), skipping' % (link_fn)
                continue

        if os.path.isdir(link_fn):
            print '%s is directory blocking our operation, skipping' % (link_fn)
            continue
        print 'Creating link: %s -> %s' % (link_fn, real_fn)
        os.symlink(real_fn, link_fn)
