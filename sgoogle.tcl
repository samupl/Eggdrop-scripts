#  ----------------------------------------------------------
#  
#   SGoogle v 0.9.9.7
#   Author: samu (IRC: samu@pirc.pl)
#
#  ----------------------------------------------------------
#
#   This is a simple and working script, which queries google 
#   When triggered in public.
#
#   There aren't many config options. All you can set is a
#   list of triggers below. 
#
#   You will need both http and htmlparse TCL packages. Both
#   can be found in TCLLIB. If you haven't got htmlparse, you
#   can try deleting 'package require htmlparse' and both
#   set * [htmlparse::mapEscapes *] lines in the code, but
#   then you'll get pure html entities printed by your bot.
#
#   The channel on which the google trigger will work must
#   have a 'sgoogle' flag. You can set it by doing:
#   .chanset #yourchannel +sgoogle
#   in the partyline.
#
#   This version has a new regexp for the new google html.
#   However, it's code has been changing for the last two
#   weeks every three-four days. I don't guarantee that
#   this regexp will be useful in a few weeks. I hope that
#   google won't change it's html code. If it does, please
#   contact me, I'll do a patch.
#
#   I also added timeout handling for the google search, so
#   the bot won't hang up if the http connections takes too
#   long.
#
#   I hope you'll enjoy it. If there's anything wrong in the
#   script, please contact me.
#
#                                                  ~samu
#  ----------------------------------------------------------

package require http
package require htmlparse



#  ----------------------------------------------------------
#
#  Trigger list
#
#  ----------------------------------------------------------

bind pub - !g pub:google
bind pub - !google pub:google

#  ----------------------------------------------------------
#
#  The actual code
#
#  ----------------------------------------------------------

set ver "0.9.9.6.2"
set agent "Mozilla"
setudef flag sgoogle

proc pub:google { nick uhost handle channel arg } {
    global agent
    global debug
    set agent "Mozilla"
    if {![channel get $channel sgoogle]} {
        putlog "Flag is not enabled for $channel"
    } else {
    	if {[llength $arg]==0} {
    		putquick "PRIVMSG $channel :\002\[GOOGLE\]\002 Nieprawidlowe kryteria wyszukwiania!"
	    } else {
		    putquick "NOTICE $nick :\002\[GOOGLE\]\002 szukam -> $arg"
		    set arg [http::formatQuery $arg]
		    set query "http://www.google.pl/search?q=$arg"
	            set token [http::config -useragent $agent]
		    set title [http::data [set token [http::geturl $query -timeout 2000]]]
		    set title [string map {"\n" "" "\t" ""} $title]
                    set result [string map {"<b>" "\002\037" "</b>" "\037\002" "<b>...</b>" "" "<em>" "\002\037" "</em>" "\037\002"} $title]
		    #regexp -nocase {class=l[^>]*?>(.*?)</a><table} $title -> title2
		    #regexp -nocase {<a href="([^"]+)" class=l[^>]*>}  $title -> newurl
                    #regexp -nocase {<a class="l" href="(.*?)"} $title -> newurl
                    #set reg "\\(this, '$newurl'\\)\">(.*?)</a>";
                    #regexp -nocase $reg $title -> title2
                    regexp -nocase {<a href="([^"]+)" class=l onmousedown=[^>]+>([^<]+)<} $result -> newurl title2

		    #if { [info exists title2] } {
		        #set title2 [string map {"<em>" "\002\037" "</em>" "\037\002" "<b>...</b>" ""} $title2]
	    	    #}

		    if { [info exists newurl] } {
		        if { [string match "/interstitial?url=*" $newurl] } {
			        set newurl "This site is blocked by google."
    		    }
		    }
			
    	    if { [info exists title2] && [info exists newurl] } {
        		set title2 [htmlparse::mapEscapes $title2]
            	set newurl [htmlparse::mapEscapes $newurl]
		    	putquick "PRIVMSG $channel :\002\[GOOGLE\]\002 $title2 -> $newurl"
		    } else {
		    	putquick "PRIVMSG $channel :\002\[GOOGLE\]\002 No results"
		    }
	    }
    }
}

putlog "Google $ver by samu (s.samu.pl) loaded!"
