# Copyright:	Public domain.
# Filename:	SPS_BACK-UP_RCS_CONTROL.agc
# Purpose: 	Part of the source code for Luminary 1A build 099.
#		It is part of the source code for the Lunar Module's (LM)
#		Apollo Guidance Computer (AGC), for Apollo 11.
# Assembler:	yaYUL
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Pages:	1507-1510
# Mod history:	2009-05-27 RSB	Adapted from the corresponding 
#				Luminary131 file, using page 
#				images from Luminary 1A.
#
# This source code has been transcribed or otherwise adapted from
# digitized images of a hardcopy from the MIT Museum.  The digitization
# was performed by Paul Fjeld, and arranged for by Deborah Douglas of
# the Museum.  Many thanks to both.  The images (with suitable reduction
# in storage size and consequent reduction in image quality as well) are
# available online at www.ibiblio.org/apollo.  If for some reason you
# find that the images are illegible, contact me at info@sandroid.org
# about getting access to the (much) higher-quality images which Paul
# actually created.
#
# Notations on the hardcopy document read, in part:
#
#	Assemble revision 001 of AGC program LMY99 by NASA 2021112-61
#	16:27 JULY 14, 1969 

# Page 1507
# PROGRAM NAME:		SPSRCS
# AUTHOR:		EDGAR M. OSHIKA (AC ELECTRONICS)
# MODIFIED:		TO RETURN TO ALL AXES VIA Q BY P. S. WEISSMAN, OCT 7, 1968
# MODIFIED TO IMPROVE BENDING STABILITY BY G. KALAN, FEB. 14, 1969
#
# FUNCTIONAL DESCRIPTION:
#	THE PROGRAM CONTROLS THE FIRING OF ALL RCS JETS IN THE DOCKED CONFIGURATION ACCORDING TO THE FOLLOWING PHASE
#	PLANE LOGIC.
#
#	1. JET SENSE TEST (SPSRCS)
#		IF JETS ARE FIRING NEGATIVELY, SET OLDSENSE NEGATIVE AND CONTINUE
#		IF JETS ARE FIRING POSITIVELY, SET OLDSENSE POSITIVE AND CONTINUE
#		IF JETS ARE NOT FIRING, SET OLDSENSE TO ZERO AND GO TO OUTER RATE LIMIT TEST
#
# 	2. RATE DEAD BAND TEST
#		IF JETS ARE FIRING NEGATIVELY AND RATE IS GREATER THAN TARGET RATE, LEAVE
#			JETS ON AND GO TO INHIBITION LOGIC.  OTHERWISE, CONTINUE.
#		IF JETS ARE FIRING POSITIVELY AND RATE IS   LESS  THAN TARGET RATE, LEAVE
#			JETS ON AND GO TO INHIBITION LOGIC.  OTHERWISE, CONTINUE.
#
#	3. OUTER RATE LIMIT TEST (SPSSTART)
#		IF MAGNITUDE OF EDOT IS GREATER THAN 1.73 DEG/SEC SET JET FIRING TIME
#			TO REDUCE RATE AND GO TO INHIBITION LOGIC.  OTHERWISE, CONTINUE.
#
#	4. COAST ZONE TEST
#		IF STATE (E,EDOT) IS BELOW LINE E + 4 X EDOT > -1.4 DEG AND EDOT IS LESS THAN 1.30 DEG/SEC SET JET TIME
#		 	POSITIVE AND CONTINUE.  OTHERWISE, SET JET FIRING TIME TO ZERO AND CONTINUE.
#		IF STATE IS ABOVE LINE E + 4 X EDOT > +1.4 DEG AND EDOT IS GREATER THAN -1.30 DEG/SEC, SET JET TIME NEGATIVE
#		 	AND CONTINUE.  OTHERWISE, SET JET FIRING TIME TO ZERO AND CONTINUE.
#
#	5. INHIBITION LOGIC
#		IF OLDSENSE IS NON-ZERO:
#			A) RETURN IF JET TIME AS THE SAME SIGN AS OLDSENSE
#			B) SET INHIBITION COUNTER* AND RETURN IF JET TIME IS ZERO
#			C) SET INHIBITION COUNTER,* SET JET TIME TO ZERO AND RETURN IF SIGN
#			   OF JET TIME IS OPPOSITE TO THAT OF OLDSENSE
#		IF OLDSENSE IS ZERO:
#			A) RETURN IF INHIBITION COUNTER IS NOT POSITIVE
#			B) SET JET TIME TO ZERO AND RETURN IF INHIBITION COUNTER IS POSITIVE
#		*NOTE: INHIBITION COUNTERS CAN BE SET TO 4 OR 10 FOR THE P AND UV AXES,
#		RESPECTIVELY, IN SPSRCS.  THEY ARE DECREMENTED BY ONE AT THE BEGINNING OF
# Page 1508
#		EACH DAP PASS.
#
#	THE MINIMUM PULSE WIDTH OF THIS CONTROLLER IS DETERMINED BY THE REPETITION RATE AT WHICH THIS ROUTINE IS CALLED
#	AND IS NOMINALLY 100 MS FOR ALL AXES IN DRIFTING FLIGHT.  DURING POWERED FLIGHT THE MINIMUM IS 100 MS FOR THE
#	P AXIS AND 200 MS FOR THE CONTROL OF THE U AND V AXES.
#
# CALLING SEQUENCE:
#		INHINT
#		TC	IBNKCALL
#		CADR	SPSRCE
#
# EXIT:
#		TC	Q
#
# ALARM/ABORT MODE:	NONE
#
# SUBROUTINES CALLED:	NONE
#
# INPUT:		E, EDOT
#			TJP, TJV, TJU		TJ MUST NOT BE NEGATIVE ZERO
#
# OUTPUT:		TJP, TJV, TJU

		BANK	21
		SETLOC	DAPS4
		BANK

		COUNT*	$$/DAPBU

		EBANK=	TJU
RATELIM2	OCT	00632		# 1.125 DEG/SEC
POSTHRST	CA	HALF

		NDX	AXISCTR
		TS	TJU
		CCS	OLDSENSE
		TCF	POSCHECK	# JETS FIRING POSITIVELY
		TCF	CTRCHECK	# JETS OFF.  CHECK INHIBITION CTR
NEGCHECK	INDEX	AXISCTR		# JETS FIRING NEGATIVELY
		CS	TJU
		CCS	A
		TC	Q		# RETURN
		TCF	+2
		TCF	+1		# JETS COMMANDED OFF.  SET CTR AND RETURN
SETCTR		INDEX	AXISCTR		# JET FIRING REVERSAL COMMANDED.  SET CTR,
		CA	UTIME		# SET JET TIME TO ZER, AND RETURN
# Page 1509
		INDEX	AXISCTR
		TS	UJETCTR
ZAPTJ		CA	ZERO
		INDEX	AXISCTR
		TS	TJU
		TC	Q
POSCHECK	INDEX	AXISCTR
		CA	TJU
		TCF	NEGCHECK +2
CTRCHECK	INDEX	AXISCTR		# CHECK JET INHIBITION COUNTER
		CCS	UJETCTR
		TCF	+2
		TC	Q		# CTR IS NOT POSITIVE.  RETURN
		TCF	ZAPTJ		# CTR IS POSITIVE.  INHIBIT FIRINGS
		TC	Q		# CTR IS NOT POSITIVE.  RETURN
		OCT	00004
UTIME		OCT	00012
		OCT	00012
OLDSENSE	EQUALS	DAPTREG1
NEGFIRE		CS	ONE		# JETS FIRING NEGATIVELY
		TS	OLDSENSE
		CA	EDOT
		TCF	+4
PLUSFIRE	CA	ONE
		TS	OLDSENSE
		CS	EDOT		# RATE DEAD BAND TEST
		LXCH	A
		CS	DAPBOOLS	# IF DRIFTBIT = 1, USE ZERO TARGET RATE
		MASK	DRIFTBIT	# IF DRIFTBIT = 0, USE 0.10 RATE TARGET
		CCS	A
		CA	RATEDB1
		AD	L
		EXTEND
		BZMF	SPSSTART
		TCF	POSTHRST +3

SPSRCS		INDEX	AXISCTR		# JET SENSE TEST
		CCS	TJU
		TCF	PLUSFIRE	# JETS FIRING POSITIVELY
		TCF	+2
		TCF	NEGFIRE		# JETS FIRING NEGATIVELY
		TS	OLDSENSE	# JETS OFF
SPSSTART	CA	EDOT		# OUTER RATE LIMIT TEST
		EXTEND
		MP	RATELIM1
		CCS	A
		TCF	NEGTHRST	# OUTER RATE LIMIT EXCEEDED
		TCF	+2
		TCF	POSTHRST	# OUTER RATE LIMIT EXCEEDED
		CA	EDOT		# COAST ZONE TEST
# Page 1510
		AD	E
		EXTEND
		MP	DKDB		# PAD LOADED DEADBAND.  FRESHSTART: 1.4 DEG
		EXTEND
		BZF	TJZERO

		EXTEND
		BZMF	+7
		CA	EDOT
		AD	RATELIM2
		EXTEND
		BZMF	TJZERO
NEGTHRST	CS	HALF
		TCF	POSTHRST +1
	+7	CS	RATELIM2
		AD	EDOT
		EXTEND
		BZMF	POSTHRST
TJZERO		CA	ZERO
		TCF	POSTHRST +1

RATELIM1	=	CALLCODE	# = 00032, CORRESPONDING TO 1.73 DEG/SEC
RATEDB1		=	TBUILDFX	# = 00045, CORRESPONDS TO 0.101 DEG/SEC

# *** END OF LMDAP  .015 ***


