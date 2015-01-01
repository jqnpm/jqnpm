import "anotheruser/pack1" as pack1;
import "someuser/pack2" as pack2;

def fg:
	pack1::f + pack2::g;

fg + "ghi"
