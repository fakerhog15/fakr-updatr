#!/bin/bash

# list_news.sh: Display the latest news
# https://github.com/fakerhog15/fakr-updatr
# SPDX-License-Identifier: GPL-3.0-or-later

# No news feed is configured for this distribution yet.
# When sourced during the full upgrade flow, just inform and continue the update.
echo
info_msg "$(eval_gettext "No news feed configured for this distribution, skipping news check")"
return 0 2> /dev/null || exit 0
