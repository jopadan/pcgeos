
#include <geos.mk>
#include <gpath.mk>

MACHINES = sparc linux win32
MAKEFILE = Makefile
NAME = utils
SYSMAKEFILE = tool.mk
TYPE = library

#if defined(sun) && defined(sparc)
DEFTARGET=sparc
#elif defined(linux)
DEFTARGET=linux
#elif defined(sun)
DEFTARGET=sun3
#elif defined(isi)
DEFTARGET=isi
#else
DEFTARGET=win32
#endif

MISRSC = fileargs.c fileUtil.c geode.c hash.c localize.c malErr.c malloc.c memAl.c\
         memAlLkd.c memFree.c memInfo.c memLock.c memRAl.c memRAlLk.c memUtils.c\
	 objSwap.c printf.c stClose.c stCreate.c stDest.c stDup.c stEnt.c stEntNL.c\
         stHash.c stIndex.c stLook.c stLookNL.c stReloc.c stSearch.c sttab.c vmAl.c\
         vmAlRd.c vmAlUnas.c vmAttach.c vmAttr.c vmClose.c vmDetach.c vmDirty.c vmEmpty.c\
         vmFAl.c vmFFree.c vmFind.c vmFree.c vmGVers.c vmHeader.c vmInfo.c vmLock.c vmMapBlk.c\
	 vmModUID.c vmOpen.c vmSetRel.c vmUpdate.c

sparcSRCS = $(MISRCS) sparc.md/
sparcOBJS = sparc.md/fileargs.o sparc.md/fileUtil.o sparc.md/geode.o sparc.md/hash.o sparc.md/localize.o\
            sparc.md/memAlLkd.o sparc.md/memFree.o sparc.md/memInfo.o sparc.md/memLock.o sparc.md/memRAl.o\
	    sparc.md/memRAlLk.o sparc.md/memUtils.o sparc.md/objSwap.o sparc.md/printf.o sparc.md/stClose.o\
	    sparc.md/stCreate.o sparc.md/stDest.o sparc.md/stDup.o sparc.md/stEnt.o sparc.md/stEntNL.o\
	    sparc.md/stHash.o sparc.md/stIndex.o sparc.md/stLook.o sparc.md/stLookNL.o sparc.md/stReloc.o\
	    sparc.md/stSearch.o sparc.md/sttab.o sparc.md/vmAl.o sparc.md/vmAlRd.o sparc.md/vmFFree.o\
	    sparc.md/vmFind.o sparc.md/vmFree.o sparc.md/vmGVers.o sparc.md/vmHeader.o sparc.md/vmInfo.o\
	    sparc.md/vmLock.o sparc.md/vmMapBlk.o sparc.md/vmModUID.o sparc.md/vmOpen.o sparc.vm/vmSetRel.o\
	    sparc.md/vmUpdate.o

sparcLIBS =

linuxSRCS = $(MISRCS) linux.md/
linuxOBJS = linux.md/fileargs.o linux.md/fileUtil.o linux.md/geode.o linux.md/hash.o linux.md/localize.o\
            linux.md/memAlLkd.o linux.md/memFree.o linux.md/memInfo.o linux.md/memLock.o linux.md/memRAl.o\
	    linux.md/memRAlLk.o linux.md/memUtils.o linux.md/objSwap.o linux.md/printf.o linux.md/stClose.o\
	    linux.md/stCreate.o linux.md/stDest.o linux.md/stDup.o linux.md/stEnt.o linux.md/stEntNL.o\
	    linux.md/stHash.o linux.md/stIndex.o linux.md/stLook.o linux.md/stLookNL.o linux.md/stReloc.o\
	    linux.md/stSearch.o linux.md/sttab.o linux.md/vmAl.o linux.md/vmAlRd.o linux.md/vmFFree.o\
	    linux.md/vmFind.o linux.md/vmFree.o linux.md/vmGVers.o linux.md/vmHeader.o linux.md/vmInfo.o\
	    linux.md/vmLock.o linux.md/vmMapBlk.o linux.md/vmModUID.o linux.md/vmOpen.o linux.md/vmSetRel.o\
	    linux.md/vmUpdate.o

linuxLIBS =


SUBDIRS =
#if  exists(local.mk)
#include  "local.mk"
#else
#include <$(SYSMAKEFILE)>
#endif

#if exists(sparc.md/dependencies.mk)
#include  "sparc.md/dependencies.mk"
#endif

#if exists(linux.md/dependencies.mk)
#include "linux.md/dependencies.mk"
#endif

#if exists(win32.md/dependencies.mk)
#include "win32.md/dependencies.mk"
#endif


