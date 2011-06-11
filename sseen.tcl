#  ----------------------------------------------------------
#  
#   SSeen v 0.2.21
#   Author: samu (IRC: samu@pirc.pl)
#
#  ----------------------------------------------------------
#
#  This is a very, very simple !seen script, which will not
#  only tell you where did the bot last seen specified nick,
#  but also where.
#
#  TODO: A simple tracking of nick changes.
#
#  ----------------------------------------------------------
#  Config section
#  ----------------------------------------------------------

set dateformat {%Y/%m/%d %H:%M:%S}	# Specify the date
					# format.

#  ----------------------------------------------------------
#
#  Then just do .chanset #channel +sseen, which will set both
#  on which channel will he log users activity, but also on
#  which will users be able to use the !seen command.
#
#  ----------------------------------------------------------

bind pubm - * public_msg_save
bind sign - * public_msg_save
bind pub - !seen pub_show_seen

set ver "0.2.21"


setudef flag sseen

proc _showcurtime { } {
	global dateformat
	set _curtime [clock seconds]
	set _curtime [clock format $_curtime -format $dateformat]
	set _curtime [string map {"\n" ""} $_curtime]
	return "$_curtime"
}

proc public_msg_save {nick userhost handle channel text} {
	global lastseen
	global lastchan
	if {[channel get $channel sseen]} {
		set lastseen($nick) [_showcurtime]
		set lastchan($nick) $channel
	}
}

proc pub_show_seen {nick userhost handle channel text} {
	global lastseen
	global lastchan
	if {[channel get $channel sseen]} {
		set text [lindex $text 0]
		if {$text == $nick} {
			putquick "PRIVMSG $channel :Why don't you try drinking less? I've heard memory is much better then..."
			return 0;
		} else {
			if {[info exists lastseen($text)]} {
				putserv "PRIVMSG $channel :I've seen $text at $lastseen($text) on $lastchan($text)."
			} else {
				putserv "PRIVMSG $channel :I haven't seen $text here yet."
			}
		}
	}
}

putlog "SSeen $ver by samu (www.samaelszafran.pl) loaded!"
