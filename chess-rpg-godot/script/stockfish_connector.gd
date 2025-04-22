@tool
extends EditorScript
class_name Stockfish_connector

const tile_size = 32

func _run() -> void:
	#print(pers("1b2r3/3r2k1/b4p2/8/8/8/1K6/3q4 b - - 0 1"))
	print(go())
	pass

static func pos_to_fen(allies: Array[Node], enemies: Array[Node], white_plays:bool=false,roque:String="-",en_passant:String="-",demi_coup:int=0,tour:int=1):
	var pos: Array[String] = []
	var piece: Array[String] = []
	var fen = ""
	for p in allies + enemies:
		pos.append(vect_to_uci(p.global_position))
		if p is Player: piece.append(p.get_texture()[-1].to_upper())
		elif p is Enemy: piece.append(p.get_texture()[-1].to_lower())
	for n in ["8","7","6","5","4","3","2","1"]:
		var num = 0
		for l in ["a","b","c","d","e","f","g","h"]:
			var piece_found = false
			while !piece_found:
				if l+n in pos:
					if num != 0: fen += str(num)
					num = 0
					fen += piece[pos.find(l+n)]
					piece_found = true
				else:
					num += 1
					break
		if num != 0: fen += str(num)
		if n != "1": fen += "/"
	if white_plays: fen += " w"
	else: fen += " b"
	fen += " " + roque + " " + en_passant + " " + str(demi_coup) + " " + str(tour)
	return fen

static func new():
	var path = []
	OS.execute("pwd",[],path)
	var output = []
	var res = OS.execute("python3", [path[0].left(-1)+"/../stock-fish/interface.py",path[0].left(-1)+"/", ""],output,true,false)
	print(output[0].left(-1))

static func rm(n: int):
	var path = []
	OS.execute("pwd",[],path)
	var output = []
	var res = OS.execute("python3", [path[0].left(-1)+"/../stock-fish/interface.py",path[0].left(-1)+"/", "rm", n],output,true,false)
	print(output[0].left(-1))

static func moves(moves: Array):
	var b = ""
	for i in moves: b += i + " "
	var path = []
	OS.execute("pwd",[],path)
	var output = []
	var res = OS.execute("python3", [path[0].left(-1)+"/../stock-fish/interface.py",path[0].left(-1)+"/", "moves", b],output,true,false)
	print(output[0].left(-1))

static func go(n: int = 10):
	var path = []
	OS.execute("pwd",[],path)
	var output = []
	var res = OS.execute("python3", [path[0].left(-1)+"/../stock-fish/interface.py",path[0].left(-1)+"/", "go", n],output,true,false)
	return output[0].left(-1)

static func pers(fen: String):
	var path = []
	OS.execute("pwd",[],path)
	var output = []
	var res = OS.execute("python3", [path[0].left(-1)+"/../stock-fish/interface.py",path[0].left(-1)+"/", "pers", fen],output,true,false)

static func uci_to_vect(uci: String):
	var x = uci[0].to_upper().unicode_at(0) - 'A'.unicode_at(0)
	return Vector2(x * tile_size + 16, (8 - int(uci[1])) * tile_size + 10)

static func vect_to_uci(vect: Vector2):
	@warning_ignore("narrowing_conversion")
	return char(97 + ((vect[0] - 16) / tile_size)) + str(8 - int((vect[1] - 10) / tile_size))
