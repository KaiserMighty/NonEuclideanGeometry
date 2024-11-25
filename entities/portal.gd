extends Area3D


@onready var player_cam = get_tree().get_first_node_in_group("player").camera
@export var other_portal : Node3D

@export var cull_layer : int = 4

@export var portal_area_z_margin : = 0
@export var portal_area_x_margin : = 0.1
@export var portal_area_y_margin : = 0.1
@export var size : = Vector2(2,3)


func _ready():
	$CSGBox3D.set_layer_mask_value(1, false)
	$CSGBox3D.set_layer_mask_value(cull_layer, true)
	
	$CSGBox3D.size.x = self.size.x
	$CSGBox3D.size.y = self.size.y
	$CollisionShape3D.shape.size = Vector3(
		self.size.x + self.portal_area_x_margin * 2,
		self.size.y + self.portal_area_y_margin * 2,
		self.portal_area_z_margin * 2)
	
	var world_3d = get_viewport().world_3d
	if not world_3d or not world_3d.environment:
		return
	$SubViewport/Camera3D.environment = world_3d.environment.duplicate()
	$SubViewport/Camera3D.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR


func _process(delta):
	_update_camera()


func _update_camera():
	var portal_transform = self.global_transform.affine_inverse() * player_cam.global_transform
	var portal_move = other_portal.global_transform * portal_transform
	
	$SubViewport/Camera3D.global_transform = portal_move
	$SubViewport/Camera3D.fov = player_cam.fov
	
	$SubViewport/Camera3D.cull_mask = player_cam.cull_mask
	$SubViewport/Camera3D.set_cull_mask_value(other_portal.cull_layer, false)
	
	$SubViewport.size = get_viewport().get_visible_rect().size
	$SubViewport.msaa_3d = get_viewport().msaa_3d
	$SubViewport.screen_space_aa = get_viewport().screen_space_aa
	$SubViewport.use_taa = get_viewport().use_taa
	$SubViewport.use_debanding = get_viewport().use_debanding
	$SubViewport.use_occlusion_culling = get_viewport().use_occlusion_culling
	$SubViewport.mesh_lod_threshold = get_viewport().mesh_lod_threshold


func _on_body_entered(body):
	if body.is_in_group("player"):
		var portal_transform = self.global_transform.affine_inverse() * body.global_transform
		var portal_move = other_portal.global_transform * portal_transform
		body.global_transform = portal_move

		var r = other_portal.global_transform.basis.get_euler() - global_transform.basis.get_euler()
		body.velocity = body.velocity \
			.rotated(Vector3(1, 0, 0), r.x) \
			.rotated(Vector3(0, 1, 0), r.y) \
			.rotated(Vector3(0, 0, 1), r.z)
