#!/bin/bash
# From http://kumarcode.com/Colorful-i3/

. /home/nick/Sources/dotfiles-private/zshrc

COUNT=`curl -su $GMAIL_USERNAME:$GMAIL_PASSWORD https://mail.google.com/mail/feed/atom || echo "<fullcount>unknown number of</fullcount>"`
COUNT=`echo "$COUNT" | grep -oPm1 "(?<=<fullcount>)[^<]+" `
echo $COUNT
if [ "$COUNT" != "0" ]; then
   if [ "$COUNT" = "1" ];then
      WORD="mail";
   else
      WORD="mails";
   fi
fi
