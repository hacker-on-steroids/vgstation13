#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Packedstation
//**************************************************************

/datum/map/active
	nameShort = "Pack"
	nameLong = "Packed Station"
	map_dir = "packedstation"
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "spacePirateShip" ;
			},
		)

	default_tagger_locations = list(
		DISP_DISPOSALS,
		DISP_CARGO_BAY,
		null,
		DISP_ENGINEERING,
		null,
		DISP_ATMOSPHERICS,
		DISP_SECURITY,
		null,
		DISP_MEDBAY,
		DISP_CMO_OFFICE,
		DISP_CHEMISTRY,
		DISP_RESEARCH,
		null,
		DISP_ROBOTICS,
		DISP_HOP_OFFICE,
		DISP_LIBRARY,
		null,
		DISP_THEATRE,
		DISP_BAR,
		DISP_KITCHEN,
		DISP_HYDROPONICS,
		DISP_JANITOR_CLOSET,
		DISP_GENETICS,
		null,
		DISP_MECHANICS,
		null
	)

	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 221
	center_y = 241

/datum/map/active/New()
	.=..()

	research_shuttle.name = "Asteroid Shuttle" //There is only one shuttle on packedstation - the asteroid shuttle
	research_shuttle.req_access = list() //It's shared by miners and researchers, so remove access requirements

////////////////////////////////////////////////////////////////
#include "packedstation.dmm"

#if !defined(MAP_OVERRIDE_FILES)
	#define MAP_OVERRIDE_FILES
	#include "packedstation\misc.dm"
	#include "packedstation\telecomms.dm"
	/* This is gonna stay just in case - Prometh
	#include "packedstation\uplink_item.dm"
	#include "packedstation\job\jobs.dm" //Job changes removed for now
	#include "packedstation\job\removed.dm"

#elif !defined(MAP_OVERRIDE)
	#warn a map has already been included, ignoring packedstation. */
#endif
#endif
