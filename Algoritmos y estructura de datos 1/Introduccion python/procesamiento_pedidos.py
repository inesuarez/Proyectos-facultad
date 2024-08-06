from queue import Queue
from typing import List
from typing import Dict
from typing import Union
import json

# ACLARACIÓN: El tipo de "pedidos" debería ser: pedidos: Queue[Dict[str, Union[int, str, Dict[str, int]]]]
# Por no ser soportado por la versión de CMS, usamos simplemente "pedidos: Queue"
def procesamiento_pedidos(pedidos: Queue, stock_productos: Dict[str, int],precios_productos: Dict[str, float]) -> List[Dict[str, Union[int, str, float, Dict[str, int]]]]:
  res:List[Dict[str, Union[int, str, float, Dict[str, int]]]] = []
  estado: str = "completo"
  while not pedidos.empty():
     pedido_total:Dict[str, Union[int, str, float, Dict[str, int]]] = {}
     pedido:Dict[str, Union[int, str, float, Dict[str, int]]] = pedidos.get()
     valores:List[str, int, Dict[str, int]] = list(pedido.values())
     compra:Dict[str,int] = valores[2]
     precio:float = 0
     productos_finales = {}
     for producto, cantidad in compra.items():
            if cantidad <= stock_productos[producto]:
                stock_productos[producto] -= cantidad
                precio += cantidad * precios_productos[producto]
                productos_finales[producto] = cantidad
            else:
                precio += stock_productos[producto] * precios_productos[producto]
                estado = "incompleto"
                productos_finales[producto] = stock_productos[producto]
                stock_productos[producto] = 0
     pedido_total["id"] = list(pedido.values())[0]
     pedido_total["cliente"] = list(pedido.values())[1]
     pedido_total["productos"] = productos_finales
     pedido_total["precio_total"] = precio
     pedido_total["estado"] = estado
     res.append(pedido_total)
  return res


if __name__ == '__main__':
  pedidos: Queue = Queue()
  list_pedidos = json.loads(input())
  [pedidos.put(p) for p in list_pedidos]
  stock_productos = json.loads(input())
  precios_productos = json.loads(input())
  print("{} {}".format(procesamiento_pedidos(pedidos, stock_productos, precios_productos), stock_productos))

# Ejemplo input  
# pedidos: [{"id":21,"cliente":"Gabriela", "productos":{"Manzana":2}}, {"id":1,"cliente":"Juan","productos":{"Manzana":2,"Pan":4,"Factura":6}}]
# stock_productos: {"Manzana":10, "Leche":5, "Pan":3, "Factura":0}
# precios_productos: {"Manzana":3.5, "Leche":5.5, "Pan":3.5, "Factura":5}