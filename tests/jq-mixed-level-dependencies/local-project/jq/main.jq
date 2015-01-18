import "anotheruser/pack1" as pack1;
import "anotheruser/pack3" as pack3;
import "someuser/pack2" as pack2;
import "someuser/pack4" as pack4;

def fg:
	pack1::f + pack2::g;

fg + "ghi789" + "|" + pack3::g + "|" + pack4::f
