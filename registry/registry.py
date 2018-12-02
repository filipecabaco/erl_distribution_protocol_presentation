import subprocess
import logging
import sqlite3
from pyrlang import Node, Process, GeventEngine
from term import Atom
from gevent import monkey

monkey.patch_socket(dns=True, aggressive=True)
logging.getLogger("").setLevel(logging.DEBUG)

conn = sqlite3.connect('registry')
c = conn.cursor()
c.execute('CREATE TABLE IF NOT EXISTS registry (device text, message text)')

def remote_receiver_name():
  return Atom('orchestrator@localhost'), Atom("orchestrator")

def send_message(node, pid, msg):
  logging.info("Sending back to orchestrator")
  logging.info(msg[0])
  c.execute(f'INSERT INTO registry(device, message) VALUES ("{msg[0]}","{msg[1]}")')
  node.send(sender=pid,
              receiver=remote_receiver_name(),
              message=msg)

class Register(Process):
    def __init__(self, node) -> None:
      Process.__init__(self, node_name=node.node_name_)
      node.register_name(self, Atom('mailbox'))

    def handle_one_inbox_message(self, msg):
      send_message(self.get_node(), self.pid_, msg)

    def exit(self, reason=None):
      logging.error(reason)
      Process.exit(self, reason)

def main():
  e = GeventEngine()

  node = Node(node_name="registry@localhost", cookie="secret", engine=e)
  Register(node)

  e.run_forever()

if __name__ == "__main__":
  main()