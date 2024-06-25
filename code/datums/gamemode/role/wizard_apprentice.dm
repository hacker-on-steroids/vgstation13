/datum/role/wizard_master
	name = "master wizard"
	id = WIZAPP_MASTER
	disallow_job = TRUE
	logo_state = "wizard-logo"
	default_admin_voice = "Wizard Federation"
	admin_voice_style = "notice"

/datum/role/wizard_apprentice
	name = "wizard's apprentice"
	id = WIZAPP
	disallow_job = TRUE
	logo_state = "apprentice-logo"
	//Lists used so that the spells will still show up at round-end even if the apprentice has been destroyed.
	//Can get lost through absorbing
	//Apprentices can't actually learn spells from spellbooks but their starting spells will still count as such
	var/list/spells_from_spellbook = list()
	var/list/spells_from_absorb = list()

	var/apprentice_type = "Normal" //Name used for scoreboard as to what kind of apprentice they were

/datum/role/wizard_apprentice/OnPostSetup()
	. = ..()
	if(!.)
		return
	equip_wizard(antag.current, apprentice = TRUE)
	antag.current.flavor_text = null
	antag.current.faction = "wizard"
	antag.mob_legacy_fac = "wizard"

/datum/role/wizard_apprentice/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		if(GREET_DEFAULT)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'>You are a Wizard's Apprentice!</br></span>")


/datum/role/wizard_apprentice/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	. = ..()
	for (var/spell/S in antag.wizard_spells)
		if (!(S.spell_flags & LOSE_IN_TRANSFER))
			transfer_spell(new_character, old_character, S)

/datum/role/wizard_apprentice/GetScoreboard()
	. = ..()
	var/mob/living/carbon/human/H = antag.current
	var/has_wizard_spell = FALSE
	//Spells that are learned from spellbooks. They cannot use the normal spellbook but they can use the one-time use ones.
	if(spells_from_spellbook.len)
		has_wizard_spell = TRUE
		. += "<BR>The [apprentice_type] apprentice learned:<BR>"
		for(var/spell/S in spells_from_spellbook)
			var/icon/tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
			. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"
	//Spells that are learned through absorbing them from other mages
	if(spells_from_absorb.len)
		has_wizard_spell = TRUE
		. += "<BR>The [apprentice_type] apprentice absorbed:<BR>"
		for(var/spell/S in spells_from_absorb)
			var/icon/tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
			. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"
	//Spells that the wizard somehow got their hands on. Must be wizard spells
	var/list/dummy_list = H.spell_list - (spells_from_spellbook + spells_from_absorb)
	if(dummy_list.len)
		var/has_an_uncategorized_wizard_spell = FALSE
		for(var/spell/S in H.spell_list)
			if(S.is_wizard_spell())
				has_an_uncategorized_wizard_spell = TRUE
				has_wizard_spell = TRUE
				break
		if(has_an_uncategorized_wizard_spell)
			//This implies adminbus or other shenanigans that could grant wizard spells
			. += "<BR>The [apprentice_type] apprentice somehow knew, through divine help or other means:<BR>"
			for(var/spell/S in dummy_list)
				var/icon/tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
				. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"
	//Zero wizard spells known at all, could have been absorbed by someone else
	if(!has_wizard_spell)
		. += "The [apprentice_type] apprentice somehow forgot everything he learned in magic school."