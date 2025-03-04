/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen/
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = MACHINE_POWER_USE_NONE
	var/energy = 0

	machine_flags = WRENCHMOVE | FIXED2WORK
	pass_flags_self = 0

/obj/machinery/the_singularitygen/process()
	if (energy < 200)
		return

	var/prints=""

	if (fingerprintshidden)
		prints=", all touchers: "
		for(var/line in fingerprintshidden)
			prints += ",[line] "

	log_admin("New singularity made[prints]. Last touched by [fingerprintslast].")
	message_admins("New singularity made[prints]. Last touched by [fingerprintslast].")
	new /obj/machinery/singularity(get_turf(src), 50)
	qdel(src)

/obj/machinery/the_singularitygen/wrenchAnchor(var/mob/user, var/obj/item/I)
	src.add_hiddenprint(user)
	. = ..()
