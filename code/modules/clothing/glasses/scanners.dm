//These are glasses that can toggle their vision effects on and off in a binary way - all on or all off.

/obj/item/clothing/glasses/scanner
	item_state = "glasses"
	species_fit = list(GREY_SHAPED)
	var/on = TRUE
<<<<<<< HEAD
	var/list/stored_huds = list() // Stores a hud datum instance to apply to a mob
	var/list/hud_types = list() // What HUD the glasses provides, if any

/obj/item/clothing/glasses/scanner/New()
	..()
	if(hud_types.len)
		for(var/H in hud_types)
			if(ispath(H))
				stored_huds += new H

/obj/item/clothing/glasses/scanner/proc/add_new_hud_by_type(type)
	if(!ispath(type, /datum/visioneffect))
		return
	hud_types += type
	stored_huds += new type
=======
>>>>>>> parent of 8ff1e71883... Europa /vg/ Lights : overhaul of the lighting system!!! (#35571)

/obj/item/clothing/glasses/scanner/attack_self()
	toggle()


/obj/item/clothing/glasses/scanner/equipped(var/mob/living/carbon/M, glasses)
	if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/O = M
		if(O.glasses != src)
			return
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.glasses != src)
			return
	else
		return
	if(on)
<<<<<<< HEAD
		if(iscarbon(M) && glasses == slot_glasses)
			for(var/datum/visioneffect/H in stored_huds)
				M.apply_hud(H)
=======
		if(iscarbon(M))
			M.update_perception()
			M.update_darkness()
>>>>>>> parent of 8ff1e71883... Europa /vg/ Lights : overhaul of the lighting system!!! (#35571)
	..()

/obj/item/clothing/glasses/scanner/unequipped(mob/living/carbon/M, var/from_slot = null)
	if(from_slot == slot_glasses)
<<<<<<< HEAD
		for(var/datum/visioneffect/H in stored_huds)
			M.remove_hud(H)
	//the parent calls for a full redraw of the hud
=======
		if(on)
			user.seedarkness = TRUE
>>>>>>> parent of 8ff1e71883... Europa /vg/ Lights : overhaul of the lighting system!!! (#35571)
	..()

/obj/item/clothing/glasses/scanner/update_icon()
	icon_state = initial(icon_state)
	if (!on)
		icon_state += "off"

/obj/item/clothing/glasses/scanner/proc/toggle()
	var/mob/C = usr
	if (!usr)
		if (!ismob(loc))
			return
		C = loc

	if (C.incapacitated())
		return

	playsound(C,'sound/misc/click.ogg',30,0,-5)
	if (on)
		disable(C)
	else
		enable(C)

	update_icon()
	C.update_inv_glasses()

/obj/item/clothing/glasses/scanner/proc/enable(var/mob/living/carbon/C)
	on = TRUE
	//check if equipped
	if(src == C.get_item_by_slot(slot_glasses))
		for(var/datum/visioneffect/H in stored_huds)
			C.apply_hud(H)
	to_chat(C, "You turn \the [src] on.")
	C.handle_regular_hud_updates()

/obj/item/clothing/glasses/scanner/proc/disable(var/mob/living/carbon/C)
	on = FALSE
	if(src == C.get_item_by_slot(slot_glasses))
		for(var/datum/visioneffect/H in stored_huds)
			C.remove_hud(H)
	to_chat(C, "You turn \the [src] off.")
	C.handle_regular_hud_updates()

//This is for harm labels blocking your vision. It also will stop most huds...
//Though, some are overridden for reality (labels won't stop your thermals, but you will be blind otherwise)
/obj/item/clothing/glasses/scanner/harm_label_update()
	..()
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		if(M.glasses == src)
			if(harm_labeled >= min_harm_label)
				for(var/datum/visioneffect/H in stored_huds)
					M.remove_hud(H)
			else
				if(!stored_huds.len)
					for(var/H in hud_types)
						if(ispath(H))
							stored_huds += new H
							if(on)
								M.apply_hud(H)
	if(harm_labeled >= min_harm_label)
		stored_huds = list()
	else
		if(!stored_huds.len)
			for(var/H in hud_types)
				if(ispath(H))
					stored_huds += new H

/obj/item/clothing/glasses/scanner/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = Tc_MAGNETS + "=2"
<<<<<<< HEAD
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	hud_types = list(/datum/visioneffect/night)
=======
	see_invisible = 0
	seedarkness = TRUE
	see_in_dark = 8
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	eyeprot = -1

/obj/item/clothing/glasses/scanner/night/enable(var/mob/living/carbon/C)
	see_in_dark = initial(see_in_dark)
	eyeprot = initial(eyeprot)
	my_dark_plane_alpha_override = "night_vision"
	if (ishuman(C))
		var/mob/living/carbon/human/H = C
		if (H.glasses == src)
			C.update_perception()
	else if (ismonkey(C))
		var/mob/living/carbon/monkey/M = C
		if (M.glasses == src)
			C.update_perception()
	return ..()

/obj/item/clothing/glasses/scanner/night/disable(var/mob/living/carbon/C)
	. = ..()
	see_in_dark = 0
	my_dark_plane_alpha_override = null
	eyeprot = 0
	if (ishuman(C))
		var/mob/living/carbon/human/H = C
		if (H.glasses == src)
			if (C.client)
				C.client.color = null
			C.update_perception()
	else if (ismonkey(C))
		var/mob/living/carbon/monkey/M = C
		if (M.glasses == src)
			if (C.client)
				C.client.color = null
			C.update_perception()

/obj/item/clothing/glasses/scanner/night/update_perception(var/mob/living/carbon/human/M)
	if (on)
		if (M.master_plane)
			M.master_plane.blend_mode = BLEND_ADD
		if (M.client)
			M.client.color = "#33FF33"
	else
		my_dark_plane_alpha_override = null
		if (M.master_plane)
			M.master_plane.blend_mode = BLEND_MULTIPLY

/obj/item/clothing/glasses/scanner/night/unequipped(mob/living/carbon/user, var/from_slot = null)
	if(from_slot == slot_glasses)
		if(on)
			if (user.client)
				user.client.color = null
				user.update_perception()
	..()

var/list/meson_wearers = list()
>>>>>>> parent of 8ff1e71883... Europa /vg/ Lights : overhaul of the lighting system!!! (#35571)

/obj/item/clothing/glasses/scanner/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=2"
	actions_types = list(/datum/action/item_action/toggle_goggles)
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	glasses_fit = TRUE
	prescription_type = /obj/item/clothing/glasses/scanner/meson/prescription
	hud_types = list(/datum/visioneffect/meson)

/obj/item/clothing/glasses/scanner/meson/enable(var/mob/living/carbon/C)
	var/area/A = get_area(src)
	if(A.flags & NO_MESONS)
		to_chat(C, "<span class = 'warning'>\The [src] flickers, but refuses to come online!</span>")
		return
	..()

/obj/item/clothing/glasses/scanner/meson/area_entered(area/A)
	if(A.flags & NO_MESONS && on)
		visible_message("<span class = 'warning'>\The [src] sputter out.</span>")
		disable()

/obj/item/clothing/glasses/scanner/material
	name = "optical material scanner"
	desc = "Allows one to see the original layout of the pipe and cable network."
	icon_state = "material"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"
	actions_types = list(/datum/action/item_action/toggle_goggles)
	hud_types = list(/datum/visioneffect/material)
	glasses_fit = TRUE

/obj/item/clothing/glasses/scanner/material/update_icon()
	if (!on)
		icon_state = "mesonoff"
	else
		icon_state = initial(icon_state)

/*
	PATHOGEN HUD
*/

/obj/item/clothing/glasses/scanner/science
	name = "science goggles"
	desc = "almost nothing."
	icon_state = "purple"
	item_state = "glasses"
	origin_tech = Tc_MATERIALS + "=1"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	actions_types = list(/datum/action/item_action/toggle_goggles)
	prescription_type = /obj/item/clothing/glasses/scanner/science/prescription
	hud_types = list(/datum/visioneffect/pathogen)

	glasses_fit = TRUE
	on = TRUE

/obj/item/clothing/glasses/scanner/science/prescription
	name = "prescription science goggles"
	nearsighted_modifier = -3
	species_fit = list(GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/glasses/scanner/science/update_icon()
	if (!on)
		icon_state = "mesonoff"
	else
		icon_state = initial(icon_state)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
