#!/usr/bin/python
#
# based on mail2muttalias RELEASE 0.5
# Copyright by Moritz Moeller-Herrmann <mmh@gmnx.net>
# http://webrum.uni-mannheim.de/jura/moritz/mail2muttalias.html
#
# Modified by Charles Cazabon <pythonstuff@discworld.dyndns.org>
# My changes are released under the GNU General Public License version 2.
#
##

##**** User CONFIGURATION here: *******
# The mutt aliases file to use must be supplied in one of three ways:
#	-supply it as the first argument to this script (preferred)
#	-specify it in the environment variable listed below
#	-specify it in the ALIASFILE variable below
#
# Warning: This file should NOT be your .muttc as everything but aliasses are deleted!!
#
# The first commandline argument (if any) is used by default.
#
# If there is no commandline argument, the environment variable chosen
# below is tried.
#
# If there is no commandline argument, and the environment variable below
# is not set, then the program attempts to use the contents of the
# ALIASFILE variable below.
#
# The aliases file may be empty, but must exist. Create an empty file if
# necessary.
# e.g. 'touch .mutt-aliases'
#
# The best way to call this script is with a macro in mutt.  For
# example, bind it to 'A' in the pager as follows:
#
# macro pager A |'~/path/to/mail2muttalias.py ~/.mutt-aliases'\n
#
# Then when viewing a message, just press 'A' to automatically find email
# addresses in it, and select one to add to your .mutt-aliases file.
##*************************************

ALIASFILE_ENV =		'MUTTALIASFILE'
#ALIASFILE =		'/path/to/aliases-file'

# Enable or disable debugging output
DEBUGOUTPUT = None			# Disables debugging output
#DEBUGOUTPUT = 1			# Enables debugging output


# Move prompt strings to variables here.  Easier to do localization or
# customization.
#
# For example, you can change the 'Yes' and 'No' prompts to German as follows:
#PROMPT_Y =				'Ja'
#PROMPT_N =				'Nein'

# English defaults:
PROMPT_Y =				'Yes'
PROMPT_N = 				'No'
TEXT_STARTING =			'Looking for mail addresses, this may take a while...'
TEXT_HELP =				'\nThe mutt aliases file was not specified.\n' \
						'Please specify it in one of the following ways:\n' \
						'  -supply it as the first argument to this script\n' \
						'  -specify it in the environment variable %s\n' \
						'  -specify it in the ALIASFILE variable at the\n' \
						'   beginning of this script\n\n'
PROMPT_NAME =			'*** Enter name manually ***'
PROMPT_WHICH_NAME =		'Use which name for address %s ?'
PROMPT_REAL_NAME =		'Enter real name for address %s :'
PROMPT_ALIAS =			'Enter alias name for "%s" <%s> :'
PROMPT_EMAIL =			'Choose address to alias:'
PROMPT_WRITE =			'Write %s ?'
PROMPT_MENU_HELP =		'Use up and down arrows + Return'
ERR_BAD_ALIAS_FILE =	'The aliases file specified ("%s") was not\n' \
						'found or could not be read.\nAborting ...\n'
ERR_NO_EMAIL_FOUND =	'Error:  no email addresses found'
ERR_PCURSES =			'Your pythoncurses module is old. Please upgrade to\n' \
						'1.4 or higher.\n' \
						'Alternative: Modify the script. Change all 6' \
						' occurences of curses.KEY_UP\n' \
						'and similiar to lowercase.'
ERR_STDIN_IS_TTY =		'Please use as a pipe!\nAborting...\n'


#
# imports
#
import re
import string, sys, os
import curses, traceback


#
# Data/defines
#
OK, ERROR = (0, -1)


#
# Functions and classes
#

#############################
def main ():
	'Main function for mail2muttalias.py'
	test_curses_ver ()
	aliasfile_name = get_aliasfile_name ()
	data = set_up_terminal ()

	### main program
	print TEXT_STARTING

	#get list, RE gets all Email addresses + prepending words
	inp_addresses = listrex (data, '"?[\s\w\ö\ä\ü\-\ß\_.]*"?\s*<?[\w.-]+\@[\w.-]+>?')

	if not inp_addresses:
		print ERR_NO_EMAIL_FOUND
		sys.exit (ERROR)

	DEBUG ('%i possible email addresses found.' % len (inp_addresses))

	current_addresses, current_names = analyze_aliasfile (aliasfile_name)

	address_dict, sorted_keys = analyze_input (inp_addresses, current_addresses)

	###menu
	ScreenObject = screenC ()						# initialize curses menu
	try:
		email_address = ScreenObject.menucall (sorted_keys, address_dict, PROMPT_EMAIL)
		if address_dict[email_address]:
			names_list = [PROMPT_NAME]		#add option to edit name
			names_list = names_list + address_dict[email_address]
			real_name = ScreenObject.menucall (names_list, {}, PROMPT_WHICH_NAME % email_address)
			# empty Dictionary {} means show list member itself, not looked up result
		else:
			real_name = ''
	except:
		T = ScreenObject.size ()
		ScreenObject.end ()
		DEBUG ('ScreenObject.size () == %s\nTraceback:\n%s' \
			   % (T, `traceback.print_exc ()`))
		sys.exit (ERROR)

	### enter new names/aliases
	if  real_name == PROMPT_NAME or real_name == '':
		real_name = ScreenObject.input (PROMPT_REAL_NAME % (email_address))
	selected_alias = ScreenObject.input (PROMPT_ALIAS % (real_name, email_address))

	if selected_alias in current_names:				#sort out existing aliasses
		ScreenObject.clearscreen ()
		ScreenObject.end ()
		sys.exit (ERROR)							# Already exists?
	if selected_alias == '':
		ScreenObject.clearscreen ()
		ScreenObject.end ()
		sys.exit (ERROR)							# no alias chosen?

	new_alias = 'alias %s "%s" <%s>\n' % (selected_alias, real_name, email_address)
	ScreenObject.clearscreen ()
	if ScreenObject.menucall ([PROMPT_Y, PROMPT_N], {}, PROMPT_WRITE % new_alias,
							  aliasfile_name) == PROMPT_N:
		ScreenObject.clearscreen ()
		ScreenObject.end ()
		sys.exit (OK)

	f = open (aliasfile_name, 'r')
	aliasfile_contents = f.readlines ()
	f.close ()

	aliasfile_contents.append (new_alias)			#append new alias
	aliasfile_contents.sort ()						#sort by alias

	# Write out the new alias file as a temporary file.
	tempfilename = '%s.%i.tmp' % (aliasfile_name, os.getpid ())
	try:
		f = open (tempfilename, 'w')
		f.writelines (aliasfile_contents)
		f.close ()
		DEBUG ('wrote temp file %s' % tempfilename)
	except:
		print 'Error writing %s -- aborting\n' % tempfilename
		sys.exit (ERROR)

	# Only if we succeeded, remove the old alias file and rename the temporary
	# file to the alias filename.	
	os.remove (aliasfile_name)
	os.rename (tempfilename, aliasfile_name)	
	DEBUG ('moved temp file to %s' % aliasfile_name)
	
	ScreenObject.clearscreen ()
	ScreenObject.end ()


#############################
def test_curses_ver ():
	try :
		testcurses = curses.KEY_UP
	except NameError:
		print ERR_PCURSES 
		sys.exit (ERROR)


#############################
def get_aliasfile_name ():
	global ALIASFILE, ALIASFILE_ENV
	try:
		filename = sys.argv[1]
		DEBUG ('alias file name from argument is %s' % filename)
		return filename
	except IndexError:	
		DEBUG ('No argument supplied for alias file name.')

	try:
		# if environment variable in ALIASFILE_ENV was set
		filename = os.environ[ALIASFILE_ENV]
		DEBUG ('alias file name from environment variable %s is %s' \
			   % (ALIASFILE_ENV, filename))
		return filename
	except KeyError:
		DEBUG ('Environment variable "%s" not defined' % ALIASFILE_ENV)

	try:
		# if ALIASFILE was configured in script
		filename = ALIASFILE
		DEBUG ('alias file name from ALIASFILE variable is %s' % filename)
		return filename
	except NameError:
		DEBUG ('ALIASFILE variable not defined')

	print TEXT_HELP % ALIASFILE_ENV
	sys.exit (ERROR)


#############################
def set_up_terminal ():
	###Thanks for the following go to Michael P. Reilly
	if not sys.stdin.isatty ():  # is it not attached to a terminal?
	  data = sys.stdin.read ()
	  sys.stdin = _dev_tty = open ('/dev/tty', 'w+')
	  # close the file descriptor for stdin thru the posix module
	  os.close (0)
	  # now we duplicate the opened _dev_tty file at file descriptor 0 (fd0)
	  # really, dup creates the duplicate at the lowest numbered, closed file
	  # descriptor, but since we just closed fd0, we know we will dup to fd0
	  os.dup (_dev_tty.fileno ())  # on UNIX, the fileno() method returns the
								 # file object's file descriptor
	else:  # is a terminal
		print ERR_STDIN_IS_TTY
		sys.exit (ERROR)
	# now standard input points to the terminal again, at the C level, not just
	# at the Python level.
	return data


#############################
def case_insensitive_sort (x, y):
	"Non-case-sensitive alphabetical sort."
	return cmp (string.lower (x), string.lower (y))


#############################
def analyze_aliasfile (aliasfile_name):
	"Looks at a mutt aliasfile, returns a list of aliasses and of mail adresses"
	try:
		f = open (aliasfile_name, 'r')
	except IOError:
		print ERR_BAD_ALIAS_FILE % aliasfile_name
		sys.exit (ERROR)
	Aliasline = ' '
	AL_Adlist = []
	AL_Namlist = []
	while Aliasline != '':
		Aliasline = f.readline ()
		Aliassplit = string.split (Aliasline)
		if len (Aliassplit) > 1 and Aliassplit[0] == 'alias':
			AL_Namlist.append (Aliassplit[1])
			for i in range (len (Aliassplit)):
				if '@' in Aliassplit[i]:
					Aliasadress = Aliassplit[i]
					AL_Adlist.append (Aliasadress)
	f.close ()
	return AL_Adlist, AL_Namlist


#############################
def analyze_input (addresses_in, cur_addresses):
	address_dict = {} 								# Dictionary created to avoid duplicates
	for i in range (len (addresses_in)):			# iterate over
		d = addresses_in[i]
		newaddress = getmailadressfromstring (d)
		if newaddress in cur_addresses:
			# remove already aliassed mail addresses
			continue
		name_end = -len (newaddress) 				#cut off mail address
		newaddress = string.replace (newaddress, '<', '')	#remove <>
		newaddress = string.replace (newaddress, '>', '')

		name = string.replace (stripempty (d[:name_end]), '"', '')		# leaves name
		if not address_dict.get (newaddress):		# if new Emailadress
			nameslist = []							# create list for names
			nameslist.append (name)					# append name
			address_dict[newaddress] = nameslist	# assign list to adress
		else :
			nameslist = address_dict[newaddress]	# otherwise get list
			nameslist.append (name)					# append name to list of names
			address_dict[newaddress] = nameslist	# and assign

	dict_keys = address_dict.keys ()				# iterate over dictionary, sort names
													# dict_keys are all the adresses
	for z in range (len (dict_keys)):
		namelist = address_dict[dict_keys[z]]		# Get list of possible names
		d = {} 										# sort out duplicates and
													# remove bad names + empty strings from adresses
		for x in namelist:
			if x in ['', '<']: continue
			d[x] = x
		namelist = d.values ()
		namelist.sort ()							# sort namelist alphabetically
		DEBUG ('%s %s had possible names:  %s' % (z, dict_keys[z], namelist))
		address_dict[dict_keys[z]] = namelist

	dict_keys.sort (case_insensitive_sort)			# Keys sort

	return address_dict, dict_keys


#############################
def listrex (str, rgx): # Return a list of all regexes matched in string
	"Search string for all occurences of regex and return a list of them."
	result = []
	start = 0 										# set counter to zero
	ende = len (str) 								# set end position
	suchadress = re.compile (rgx, re.LOCALE)		# compile regular expression, with LOCALE
	while 1:
		einzelerg = suchadress.search (str, start, ende) # create Match Object einzelerg
		if einzelerg == None:						# until none is found
			break
		result.append (string.strip (einzelerg.group ())) # add to result
		start = einzelerg.end ()
	return result


#############################
def strrex (str): # Return first occurence of regular exp  as string
	"Search string for first occurence of regular expression and return it"
	muster = re.compile (r"<?[\w\b.ßüöä-]+\@[\w.-]+>?", re.LOCALE)	# compile re
	matobj = muster.search (str)					# get Match Objekt from string
	if muster.search (str) == None:					# if none found
		return ''
	return matobj.group ()							# return string


#############################
def stripempty (str):#Looks for all empty charcters and replaces them with a space
	"Looks for all empty charcters and replaces them with a space,kills trailing"
	p = re.compile ( '\s+')							# shorten
	shrt = p.sub (' ', str)
	q = re.compile ('^\s+|\s+$')					# strip
	strp = q.sub ('', shrt)
	return strp


#############################
def getmailadressfromstring (str):
	"Takes str and gets the first word containing @ == mail adress"
	parts = string.split (str)
	for i in range (len (parts)):
		if '@' in parts[i]:
			return parts[i]
	return None


#############################
class screenC:
	"Class to create a simple to use menu using curses"
	def __init__ (self):
		import curses, traceback
		self.MAXSECT = 0
		self.lsect = 1
		# Initialize curses
		self.stdscr = curses.initscr ()
		# Turn off echoing of keys, and enter cbreak mode,
		# where no buffering is performed on keyboard input
		curses.noecho ()
		curses.cbreak ()

		# In keypad mode, escape sequences for special keys
		# (like the cursor keys) will be interpreted and
		# a special value like curses.KEY_LEFT will be returned
		self.stdscr.keypad (1)

	def title (self, TITLE = '', HELP = PROMPT_MENU_HELP):
		"Draws Title and Instructions"
		self.stdscr.addstr (0, 0, TITLE, curses.A_UNDERLINE)	# Title + Help
		self.stdscr.addstr (self.Y - 2, 0, HELP, curses.A_REVERSE)

	def refresh (self):
		self.stdscr.refresh ()

	def size (self):
		"Returns screen size and cursor position"
		self.Y, self.X = self.stdscr.getmaxyx ()
		self.y, self.x = self.stdscr.getyx ()
		return self.Y, self.X, self.y, self.x

	def showlist (self, list, lsect = 1):
		"Analyzes list, calculates screen, draws current part of list on screen."
		s = self.Y - 3								# space on screen
		self.MAXSECT = 1
		while len (list) > self.MAXSECT * s :		# how many times do we need the screen?
			self.MAXSECT = self.MAXSECT + 1

		if self.lsect > self.MAXSECT:				# check for end of list
			self.lsect = lsect - 1

		if self.lsect <= 0:
			self.lsect = 1

		if len (list) <= s:
			self.LISTPART = list

		else :
			self.LISTPART = list[s * (self.lsect - 1) : s * self.lsect]	# part of the List is shown

		self.stdscr.addstr (self.Y - 2,
							self.X - len ('%s%s' % (self.lsect, self.MAXSECT)) - 5,
							'(%s/%s)' % (self.lsect, self.MAXSECT))

		for i in range (1, self.Y -2):				# clear screen between title and help text
			self.stdscr.move (i, 0)
			self.stdscr.clrtoeol ()
		for i in range (0, len (self.LISTPART)):	# print out current part of list
			Item = self.LISTPART[i]
			self.stdscr.addstr (i + 1, 0, Item[:self.X])

	def getresult (self, HOEHE):
		"Get Result from cursor position"
		return self.LISTPART[(HOEHE -1)]

	def showresult (self, hoehe, dict = {}):
		'Look up result to show in dictionary if provided, return list' \
		'member otherwise.'
		if dict == {}:
			return self.getresult (hoehe)
		else :
			return string.join (dict[self.getresult (hoehe)], ' || ')

	def menucall (self, list, dict = {}, TITLE = '', HELP = PROMPT_MENU_HELP):
		'Takes a list and offers a menu where you can choose one item,' \
		'optionally, look up result in dictionary if provided.'
		REFY = 1
		self.__init__ ()
		self.size ()
		self.title (TITLE, HELP)
		self.showlist (list)
		self.refresh ()
		self.stdscr.move (1, 0)
		while 1:									# read Key events
			c = self.stdscr.getch ()
			self.size ()

			if c == curses.KEY_UP or c == ord ('k'): # up arrow or k
				if self.y > 1:
					self.stdscr.move (self.y - 1, self.x); REFY = 1
				else :
					self.lsect = self.lsect-1
					self.showlist (list, self.lsect)
					self.stdscr.move (len (self.LISTPART), 0)
					REFY = 1

			elif c == curses.KEY_DOWN or c == ord ('j'): # down arrow or j
				if self.y < len (self.LISTPART) :
					self.stdscr.move (self.y + 1, self.x); REFY = 1
				else :
					self.lsect = self.lsect + 1
					self.showlist (list, self.lsect)
					self.stdscr.move (1, 0)
					REFY = 1

			elif c == curses.KEY_PPAGE:
				self.lsect = self.lsect - 1
				self.showlist (list, self.lsect)
				self.stdscr.move (1, 0)
				REFY = 1

			elif c == curses.KEY_NPAGE:
				self.lsect = self.lsect + 1
				self.showlist (list, self.lsect)
				self.stdscr.move (1, 0)
				REFY = 1

			elif c == curses.KEY_END:
				self.lsect = self.MAXSECT
				self.showlist (list, self.lsect)
				self.stdscr.move (1, 0)
				REFY = 1

			elif c == curses.KEY_HOME:
				self.lsect = 1
				self.showlist (list, self.lsect)
				self.stdscr.move (1, 0)
				REFY = 1

			elif c == ord ('\n'): 						# \n (new line)
				ERG = self.getresult (self.y )
				self.end ()
				return ERG

			elif c == ord ('q') or c == ord ('Q'): 		# "q or Q"
				self.clearscreen ()
				self.end ()
				sys.exit (OK)
				return 0

			if REFY == 1:
				REFY = 0
				self.size ()
				self.stdscr.move (self.Y - 1, 0)
				self.stdscr.clrtoeol ()
				self.stdscr.addstr (self.Y - 1, 0,
									self.showresult (self.y, dict)[:self.X - 1],
									curses.A_BOLD)
				self.stdscr.move (self.y, self.x)
				self.refresh ()

	def end (self):
		"Return terminal"
		# In the event of an error, restore the terminal to a sane state.
		self.Y, self.X, self.y, self.x = 0, 0, 0, 0
		self.LISTPART = []
		self.stdscr.keypad (0)
		curses.echo ()
		curses.nocbreak ()
		curses.endwin ()
		DEBUG ('Traceback:\n%s' % `traceback.print_exc ()`)

	def input (self, promptstr):
		"raw_input equivalent in curses, asks for  Input and returns it"
		self.size ()
		curses.echo ()
		self.stdscr.move (0, 0)
		self.stdscr.clear ()
		self.stdscr.addstr (promptstr)
		self.refresh ()
		INPUT = self.stdscr.getstr ()
		curses.noecho ()
		return INPUT


	def printoutnwait (self, promptstr):
		"Print out Text, wait for key"
		curses.noecho ()
		self.stdscr.move (0, 0)
		self.stdscr.clear ()

	def clearscreen (self):
		"Clear screen"
		curses.noecho ()
		self.stdscr.move (0, 0)
		self.stdscr.clear ()


#############################
def DEBUG (text):
	if DEBUGOUTPUT:
		me = os.path.split (sys.argv[0])[-1]
		print '%s:  %s\n' % (me, text)


#############################
if __name__ == '__main__':
	main ()
	sys.exit (OK)
