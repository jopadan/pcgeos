COMMENT @%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	Copyright (c) GeoWorks 1991 -- All Rights Reserved

PROJECT:	PC GEOS
MODULE:		DotMatrix printers
FILE:		correctGamma27.asm

AUTHOR:		Jim DeFrisco, May 27, 1992

REVISION HISTORY:
	Name	Date		Description
	----	----		-----------
	Jim	5/27/92		Initial revision

DESCRIPTION:
	Gamma correction table for printing
		

	$Id: correctGamma27.asm,v 1.1 97/04/18 11:51:33 newdeal Exp $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%@

gamma27		segment	resource

		; A Gamma-correction table for GAMMA = 2.70

		byte	0x00, 0x21, 0x2a, 0x31, 0x37, 0x3b, 0x40, 0x43
		byte	0x47, 0x4a, 0x4d, 0x50, 0x52, 0x55, 0x57, 0x59
		byte	0x5b, 0x5e, 0x60, 0x61, 0x63, 0x65, 0x67, 0x69
		byte	0x6a, 0x6c, 0x6d, 0x6f, 0x71, 0x72, 0x73, 0x75
		byte	0x76, 0x78, 0x79, 0x7a, 0x7b, 0x7d, 0x7e, 0x7f
		byte	0x80, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88
		byte	0x89, 0x8a, 0x8b, 0x8c, 0x8e, 0x8f, 0x90, 0x90
		byte	0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98
		byte	0x99, 0x9a, 0x9b, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f
		byte	0xa0, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa4, 0xa5
		byte	0xa6, 0xa7, 0xa8, 0xa8, 0xa9, 0xaa, 0xaa, 0xab
		byte	0xac, 0xad, 0xad, 0xae, 0xaf, 0xb0, 0xb0, 0xb1
		byte	0xb2, 0xb2, 0xb3, 0xb4, 0xb4, 0xb5, 0xb6, 0xb6
		byte	0xb7, 0xb8, 0xb8, 0xb9, 0xba, 0xba, 0xbb, 0xbb
		byte	0xbc, 0xbd, 0xbd, 0xbe, 0xbe, 0xbf, 0xc0, 0xc0
		byte	0xc1, 0xc1, 0xc2, 0xc3, 0xc3, 0xc4, 0xc4, 0xc5
		byte	0xc6, 0xc6, 0xc7, 0xc7, 0xc8, 0xc8, 0xc9, 0xc9
		byte	0xca, 0xcb, 0xcb, 0xcc, 0xcc, 0xcd, 0xcd, 0xce
		byte	0xce, 0xcf, 0xcf, 0xd0, 0xd0, 0xd1, 0xd2, 0xd2
		byte	0xd3, 0xd3, 0xd4, 0xd4, 0xd5, 0xd5, 0xd6, 0xd6
		byte	0xd7, 0xd7, 0xd8, 0xd8, 0xd9, 0xd9, 0xda, 0xda
		byte	0xda, 0xdb, 0xdb, 0xdc, 0xdc, 0xdd, 0xdd, 0xde
		byte	0xde, 0xdf, 0xdf, 0xe0, 0xe0, 0xe1, 0xe1, 0xe2
		byte	0xe2, 0xe2, 0xe3, 0xe3, 0xe4, 0xe4, 0xe5, 0xe5
		byte	0xe6, 0xe6, 0xe6, 0xe7, 0xe7, 0xe8, 0xe8, 0xe9
		byte	0xe9, 0xe9, 0xea, 0xea, 0xeb, 0xeb, 0xec, 0xec
		byte	0xec, 0xed, 0xed, 0xee, 0xee, 0xef, 0xef, 0xef
		byte	0xf0, 0xf0, 0xf1, 0xf1, 0xf1, 0xf2, 0xf2, 0xf3
		byte	0xf3, 0xf3, 0xf4, 0xf4, 0xf5, 0xf5, 0xf5, 0xf6
		byte	0xf6, 0xf7, 0xf7, 0xf7, 0xf8, 0xf8, 0xf9, 0xf9
		byte	0xf9, 0xfa, 0xfa, 0xfa, 0xfb, 0xfb, 0xfc, 0xfc
		byte	0xfc, 0xfd, 0xfd, 0xfe, 0xfe, 0xfe, 0xff, 0xff
gamma27		ends
