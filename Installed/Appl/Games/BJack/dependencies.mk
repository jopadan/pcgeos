bjack.rdef: generic.uih product.uih cards.uih game.uih Art/mkbjack.ui
bjack.obj \
bjack.eobj: geos.def geode.def ec.def myMacros.def library.def \
                resource.def object.def lmem.def graphics.def fontID.def \
                font.def color.def gstring.def text.def char.def \
                Objects/winC.def win.def Objects/metaC.def chunkarr.def \
                geoworks.def heap.def timer.def timedate.def system.def \
                localize.def sllang.def file.def fileEnum.def vm.def \
                hugearr.def Objects/inputC.def initfile.def dbase.def \
                ui.def input.def hwr.def Objects/processC.def gcnlist.def \
                Objects/Text/tCommon.def stylesh.def iacp.def \
                Objects/uiInputC.def Objects/visC.def Objects/vCompC.def \
                Objects/vCntC.def Internal/vUtils.def Objects/genC.def \
                disk.def drive.def uDialog.def Objects/gInterC.def \
                token.def Objects/clipbrd.def Objects/gSysC.def \
                Objects/gProcC.def alb.def Objects/gFieldC.def \
                Objects/gScreenC.def Objects/gFSelC.def \
                Objects/gViewC.def Objects/gContC.def Objects/gCtrlC.def \
                Objects/gDocC.def Objects/gDocCtrl.def \
                Objects/gDocGrpC.def Objects/gEditCC.def \
                Objects/gViewCC.def Objects/gToolCC.def \
                Objects/gPageCC.def Objects/gPenICC.def \
                Objects/gGlyphC.def Objects/gTrigC.def \
                Objects/gBoolGC.def Objects/gItemGC.def \
                Objects/gDListC.def Objects/gItemC.def Objects/gBoolC.def \
                Objects/gDispC.def Objects/gDCtrlC.def Objects/gPrimC.def \
                Objects/gAppC.def Objects/gTextC.def Objects/gGadgetC.def \
                Objects/gValueC.def Objects/gToolGC.def \
                Internal/gUtils.def Objects/helpCC.def Objects/eMenuC.def \
                Objects/emomC.def Objects/emTrigC.def Internal/uProcC.def \
                game.def cards.def sound.def driver.def \
                Internal/soundFmt.def Internal/semInt.def \
                Objects/vTextC.def spool.def print.def \
                Internal/prodFeatures.def wav.def bjackGame.asm \
                bjackSound.asm sizes.def bjack.rdef

bjackEC.geo bjack.geo : geos.ldf ui.ldf game.ldf sound.ldf wav.ldf cards.ldf 