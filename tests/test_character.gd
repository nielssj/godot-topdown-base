extends GutTest

var character: Character


func before_each():
	character = Character.new()
	add_child_autofree(character)


func after_each():
	if is_instance_valid(character) and not character.is_queued_for_deletion():
		character.queue_free()
		character = null


func test_damage_reduces_health_and_emits_damage_taken():
	character.health = 10
	var source := Node3D.new()
	add_child_autofree(source)
	watch_signals(character)

	character.damage(3, source)

	assert_eq(character.health, 7, "Health should be reduced by damage amount")
	assert_signal_emitted_with_parameters(character, "damage_taken", [3, source])
	assert_false(character.is_dead, "Should not be dead after partial damage")


func test_damage_to_zero_health_sets_is_dead_and_emits_died():
	character.health = 3
	watch_signals(character)

	character.damage(3)

	assert_true(character.is_dead, "is_dead should be true once health reaches 0")
	assert_signal_emitted(character, "died", "died signal should fire when health reaches 0")


func test_damage_after_death_is_ignored():
	character.health = 3
	character.damage(3)  # kills it

	watch_signals(character)
	character.damage(5)

	assert_eq(character.health, 0, "Health should not change after death")
	assert_signal_not_emitted(character, "damage_taken", "No damage_taken signal should fire post-death")
	assert_signal_not_emitted(character, "died", "died signal should not fire again after death")
