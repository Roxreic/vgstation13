/spell/targeted/hypnotise
	name = "Hypnotise (10)"
	desc = "A piercing stare that incapacitates your victim for a good length of time."
	abbreviation = "HN"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 1
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK | NEEDSHUMAN
	cooldown_min = 3 MINUTES
	selection_type = "range"

	amt_paralysis = 20
	amt_stuttering = 50

	override_base = "vamp"
	hud_state = "vampire_hypno"

	var/blood_cost = 10
	compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey)

/spell/targeted/hypnotise/cast_check(skipcharge = 0, mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (istype(user.get_item_by_slot(slot_glasses), /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, "<span class='warning'>You're blindfolded!</span>")
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/targeted/hypnotise/cast(var/list/targets, var/mob/user)
	if (targets.len > 1)
		return FALSE

	var/target = targets[1]

	var/mob/living/carbon/C = target
	if ((C.sdisabilities & BLIND) || (C.sight & BLIND))
		to_chat(user, "<span class='warning'>\the [C] is blind!</span>")
		return TRUE
	var/success = C.vampire_affected(user.mind)
	switch(success)
		if(FALSE)
			return TRUE //Refunds the spell cooldown if it failed
		if(VAMP_FAILURE)
			critfail(targets, user)
			return
	if(do_mob(user, C, 10 - C.get_vamp_enhancements()))
		to_chat(user, "<span class='warning'>Your piercing gaze knocks out \the [C].</span>")
		to_chat(C, "<span class='sinister'>You find yourself unable to move and barely able to speak.</span>")
		apply_spell_damage(target)
	else
		to_chat(user, "<span class='warning'>You broke your gaze.</span>")
		return TRUE
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(blood_cost)

/spell/targeted/hypnotise/critfail(var/list/targets, var/mob/user)
	to_chat(user, "<span class='danger'>You feel yourself sleepy...</span>")
	apply_spell_damage(user)
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(3*blood_cost)
