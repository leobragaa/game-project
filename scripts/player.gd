extends CharacterBody2D

enum PlayerState{
	idle,
	jump,
	down,
	run
}

const SPEED = 150.0
const JUMP_VELOCITY = -300.0


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var status: PlayerState
var direction = 0
var jump_count = 0
var max_jump_cont = 2

func _ready() -> void:
	go_to_idle_state()

func  _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			indle_state()
		PlayerState.run:
			run_state()
		PlayerState.jump:
			jump_state()
		PlayerState.down:
			down_state()
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_run_state():
	status = PlayerState.run
	anim.play("run")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_down_state():
	status = PlayerState.down
	anim.play("down")
	collision_shape.shape.radius = 8
	collision_shape.shape.height = 10
	collision_shape.position.y = 3
	
func exit_form_down_state():
	collision_shape.shape.radius = 5
	collision_shape.shape.height = 22
	collision_shape.position.y = -1

func indle_state():
	move()
	if velocity.x != 0:
		go_to_run_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("down"):
		go_to_down_state()
		return

func jump_state():
	move()
	
	if Input.is_action_just_pressed("jump") && jump_count < max_jump_cont:
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_run_state()
		return

func run_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		

func down_state():
	update_direction()
	if Input.is_action_just_released("down"):
		exit_form_down_state()
		go_to_idle_state()
		return

func move():
	update_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	return
	

func update_direction():
	direction = Input.get_axis("left","right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false
