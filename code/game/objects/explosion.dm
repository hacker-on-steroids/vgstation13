//TODO: Flash range does nothing currently

/proc/trange(var/Dist = 0, var/turf/Center = null)//alternative to range (ONLY processes turfs and thus less intensive)
	if (isnull(Center))
		return

	//var/x1 = ((Center.x-Dist) < 1 ? 1 : Center.x - Dist)
	//var/y1 = ((Center.y-Dist) < 1 ? 1 : Center.y - Dist)
	//var/x2 = ((Center.x+Dist) > world.maxx ? world.maxx : Center.x + Dist)
	//var/y2 = ((Center.y+Dist) > world.maxy ? world.maxy : Center.y + Dist)

	var/turf/x1y1 = locate(((Center.x - Dist) < 1 ? 1 : Center.x - Dist), ((Center.y - Dist) < 1 ? 1 : Center.y - Dist), Center.z)
	var/turf/x2y2 = locate(((Center.x + Dist) > world.maxx ? world.maxx : Center.x + Dist), ((Center.y + Dist) > world.maxy ? world.maxy : Center.y + Dist), Center.z)
	return block(x1y1, x2y2)

/**
 * Make boom
 *
 * @param epicenter          Where explosion is centered
 * @param devastation_range
 * @param heavy_impact_range
 * @param light_impact_range
 * @param flash_range        Unused
 * @param adminlog           Log to admins
 * @param ignored            Do not notify explosion listeners
 * @param verbose            Explosion listeners will treat as an important explosion worth reporting on radio
 */

var/explosion_shake_message_cooldown = 0

/proc/explosion(turf/epicenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range, adminlog = 1, ignored = 0, verbose = 1, var/mob/whodunnit, var/list/whitelist)
	var/explosion_time = world.time

	spawn()
		var/watch = start_watch()
		epicenter = get_turf(epicenter)
		if(!epicenter)
			return

		if(devastation_range > 1)
			score.largeexplosions++ //For the scoreboard
		if(istype(get_area(epicenter),/area/shuttle/escape/centcom))
			score.shuttlebombed += devastation_range //For the scoreboard
		score.explosions++ //For the scoreboard

		stat_collection.add_explosion_stat(epicenter, devastation_range, heavy_impact_range, light_impact_range)

		explosion_effect(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([formatJumpTo(epicenter,"JMP")]) [whodunnit ? " caused by [whodunnit] [whodunnit.ckey ? "([whodunnit.ckey])" : "(no key)"] ([formatJumpTo(whodunnit,"JMP")])" : ""]")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] [whodunnit ? " caused by [whodunnit] [whodunnit.ckey ? "([whodunnit.ckey])" : "(no key)"]" : ""]")

		SSlighting.postpone(max(round(devastation_range/8),1)) //Pause the lighting updates for a bit.
		SSair.postpone(max(round(heavy_impact_range/8),1)) //And air.

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		explosion_destroy(epicenter,devastation_range,heavy_impact_range,light_impact_range,flash_range,explosion_time,whodunnit,whitelist)

		var/took = stop_watch(watch)
		if(took > 0.1)
			log_debug("Explosion at [epicenter.x],[epicenter.y],[epicenter.z] took [took] seconds.")

		//Machines which report explosions.
		if(!ignored)
			for(var/obj/machinery/computer/bhangmeter/bhangmeter in doppler_arrays)
				if(bhangmeter && !bhangmeter.stat)
					bhangmeter.sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range, light_impact_range, took, 0, verbose)

		sleep(8)

	return 1

//Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
//Stereo users will also hear the direction of the explosion!
//Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
//3/7/14 will calculate to 80 + 35
/proc/explosion_effect(turf/epicenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range)
	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/far_dist = (devastation_range * 20) + (heavy_impact_range * 5)
	var/frequency = get_rand_frequency()
	var/skip_shake = 0 //Will not display shaking-related messages

	for (var/mob/M in player_list)
		//Double check for client
		if(M?.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && AreConnectedZLevels(M_turf.z,epicenter.z) && abs(M_turf.z - epicenter.z) <= max_range)
				var/dist = get_dist(M_turf, epicenter)
				//If inside the blast radius + world.view - 2
				if((dist <= round(max_range + world.view - 2, 1)) && (M_turf.z == epicenter.z))
					if(devastation_range > 0)
						M.playsound_local(epicenter, get_sfx("explosion"), 100, 1, frequency, falloff = 5) // get_sfx() is so that everyone gets the same sound
						shake_camera(M, clamp(devastation_range, 3, 10), 2)
					else
						M.playsound_local(epicenter, get_sfx("explosion_small"), 100, 1, frequency, falloff = 5)
						shake_camera(M, 3, 1)

					//You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.

				else if(dist <= far_dist)
					var/far_volume = clamp(far_dist, 30, 50) // Volume is based on explosion size and dist
					far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
					if(devastation_range > 0)
						M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)
						shake_camera(M, 3, 1)
					else
						M.playsound_local(epicenter, 'sound/effects/explosionsmallfar.ogg', far_volume, 1, frequency, falloff = 5)
						skip_shake = 1

				if(!explosion_shake_message_cooldown && !skip_shake)
					to_chat(M, "<span class='danger'>You feel everything shaking all around you.</span>")
					explosion_shake_message_cooldown = 1
					spawn(50)
						explosion_shake_message_cooldown = 0

	var/close = trange(world.view+round(devastation_range,1), epicenter)
	//To all distanced mobs play a different sound
	for(var/mob/M in mob_list) if(M.z == epicenter.z) if(!(M in close))
		//Check if the mob can hear
		if(M.ear_deaf <= 0 || !M.ear_deaf)
			if(!istype(M.loc,/turf/space))
				M << 'sound/effects/explosionfar.ogg'

	if(heavy_impact_range > 1)
		var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
		E.set_up(epicenter)
		E.start()
	else
		epicenter.turf_animation('icons/effects/96x96.dmi',"explosion_small",-WORLD_ICON_SIZE, -WORLD_ICON_SIZE, 13)

/proc/explosion_destroy(turf/epicenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range, var/explosion_time, var/mob/whodunnit, var/list/whitelist)
	var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z

	var/list/affected_turfs = multi_z_spiral_block(epicenter,max_range,0,0,0.5)
	var/list/cached_exp_block = CalculateExplosionBlock(affected_turfs,z0)

	for(var/turf/T in affected_turfs)
		if(whitelist && (T in whitelist))
			continue
		var/dist = cheap_pythag(T.x - x0, T.y - y0) * (2**abs(T.z - z0))
		var/severity = dist
		var/pushback = 0
		for(var/turf/Trajectory = T, Trajectory != epicenter, Trajectory = get_zstep_towards(Trajectory,epicenter))
			severity += cached_exp_block[Trajectory]

		if(severity < devastation_range)
			severity = 1
			pushback = 5
		else if(severity < heavy_impact_range)
			severity = 2
			pushback = 3
		else if(severity < light_impact_range)
			severity = 3
			pushback = 1
		else
			//invulnerable therefore no further explosion
			continue

		// this was previously a loop that got the steps away to the desired position for each atom,
		// now moved up to the turf level and changed to a slope-ish function that gets it just the same
		var/divisor = pushback/(max(1,dist))
		var/rise = round((T.y - y0) * divisor)
		var/run = round((T.x - x0) * divisor)
		var/turf/throwT = locate(T.x+run,T.y+rise,T.z) || (get_step_away(T,epicenter,dist+pushback) || T)

		var/turftime = world.time
		for(var/atom/movable/A in T)
			var/atomtime = world.time
			if(whitelist && (A in whitelist))
				continue
			var/list/atom/movable/atoms2throw = list(A)
			atoms2throw += A.ex_act(severity,null,whodunnit)
			if(T != epicenter && throwT != T)
				for(var/atom/movable/thrown in atoms2throw)
					if(!thrown.anchored && thrown.last_explosion_push != explosion_time)
						thrown.last_explosion_push = explosion_time
						if(!isturf(throwT))
							log_debug("Bad turf [throwT], could not throw atom [thrown] at.")
							continue
						if(ismob(thrown))
							to_chat(thrown, "<span class='warning'>You are blown away by the explosion!</span>")

						thrown.throw_at(throwT,pushback+2,500)
			atomtime = world.time - atomtime
			if(atomtime > 0)
				log_debug("Slow explosion effect on [A]: Took [atomtime/10] seconds.")
		turftime = world.time - turftime
		if(turftime > 0)
			log_debug("Slow turf explosion processing at [T.x],[T.y],[T.z]: Took [turftime/10] seconds.")

		T.ex_act(severity,null,whodunnit)

		CHECK_TICK

/proc/CalculateExplosionBlock(list/affected_turfs,var/epicenter_z)
	. = list()
	// we cache the explosion block rating of every turf in the explosion area
	//explosion block reduces explosion distance based on path from epicentre
	for(var/turf/T as anything in affected_turfs)
		var/current_exp_block = T.density || T.z != epicenter_z ? T.explosion_block : 0
		for (var/obj/machinery/door/D in T)
			if(D.density && D.explosion_block)
				current_exp_block += D.explosion_block
				continue
		for (var/obj/effect/forcefield/F in T)
			current_exp_block += F.explosion_block
			continue
		for (var/obj/effect/energy_field/E in T)
			current_exp_block += E.explosion_block
			continue

		.[T] = current_exp_block
