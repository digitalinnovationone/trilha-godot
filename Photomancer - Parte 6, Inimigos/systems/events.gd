extends Node


signal health_changed(entity, health, old_health, max_health)

signal entity_died(entity)

signal projectile_collided(projectile: Projectile, collided_with)

