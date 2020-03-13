##############################################################################
#
# 	Copyright (c) GeoWorks 1992 -- All Rights Reserved
#
# PROJECT:	PC GEOS
# MODULE:	goc -- Makefile
# FILE: 	Makefile
# AUTHOR: 	Mathias Winkler, Mon Nov 28 12:14:15 CET 2005
#
# TARGETS:
# 	Name			Description
#	----			-----------
#	all			create the tool for all possible architectures
#	install			create and install for all architectures
#	depend			generate dependencies for all architectures
#	sparc                   create tool for sparc 
#	installsparc            create and install tool for sparc 
#	dependsparc             generate dependencies for sparc 
#
# DESCRIPTION:
#	This makefile was automatically generated from:
#	    /staff/pcgeos/Tools/mkmf/Makefile.tool
#
#	DO NOT EDIT IT, AS YOU MAY LOSE YOUR CHANGES WHEN IT IS REGENERATED
#
#	$Id: Makefile.tool,v 1.5 96/09/05 15:58:56 jacob Exp $
#
###############################################################################


#include	<geos.mk>
#include	<gpath.mk>

MACHINES	= linux sparc win32
MAKEFILE	= Makefile
NAME		= goc
SYSMAKEFILE	= tool.mk
TYPE		= tool

#if	defined(sun) && defined(sparc)
DEFTARGET	= sparc
#elif	defined(linux)
DEFTARGET	= linux
#elif	defined(sun)
DEFTARGET	= sun3
#elif   defined(isi)
DEFTARGET	= isi
#else
DEFTARGET	= win32
#endif

MISRCS          = buf.c buf.h cond.c cond.h depends.c depends.h goc.c goc.h\
                  japan.h map.c map.h output.c parse.c parse.h parse.y\
                  scan.c scan.h semantic.c sprite.h stringt.c stringt.h\
                  strwid.c strwid.h symbol.c symbol.h

sparcSRCS       = $(MISRCS) sparc.md/
sparcOBJS       = sparc.md/buf.o sparc.md/cond.o sparc.md/depends.o\
                  sparc.md/goc.o sparc.md/map.o sparc.md/output.o\
                  sparc.md/parse.o sparc.md/scan.o sparc.md/semantic.o\
                  sparc.md/stringt.o sparc.md/strwid.o sparc.md/symbol.o
sparcLIBS       =

linuxSRCS       = $(MISRCS) linux.md/
linuxOBJS       = linux.md/buf.o linux.md/cond.o linux.md/depends.o\
                  linux.md/goc.o linux.md/map.o linux.md/output.o\
                  linux.md/parse.o linux.md/scan.o linux.md/semantic.o\
                  linux.md/stringt.o linux.md/strwid.o linux.md/symbol.o
linuxLIBS       =

win32SRCS       = $(MISRCS) win32.md/
win32OBJS       = win32.md/buf.o win32.md/cond.o win32.md/depends.o\
                  win32.md/goc.o win32.md/map.o win32.md/output.o\
                  win32.md/parse.o win32.md/scan.o win32.md/semantic.o\
                  win32.md/stringt.o win32.md/strwid.o win32.md/symbol.o
win32LIBS       =

SUBDIRS         = dos linux

#if exists(local.mk)
#include	"local.mk"
#else
#include	<$(SYSMAKEFILE)>
#endif

#if	exists(sparc.md/dependencies.mk)
#include	"sparc.md/dependencies.mk"
#endif


# Allow mkmf
