
/obj/item/weapon/reagent_containers/glass/bottle/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = FPRINT  | OPENCONTAINER
	volume = 60
	var/reagent = ""

/obj/item/weapon/reagent_containers/glass/bottle/robot/New()
	..()
	reagents.add_reagent(reagent, 60)

/obj/item/weapon/reagent_containers/glass/bottle/robot/restock()
	if(reagent && (reagents.get_reagent_amount(reagent) < volume))
		reagents.add_reagent(reagent, 2)

/obj/item/weapon/reagent_containers/glass/bottle/robot/inaprovaline
	name = "internal inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle16"
	reagent = INAPROVALINE

/obj/item/weapon/reagent_containers/glass/bottle/robot/antitoxin
	name = "internal anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle17"
	reagent = ANTI_TOXIN
	
/obj/item/weapon/reagent_containers/glass/bottle/robot/water
	name = "internal water bottle"
	desc = "A small bottle for watering plants."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle17"
	reagent = WATER

/obj/item/weapon/reagent_containers/glass/bottle/robot/eznutrient
	name = "internal E-Z-nutrient bottle"
	desc = "A small bottle for feeding plants."
	icon = 'icons/obj/chemical.dmi'
	//icon_state = "bottle17"
	reagent = EZNUTRIENT