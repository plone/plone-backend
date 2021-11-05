#!/usr/bin/env bash
globalTests+=(
        utc
        no-hard-coded-passwords
        override-cmd
)

imageTests+=(
	[plone/plone-backend]='
		plone-basics
		plone-addons
		plone-zeoclient
	'
)

globalExcludeTests+=(
	
)
