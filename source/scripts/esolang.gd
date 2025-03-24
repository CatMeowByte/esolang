extends Node

var memory_size: int = 64
var tick_limiter: int = 1000

enum State {RUNNING, AWAITING_INPUT, STOPPED}

var memory: PackedByteArray = PackedByteArray()
var pointer: int = 0
var stepper: int = 0
var input: int = 0
var output: String = ""
var state: Array[State] = [State.STOPPED, State.STOPPED]
var code: String = ""


func _ready() -> void:
	init()


func _process(delta: float) -> void:
	tick_loop(true)


func _input(event: InputEvent) -> void:
		if event is InputEventKey and event.is_pressed():
			input = event.get_unicode()
			if is_state(State.AWAITING_INPUT): undo_state()


func set_state(key: State) -> void:
	state[1] = state[0]
	state[0] = key
func undo_state() -> void:
	if state[0] == state[1]: return
	var key = state[0]
	state[0] = state[1]
	state[1] = key
func is_state(key: State) -> bool: return state[0] == key


func get_number() -> int:
	var number: int = 0
	var found_digit: bool = false
	while true:
		stepper += 1
		if stepper >= code.length() or not code[stepper].is_valid_int():
			if found_digit: return number
			else: break
		if found_digit: number *= 10
		number += int(code[stepper])
		found_digit = true
	return 1



func update_ui()-> void:
	var map: PackedStringArray = Array(memory)
	for i in memory_size:
		map[i] = (char(183) if i == pointer else " ")
		map[i] += " " + str(i).pad_zeros(4)
		map[i] += " " + str(memory[i]).pad_zeros(3)
		map[i] += " " + char(memory[i]).c_escape()
	var map_text = "\n".join(map)
	if %Map.get_text() != map_text:
		%Map.set_text(map_text)
		%Map.scroll_to_line(pointer)

	var text = str(input) + " KEY [" +( char(input)) + "]"
	%Input.set_text(text if input else "")

	if %Output.get_text() != output: %Output.set_text(output)


	%State.set_visible(state[0] == State.AWAITING_INPUT)


func _ticker_value_changed(value: float) -> void:
	tick_limiter = value


func _size_value_changed(value: float) -> void:
	memory_size = value
	reset()


func init() -> void:
	memory.resize(memory_size)
	memory.fill(0)
	pointer = 0
	stepper = 0
	input = 0
	output = ""
	set_state(State.STOPPED)
	code = %Code.get_text().strip_escapes().replace(" ", "")


func reset() -> void:
	print()
	init()


func run() -> void:
	set_state(State.RUNNING)


func jump() -> void:
	tick_loop(false)


func step() -> void:
	set_state(State.STOPPED)
	if stepper < 0 or stepper >= code.length():
		return
	tick()
	%Map.scroll_to_line(pointer)


func tick_loop(continuous: bool = true) -> void:
	var limiter: int = tick_limiter

	while limiter:
		if continuous and not is_state(State.RUNNING): break
		if stepper < 0 or stepper >= code.length():
			if continuous: set_state(State.STOPPED)
			return
		tick()
		limiter -= 1

	update_ui()


func tick() -> void:
	if pointer < 0 or pointer >= memory_size: return
	var e_input = input if input else ""
	printt(stepper, pointer, memory[pointer], code[stepper], e_input)
	execute()


func execute() -> void:
	match code[stepper]:
		# Jumper
		"<":
			pointer -= get_number()
		">":
			pointer += get_number()
		"#":
			pointer = get_number()

		# Setter
		"-":
			memory[pointer] -= get_number()
		"+":
			memory[pointer] += get_number()
		"=":
			memory[pointer] = get_number()

		# Teleporter
		"[":
			if not memory[pointer]:
				var depth = 1
				while depth > 0:
					stepper += 1
					if stepper >= code.length():
						break  # prevent runaway
					match code[stepper]:
						"[":
							depth += 1
						"]":
							depth -= 1
			else:
				stepper += 1

		"]":
			if memory[pointer]:
				var depth = 1
				while depth > 0:
					stepper -= 1
					if stepper < 0:
						break  # prevent runaway
					match code[stepper]:
						"]":
							depth += 1
						"[":
							depth -= 1
			else:
				stepper += 1

		# Input - Output
		"?", ",":
			if not input:
				set_state(State.AWAITING_INPUT)
			else:
				memory[pointer] = input
				input = 0
				stepper += 1

		"!", ".":
			output += char(memory[pointer])
			stepper += 1

		# Else
		_:
			stepper += 1
