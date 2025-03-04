//Procedures in this file: Facial reconstruction surgery
//////////////////////////////////////////////////////////////////
//						FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/face
	priority = 2
	can_infect = 0
/datum/surgery_step/face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (!affected)
		return 0
	return target_zone == "mouth"


///////CUT FACE/////////
/datum/surgery_step/generic/cut_face/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/generic/cut_face
	allowed_tools = list(
		/obj/item/tool/scalpel = 100,
		/obj/item/weapon/melee/blood_dagger = 90,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		/obj/item/soulstone/gem = 0,
		/obj/item/soulstone = 50,
		)

	duration = 9 SECONDS

/datum/surgery_step/generic/cut_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == "mouth" && target.op_stage.face == 0 && check_anesthesia(target)

/datum/surgery_step/generic/cut_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to cut open [target]'s face and neck with \the [tool].", \
	"You start to cut open [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/generic/cut_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has cut open [target]'s face and neck with \the [tool].</span>" , \
	"<span class='notice'>You have cut open [target]'s face and neck with \the [tool].</span>",)
	target.op_stage.face = 1

/datum/surgery_step/generic/cut_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing [target]'s throat wth \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, slicing [target]'s throat wth \the [tool]!</span>" )
	affected.createwound(CUT, 60)
	target.losebreath += 10



///////MEND VOCAL///////
/datum/surgery_step/face/mend_vocal
	allowed_tools = list(
		/obj/item/tool/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 10	//I don't know. Don't ask me. But I'm leaving it because hilarity.
		)

	duration = 7 SECONDS

/datum/surgery_step/face/mend_vocal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 1

/datum/surgery_step/face/mend_vocal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
	"You start mending [target]'s vocal cords with \the [tool].")
	..()

/datum/surgery_step/face/mend_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends [target]'s vocal cords with \the [tool].</span>", \
	"<span class='notice'>You mend [target]'s vocal cords with \the [tool].</span>")
	target.op_stage.face = 2

/datum/surgery_step/face/mend_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</span>")
	target.losebreath += 10



////////FIX FACE//////
/datum/surgery_step/face/fix_face
	allowed_tools = list(
		/obj/item/tool/retractor = 100,
		/obj/item/tool/crowbar = 55,
		/obj/item/weapon/kitchen/utensil/fork = 75,
		)

	duration = 8 SECONDS

/datum/surgery_step/face/fix_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 2

/datum/surgery_step/face/fix_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts pulling skin on [target]'s face back in place with \the [tool].", \
	"You start pulling skin on [target]'s face back in place with \the [tool].")
	..()

/datum/surgery_step/face/fix_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pulls skin on [target]'s face back in place with \the [tool].</span>",	\
	"<span class='notice'>You pull skin on [target]'s face back in place with \the [tool].</span>")
	target.op_stage.face = 3

/datum/surgery_step/face/fix_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, tearing skin on [target]'s face with \the [tool]!</span>")
	target.apply_damage(10, BRUTE, affected)



////////CAUTERIZE////////
/datum/surgery_step/face/cauterize/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_hot())
		return 0

/datum/surgery_step/face/cauterize
	allowed_tools = list(
		/obj/item/tool/cautery = 100,
		/obj/item/tool/scalpel/laser = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/tool/weldingtool = 25,
		)

	duration = 7 SECONDS

/datum/surgery_step/face/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face > 0

/datum/surgery_step/face/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/face/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s face and neck with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s face and neck with \the [tool].</span>")
	affected.open = 0
	affected.status &= ~ORGAN_BLEEDING
	if (target.op_stage.face == 3)
		var/datum/organ/external/head/head_organ = affected
		head_organ.disfigured = FALSE
		target.visible_message("<span class='notice'>[target]'s face has been repaired.</span>")
	target.op_stage.face = 0
	target.op_stage.tooth_replace = 0
	target.update_name()
	target.update_hair()

/datum/surgery_step/face/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s face with \the [tool]!</span>")
	target.apply_damage(4, BURN, affected)
