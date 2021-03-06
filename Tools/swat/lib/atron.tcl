##############################################################################
#
# 	Copyright (c) Berkeley Softworks 1989 -- All Rights Reserved
#
# PROJECT:	PC GEOS
# MODULE:	Swat System Library
# FILE: 	atron.tcl
# AUTHOR: 	Adam de Boor, Dec 19, 1989
#
# COMMANDS:
# 	Name			Description
#	----			-----------
#   	ptrace	    	    	Print the contents of the trace buffer.
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/19/89	Initial Revision
#
# DESCRIPTION:
#	Support code for use with the atron-specific Swat stub.
#
#	NOTE: THIS FILE CONTAINS INFORMATION THAT IS PROPRIETARY TO
#	CADRE, INC., AND HAS BEEN PROVIDED UNDER A NON-DISCLOSURE
#	AGREEMENT. IF YOU HAVE NOT SIGNED THIS AGREEMENT, DO NOT LOOK
#	AT THIS FILE.
#
#	$Id: atron.tcl,v 3.1 90/02/17 22:24:47 adam Exp $
#
###############################################################################

defvar atron_initialized 0

#
# A table for the trace records we are sent from the PC. The table will be keyed
# by record number.
#
defvar atron_trace nil
#
# Number to assign to next received trace record
#
defvar atron_next_record 0
#
# Number of records expected
#
defvar atron_num_records 0
#
# Server token for RPC_TRACE_NEXT call transmitted by the stub
#
defvar atron_server nil
defvar atron_record nil

#
# Initialize state on first load-in
#
global atron_initialized
if {! $atron_initialized} {
    var atron_record [type make pstruct
    	    	    	atr_addrLow 	[type word]
			atr_data    	[type word]
			atr_bus	    	[type byte]
			atr_misc    	[type byte]
			atr_addrHigh	[type byte]
			atr_pad	    	[type byte]]
    gc register $atron_record
    var atron_server [rpc serve 113 [type make array 
    	    	    	    	    	[expr (256-4)/[type size $atron_record]]
					$atron_record]
    	    	    	    	    [type byte]
				    atron-trace-next]
    event handle CONTINUE atron-nuke-records
    event handle DETACH atron-nuke-records
    var atron_initialized 1
}

##############################################################################
#				atron-nuke-records
##############################################################################
#
# SYNOPSIS:	Clear out any trace buffer state cached while the machine
#   	    	has been stopped.
# CALLED BY:	EVENT_CONTINUE, EVENT_DETACH
# RETURN:	EVENT_HANDLED
# SIDE EFFECTS:	atron_trace is set to nil after deleting its table
#   	    	atron_next_record is set to 0
#
# STRATEGY: 	None
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/20/89	Initial Revision
#
##############################################################################
[defsubr atron-nuke-records {args}
{
    global atron_trace
    
    if {![null $atron_trace]} {
    	table destroy $atron_trace
    }
    var atron_trace nil

    return EVENT_HANDLED
}]

##############################################################################
#                               atron-decode-cycle
##############################################################################
#
# SYNOPSIS:     Decode a trace record from the PC into a manageable form
# CALLED BY:    atron-trace-next
# RETURN:       A list of the form: {type addr size data options}
#               type is one of:
#                       rio         read from I/O space
#                       wio         write to I/O space
#                       ifetch      instruction fetch
#                       rmem        read from memory
#                       wmem        write to memory
#                       none        none of the above (CPU passive)
#                       refresh     memory refresh
#               these two would be used except we've been told that the S0 and
#               S1 signals aren't reliable on all AT's (some manufacturers
#               don't provide the signals to the coprocessor b/c Intel has said
#               they aren't required):
#                       inta        interrupt acknowledge
#                       halt        shutdown
#              
#               "addr" is the 24-bit address involved in the cycle, in decimal.
#               "size" is 1 or 2, indicating the size of the data involved.
#               "data" is the data involved in the cycle, right justified. e.g.
#               if reading the byte 3 from an odd address, the value here will
#               be 3 even though the 3 is actually transfered on the high 8
#               data bits of the bus.
#              
#               options is a list that can contain any of the following:
#                       dma         cycle is caused by DMA
#                       coproc      cycle is on behalf of the coprocessor
#                       other       cycle is caused by some other bus master
#                                   besides DMA
#
# SIDE EFFECTS: None
#
# STRATEGY
#       The cycle is passed as a value list structured into an AtronTraceRecord,
#       as stored in the $atron_record defined above.
#       The two fields that determine the type of bus cycle are the atr_bus and
#       atr_misc fields, which contain the following bits:
#                       atr_bus             atr_misc
#               b0      AEN                 S0
#               b1      -MASTER             -COD/INTA
#               b2      IOR                 S1
#               b3      MRD                 PEACK
#               b4      MWT                 RUN
#               b5      IOW                 HW BP
#               b6      REFRESH             MISC BP
#               b7      BHE                 -IOCHCHK                
#
#       AEN is asserted if the bus is being controlled by the DMA controller.
#       -MASTER is asserted (low) if the bus is being controlled by some other
#           bus controller than the CPU
#       IOR is asserted (high) if the cycle is a read from I/O space
#       MRD is asserted (high) if the cycle is a read from memory. -COD/INTA
#           is also asserted (low) if the cycle is an instruction fetch.
#       MWT is asserted (high) if the cycle is a write to memory
#       IOW is asserted (high) if the cycle is a write to I/O space
#       REFRESH is asserted if the cycle is to refresh dynamic memory. This
#           implies that none of the other bus-control signals are to be
#           trusted as the bus is being used only to strobe the proper row
#           in the RAMs
#       BHE is asserted (high) if the high half of the data bus is active/valid
#       S0 and S1 are status lines from the CPU. They are not valid on all
#           clones, so we ignore them
#       -COD/INTA is a status line from the CPU that indicates, with MRD, if the
#           cycle is an instruction fetch.
#       PEACK is asserted (high) if the cycle is on behalf of a coprocessor.
#       RUN is asserted (high) whenever hardware breakpoints and the trace
#           buffer are active.
#       HW BP, MISC BP are supposed to be unreliable...
#       -IOCHCHK is asserted (low) whenever the IO Channel Check line is
#           active (an NMI will be taken in a moment :)
#
#       Other bits of strategy are detailed in the in-line comment blocks...
#
# REVISION HISTORY:
#       Name    Date            Description
#       ----    ----            -----------
#       ardeb   12/20/89        Initial Revision
#
##############################################################################
[defsubr atron-decode-cycle {cycle}
{
    var bus [field $cycle atr_bus] misc [field $cycle atr_misc]

#echo [map i $cycle {format %02x [index $i 2]}]

    #
    # Determine cycle type. The bits in the result of the expr are:
    #	type	| IOW | MW | MR | IOR | COD
    #   -----------------------------------
    #	rio 	|  0  |  0 |  0 |  1  |  0
    #	wio 	|  1  |  0 |  0 |  0  |  0
    #	ifetch	|  0  |  0 |  1 |  0  |  0
    #	rmem	|  0  |  0 |  1 |  0  |  1
    #	wmem	|  0  |  1 |  0 |  0  |  1
    var addr [expr [field $cycle atr_addrLow]|([field $cycle atr_addrHigh]<<16)]
    if {$bus & 0x40} {
    	var type refresh data 0 size 1
    } else {
	[case [expr (($bus&0x3c)|($misc&2))>>1] in
	    2   {var type rio}
	    16  {var type wio}
	    4   {var type ifetch}
	    5   {var type rmem}
	    9   {var type wmem}
	    default {var type none}]
	#
	# Determine the data size and value. The signals BHE and A0 are used to
	# determine things (BHE stands for Bus High Enable and, when 1, says
	# the high half of the data bus contains valid data):
	#	BHE 	A0
	#	 1  	0   	word-sized operation
	#	 1  	1   	byte-sized operation on high half of the bus
	#	 0  	0   	byte-sized operation on low half of the bus
	#	 0  	1   	"can't happen"
	#
	[case [expr ($addr&1)|$bus>>6] in
	    2 {var data [field $cycle atr_data] size 2}
	    3 {var data [expr ([field $cycle atr_data]>>8)&0xff] size 1}
	    0 {var data [expr [field $cycle atr_data]&0xff] size 1}
	    1 {error {BHE/A0 is 1 in atron-decode-cycle}}]
    }

    #
    # Handle options:
    #	atr_bus bit 1 is the MASTER (inverted active-low) signal
    #	atr_bus bit 0 is the AEN ([inverted?] active high) signal
    #	atr_misc bit 3 is the PEACK (inverted active-low) signal
    #
    var options {}
    if {!($bus&0x02)} 	{var options [concat other $options]}
    if {$bus&0x01}  	{var options [concat dma $options]}
    if {!($misc&0x80)} 	{var options [concat coproc $options]}
    
    if {![null $options] && [string c $type ifetch] == 0} {
    	# COD signal seems to persist and can lead us to think a memory
	# read by DMA or another bus master is an instruction fetch...
	var type rmem
    }
    return [list $type $addr $size $data $options]
}]

##############################################################################
#				atron-trace-next
##############################################################################
#
# SYNOPSIS:	RPC server procedure to receive trace records sent by the stub
# CALLED BY:	RPC 113 (RPC_TRACE_NEXT)
# RETURN:	0 if no more records are desired, 1 if they are.
# SIDE EFFECTS:	The passed records are decoded and placed into the trace
#   	    	record table under successive numbers, incrementing 
#   	    	atron_next_record.
#
# STRATEGY:
#   	The records are passed to us in $args as a value list made of structures
#   	described by $atron_record. We pass each one in turn to
#   	atron-decode-cycle and store the results in the table pointed to by
#   	$atron_trace.
#
#   	We return 0 to the PC if either we've reached the limit the user set
#   	or an interrupt is pending.
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/20/89	Initial Revision
#
##############################################################################
[defsubr atron-trace-next {len args data}
{
    global atron_num_records atron_next_record atron_trace

    #
    # If tracing was interrupted already, tell the PC to shut up.
    #
    if {[null $atron_trace]} {
    	return 0
    }
    #
    # Enter each record into the table under successive numbers after decoding
    # it into something the other routines here can handle.
    #
    foreach i $args {
    	var cycle [atron-decode-cycle $i]
    	table enter $atron_trace $atron_next_record $cycle
#echo cycle $atron_next_record $cycle
	var atron_next_record [expr $atron_next_record+1]
    }
    
    global msgwin
    if {![null $msgwin]} {
    	protect {
    	    wpush $msgwin
	    wclear
	    echo [format {Trace Record: %4d} $atron_next_record]
	    wrefresh
	} {
	    wpop
	}
    }
    #
    # If interrupt requested or reached the max number of records the user
    # wants to see, tell the PC to stop sending records, else let it continue.
    #
    if {[irq] || $atron_next_record >= $atron_num_records} {
    	return 0
    } else {
    	return 1
    }
}]

##############################################################################
#				atron-fetch-record
##############################################################################
#
# SYNOPSIS:	Fetch the indicated record from the trace buffer, waiting for
#   	    	it to arrive if it's not yet present. Records are numbered from
#   	    	0 to $atron_num_records
# CALLED BY:	atron-find-start, ptrace
# RETURN:	the decoded record, if found, or nil if it couldn't be
#   	    	gotten.
# SIDE EFFECTS:	None
#
# STRATEGY:
#   	Look for the record in the table. While it's not there and no
#   	interrupt has been requested, call "rpc wait" to field any rpc call
#   	that might be providing the record for us.
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/20/89	Initial Revision
#
##############################################################################
[defsubr atron-fetch-record {num}
{
    global atron_trace atron_num_records
    
    if {$num <= $atron_num_records} {
    	#
	# While record not in table and not interrupted, wait for an RPC or
	# something else interesting to come in.
	#
    	[for {var record [table lookup $atron_trace $num]}
	     {[null $record] && ![irq]}
	     {var record [table lookup $atron_trace $num]}
	{
	    rpc wait
	}]
    }
    
    #
    # Return whatever we've got. This will be {} if number out-of-range or
    # we got interrupted before the record arrived.
    #
    return $record
}]
    
##############################################################################
#				atron-find-start
##############################################################################
#
# SYNOPSIS:	Locate the start of an instruction stream at which we know
#   	    	a valid instruction to be.
# CALLED BY:	ptrace
# RETURN:	the record number of a prefetch cycle that begins a valid
#   	    	instruction. nil if no such cycle can be found
# SIDE EFFECTS:	none
#
# STRATEGY
#   	A valid instruction is located by looking for discontinuities in
#   	the addresses of successive prefetch cycles. Such discontinuities
#   	indicate a change in the flow of control and, since the address
#   	after the discontinuity must be the destination of the flow change,
#   	it must be the address of a valid instruction.
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/20/89	Initial Revision
#
##############################################################################
[defsubr atron-find-start {cur}
{
    global  atron_num_records

    #
    # Locate the first prefetch cycle
    #
#echo -n looking for initial prefetch cycle...
    [for {var cycle [atron-fetch-record $cur]}
    	 {![null $cycle] && [string c [index $cycle 0] ifetch]}
	 {var cycle [atron-fetch-record $cur]}
     {
    	#echo -n $cur is [index $cycle 0]...
     	var cur [expr $cur+1]
	if {$cur == $atron_num_records} {
    	    #
	    # No instruction-fetch cycles, so return nil
    	    #
    	    #echo none found
	    return nil
    	}
    }]

    if {[null $cycle]} {
    	return nil
    }
    #echo $cur is ifetch
    #
    # Record first instruction-fetch cycle in this stream...
    #
    var paddr [index $cycle 1] cur [expr $cur+1] prev $cur
    
    #
    # Continue backwards in the buffer until we find a discontinuity in
    # the prefetch addresses. This implies that the previous cycle must
    # have had the address of a valid instruction. Note: this may have
    # problems with something like "jmp $+2" where bytes will have been
    # prefetched, discarded, and prefetched again. maybe.
    #
#echo -n looking for discontinuity...
    [for {
    	    var cycle [atron-fetch-record $cur]
    	    var caddr [index $cycle 1]
	 }
    	 {![null $cycle] &&
	  ([string c [index $cycle 0] ifetch] ||
	   $caddr == $paddr-[index $cycle 2])}
	 {
	    var cycle [atron-fetch-record $cur]
	    var caddr [index $cycle 1]
	 }
    {
    	if {[string c [index $cycle 0] ifetch] == 0} {
    	    # Instruction-fetch cycle -- record it as the new "prev"
	    var prev $cur paddr $caddr
    	    #echo -n paddr is $caddr from $cur...
	} else {
	    #echo -n $cur is [index $cycle 0]...
    	}
    	#
	# Advance to previous cycle
	#
    	var cur [expr $cur+1]
	if {$cur == $atron_num_records} {
    	    # Didn't find discontinuity before running out of records. We
	    # think it difficult to come up with a valid instruction so we
	    # discard the prefetch cycles over which we've skipped. In the
	    # future, with line number info, it might be possible to determine
	    # instructions, but not now.
	    return nil
	}
    }]
    
    if {[null $cycle]} {
    	return nil
    } else {
    	return $prev
    }
}]
    
##############################################################################
#				atron-find-addr
##############################################################################
#
# SYNOPSIS:	Decode an absolute 24-bit address into a symbolic one
# CALLED BY:	atron-format-cycle, ptrace
# RETURN:	the symbolic address, if possible, else segment:offset, if
#   	    	address in a block, else an absolute hexadecimal number
# SIDE EFFECTS:	none
#
# STRATEGY
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/21/89	Initial Revision
#
##############################################################################
[defsubr atron-find-addr {abs {full full} {type {var func label}}}
{
    #
    # First convert to a segment:offset form so addr-parse et al bother to
    # look for a handle for the thing.
    #
    var addr [expr ($abs>>4)&0xffff]:[expr $abs&0xf]
    #
    # Now find the actual handle and offset of it and look for the closest
    # symbol of any sort to the address
    #
    var a [addr-parse $addr] s [sym faddr $type $addr]
    if {![null $s]} {
    	#
	# Got a symbol for it -- figure out what its offset is. 
	#
    	var offset [sym addr $s]
	#
	# Assume exact match and set address to return to be the name of
	# the symbol. If caller desires, we will look for the fullname
	#
    	var saddr [sym ${full}name $s]
    	#
	# Figure difference between actual offset and symbol's offset and tack
	# it on if it exists.
	#
    	var diff [expr [index $a 1]-$offset]
	if {$diff} {
	    var saddr $saddr+$diff
	}
    } elif {![null [index $a 0]]} {
    	#
	# Well, no symbol nearby, but it's in a handle, so give the
	# segment:offset form instead.
	#
	var saddr [format %04x:%04x [handle segment [index $a 0]]
				   [index $a 1]]
    } else {
    	#
	# Completely off the wall -- give absolute value for it.
	#
	var saddr [format %06x [index $a 1]] 
    }
    return $saddr
}]

##############################################################################
#				atron-format-cycle
##############################################################################
#
# SYNOPSIS:	Given a decoded cycle, make it look nice
# CALLED BY:	ptrace
# RETURN:	the formatted cycle
# SIDE EFFECTS:	none
#
# STRATEGY
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/21/89	Initial Revision
#
##############################################################################
[defsubr atron-format-cycle {c}
{
    if {[index $c 2] == 2} {
    	var size word
    } else {
    	var size byte
    }
    
    return [case [index $c 0] in
    	    rio {[format {read %s I/O from %d (%xh) = %d (%xh)} $size
	    	    [index $c 1] [index $c 1] [index $c 3] [index $c 3]]}
    	    wio {[format {write %s I/O to %d (%xh) = %d (%xh)} $size
	    	    [index $c 1] [index $c 1] [index $c 3] [index $c 3]]}
    	    rmem {[format {read %s from %s = %d (%xh)} $size
	    	    [atron-find-addr [index $c 1]] [index $c 3] [index $c 3]]}
    	    wmem {[format {write %s to %s = %d (%xh)} $size
	    	    [atron-find-addr [index $c 1]] [index $c 3] [index $c 3]]}]
}]
    	
##############################################################################
#				ptrace
##############################################################################
#
# SYNOPSIS:	Print out the contents of the trace buffer in reverse order
# CALLED BY:	user
# RETURN:	nothing
# SIDE EFFECTS:	
#
# STRATEGY
#
# REVISION HISTORY:
#	Name	Date		Description
#	----	----		-----------
#	ardeb	12/20/89	Initial Revision
#
##############################################################################
[defdsubr ptrace {{max 2048}} top
{Print out the contents of the Atron trace buffer. The printout proceeds
backwards from the most recent recorded bus cycle. Optional argument MAX is
the maximum number of records to produce.}
{
    global atron_trace atron_num_records atron_next_record
    
    if {[null $atron_trace]} {
    	var atron_trace [table create 64]
    	var atron_next_record 0 atron_num_records 0
    }
    #
    # Fetch the total number of records in the trace buffer and start them
    # flowing.
    #
    irq	no
    
    [if {$atron_num_records == 0 || $atron_next_record < $atron_num_records ||
    	 $atron_num_records < $max}
    {
	[if {[catch {[rpc call 112 [type word] $atron_next_record
			     [type word]]} result]}
    	{
	    irq yes
	    error [format {couldn't read trace records: %s} $result]
	}]
	var atron_num_records $result
    }]

    echo $atron_num_records records
    if {$atron_num_records > $max} {
    	echo limiting to $max
    	var atron_num_records $max
    }


    [for {var i 0} {$i < $atron_num_records && ![irq]} {var i [expr $istart+1]}
    {
    	#
	# Locate the start of the next set of instructions
	#
    	var istart [atron-find-start $i]
	if {[null $istart]} {
	    break
	}
    	#
	# Locate all prefetched bytes in this batch of cycles
	#
	for {var bytes {} addrs {} j $istart} {$j >= $i} {var j [expr $j-1]} {
	    var cycle [atron-fetch-record $j]
	    if {[string c [index $cycle 0] ifetch] == 0} {
		var addrs [concat $addrs [index $cycle 1]]
		if {[index $cycle 2] == 2} {
		    var bytes [concat $bytes
				      [expr [index $cycle 3]&0xff]
				      [expr ([index $cycle 3]>>8)&0xff]]
    	    	    var addrs [concat $addrs [expr [index $cycle 1]+1]]
		} else {
		    var bytes [concat $bytes [expr [index $cycle 3]&0xff]]
		}
	    }
	}
	if {[length $bytes] == 0} {
	    #
	    # No fetch cycles found -- get out now
	    #
	    break
    	}
	    
    	#
	# Now we've got all the bytes, decode the various bytes into
	# instructions, keeping track of the number of bytes read and written
	# for each instruction. The instructions (formatted as regular
	# instruction lists) are placed in $ilist in order from oldest to
	# youngest as we still need to find the data cycles for the things and
	# we can't really do that until we know which instructions, if any,
	# were discarded owing to a jump that was taken.
	#
    	for {var ilist {} lastjmp -1} {[length $bytes] > 0} {} {
    	    #
	    # Figure address of first prefetched byte.
	    #
    	    var addr [index $addrs 0]
	    var addr [expr ($addr>>4)&0xffff]:[expr $addr&0xf]
    	    #
	    # Use as many bytes as are needed to decode the instruction,
	    # initializing reads and writes to 0 while we're at it
	    #
	    var op [eval [concat find-opcode $addr $bytes]]
	    var reads 0 writes 0 order rw
    
    	    #
	    # Look at the instruction class and figure the number of bytes
	    # read and written by the instruction.
	    #
	    [case [index $op 2] in
    	     {[rRi]} {
    	    	#
		# Return of some sort -- discard remaining prefetched bytes
		# and figure the number of bytes read by the instruction.
		#
    	    	var lastjmp [length $ilist]
    	    	var reads [index $op 5] writes [index $op 6]
	     }
	     I|j {
	     	#
		# Absolute jump/interrupt -- just need to record the inst index
    	    	# and figure how many byte reads, if any, were required.
		# We think that all these things write before reading, but we're
		# not sure.
		#
    	    	var lastjmp [length $ilist]
		var order wr
    	    	[case [index $op 3] in
		 e* {
		    if {([index $op 4] & 0xc0) != 0xc0} {
    	    	    	var reads [index $op 5] writes [index $op 6]
		    }
		 }
		 default {
		    var reads [index $op 5] writes [index $op 6]
    	    	 }]
    	     }
	     b {
	     	#
		# PC-relative branch -- no reads needed, but truncate bytes
		# list to the length of the instruction.
		#
    	    	var lastjmp [length $ilist]
    	    	var reads [index $op 5] writes [index $op 6]
    	     }
	     default {
	     	#
		# Normal instruction -- figure the reads and writes needed.
		# read/write only happens if one of the operands is an effective
		# address (I think) and the ea doesn't refer to a register.
		#
		[if {[string match [index $op 3] {*[em][bwd]*}]}
		{
		    if {([index $op 4]&0xc0) != 0xc0} {
		    	var reads [index $op 5] writes [index $op 6]
		    }
		} else {
		    var reads [index $op 5] writes [index $op 6]
    	    	}]		
    	     }]

    	    if {[null [index $op 7]]} {
    	    	#
		# Instruction incomplete -- get out now. Probably just made of
		# discarded prefetch cycles...
    	    	#
	    	break
    	    }

    	    #
	    # Figure the address to place in the instruction.
	    #
    	    var saddr [atron-find-addr [index $addrs 0] {} func]
    	    #
	    # Make life easier by flipping the order in which reads and writes
	    # are placed in ilist if the order in which they occur for the
	    # instruction is flipped.
	    #
    	    if {[string c $order wr] == 0} {
	    	var reads $writes writes $reads
    	    }
    	    var ilist [concat $ilist
	    	    	      [list
			       [list $order $reads $writes
			        [list $saddr [index $op 7] [index $op 1] {}]]]]
	    var bytes [range $bytes [index $op 1] end]
	    var addrs [range $addrs [index $op 1] end]
	}
    	#
	# Trim the instruction list to end at the last control-transfer
	# instruction, as we assume that's the last valid instruction for the
	# group. XXX: what about the most-recent group?
	#
    	if {$lastjmp >= 0} {
	    var ilist [range $ilist 0 $lastjmp]
    	}
    	var j $istart
    	var nilist {}
	foreach inst $ilist {
    	    #
	    # Figure the type of cycle to look for first
	    #
    	    var type [index [index $inst 0] 0 char][if {[index $inst 1] < 0} {format io} {format mem}]
	    [for {
	    	    var num [index $inst 1] cycles {}
		    if {$num < 0} {var num [expr -$num]}
		 }
	    	 {$num > 0 && $j >= $i}
		 {var j [expr $j-1]}
	    { 
	    	var c [atron-fetch-record $j]
		if {[string c [index $c 0] $type] == 0} {
		    var cycles [concat $cycles [list $c]]
    	    	    var num [expr $num-[index $c 2]]
		}
	    }]
	    var type [index [index $inst 0] 1 char][range $type 1 end char]
	    [for {
	    	    var num [index $inst 2]
		    if {$num < 0} {var num [expr -$num]}
		 }
	    	 {$num > 0 & $j >= $i}
		 {var j [expr $j-1]}
    	    {
	    	var c [atron-fetch-record $j]
		if {[string c [index $c 0] $type] == 0} {
		    var cycles [concat $cycles [list $c]]
		    var num [expr $num-[index $c 2]]
		}
    	    }]
    	    var nilist [concat [list [list [range $inst 1 2] [index $inst 3] $cycles]]
	    	    	       $nilist]
    	}
	foreach inst $nilist {
	    echo [index $inst 0]:[format-instruction [index $inst 1]]
	    foreach c [index $inst 2] {
	    	echo [format {    %s} [atron-format-cycle $c]]
    	    }
    	}
    }]
    irq yes
}]
   
